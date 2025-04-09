import { where } from 'sequelize';
import db from '../models'
import jwt from 'jsonwebtoken'

export const editProfile = ({ userId, fullName, dateOfBirth, gender, medicalHistory, allergies, avatar }) => new Promise(async (resolve, reject) => {
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
                avatar_url: avatar
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
            attributes: ['full_name', 'date_of_birth', 'gender', 'medical_history', 'allergies', 'anonymous_name', 'avatar_url']
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
            data: patient
        });
    } catch (error) {
        reject(error);
    }
});

export const uploadAvatar = ({ userId, fileBuffer, originalName, mimetype }) =>
    new Promise(async (resolve, reject) => {
        try {
            if (!userId || !fileBuffer || !originalName || !mimetype) {
                return resolve({
                    err: 1,
                    mes: 'Missing required fields',
                })
            }

            const ext = originalName.split('.').pop()
            const filePath = `avatars/${userId}_${uuidv4()}.${ext}`

            const { error: uploadError } = await supabase.storage
                .from('image-mobile-app')
                .upload(filePath, fileBuffer, {
                    contentType: mimetype,
                    upsert: true,
                })

            if (uploadError) {
                return resolve({
                    err: 1,
                    mes: uploadError.message,
                })
            }

            const { data } = supabase.storage.from('image-mobile-app').getPublicUrl(filePath)

            resolve({
                err: 0,
                mes: 'Upload successful',
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
        const healthRecord = await db.Health_records.create({
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
export const editHealthRecord = ({ userId, id, recordDate, height, weight }) => new Promise(async (resolve, reject) => {
    try {
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