import { where } from 'sequelize';
import db from '../models'
import jwt from 'jsonwebtoken'
import supabase from '../config/supabaseClient';
import { phone_number } from '../helpers/joi_schema';
import { v4 as uuidv4 } from 'uuid';


export const editProfile = ({ userId, fullName, dateOfBirth, gender, medicalHistory, allergies }) => new Promise(async (resolve, reject) => {
    try {
        const patient = await db.Patient.findOne({ where: { patient_id: userId } });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }

        await db.Patient.update(
            {
                full_name: fullName,
                date_of_birth: dateOfBirth,
                gender: gender,
                medical_history: medicalHistory,
                allergies: allergies,
            },
            {
                where: { patient_id: userId }
            }
        );

        resolve({
            err: 0,
            mes: 'Change profile successfully'
        });
    } catch (error) {
        reject(error);
    }
});

export const editAnonymousName = ({ userId, anonymousName }) => new Promise(async (resolve, reject) => {
    try {
        const patient = await db.Patient.findOne({ where: { patient_id: userId } });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }

        await db.Patient.update(
            {
                anonymous_name: anonymousName
            },
            {
                where: { patient_id: userId }
            }
        );

        resolve({
            err: 0,
            mes: 'Change anonymous name successfully',
            anonymousName
        });
    } catch (error) {
        reject(error);
    }
});

export const getProfile = ({ userId }) => new Promise(async (resolve, reject) => {
    try {
        const patient = await db.Patient.findOne({
            where: { patient_id: userId },
            include: [
                {
                    model: db.User,
                    as: 'user',
                    attributes: ['phone_number']
                }
            ]
        });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }

        resolve({
            err: 0,
            mes: 'Get profile successfully',
            data: {
                full_name: patient.full_name ?? '',
                date_of_birth: new Date(patient.date_of_birth).toISOString().split('T')[0] ?? '',
                gender: patient.gender ?? '',
                medical_history: patient.medical_history ?? '',
                allergies: patient.allergies ?? '',
                anonymous_name: patient.anonymous_name ?? '',
                avatar_url: patient.avatar_url ?? '',
                phone_number: patient.user.phone_number
            }
        });
    } catch (error) {
        reject(error);
    }
});

export const editAvatar = ({ userId, fileBuffer, originalName, mimetype }) =>
    new Promise(async (resolve, reject) => {
        try {
            if (!userId || !fileBuffer || !originalName || !mimetype) {
                return resolve({
                    err: 1,
                    mes: 'Missing required fields',
                })
            }

            const ext = originalName.split('.').pop()
            const filePath = `${userId}_${uuidv4()}.${ext}`

            const { error: uploadError } = await supabase.storage
                .from('image-mobile-app')
                .upload(filePath, fileBuffer, {
                    contentType: mimetype,
                    upsert: true,
                })
            const {
                data: { user },
                error,
            } = await supabase.auth.getUser();

            console.log('🧑‍💻 Logged-in user:', user?.id);

            if (uploadError) {
                console.log('❌ Upload error:', uploadError);
                return resolve({
                    err: 1,
                    mes: uploadError.message,
                })
            }

            const { data, error: urlError } = supabase.storage.from('image-mobile-app').getPublicUrl(filePath);
            if (urlError) {
                return resolve({
                    err: 1,
                    mes: urlError.message,
                });
            }
            const updateResult = await db.Patient.update(
                {
                    avatar_url: data.publicUrl
                },
                {
                    where: { patient_id: userId }
                }
            );
            if (updateResult[0] === 0) {
                return resolve({
                    err: 1,
                    mes: 'Failed to update avatar in the database.',
                });
            }
            resolve({
                err: 0,
                mes: 'Upload and update avatar successful',
                url: data.publicUrl,
            })
        } catch (error) {
            reject(error)
        }
    });


export const addHealthRecord = ({ userId, recordDate, height, weight }) => new Promise(async (resolve, reject) => {
    try {
        const patient = await db.Patient.findOne({ where: { patient_id: userId } });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }
        const healthRecord = await db.Health_record.create({
            patient_id: patient.patient_id,
            record_date: recordDate,
            height: height,
            weight: weight
        })

        resolve({
            err: 0,
            mes: 'Create new health record successfully',
            data: healthRecord
        });
    } catch (error) {
        reject(error);
    }
});
export const getHealthRecords = ({ userId }) => new Promise(async (resolve, reject) => {
    try {
        const patient = await db.Patient.findOne({ where: { patient_id: userId } });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }
        const healthRecords = await db.Health_record.findAll({
            where: { patient_id: userId },
            order: [['record_date', 'DESC']]
        });

        if (!healthRecords || healthRecords.length === 0) {
            return resolve({
                err: 1,
                mes: 'No health records found.'
            });
        }

        resolve({
            err: 0,
            mes: 'Get health record successfully',
            data: healthRecords
        });
    } catch (error) {
        reject(error);
    }
});
export const editHealthRecord = ({ userId, id, recordDate, height, weight }) => new Promise(async (resolve, reject) => {
    try {
        if (!id) {
            return resolve({
                err: 1,
                mes: 'Patient does not have any health records.'
            });
        }
        const patient = await db.Patient.findOne({ where: { patient_id: userId } });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }
        const healthRecord = await db.Health_record.findOne({ where: { id: id, patient_id: userId } });

        if (!healthRecord) {
            return resolve({
                err: 1,
                mes: 'Health Record is not exist.'
            });
        }
        await db.Health_record.update(
            {
                record_date: recordDate,
                height: height,
                weight: weight
            },
            {
                where: { id: id }
            }
        );
        const updated = await db.Health_record.findOne({ where: { id } });

        resolve({
            err: 0,
            mes: 'Edit health record successfully',
            data: updated
        });
    } catch (error) {
        reject(error);
    }
});

export const deleteHealthRecord = ({ userId, id }) => new Promise(async (resolve, reject) => {
    try {
        if (!id) {
            return resolve({
                err: 1,
                mes: 'Patient does not have any health records.'
            });
        }
        const patient = await db.Patient.findOne({ where: { patient_id: userId } });

        if (!patient) {
            return resolve({
                err: 1,
                mes: 'Patient is not exist.'
            });
        }
        const healthRecord = await db.Health_record.findOne({ where: { id: id, patient_id: userId } });

        if (!healthRecord) {
            return resolve({
                err: 1,
                mes: 'Health Record is not exist.'
            });
        }
        await db.Health_record.destroy(
            {
                where: { id: id }
            }
        );

        resolve({
            err: 0,
            mes: 'Delete health record successfully',
        });
    } catch (error) {
        reject(error);
    }
});