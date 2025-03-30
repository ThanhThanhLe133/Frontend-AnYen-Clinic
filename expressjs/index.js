const express = require("express");
const dotenv = require("dotenv");
const authRoutes = require("./routes/authRoute");
const userRoutes = require("./services/authService");

const app = express();

// Middleware
app.use(express.json());

//use routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
