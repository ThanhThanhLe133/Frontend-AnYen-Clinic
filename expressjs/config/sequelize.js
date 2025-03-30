import { Sequelize } from "sequelize";
import "dotenv/config";

export const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: "localhost",
    port: process.env.DB_PORT,
    dialect: "postgres",

    pool: {
      max: 5,
      min: 0,
      idle: 10000,
    },
  }
);
