import dotenv from "dotenv";
import express from "express";
import initRoutes from "./routes/index.js";
import cors from "cors";
require('./connection_db')
const app = express();

app.use(
  cors({
    origin: process.env.CLIENT_URL,
    methods: ["GET", "POST", "PUT", "DELETE"],
  })
);

// Middleware
app.use(express.json());

initRoutes(app);
const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
