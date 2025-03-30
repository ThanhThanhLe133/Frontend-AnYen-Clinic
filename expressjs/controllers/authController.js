const jwt = require("jsonwebtoken");
const { validationResult } = require("express-validator");
const { User } = require("../models/user");
const {
  generateTokens,
  verifyRefreshToken,
  saveRefreshToken,
  revokeRefreshToken,
  blacklistAccessToken,
} = require("../utils/tokenUtils");
const { AppError } = require("../middlewares/errorMiddleware");

// Register a new user
const register = async (req, res, next) => {
  try {
    // Validate request data
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { phoneNumber, password } = req.body;
    console.log(phoneNumber, password);

    // Check if user already exists
    const existingUser = await User.findOne({
      where: { phone_number: phoneNumber },
    });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "User already exists",
      });
    }

    // Create user
    const user = await User.create({
      phone_number: phoneNumber,
      password_hash: password,
    });

    // Return user
    res.status(201).json({
      success: true,
      message: "User registered successfully",
      user: {
        id: user.id,
        phoneNumber: user.phone_number,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Login user
const login = async (req, res, next) => {
  try {
    // Validate request data
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { phoneNumber, password } = req.body;

    // Find user
    const user = await User.findOne({ where: { phone_number: phoneNumber } });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Check if user is active
    if (!user.is_active) {
      return res.status(401).json({
        success: false,
        message: "Account is deactivated",
      });
    }

    // Validate password
    const isPasswordValid = await user.isValidPassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Generate tokens
    const { accessToken, refreshToken, jti } = await generateTokens(user.id);

    // Save refresh token to database
    await saveRefreshToken(
      refreshToken,
      user.id,
      req.ip,
      req.headers["user-agent"]
    );

    // Return user and access token
    res.status(200).json({
      success: true,
      message: "Login successful",
      user: {
        id: user.id,
        email: user.email,
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    next(error);
  }
};

// Refresh access token
const refreshAccessToken = async (req, res, next) => {
  try {
    // Get refresh token from cookie
    const refreshToken = req.cookies.refreshToken;

    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        message: "Refresh token not found",
      });
    }

    // Verify refresh token
    const decoded = await verifyRefreshToken(refreshToken);

    // Revoke old refresh token
    await revokeRefreshToken(refreshToken);

    // Generate new tokens
    const {
      accessToken,
      refreshToken: newRefreshToken,
      jti,
    } = await generateTokens(decoded.sub);

    // Save new refresh token
    await saveRefreshToken(
      newRefreshToken,
      decoded.sub,
      req.ip,
      req.headers["user-agent"]
    );

    // Set new refresh token in cookie
    res.cookie("refreshToken", newRefreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    // Return new access token
    res.status(200).json({
      success: true,
      message: "Token refreshed successfully",
      accessToken,
    });
  } catch (error) {
    // Clear cookie if refresh failed
    res.clearCookie("refreshToken");

    if (
      error.message === "Invalid refresh token" ||
      error.message === "Refresh token expired"
    ) {
      return res.status(401).json({
        success: false,
        message: error.message,
      });
    }

    next(error);
  }
};

// Logout user
const logout = async (req, res, next) => {
  try {
    // Get refresh token from cookie
    const refreshToken = req.cookies.refreshToken;

    if (refreshToken) {
      // Revoke refresh token
      await revokeRefreshToken(refreshToken);
    }

    // If user is authenticated, blacklist access token
    if (req.user && req.jti) {
      const decoded = jwt.decode(req.headers.authorization.split(" ")[1]);
      await blacklistAccessToken(req.jti, decoded.exp);
    }

    // Clear refresh token cookie
    res.clearCookie("refreshToken");

    res.status(200).json({
      success: true,
      message: "Logout successful",
    });
  } catch (error) {
    next(error);
  }
};

// Get current user profile
const me = async (req, res, next) => {
  try {
    // User is already set in req by auth middleware
    res.status(200).json({
      success: true,
      user: {
        id: req.user.id,
        email: req.user.email,
        created_at: req.user.created_at,
        last_login: req.user.last_login,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  refreshAccessToken,
  logout,
  me,
};
