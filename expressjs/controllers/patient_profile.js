import { gender as genderSchema, dateOfBirth as dobSchema, healthRecordSchema } from '../helpers/joi_schema'
import joi from 'joi'
import * as services from '../services'
import { internalServerError, badRequest } from '../middlewares/handle_errors.js'

export const editProfile = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const { fullName, dateOfBirth, gender, medicalHistory, allergies, avatar } = req.body;

        const { error } = joi.object({
            dateOfBirth: dobSchema,
            gender: genderSchema
        }).validate({ dateOfBirth, gender });

        if (error)
            return badRequest(error.details[0]?.message, res)

        const response = await services.editProfile({
            userId,
            fullName,
            dateOfBirth,
            gender,
            medicalHistory,
            allergies,
            avatar
        });


        return res.status(200).json(response)
    } catch (error) {
        console.log(error);
        return internalServerError(res)
    }
}
export const editAnonymousName = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const { anonymousName } = req.body;

        const response = await services.editAnonymousName({
            userId,
            anonymousName
        });
        return res.status(200).json(response)
    } catch (error) {
        console.log(error);
        return internalServerError(res)
    }
}
export const getProfile = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const response = await services.getProfile({ userId });

        return res.status(200).json(response);
    } catch (error) {
        console.log(error);
        return internalServerError(res);
    }
}
export const editAvatar = async (req, res) => {
    try {
        const userId = req.user?.id
        const file = req.file

        if (!file) return res.status(400).json({ err: 1, mes: 'No file uploaded' })

        const result = await services.editAvatar({
            userId,
            fileBuffer: file.buffer,
            originalName: file.originalname,
            mimetype: file.mimetype
        })

        return res.status(200).json(result)
    } catch (error) {
        console.log(error)
        return res.status(500).json({ err: 1, mes: 'Server error' })
    }
}

export const addHealthRecord = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const { recordDate, height, weight } = req.body;

        const { error } = healthRecordSchema.validate({ recordDate, height, weight });
        if (error) return badRequest(error.details[0]?.message, res);

        const response = await services.addHealthRecord({
            userId,
            recordDate,
            height,
            weight
        });
        return res.status(200).json(response)
    } catch (error) {
        console.log(error);
        return internalServerError(res)
    }
}
export const getHealthRecords = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const response = await services.getHealthRecords({ userId });

        return res.status(200).json(response);
    } catch (error) {
        console.log(error);
        return internalServerError(res);
    }
}
export const editHealthRecord = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const { id, recordDate, height, weight } = req.body;

        const { error } = healthRecordSchema.validate({ recordDate, height, weight });
        if (error) return badRequest(error.details[0]?.message, res);

        const response = await services.editHealthRecord({
            userId,
            id,
            recordDate,
            height,
            weight
        });
        return res.status(200).json(response)
    } catch (error) {
        console.log(error);
        return internalServerError(res)
    }
}

export const deleteHealthRecord = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) return badRequest('Missing user id', res);

        const { id } = req.body;

        const response = await services.deleteHealthRecord({
            userId,
            id,
        });
        return res.status(200).json(response)
    } catch (error) {
        console.log(error);
        return internalServerError(res)
    }
}