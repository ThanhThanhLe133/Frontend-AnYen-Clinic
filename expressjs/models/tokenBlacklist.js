const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/sequelize.js");

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

module.exports = TokenBlacklist;
