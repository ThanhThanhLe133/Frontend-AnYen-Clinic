import "dotenv/config";
import express from "express";
import "./sync.js";
// import { router as authRoutes } from "./routes/auth.js";

const app = express();

// Middleware
app.use(express.json());

// Routes
// app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
