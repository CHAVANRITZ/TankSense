
const express = require('express');
const cors = require('cors');

const tankRoutes = require('./routes/tankRoutes');
const sensorRoutes = require('./routes/sensorRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const pumpRoutes = require('./routes/pumpRoutes');
const deviceRoutes = require('./routes/deviceRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'TankSense API is running',
        timestamp: new Date()
    });
});

// Tank routes
app.use('/api/tanks', tankRoutes);

// Sensor routes
app.use('/api/sensors', sensorRoutes);

// Dashboard routes
app.use('/api/dashboard', dashboardRoutes);

// Pump routes
app.use('/api/pumps', pumpRoutes);

// Device routes (ESP32 communication)
app.use('/api/devices', deviceRoutes);

module.exports = app;
