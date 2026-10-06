import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/reservation/screens/reservation_home_screen.dart';
import 'features/occupancy_vision/screens/occupancy_vision_screen.dart';
import 'features/payment_billing/screens/payment_billing_screen.dart';
import 'features/iot_navigation/screens/iot_navigation_screen.dart';
import 'shared_widgets/uber_bottom_navigation_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPS Smart Parking (J26-IT-335)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.uberLightTheme,
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

  final List<Widget> _screens = const [
    ReservationHomeScreen(),   // Explore: Working Uber Search, Colombo & SLIIT Malabe Map (Cooray)
    PaymentBillingScreen(),    // Bookings: Dynamic QR Billing & Pass (Rathnayake)
    OccupancyVisionScreen(),   // Vision AI: CCTV YOLO Detection & Violations (Samudi)
    IotNavigationScreen(),     // Account: IoT Barrier & Find My Car (Varunprasath)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: UberBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
