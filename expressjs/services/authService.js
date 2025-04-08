import bcrypt from "bcryptjs"
import db from '../models'
import jwt from 'jsonwebtoken'

const hashPassword = password => bcrypt.hashSync(password, bcrypt.genSaltSync(10))

export const register = ({ phone_number, password }) => new Promise(async (resolve, reject) => {
  try {
    const [patientRole, createdRole] = await db.Role.findOrCreate({
      where: { value: 'patient' }
    });

    const [user, created] = await db.User.findOrCreate({
      where: { phone_number },
      raw: true,
      defaults: {
        phone_number,
        password: hashPassword(password),
        role_id: patientRole.id
      }
    });

    if (!created) {
      return resolve({
        err: 1,
        mes: "Phone number is already in use",
        access_token: null,
        refresh_token: null
      });
    }
    const [patient, patientCreated] = await db.Patient.findOrCreate({
      where: { patient_id: user.id },
      raw: true,
      defaults: {
        patient_id: user.id
      }
    });

    const access_token = jwt.sign(
      {
        id: user.id,
        phone_number: user.phone_number,
        role: 'patient'
      },
      process.env.JWT_SECRET,
      { expiresIn: "5m" }
    );

    const refresh_token = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET_REFRESH_TOKEN,
      { expiresIn: "15d" }
    );

    const [updateCount] = await db.User.update(
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
    const response = await db.User.findOne({
      where: { phone_number },
      raw: true,
      nest: true,
      include: [
        {
          model: db.Role,
          foreignKey: 'role_id',
          as: 'roleData',
          attributes: ['value']
        }
      ]
    })
    if (!response) {
      return resolve({
        err: 1,
        mes: 'Phone number has not been registered',
        access_token: null,
        refresh_token: null,
        id: null,
        role: null,
      });
    }
    const isChecked = response && bcrypt.compareSync(password, response.password)
    if (!isChecked) {
      return resolve({
        err: 1,
        mes: 'Password is incorrect',
        access_token: null,
        refresh_token: null,
        id: null,
        role: null,
      });
    }

    const access_token = isChecked
      ? jwt.sign({ id: response.id, phone_number: response.phone_number, role: response.roleData.value }, process.env.JWT_SECRET, { expiresIn: '5m' })
      : null

    const refresh_token = jwt.sign({ id: response.id }, process.env.JWT_SECRET_REFRESH_TOKEN, { expiresIn: '7d' })

    resolve({
      err: 0,
      mes: 'Login successfully',
      access_token: `Bearer ${access_token}`,
      refresh_token,
      id: response.id,
      role: response.roleData.value,
    });

    await db.User.update(
      { refresh_token },
      { where: { id: response.id } }
    );
  } catch (error) {
    reject(error)
  }
})

export const forgotPassword = ({ phone_number, password }) => new Promise(async (resolve, reject) => {
  try {
    const user = await db.User.findOne({ where: { phone_number } });

    if (!user) {
      return resolve({
        err: 1,
        mes: 'Phone number is not exist.'
      });
    }

    const hashedPassword = hashPassword(password);

    await db.User.update(
      { password: hashedPassword },
      { where: { phone_number } }
    );

    resolve({
      err: 0,
      mes: 'Change password successfully.'
    });
  } catch (error) {
    reject(error);
  }
});


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

export const logout = ({ userId }) => new Promise(async (resolve, reject) => {
  try {
    const updated = await db.User.update(
      { refresh_token: null },
      { where: { id: userId } }
    );

    if (updated[0] === 0) {
      return resolve({
        err: 1,
        mes: 'User not found or already logged out'
      });
    }

    resolve({
      err: 0,
      mes: 'Logout successfully'
    });
  } catch (error) {
    reject(error);
  }
});
