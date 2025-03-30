const dotenv = require("dotenv");
const { User } = require("./models/user");
const RefreshToken = require("./models/refreshToken");
const TokenBlacklist = require("./models/tokenBlacklist");
const { sequelize } = require("./config/sequelize");

// Connect to database and sync models
sequelize
  .authenticate()
  .then(() => {
    console.log("Database connection established successfully.");
    return sequelize.sync({ alter: false }); // force: true will drop the table if it already exists (use cautiously)
  })
  .then(() => {
    console.log("Database & tables initialized successfully.");
  });
