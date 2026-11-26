
const express = require('express');

const router = express.Router();

const {
    getDeviceCommand,
    updateDeviceStatus
} = require('../controllers/deviceController');

// ESP32 polls backend for pump commands
router.get('/:deviceId/command', getDeviceCommand);

// ESP32 reports actual pump status
router.put('/:deviceId/status', updateDeviceStatus);

module.exports = router;
