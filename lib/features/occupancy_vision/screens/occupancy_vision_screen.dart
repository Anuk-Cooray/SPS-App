import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/violation_record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/custom_button.dart';

/// Vision-Based Occupancy and Violation Detection Model
/// Sub-Objective Owner: G.V.K Samudi (IT23343498)
class OccupancyVisionScreen extends StatefulWidget {
  const OccupancyVisionScreen({super.key});

  @override
  State<OccupancyVisionScreen> createState() => _OccupancyVisionScreenState();
}

class _OccupancyVisionScreenState extends State<OccupancyVisionScreen> {
  bool _simulatingCctvStream = true;
  ViolationRecord? _activeViolation;

  void _triggerSimulatedViolation() {
    setState(() {
      _activeViolation = ViolationRecord(
        id: 'viol-${DateTime.now().millisecondsSinceEpoch}',
        slotOccupied: 'B-02',
        adjacentSlotEncroached: 'B-03',
        detectedVehicleType: 'Toyota Prius (Car)',
        timestamp: DateTime.now(),
        confidenceScore: 0.94,
      );
    });
  }

  void _dismissViolation() {
    setState(() {
      _activeViolation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.videocam_rounded, color: AppTheme.reoptIndigo, size: 24),
            SizedBox(width: 8),
            Text('Vision Occupancy & Violations'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Violation Alert Banner (if YOLO detects multi-slot parking)
            if (_activeViolation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.violationDarkRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.occupiedRed, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.occupiedRed, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'IMPROPER PARKING VIOLATION DETECTED',
                            style: TextStyle(
                              color: AppTheme.occupiedRed,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'CCTV YOLO model detected vehicle occupying ${_activeViolation!.slotOccupied} and encroaching into adjacent slot ${_activeViolation!.adjacentSlotEncroached} (Confidence: ${(_activeViolation!.confidenceScore * 100).toInt()}%).',
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Action Required: Please reposition your vehicle within marked boundary lines.',
                      style: TextStyle(color: AppTheme.reservedAmber, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _dismissViolation,
                        child: const Text('Dismiss Alert', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // CCTV Feed & Telemetry Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.camera_alt_outlined, color: AppTheme.textSecondary, size: 18),
                          SizedBox(width: 8),
                          Text('CCTV-04 (Zone B North)', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.availableGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('LIVE 30 FPS', style: TextStyle(color: AppTheme.availableGreen, fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_red_eye_outlined, color: AppTheme.reoptIndigo.withOpacity(0.6), size: 40),
                              const SizedBox(height: 8),
                              const Text('YOLOv8 Real-Time Inference Stream', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('Detecting Cars, Vans, & Three-Wheelers', style: TextStyle(color: AppTheme.textMuted.withOpacity(0.8), fontSize: 10)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Edge Model: YOLOv8n-custom', style: TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Live Occupancy Analytics Grid
            const Text(
              'Real-Time Space Distribution',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Cars & SUVs',
                    value: '14 Occupied',
                    icon: Icons.directions_car,
                    color: AppTheme.reoptIndigo,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Three-Wheelers',
                    value: '6 Occupied',
                    icon: Icons.electric_rickshaw_rounded,
                    color: AppTheme.reservedAmber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Available',
                    value: '20 Free',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.availableGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Testing / Simulation Action
            CustomButton(
              text: 'Simulate CCTV Multi-Slot Violation',
              icon: Icons.warning_rounded,
              backgroundColor: AppTheme.occupiedRed,
              onPressed: _triggerSimulatedViolation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
