import { DataTypes } from "sequelize";
import { sequelize } from "../config/sequelize.js";

export var User = sequelize.define("Users", {
  phoneNumber: DataTypes.STRING,
  passWord: DataTypes.STRING,
  fullName: DataTypes.STRING,
  dateOfBirth: DataTypes.DATE,
  gender: DataTypes.STRING,
});
