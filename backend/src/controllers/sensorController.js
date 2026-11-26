
const mongoose = require('mongoose');

const Tank = require('../models/Tank');
const Device = require('../models/Device');
const SensorReading = require('../models/SensorReading');
const { updateAutomaticPump } = require('../services/pumpService');

// Receive sensor reading from ESP32
const receiveSensorReading = async (req, res) => {
    try {
        const { deviceId, distance } = req.body;

        // Validate request data
        if (!deviceId || distance === undefined) {
            return res.status(400).json({
                success: false,
                message: 'Device ID and distance are required'
            });
        }

        const measuredDistance = Number(distance);

        if (
            !Number.isFinite(measuredDistance) ||
            measuredDistance <= 0
        ) {
            return res.status(400).json({
                success: false,
                message: 'Distance must be a valid positive number'
            });
        }

        // Find registered device and its tank
        const device = await Device.findOne({
            deviceId: deviceId.toUpperCase(),
            isActive: true
        }).populate('tank');

        if (!device || !device.tank) {
            return res.status(404).json({
                success: false,
                message: 'Device or associated tank not found'
            });
        }

        const tank = device.tank;

        if (!tank.isActive) {
            return res.status(400).json({
                success: false,
                message: 'Tank is inactive'
            });
        }

        // Validate measured distance against tank height
        if (measuredDistance >= tank.height) {
            return res.status(400).json({
                success: false,
                message: 'Distance must be smaller than tank height'
            });
        }

        // Calculate water level
        const waterLevel = tank.height - measuredDistance;

        // Calculate water percentage
        const waterPercentage =
            (waterLevel / tank.height) * 100;

        // Calculate water volume
        const waterVolume =
            (waterPercentage / 100) * tank.capacity;

        // Save sensor reading
        const reading = await SensorReading.create({
            tank: tank._id,
            device: device._id,
            distance: measuredDistance,
            waterLevel: Number(waterLevel.toFixed(2)),
            waterPercentage: Number(waterPercentage.toFixed(2)),
            waterVolume: Number(waterVolume.toFixed(2)),
            sensorStatus: 'NORMAL'
        });

// Update current tank status
tank.currentLevel = Number(waterPercentage.toFixed(2));
tank.currentVolume = Number(waterVolume.toFixed(2));

await tank.save();

// Run automatic pump control
await updateAutomaticPump(
    tank,
    device,
    Number(waterPercentage.toFixed(2))
);

        // Update device connection status
        device.connectionStatus = 'ONLINE';
        device.lastSeen = new Date();

        await device.save();

        res.status(201).json({
            success: true,
            message: 'Sensor reading received successfully',
            data: {
                tankCode: tank.tankCode,
                deviceId: device.deviceId,
                distance: measuredDistance,
                waterLevel: reading.waterLevel,
                waterPercentage: reading.waterPercentage,
                waterVolume: reading.waterVolume,
                sensorStatus: reading.sensorStatus,
                recordedAt: reading.createdAt
            }
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to process sensor reading',
            error: error.message
        });
    }
};

// Get sensor reading history for a tank
const getSensorReadings = async (req, res) => {
    try {
        const { tankId } = req.params;

        // Validate MongoDB tank ID
        if (!mongoose.isValidObjectId(tankId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid tank ID'
            });
        }

        // Check if tank exists
        const tank = await Tank.findById(tankId);

        if (!tank) {
            return res.status(404).json({
                success: false,
                message: 'Tank not found'
            });
        }

        // Pagination
        const page = Math.max(1, parseInt(req.query.page, 10) || 1);
        const limit = Math.min(
            100,
            Math.max(1, parseInt(req.query.limit, 10) || 10)
        );

        const skip = (page - 1) * limit;

        // Fetch sensor readings
        const readings = await SensorReading.find({
            tank: tankId
        })
            .populate('device', 'deviceId deviceName')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        // Total reading count
        const totalReadings = await SensorReading.countDocuments({
            tank: tankId
        });

        res.status(200).json({
            success: true,
            message: 'Sensor reading history fetched successfully',
            tankCode: tank.tankCode,
            pagination: {
                totalReadings,
                currentPage: page,
                totalPages: Math.ceil(totalReadings / limit),
                limit
            },
            data: readings
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch sensor reading history',
            error: error.message
        });
    }
};

module.exports = {
    receiveSensorReading,
    getSensorReadings
};
