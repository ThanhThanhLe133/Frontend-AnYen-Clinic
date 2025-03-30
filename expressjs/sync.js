import { sequelize } from "./config/sequelize.js";
import { User } from "./models/user.js";
import { RefreshToken } from "./models/token.js";

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
