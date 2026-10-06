import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/custom_button.dart';

/// Hybrid Payment Analytics and Automated Billing Model
/// Sub-Objective Owner: R.M.M.K.S Rathnayake (IT23333666)
class PaymentBillingScreen extends StatefulWidget {
  const PaymentBillingScreen({super.key});

  @override
  State<PaymentBillingScreen> createState() => _PaymentBillingScreenState();
}

class _PaymentBillingScreenState extends State<PaymentBillingScreen> {
  int _parkedHours = 2;
  int _parkedMinutes = 24;
  bool _isPeakHour = true;
  bool _isGuardAssisted = false;
  bool _paymentCompleted = false;
  String _generatedExitToken = '';

  double get _calculatedFee {
    final totalMinutes = (_parkedHours * 60) + _parkedMinutes;
    final hoursFraction = totalMinutes / 60.0;
    double base = hoursFraction * AppConstants.baseRatePerHour;
    if (_isPeakHour) {
      base *= AppConstants.peakHourMultiplier;
    }
    return base;
  }

  void _processPayment() {
    setState(() {
      _paymentCompleted = true;
      _generatedExitToken = 'SPS-EXIT-${DateTime.now().millisecondsSinceEpoch}-V4821';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: AppTheme.availableGreen, size: 24),
            SizedBox(width: 8),
            Text('Hybrid Billing & Exit Pass'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selector: Mobile Self-Pay vs Guard Assisted (Hybrid)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isGuardAssisted = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isGuardAssisted ? AppTheme.reoptIndigo : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Mobile Self-Payment',
                          style: TextStyle(
                            color: !_isGuardAssisted ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isGuardAssisted = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isGuardAssisted ? AppTheme.reoptIndigo : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Guard Booth Assisted',
                          style: TextStyle(
                            color: _isGuardAssisted ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Dynamic Billing Card
            Container(
              padding: const EdgeInsets.all(18),
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
                      const Text(
                        'Live Parking Session',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isPeakHour ? AppTheme.reservedAmber.withOpacity(0.15) : AppTheme.availableGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isPeakHour ? 'PEAK RATE (1.35x)' : 'STANDARD RATE',
                          style: TextStyle(
                            color: _isPeakHour ? AppTheme.reservedAmber : AppTheme.availableGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Vehicle Number:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const Text('WP CAA-4821', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Allocated Spot:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const Text('Slot A-02 (Near Lift)', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('$_parkedHours hrs $_parkedMinutes mins', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: AppTheme.darkBorder, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Calculated Total Fee', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('Dynamic real-time rate', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                        ],
                      ),
                      Text(
                        'LKR ${_calculatedFee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.availableGreen,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (!_paymentCompleted) ...[
              CustomButton(
                text: _isGuardAssisted ? 'Request Guard Cash Receipt' : 'Pay Online Now (LKR ${_calculatedFee.toStringAsFixed(2)})',
                icon: Icons.payment_rounded,
                backgroundColor: AppTheme.reoptIndigo,
                onPressed: _processPayment,
              ),
            ] else ...[
              // Time-Sensitive Dynamic QR Code for Exit Barrier
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.availableGreen, width: 2),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.availableGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Payment Settled • Single-Use Exit QR',
                          style: TextStyle(color: AppTheme.availableGreen, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: _generatedExitToken,
                        version: QrVersions.auto,
                        size: 180.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _generatedExitToken,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan this QR code at the exit gate scanner within 15 minutes to automatically lower the barrier.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
