import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/custom_button.dart';

/// IoT-Driven Physical Slot Protection and Authentication Model
/// Sub-Objective Owner: R. Varunprasath (IT23347526)
class IotNavigationScreen extends StatefulWidget {
  const IotNavigationScreen({super.key});

  @override
  State<IotNavigationScreen> createState() => _IotNavigationScreenState();
}

class _IotNavigationScreenState extends State<IotNavigationScreen> {
  bool _isBollardRaised = true;
  bool _isActuating = false;
  bool _carLocationSaved = true;
  final String _savedSpotNumber = 'A-02';
  final String _savedFloor = 'Level B1 (Near Pillar 14)';
  final int _remainingDistanceMeters = 38;

  void _toggleBollard() async {
    setState(() => _isActuating = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isBollardRaised = !_isBollardRaised;
      _isActuating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: AppTheme.availableGreen, size: 24),
            SizedBox(width: 8),
            Text('IoT Barriers & Find My Car'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Physical Slot Protection (ESP32 IoT Bollard Controller)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isBollardRaised ? AppTheme.reservedAmber : AppTheme.availableGreen,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isBollardRaised ? Icons.shield_rounded : Icons.lock_open_rounded,
                            color: _isBollardRaised ? AppTheme.reservedAmber : AppTheme.availableGreen,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('IoT Smart Barrier / Bollard', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(
                                _isBollardRaised ? 'Active Protection (Slot Reserved)' : 'Lowered (Vehicle Authorized)',
                                style: TextStyle(
                                  color: _isBollardRaised ? AppTheme.reservedAmber : AppTheme.availableGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('ESP32 / BLE', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontFamily: 'monospace')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'When a reservation is active, the physical bollard prevents unauthorized vehicles from taking your spot. Trigger lowering upon vehicle arrival.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isBollardRaised ? 'Lower Barrier to Park' : 'Raise Barrier to Lock Slot',
                      icon: _isBollardRaised ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      backgroundColor: _isBollardRaised ? AppTheme.availableGreen : AppTheme.reservedAmber,
                      isLoading: _isActuating,
                      onPressed: _toggleBollard,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // "Find My Car" Reverse Route Navigation
            const Text(
              'Find My Parked Vehicle',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.reoptIndigo.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.my_location_rounded, color: AppTheme.reoptIndigo, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Auto-Saved Parking Spot', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('$_savedSpotNumber • $_savedFloor', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.availableGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_remainingDistanceMeters m',
                          style: const TextStyle(color: AppTheme.availableGreen, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.turn_slight_right_rounded, color: AppTheme.reoptIndigo, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Walking Directions', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(height: 2),
                              Text('Exit Elevators B, turn right down Aisle 2 toward Pillar 14.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Beep IoT Beacon',
                          icon: Icons.volume_up_rounded,
                          backgroundColor: AppTheme.reoptIndigo,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Buzzer signal dispatched to Slot A-02 beacon.'),
                                backgroundColor: AppTheme.reoptIndigo,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
