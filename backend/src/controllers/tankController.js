
const Tank = require('../models/Tank');

// Create a new tank
const createTank = async (req, res) => {
    try {
        const {
            name,
            tankCode,
            capacity,
            height,
            lowLevelThreshold,
            highLevelThreshold
        } = req.body;

        // Check if tank code already exists
        const existingTank = await Tank.findOne({ tankCode });

        if (existingTank) {
            return res.status(409).json({
                success: false,
                message: 'Tank code already exists'
            });
        }

        // Create tank
        const tank = await Tank.create({
            name,
            tankCode,
            capacity,
            height,
            lowLevelThreshold,
            highLevelThreshold
        });

        res.status(201).json({
            success: true,
            message: 'Tank created successfully',
            data: tank
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to create tank',
            error: error.message
        });
    }
};

// Get all tanks
const getAllTanks = async (req, res) => {
    try {
        const tanks = await Tank.find().sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: tanks.length,
            data: tanks
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch tanks',
            error: error.message
        });
    }
};

// Get a single tank
const getTankById = async (req, res) => {
    try {
        const tank = await Tank.findById(req.params.id);

        if (!tank) {
            return res.status(404).json({
                success: false,
                message: 'Tank not found'
            });
        }

        res.status(200).json({
            success: true,
            data: tank
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch tank',
            error: error.message
        });
    }
};

// Update tank details
const updateTank = async (req, res) => {
    try {
        const tank = await Tank.findByIdAndUpdate(
            req.params.id,
            req.body,
            {
                new: true,
                runValidators: true
            }
        );

        if (!tank) {
            return res.status(404).json({
                success: false,
                message: 'Tank not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Tank updated successfully',
            data: tank
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to update tank',
            error: error.message
        });
    }
};

module.exports = {
    createTank,
    getAllTanks,
    getTankById,
    updateTank
};
