
const express = require('express');

const router = express.Router();

const {
    receiveSensorReading,
    getSensorReadings
} = require('../controllers/sensorController');

// Receive sensor reading from ESP32
router.post('/readings', receiveSensorReading);

// Get sensor reading history for a tank
router.get('/readings/:tankId', getSensorReadings);

module.exports = router;
