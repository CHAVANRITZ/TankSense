
const mongoose = require('mongoose');

const Tank = require('../models/Tank');
const Device = require('../models/Device');
const SensorReading = require('../models/SensorReading');
const PumpLog = require('../models/PumpLog');

// Get dashboard data for a tank
const getDashboard = async (req, res) => {
    try {
        const { tankId } = req.params;

        // Validate tank ID
        if (!mongoose.isValidObjectId(tankId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid tank ID'
            });
        }

        // Find tank
        const tank = await Tank.findById(tankId);

        if (!tank || !tank.isActive) {
            return res.status(404).json({
                success: false,
                message: 'Tank not found'
            });
        }

        // Find associated device
        const device = await Device.findOne({
            tank: tank._id,
            isActive: true
        });

        // Find latest sensor reading
        const latestReading = await SensorReading.findOne({
            tank: tank._id
        }).sort({ createdAt: -1 });

        // Find latest pump log
        const latestPumpLog = await PumpLog.findOne({
            tank: tank._id
        }).sort({ createdAt: -1 });

        // Calculate device connection status
        const deviceOnline = device && device.lastSeen
            ? (Date.now() - new Date(device.lastSeen).getTime()) <= 60000
            : false;

        // Generate water level alert
        let waterAlert = 'NORMAL';

        if (tank.currentLevel <= tank.lowLevelThreshold) {
            waterAlert = 'LOW_LEVEL';
        } else if (tank.currentLevel >= tank.highLevelThreshold) {
            waterAlert = 'HIGH_LEVEL';
        }

        return res.status(200).json({
            success: true,
            message: 'Dashboard data fetched successfully',

            data: {
                tank: {
                    id: tank._id,
                    name: tank.name,
                    tankCode: tank.tankCode,
                    capacity: tank.capacity,
                    height: tank.height,
                    currentLevel: tank.currentLevel,
                    currentVolume: tank.currentVolume,
                    lowLevelThreshold: tank.lowLevelThreshold,
                    highLevelThreshold: tank.highLevelThreshold
                },

                pump: {
                    mode: tank.pumpMode,
                    desiredStatus: tank.desiredPumpStatus,
                    actualStatus: tank.pumpStatus,
                    latestLog: latestPumpLog
                },

                device: {
                    deviceId: device ? device.deviceId : null,
                    deviceName: device ? device.deviceName : null,
                    connectionStatus: deviceOnline ? 'ONLINE' : 'OFFLINE',
                    lastSeen: device ? device.lastSeen : null,
                    firmwareVersion: device ? device.firmwareVersion : null
                },

                latestReading: latestReading || null,

                alert: {
                    waterLevel: waterAlert,
                    message: waterAlert === 'LOW_LEVEL'
                        ? 'Water level is low'
                        : waterAlert === 'HIGH_LEVEL'
                            ? 'Water tank is almost full'
                            : 'Water level is normal'
                }
            }
        });

    } catch (error) {
        console.error('Dashboard Error:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch dashboard data',
            error: error.message
        });
    }
};

module.exports = {
    getDashboard
};
