
const express = require('express');

const router = express.Router();

const {
    updatePumpMode,
    controlPump,
    getPumpHistory
} = require('../controllers/pumpController');

// Change pump mode (AUTO / MANUAL)
router.put('/:tankId/mode', updatePumpMode);

// Manually control pump (ON / OFF)
router.put('/:tankId/control', controlPump);

// Get pump activity history
router.get('/:tankId/history', getPumpHistory);

module.exports = router;
