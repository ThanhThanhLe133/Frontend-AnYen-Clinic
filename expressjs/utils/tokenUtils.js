import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import {
  accessTokenSecret,
  refreshTokenSecret,
  accessTokenExpiration,
  refreshTokenExpiration,
} from "../config/jwt.js";
import RefreshToken from "../models/refreshToken.js";
import TokenBlacklist from "../models/tokenBlacklist.js";

// Generate JWT tokens
const generateTokens = async (userId) => {
  try {
    // Generate JWT ID for the access token
    const jti = uuidv4();

    // Create payload for tokens
    const payload = {
      sub: userId,
      jti,
    };

    // Generate access token
    const accessToken = jwt.sign(payload, accessTokenSecret, {
      expiresIn: accessTokenExpiration,
    });

    // Generate refresh token
    const refreshToken = jwt.sign(payload, refreshTokenSecret, {
      expiresIn: refreshTokenExpiration,
    });

    return { accessToken, refreshToken, jti };
  } catch (error) {
    throw new Error("Error generating tokens");
  }
};

// Verify access token
const verifyAccessToken = async (token) => {
  try {
    const decoded = jwt.verify(token, accessTokenSecret);

    // Check if token is blacklisted
    const blacklistedToken = await TokenBlacklist.findOne({
      where: { token_jti: decoded.jti },
    });

    if (blacklistedToken) {
      throw new Error("Token has been revoked");
    }

    return decoded;
  } catch (error) {
    throw error;
  }
};

// Verify refresh token
const verifyRefreshToken = async (token) => {
  try {
    // Verify token signature and expiration
    const decoded = jwt.verify(token, refreshTokenSecret);

    // Check if token exists in database and is not revoked
    const storedToken = await RefreshToken.findOne({
      where: {
        token: token,
        revoked: false,
      },
    });

    if (!storedToken) {
      throw new Error("Invalid refresh token");
    }

    // Check if token has expired in the database
    if (new Date() > new Date(storedToken.expires_at)) {
      throw new Error("Refresh token expired");
    }

    return decoded;
  } catch (error) {
    throw error;
  }
};

// Save refresh token to database
const saveRefreshToken = async (token, userId, ipAddress, userAgent) => {
  try {
    // Decode token to get expiration
    const decoded = jwt.decode(token);
    const expiresAt = new Date(decoded.exp * 1000);

    // Create refresh token in database
    await RefreshToken.create({
      token,
      user_id: userId,
      expires_at: expiresAt,
      ip_address: ipAddress,
      user_agent: userAgent,
    });
  } catch (error) {
    throw new Error("Error saving refresh token");
  }
};

// Revoke refresh token
const revokeRefreshToken = async (token) => {
  try {
    const refreshToken = await RefreshToken.findOne({
      where: { token },
    });

    if (refreshToken) {
      await refreshToken.update({
        revoked: true,
        revoked_at: new Date(),
      });
    }
  } catch (error) {
    throw new Error("Error revoking refresh token");
  }
};

// Blacklist an access token
const blacklistAccessToken = async (jti, expiresAt) => {
  try {
    await TokenBlacklist.create({
      token_jti: jti,
      expires_at: new Date(expiresAt * 1000),
    });
  } catch (error) {
    throw new Error("Error blacklisting access token");
  }
};

// Clean up expired refresh tokens
const cleanupExpiredTokens = async () => {
  const now = new Date();

  try {
    // Delete expired refresh tokens
    await RefreshToken.destroy({
      where: {
        expires_at: { [Op.lt]: now },
      },
    });

    // Delete expired blacklisted tokens
    await TokenBlacklist.destroy({
      where: {
        expires_at: { [Op.lt]: now },
      },
    });
  } catch (error) {
    console.error("Error cleaning up expired tokens:", error);
  }
};

export {
  generateTokens,
  verifyAccessToken,
  verifyRefreshToken,
  saveRefreshToken,
  revokeRefreshToken,
  blacklistAccessToken,
  cleanupExpiredTokens,
};
