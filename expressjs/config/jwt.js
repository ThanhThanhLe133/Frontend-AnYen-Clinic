import dotenv from "dotenv";

dotenv.config();

export const accessTokenSecret = process.env.JWT_ACCESS_SECRET;
export const refreshTokenSecret = process.env.JWT_REFRESH_SECRET;
export const accessTokenExpiration = process.env.JWT_ACCESS_EXPIRATION;
export const refreshTokenExpiration = process.env.JWT_REFRESH_EXPIRATION;
