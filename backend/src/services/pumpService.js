
const updateAutomaticPump = async (tank, device, waterPercentage) => {
    // Automatic control should only work in AUTO mode
    if (tank.pumpMode !== 'AUTO') {
        return tank;
    }

    let newPumpStatus = tank.desiredPumpStatus;

    // Start pump when water reaches or falls below low threshold
    if (waterPercentage <= tank.lowLevelThreshold) {
        newPumpStatus = 'ON';
    }

    // Stop pump when water reaches or exceeds high threshold
    else if (waterPercentage >= tank.highLevelThreshold) {
        newPumpStatus = 'OFF';
    }

    // Avoid unnecessary database updates
    if (newPumpStatus === tank.desiredPumpStatus) {
        return tank;
    }

    const previousStatus = tank.desiredPumpStatus;

    // Update only the desired pump state
    tank.desiredPumpStatus = newPumpStatus;
    await tank.save();

    console.log(
        `Automatic Pump Command: ${previousStatus} -> ${newPumpStatus}`
    );

    return tank;
};

module.exports = {
    updateAutomaticPump
};
