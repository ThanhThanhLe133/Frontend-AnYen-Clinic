require("dotenv").config();

module.exports = {
  accessTokenSecret: process.env.JWT_ACCESS_SECRET,
  refreshTokenSecret: process.env.JWT_REFRESH_SECRET,
  accessTokenExpiration: process.env.JWT_ACCESS_EXPIRATION,
  refreshTokenExpiration: process.env.JWT_REFRESH_EXPIRATION,
};
