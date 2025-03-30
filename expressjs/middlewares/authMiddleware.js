const { verifyAccessToken } = require("../utils/tokenUtils");
const User = require("../models/user");

// Authentication middleware to protect routes
const authenticate = async (req, res, next) => {
  try {
    // Get authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Access token is required",
      });
    }

    // Extract token
    const token = authHeader.split(" ")[1];

    // Verify token
    const decoded = await verifyAccessToken(token);

    // Check if user exists
    const user = await User.findByPk(decoded.sub);

    if (!user || !user.is_active) {
      return res.status(401).json({
        success: false,
        message: "User does not exist or is deactivated",
      });
    }

    // Set user in request object
    req.user = user;
    req.jti = decoded.jti; // Store JWT ID for potential blacklisting

    next();
  } catch (error) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        success: false,
        message: "Access token expired",
      });
    }

    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        success: false,
        message: "Invalid token",
      });
    }

    return res.status(401).json({
      success: false,
      message: "Authentication failed",
    });
  }
};

module.exports = { authenticate };
