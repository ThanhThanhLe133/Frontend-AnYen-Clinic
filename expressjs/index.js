require("dotenv").config();
import express from 'express'
const connectDB = require("./config/db");
const authRoutes = require("./routes/auth");
import cors from 'cors'
const app = express();

app.use(cors({
	origin: process.env.CLIENT_URL,
	methods: ['GET', 'POST', 'PUT', 'DELETE']
}))


// Connect to database
connectDB();

// Middleware
app.use(express.json());

// // Routes
// app.use("/api/auth", authRoutes);

initRoutes(app)
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
	console.log(`Server running on port ${PORT}`);
});
