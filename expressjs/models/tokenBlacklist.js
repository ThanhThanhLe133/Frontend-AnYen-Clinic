import { DataTypes } from "sequelize";
import { sequelize } from "../config/sequelize.js";
import e from "express";

const TokenBlacklist = sequelize.define(
  "TokenBlacklist",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    token_jti: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    blacklisted_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    timestamps: false,
    tableName: "token_blacklist",
  }
);

export default TokenBlacklist;
