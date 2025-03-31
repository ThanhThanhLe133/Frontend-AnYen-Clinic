import express from "express";
import { body } from "express-validator";
import * as userController from "../controllers/userController.js";
import { authenticate } from "../middlewares/authMiddleware.js";
import bcrypt from "bcryptjs"
import db from '../models'
import jwt from 'jsonwebtoken'

const hashPassword = password => bcrypt.hashSync(password, bcrypt.genSaltSync(10))

export const register = ({ phone_number, password }) => new Promise(async (resolve, reject) => {
  try {
    const [user, created] = await db.Patient.findOrCreate({
      where: { phone_number },
      raw: true,
      defaults: {
        phone_number,
        password: hashPassword(password)
      }
    })
    if (!created) {
      return resolve({
        err: 1,
        mes: "Phone number is already in use",
        access_token: null,
        refresh_token: null
      });
    }
    const access_token = jwt.sign(
      { id: user.id, phone_number: user.phone_number },
      process.env.JWT_SECRET,
      { expiresIn: "30s" }
    );
    const refresh_token = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET_REFRESH_TOKEN,
      { expiresIn: "15d" }
    );

    const [updateCount] = await db.Patient.update(
      { refresh_token },
      { where: { id: user.id } }
    );

    if (updateCount === 0) {
      return resolve({
        err: 1,
        mes: 'Failed to update refresh token',
        access_token: null,
        refresh_token: null
      });
    }

    resolve({
      err: 0,
      mes: 'Register successfully',
      access_token: `Bearer ${access_token}`,
      refresh_token
    });
  } catch (error) {
    reject(error)
  }
})


export const login = ({ phone_number, password }) => new Promise(async (resolve, reject) => {
  try {
    const response = await db.Patient.findOne({
      where: { phone_number },
      raw: true //tra ve object 
    })
    if (!response) {
      return resolve({
        err: 1,
        mes: 'Phone number has not been registered',
        access_token: null,
        refresh_token: null
      });
    }
    const isChecked = response && bcrypt.compareSync(password, response.password)
    if (!isChecked) {
      return resolve({
        err: 1,
        mes: 'Password is incorrect',
        access_token: null,
        refresh_token: null
      });
    }

    const access_token = isChecked
      ? jwt.sign({ id: response.id, phone_number: response.phone_number }, process.env.JWT_SECRET, { expiresIn: '5m' })
      : null

    const refresh_token = jwt.sign({ id: response.id }, process.env.JWT_SECRET_REFRESH_TOKEN, { expiresIn: '7d' })

    resolve({
      err: 0,
      mes: 'Login successfully',
      access_token: `Bearer ${access_token}`,
      refresh_token,
    });

    await db.Patient.update(
      { refresh_token },
      { where: { id: response.id } }
    );
  } catch (error) {
    reject(error)
  }
})

export const refreshToken = (refresh_token) => new Promise(async (resolve, reject) => {
  try {
    if (!refresh_token) {
      return resolve({
        err: 1,
        mes: 'No refresh token provided',
      });
    }
    const response = await db.Patient.findOne({
      where: { refresh_token },
      raw: true
    })
    if (!response) {
      return resolve({
        err: 1,
        mes: 'Invalid refresh token',
      });
    }
    else {
      jwt.verify(refresh_token, process.env.JWT_SECRET_REFRESH_TOKEN, (err, decoded) => {
        if (err) {
          return resolve({
            err: 1,
            mes: 'Refresh token expired. Please login again.',
          });
        }
        else {
          const access_token = jwt.sign({ id: response.id, phone_number: response.phone_number }, process.env.JWT_SECRET, { expiresIn: '1h' })

          resolve({
            err: access_token ? 0 : 1,
            mes: access_token ? 'OK' : 'Fail to generate new access token. Try later',
            'access_token': access_token ? `Bearer ${access_token}` : null,
            'refresh_token': refresh_token
          })
        }
      })
    }
  } catch (error) {
    reject(error)
  }
})


// const router = express.Router();


// // Update profile route
// router.put(
//   "/profile",
//   [
//     body("email")
//       .optional()
//       .isEmail()
//       .withMessage("Please provide a valid email"),
//   ],
//   userController.updateProfile
// );

// // Change password route
// router.put(
//   "/change-password",
//   [
//     body("currentPassword")
//       .notEmpty()
//       .withMessage("Current password is required"),
//     body("newPassword")
//       .isLength({ min: 8 })
//       .withMessage("Password must be at least 8 characters long")
//       .matches(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*])/)
//       .withMessage(
//         "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
//       ),
//   ],
//   userController.changePassword
// );

// export { router };
