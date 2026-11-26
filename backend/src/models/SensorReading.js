
const mongoose = require('mongoose');

const sensorReadingSchema = new mongoose.Schema(
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

        distance: {
            type: Number,
            required: true,
            min: 0
        },

        waterLevel: {
            type: Number,
            required: true,
            min: 0
        },

        waterPercentage: {
            type: Number,
            required: true,
            min: 0,
            max: 100
        },

        waterVolume: {
            type: Number,
            required: true,
            min: 0
        },

        sensorStatus: {
            type: String,
            enum: ['NORMAL', 'ERROR'],
            default: 'NORMAL'
        }
    },
    {
        timestamps: true
    }
);

// Automatically create an index for recent tank readings
sensorReadingSchema.index({ tank: 1, createdAt: -1 });

const SensorReading = mongoose.model(
    'SensorReading',
    sensorReadingSchema
);

module.exports = SensorReading;
