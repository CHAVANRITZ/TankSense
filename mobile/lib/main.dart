
import 'package:flutter/material.dart';
import 'services/api_service.dart';
void main() {
  runApp(const TankSenseApp());
}

class TankSenseApp extends StatelessWidget {
  const TankSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TankSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087E8B),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    PumpControlScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.water),
            label: 'Pump Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// DASHBOARD SCREEN


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  static const Color primaryColor = Color(0xFF087E8B);

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final data = await ApiService.getDashboard();

      if (!mounted) return;

      setState(() {
        dashboardData = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Color getLevelColor(String status) {
    switch (status) {
      case 'HIGH_LEVEL':
        return Colors.orange;
      case 'LOW_LEVEL':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TankSense'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                const Text('Unable to load dashboard'),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    fetchDashboard();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tank = dashboardData!['tank'];
    final pump = dashboardData!['pump'];
    final device = dashboardData!['device'];
    final alert = dashboardData!['alert'];

    final int waterLevel =
        ((tank['currentLevel'] as num?)?.toInt() ?? 0)
            .clamp(0, 100);

    final int capacity =
        (tank['capacity'] as num?)?.toInt() ?? 0;

    final int volume =
        (tank['currentVolume'] as num?)?.toInt() ?? 0;

    final String pumpStatus =
        (pump['actualStatus'] ?? 'UNKNOWN').toString();

    final String desiredStatus =
        (pump['desiredStatus'] ?? 'UNKNOWN').toString();

    final String deviceStatus =
        (device['connectionStatus'] ?? 'OFFLINE').toString();

    final String levelStatus =
        (alert['waterLevel'] ?? 'NORMAL').toString();

    final String alertMessage =
        (alert['message'] ?? 'Water level is normal').toString();

    final Color levelColor = getLevelColor(levelStatus);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.water_drop),
            SizedBox(width: 10),
            Text(
              'TankSense',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: fetchDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh dashboard',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tank heading
              Text(
                tank['name'] ?? 'My Water Tank',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Smart water monitoring system',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 22),

              // Water level card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WATER LEVEL',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        // Visual water tank
                        Expanded(
                          child: Center(
                            child: _waterTank(waterLevel),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Water percentage and volume
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$waterLevel%',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),

                              const Text(
                                'Water Available',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Current Volume',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '$volume L',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Total Capacity',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '$capacity L',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Divider(color: Colors.grey.shade200),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tank Status',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: levelColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            levelStatus.replaceAll('_', ' '),
                            style: TextStyle(
                              color: levelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Water level alert
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      levelStatus == 'NORMAL'
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      color: levelColor,
                      size: 27,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alertMessage,
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // System status
              const Text(
                'System Status',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statusCard(
                      icon: Icons.wifi,
                      title: 'ESP32 Device',
                      value: deviceStatus,
                      color: deviceStatus == 'ONLINE'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statusCard(
                      icon: Icons.power_settings_new,
                      title: 'Actual Pump',
                      value: pumpStatus,
                      color: pumpStatus == 'ON'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pump information
              const Text(
                'Pump Information',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _detailRow(
                      'Operating Mode',
                      pump['mode'].toString(),
                      Icons.settings,
                    ),

                    const Divider(height: 24),

                    _detailRow(
                      'Desired Pump Status',
                      desiredStatus,
                      Icons.track_changes,
                    ),

                    const Divider(height: 24),

                    _detailRow(
                      'Actual Pump Status',
                      pumpStatus,
                      Icons.power,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'TankSense IoT • Smart Water Management',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Vertical tank illustration
  Widget _waterTank(int level) {
    return Container(
      width: 145,
      height: 220,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue.shade50,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double fillHeight =
                constraints.maxHeight * level / 100;

            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.blue.shade50,
                  ),
                ),

                if (fillHeight > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: fillHeight,
                    child: Container(
                      color: const Color(0xFF20A4C8),
                    ),
                  ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 35,
                      color: level > 45
                          ? Colors.white
                          : primaryColor,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$level%',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: level > 45
                            ? Colors.white
                            : primaryColor,
                      ),
                    ),

                    Text(
                      'WATER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: level > 45
                            ? Colors.white
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Reusable system status card
  static Widget _statusCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 29),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable information row
  static Widget _detailRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 22,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}



// PUMP CONTROL SCREEN

class PumpControlScreen extends StatefulWidget {
  const PumpControlScreen({super.key});

  @override
  State<PumpControlScreen> createState() => _PumpControlScreenState();
}



class _PumpControlScreenState extends State<PumpControlScreen> {
  String pumpMode = 'AUTO';
  String desiredPumpStatus = 'OFF';
  String actualPumpStatus = 'OFF';

  bool isLoading = true;
  bool isUpdatingMode = false;
  bool isControllingPump = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPumpMode();
  }

  // Load pump information from backend
  Future<void> loadPumpMode() async {
    try {
      final data = await ApiService.getDashboard();

      if (!mounted) return;

      final pump = data['pump'];

      setState(() {
        pumpMode = pump['mode'] ?? 'AUTO';
        desiredPumpStatus = pump['desiredStatus'] ?? 'OFF';
        actualPumpStatus = pump['actualStatus'] ?? 'OFF';
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  // Change AUTO / MANUAL mode
  Future<void> changePumpMode(String mode) async {
    if (mode == pumpMode || isUpdatingMode) return;

    setState(() {
      isUpdatingMode = true;
    });

    try {
      final data = await ApiService.updatePumpMode(mode);

      if (!mounted) return;

      setState(() {
        pumpMode = data['pumpMode'];
        desiredPumpStatus = data['desiredPumpStatus'];
        actualPumpStatus = data['pumpStatus'];
        isUpdatingMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pump mode changed to $mode'),
          backgroundColor: Colors.green,
        ),
      );

      await loadPumpMode();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isUpdatingMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update mode: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Send manual ON / OFF command
  Future<void> controlPump(String action) async {
    if (pumpMode != 'MANUAL' || isControllingPump) return;

    setState(() {
      isControllingPump = true;
    });

    try {
      final data = await ApiService.controlPump(action);

      if (!mounted) return;

      setState(() {
        desiredPumpStatus = data['desiredPumpStatus'];
        actualPumpStatus = data['pumpStatus'];
        isControllingPump = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pump $action command sent successfully. '
            'Waiting for device confirmation.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh actual status from backend
      try {
        final dashboard = await ApiService.getDashboard();

        if (!mounted) return;

        final pump = dashboard['pump'];

        setState(() {
          desiredPumpStatus = pump['desiredStatus'] ?? 'OFF';
          actualPumpStatus = pump['actualStatus'] ?? 'OFF';
        });
      } catch (_) {
        // Keep the command response if refresh fails.
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isControllingPump = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pump control failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pump Control'),
          backgroundColor: const Color(0xFF087E8B),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    loadPumpMode();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump Control'),
        backgroundColor: const Color(0xFF087E8B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isControllingPump || isUpdatingMode
                ? null
                : loadPumpMode,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operating Mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'AUTO',
                  label: Text('AUTO'),
                ),
                ButtonSegment(
                  value: 'MANUAL',
                  label: Text('MANUAL'),
                ),
              ],
              selected: {pumpMode},
              onSelectionChanged:
                  isUpdatingMode || isControllingPump
                      ? null
                      : (value) {
                          changePumpMode(value.first);
                        },
            ),

            if (isUpdatingMode) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
              const SizedBox(height: 5),
              const Text(
                'Updating pump mode...',
                style: TextStyle(color: Colors.grey),
              ),
            ],

            const SizedBox(height: 30),

            // Actual pump status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.water,
                    size: 55,
                    color: actualPumpStatus == 'ON'
                        ? Colors.green
                        : Colors.orange,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Actual Pump Status',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    actualPumpStatus,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: actualPumpStatus == 'ON'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Desired Status: $desiredPumpStatus',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Manual Pump Operation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              pumpMode == 'MANUAL'
                  ? 'You can now control the pump manually.'
                  : 'Switch to MANUAL mode to operate the pump.',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pumpMode == 'MANUAL' &&
                            !isControllingPump
                        ? () => controlPump('ON')
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Pump ON'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pumpMode == 'MANUAL' &&
                            !isControllingPump
                        ? () => controlPump('OFF')
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Pump OFF'),
                  ),
                ),
              ],
            ),

            if (isControllingPump) ...[
              const SizedBox(height: 15),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Sending pump command...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



// HISTORY SCREEN


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getPumpHistory();

      if (!mounted) return;

      setState(() {
        history = result['data'];
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  String formatDateTime(dynamic dateValue) {
    if (dateValue == null) return 'Unknown time';

    final date = DateTime.tryParse(dateValue.toString());

    if (date == null) return 'Unknown time';

    final localDate = date.toLocal();

    final hour = localDate.hour % 12 == 0
        ? 12
        : localDate.hour % 12;

    final minute = localDate.minute.toString().padLeft(2, '0');

    final period = localDate.hour >= 12 ? 'PM' : 'AM';

    return '${localDate.day}/${localDate.month}/${localDate.year} '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xFF087E8B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 45,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      const Text('Failed to load history'),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: loadHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : history.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 55,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No pump activity found',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        ...history.map((item) {
                          final action =
                              (item['action'] ?? 'UNKNOWN').toString();

                          final mode =
                              (item['mode'] ?? 'UNKNOWN').toString();

                          final reason =
                              (item['reason'] ?? 'No reason provided')
                                  .toString();

                          final isOn = action == 'ON';

                          return HistoryItem(
                            icon: Icons.power_settings_new,
                            title: 'Pump turned $action',
                            subtitle: 'Mode: $mode\n$reason',
                            time: formatDateTime(item['createdAt']),
                            color: isOn ? Colors.green : Colors.orange,
                          );
                        }),
                      ],
                    ),
    );
  }
}


class HistoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const HistoryItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(time),
      ),
    );
  }
}
