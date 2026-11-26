
const mongoose = require('mongoose');

const tankSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true
        },

        tankCode: {
            type: String,
            required: true,
            unique: true,
            uppercase: true,
            trim: true
        },

        capacity: {
            type: Number,
            required: true,
            min: 1
        },

        height: {
            type: Number,
            required: true,
            min: 1
        },

        lowLevelThreshold: {
            type: Number,
            default: 20,
            min: 0,
            max: 100
        },

        highLevelThreshold: {
            type: Number,
            default: 90,
            min: 0,
            max: 100
        },

        currentLevel: {
            type: Number,
            default: 0,
            min: 0,
            max: 100
        },

        currentVolume: {
            type: Number,
            default: 0,
            min: 0
        },

        pumpMode: {
            type: String,
            enum: ['AUTO', 'MANUAL'],
            default: 'AUTO'
        },

        desiredPumpStatus: {
            type: String,
            enum: ['ON', 'OFF'],
            default: 'OFF'
        },

        pumpStatus: {
            type: String,
            enum: ['ON', 'OFF'],
            default: 'OFF'
        },

        isActive: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true
    }
);

const Tank = mongoose.model('Tank', tankSchema);

module.exports = Tank;
