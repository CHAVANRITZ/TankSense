
const mongoose = require('mongoose');

const pumpLogSchema = new mongoose.Schema(
    {
        tank: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Tank',
            required: true,
            index: true
        },

        device: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Device',
            required: true
        },

        action: {
            type: String,
            enum: ['ON', 'OFF'],
            required: true
        },

        mode: {
            type: String,
            enum: ['AUTO', 'MANUAL'],
            required: true
        },

        reason: {
            type: String,
            required: true,
            trim: true
        },

        startTime: {
            type: Date,
            default: null
        },

        endTime: {
            type: Date,
            default: null
        },

        duration: {
            type: Number,
            default: 0,
            min: 0
        }
    },
    {
        timestamps: true
    }
);

pumpLogSchema.index({ tank: 1, createdAt: -1 });

const PumpLog = mongoose.model('PumpLog', pumpLogSchema);

module.exports = PumpLog;
