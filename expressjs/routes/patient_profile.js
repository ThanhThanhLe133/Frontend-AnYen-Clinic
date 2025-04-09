import express from "express";
import * as controllers from "../controllers/patient_profile.js";
import verifyToken from '../middlewares/verify_token'

const router = express.Router();
router.use(verifyToken);

router.patch("/edit-profile", controllers.editProfile);
router.patch("/edit-anonymousName", controllers.editAnonymousName);
router.get("/get-profile", controllers.getProfile);
router.post('/upload/avatar', upload.single('avatar'), controllers.uploadAvatar);
router.post("/health-records", controllers.addHealthRecord);
router.patch("/health-records/:id", controllers.editHealthRecord);
router.delete("/health-records/:id", controllers.deleteHealthRecord);

export { router };
