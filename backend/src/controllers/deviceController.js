
const Device = require('../models/Device');
const PumpLog = require('../models/PumpLog');

// ESP32 polls backend for the latest pump command
const getDeviceCommand = async (req, res) => {
    try {
        const { deviceId } = req.params;

        if (!deviceId) {
            return res.status(400).json({
                success: false,
                message: 'Device ID is required'
            });
        }

        const device = await Device.findOne({
            deviceId: deviceId.toUpperCase(),
            isActive: true
        }).populate('tank');

        if (!device || !device.tank || !device.tank.isActive) {
            return res.status(404).json({
                success: false,
                message: 'Active device or associated tank not found'
            });
        }

        // Update device heartbeat
        device.connectionStatus = 'ONLINE';
        device.lastSeen = new Date();
        await device.save();

        return res.status(200).json({
            success: true,
            message: 'Device command fetched successfully',
            data: {
                deviceId: device.deviceId,
                tankCode: device.tank.tankCode,
                pumpMode: device.tank.pumpMode,
                desiredPumpStatus: device.tank.desiredPumpStatus
            }
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch device command',
            error: error.message
        });
    }
};

// ESP32 reports the actual pump status after executing a command
const updateDeviceStatus = async (req, res) => {
    try {
        const { deviceId } = req.params;
        const { pumpStatus } = req.body;

        if (!['ON', 'OFF'].includes(pumpStatus)) {
            return res.status(400).json({
                success: false,
                message: 'Pump status must be ON or OFF'
            });
        }

        const device = await Device.findOne({
            deviceId: deviceId.toUpperCase(),
            isActive: true
        }).populate('tank');

        if (!device || !device.tank || !device.tank.isActive) {
            return res.status(404).json({
                success: false,
                message: 'Active device or associated tank not found'
            });
        }

        const tank = device.tank;
        const previousStatus = tank.pumpStatus;
        const currentTime = new Date();

        // Record activity only when actual pump status changes
        if (previousStatus !== pumpStatus) {

            // Pump is starting
            if (pumpStatus === 'ON') {
                await PumpLog.create({
                    tank: tank._id,
                    device: device._id,
                    action: 'ON',
                    mode: tank.pumpMode,
                    reason: tank.pumpMode === 'AUTO'
                        ? 'Pump started by automatic control'
                        : 'Pump started by manual control',
                    startTime: currentTime,
                    endTime: null,
                    duration: 0
                });
            }

            // Pump is stopping
            else if (pumpStatus === 'OFF') {
                const activePumpLog = await PumpLog.findOne({
                    tank: tank._id,
                    action: 'ON',
                    endTime: null
                }).sort({ startTime: -1 });

                if (activePumpLog) {
                    activePumpLog.endTime = currentTime;

                    // Calculate actual running duration in seconds
                    activePumpLog.duration = Math.max(
                        0,
                        Math.round(
                            (currentTime - activePumpLog.startTime) / 1000
                        )
                    );

                    await activePumpLog.save();
                }

                // Create OFF activity record
                await PumpLog.create({
                    tank: tank._id,
                    device: device._id,
                    action: 'OFF',
                    mode: tank.pumpMode,
                    reason: tank.pumpMode === 'AUTO'
                        ? 'Pump stopped by automatic control'
                        : 'Pump stopped by manual control',
                    startTime: null,
                    endTime: currentTime,
                    duration: 0
                });
            }
        }

        // Update actual pump status
        tank.pumpStatus = pumpStatus;
        await tank.save();

        // Update device heartbeat
        device.connectionStatus = 'ONLINE';
        device.lastSeen = currentTime;
        await device.save();

        return res.status(200).json({
            success: true,
            message: 'Device status updated successfully',
            data: {
                deviceId: device.deviceId,
                tankCode: tank.tankCode,
                pumpMode: tank.pumpMode,
                desiredPumpStatus: tank.desiredPumpStatus,
                pumpStatus: tank.pumpStatus,
                commandMatched: tank.desiredPumpStatus === pumpStatus
            }
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: 'Failed to update device status',
            error: error.message
        });
    }
};

module.exports = {
    getDeviceCommand,
    updateDeviceStatus
};
