
const express = require('express');

const router = express.Router();

const {
    createTank,
    getAllTanks,
    getTankById,
    updateTank
} = require('../controllers/tankController');

// Create a new tank
router.post('/', createTank);

// Get all tanks
router.get('/', getAllTanks);

// Get tank by ID
router.get('/:id', getTankById);

// Update tank
router.put('/:id', updateTank);

module.exports = router;
