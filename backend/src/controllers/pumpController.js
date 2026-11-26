
const mongoose = require('mongoose');

const Tank = require('../models/Tank');
const Device = require('../models/Device');
const PumpLog = require('../models/PumpLog');

// Change pump mode
const updatePumpMode = async (req, res) => {
    try {
        const { tankId } = req.params;
        const { mode } = req.body;

        if (!mongoose.isValidObjectId(tankId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid tank ID'
            });
        }

        if (!['AUTO', 'MANUAL'].includes(mode)) {
            return res.status(400).json({
                success: false,
                message: 'Mode must be AUTO or MANUAL'
            });
        }

        const tank = await Tank.findById(tankId);

        if (!tank || !tank.isActive) {
            return res.status(404).json({
                success: false,
                message: 'Tank not found'
            });
        }

        tank.pumpMode = mode;

        // When switching to AUTO, evaluate current water level
        if (mode === 'AUTO') {
            if (tank.currentLevel <= tank.lowLevelThreshold) {
                tank.desiredPumpStatus = 'ON';
            } else if (tank.currentLevel >= tank.highLevelThreshold) {
                tank.desiredPumpStatus = 'OFF';
            }
        }

        await tank.save();

        return res.status(200).json({
            success: true,
            message: `Pump mode changed to ${mode}`,
            data: {
                tankCode: tank.tankCode,
                pumpMode: tank.pumpMode,
                desiredPumpStatus: tank.desiredPumpStatus,
                pumpStatus: tank.pumpStatus
            }
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Failed to update pump mode',
            error: error.message
        });
    }
};

// Manually control pump
const controlPump = async (req, res) => {
    try {
        const { tankId } = req.params;
        const { action } = req.body;

        if (!mongoose.isValidObjectId(tankId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid tank ID'
            });
        }

        if (!['ON', 'OFF'].includes(action)) {
            return res.status(400).json({
                success: false,
                message: 'Action must be ON or OFF'
            });
        }

        const tank = await Tank.findById(tankId);

        if (!tank || !tank.isActive) {
            return res.status(404).json({
                success: false,
                message: 'Tank not found'
            });
        }

        if (tank.pumpMode !== 'MANUAL') {
            return res.status(400).json({
                success: false,
                message: 'Switch pump mode to MANUAL first'
            });
        }

        const device = await Device.findOne({
            tank: tank._id,
            isActive: true
        });

        if (!device) {
            return res.status(404).json({
                success: false,
                message: 'Associated device not found'
            });
        }

        // Avoid duplicate commands
        if (tank.desiredPumpStatus === action) {
            return res.status(200).json({
                success: true,
                message: `Pump is already requested to be ${action}`,
                data: {
                    desiredPumpStatus: tank.desiredPumpStatus,
                    pumpStatus: tank.pumpStatus
                }
            });
        }

        // Update desired pump state
        tank.desiredPumpStatus = action;
        await tank.save();

        return res.status(200).json({
            success: true,
            message: `Pump ${action} command saved successfully`,
            data: {
                tankCode: tank.tankCode,
                pumpMode: tank.pumpMode,
                desiredPumpStatus: tank.desiredPumpStatus,
                pumpStatus: tank.pumpStatus
            }
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Failed to control pump',
            error: error.message
        });
    }
};

// Get pump activity history for a tank
const getPumpHistory = async (req, res) => {
    try {
        const { tankId } = req.params;

        if (!mongoose.isValidObjectId(tankId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid tank ID'
            });
        }

        const tank = await Tank.findById(tankId);

        if (!tank || !tank.isActive) {
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

        // Get pump logs, newest first
        const pumpLogs = await PumpLog.find({
            tank: tankId
        })
            .populate('device', 'deviceId deviceName')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        const totalRecords = await PumpLog.countDocuments({
            tank: tankId
        });

        return res.status(200).json({
            success: true,
            message: 'Pump history fetched successfully',
            pagination: {
                currentPage: page,
                totalPages: Math.ceil(totalRecords / limit),
                totalRecords,
                limit
            },
            data: pumpLogs
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch pump history',
            error: error.message
        });
    }
};

module.exports = {
    updatePumpMode,
    controlPump,
    getPumpHistory
};
