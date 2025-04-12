import bcrypt from "bcryptjs"
import db from '../models'
import jwt from 'jsonwebtoken'

const hashPassword = password => bcrypt.hashSync(password, bcrypt.genSaltSync(10))

export const register = ({ phone_number, password }) => new Promise(async (resolve, reject) => {
  try {
    const [role] = await db.Role.findOrCreate({
      where: { value: 'patient' }
    });

    const [user, created] = await db.User.findOrCreate({
      where: { phone_number },
      raw: true,
      defaults: {
        phone_number,
        is_active: true,
        password: hashPassword(password),
      }
    });

    const existingRole = await db.UserRole.findOne({
      where: { user_id: user.id, role_id: role.id }
    });

    // Đã tồn tại user + đã có role 'patient' => không tạo thêm gì
    if (existingRole && !created) {
      return resolve({
        err: 1,
        mes: "Phone number already exists."
      });
    }

    // Nếu là user mới hoặc user chưa có role 'patient' => thêm role
    if (!existingRole) {
      await db.UserRole.create({
        user_id: user.id,
        role_id: role.id
      });
    }
    //tạo bệnh nhân
    await db.Patient.create({
      patient_id: user.id,
      anonymous_name: `User${user.id.substring(0, 3)}`
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
      include: [
        {
          model: db.Role,
          as: 'roles',
          attributes: ['value'],
          through: {
            model: db.UserRole,
            attributes: []
          }
        }
      ]
    })
    if (!response) {
      return resolve({
        err: 1,
        mes: 'Phone number has not been registered',
        access_token: null,
        refresh_token: null,
        roles: null,
      });
    }
    const isChecked = response && bcrypt.compareSync(password, response.password)
    if (!isChecked) {
      return resolve({
        err: 1,
        mes: 'Password is incorrect',
        access_token: null,
        refresh_token: null,
        roles: null,
      });
    }

    const roleValues = response.roles?.map(r => r.value) || [];

    const access_token = isChecked
      ? jwt.sign({ id: response.id, phone_number: response.phone_number, roles: roleValues }, process.env.JWT_SECRET, { expiresIn: '5m' })
      : null

    const refresh_token = jwt.sign({ id: response.id }, process.env.JWT_SECRET_REFRESH_TOKEN, { expiresIn: '7d' })

    resolve({
      err: 0,
      mes: 'Login successfully',
      access_token: `Bearer ${access_token}`,
      refresh_token,
      roles: roleValues,
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
export const resetPassword = ({ userId, oldPassword, newPassword }) => new Promise(async (resolve, reject) => {
  try {
    const user = await db.User.findOne({ where: { id: userId } });

    if (!user) {
      return resolve({
        err: 1,
        mes: 'Phone number is not exist.'
      });
    }

    if (!user.password) {
      return resolve({
        err: 1,
        mes: 'Password is not set for this user',
      });
    }

    const isChecked = bcrypt.compareSync(oldPassword, user.password);

    if (!isChecked) {
      return resolve({
        err: 1,
        mes: 'Password is incorrect',
      });
    }

    const hashedPassword = hashPassword(newPassword);

    await db.User.update(
      {
        password: hashedPassword,
        refresh_token: null
      },
      {
        where: { id: userId }
      }
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
    const response = await db.User.findOne({
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
      jwt.verify(refresh_token, process.env.JWT_SECRET_REFRESH_TOKEN, async (err, decoded) => {
        if (err) {
          return resolve({
            err: 1,
            mes: 'Refresh token expired. Please login again.',
          });
        }
        else {
          const access_token = jwt.sign({ id: response.id, phone_number: response.phone_number }, process.env.JWT_SECRET, { expiresIn: '1h' })

          const refresh_token = jwt.sign(
            { id: response.id },
            process.env.JWT_SECRET_REFRESH_TOKEN,
            { expiresIn: '7d' }
          );

          // ✅ Lưu refresh token mới vào DB
          await db.User.update(
            { refresh_token: refresh_token },
            { where: { id: response.id } }
          );
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
      mes: 'Logout successfully',
      access_token: null,
      refresh_token: null,
    });
  } catch (error) {
    reject(error);
  }
});
