import dotenv from "dotenv";
import User from "./models/patient.js";
import { sequelize } from "./config/sequelize.js";

// Connect to database and sync models
export const syncDatabase = () => {
  sequelize
    .authenticate()
    .then(() => {
      console.log("Database connection established successfully.");
      return sequelize.sync({ alter: true }); // force: true will drop the table if it already exists (use cautiously)
    })
    .then(() => {
      console.log("Database & tables initialized successfully.");
    });
};
