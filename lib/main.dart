import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/reservation/screens/reservation_home_screen.dart';
import 'features/occupancy_vision/screens/occupancy_vision_screen.dart';
import 'features/payment_billing/screens/payment_billing_screen.dart';
import 'features/iot_navigation/screens/iot_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking SPS (J26-IT-335)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // The 4 research components individually led by team members
  final List<Widget> _screens = const [
    ReservationHomeScreen(),   // Cooray: Dynamic Reservation & Re-optimization
    OccupancyVisionScreen(),   // Samudi: CCTV YOLO Detection & Violations
    PaymentBillingScreen(),    // Rathnayake: Dynamic Billing & QR Pass
    IotNavigationScreen(),     // Varunprasath: IoT Barrier & Find My Car
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking_rounded),
            activeIcon: Icon(Icons.local_parking_rounded, color: AppTheme.reoptIndigo),
            label: 'Reserve',
            tooltip: 'Dynamic Slot Reservation (Cooray)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye_outlined),
            activeIcon: Icon(Icons.remove_red_eye_rounded, color: AppTheme.reoptIndigo),
            label: 'CCTV Vision',
            tooltip: 'Occupancy & Violations (Samudi)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            activeIcon: Icon(Icons.qr_code_2_rounded, color: AppTheme.reoptIndigo),
            label: 'Billing & QR',
            tooltip: 'Dynamic QR Billing (Rathnayake)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors_rounded),
            activeIcon: Icon(Icons.sensors_rounded, color: AppTheme.reoptIndigo),
            label: 'IoT & Car',
            tooltip: 'Physical Protection & Find My Car (Varunprasath)',
          ),
        ],
      ),
    );
  }
}
