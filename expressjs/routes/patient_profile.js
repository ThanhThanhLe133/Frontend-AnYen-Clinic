import express from "express";
import * as controllers from "../controllers/patient_profile.js";
import verifyToken from '../middlewares/verify_token'
import multer from 'multer';

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });
router.use(verifyToken);

router.patch("/edit-profile", controllers.editProfile);
router.patch("/edit-anonymousName", controllers.editAnonymousName);
router.get("/get-profile", controllers.getProfile);
router.post('/upload/avatar', upload.single('avatar'), controllers.uploadAvatar);

router.get("/health-records", controllers.getHealthRecords);
router.post("/health-records", controllers.addHealthRecord);
router.patch("/health-records", controllers.editHealthRecord);
router.delete("/health-records", controllers.deleteHealthRecord);

export { router };
