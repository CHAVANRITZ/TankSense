
const mongoose = require('mongoose');

const deviceSchema = new mongoose.Schema(
    {
        deviceId: {
            type: String,
            required: true,
            unique: true,
            uppercase: true,
            trim: true
        },

        deviceName: {
            type: String,
            required: true,
            trim: true
        },

        tank: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Tank',
            required: true,
            unique: true
        },

        connectionStatus: {
            type: String,
            enum: ['ONLINE', 'OFFLINE'],
            default: 'OFFLINE'
        },

        lastSeen: {
            type: Date,
            default: null
        },

        firmwareVersion: {
            type: String,
            default: '1.0.0'
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

const Device = mongoose.model('Device', deviceSchema);

module.exports = Device;
