
const express = require('express');

const router = express.Router();

const {
    getDashboard
} = require('../controllers/dashboardController');

// Get dashboard data for a tank
router.get('/:tankId', getDashboard);

module.exports = router;
