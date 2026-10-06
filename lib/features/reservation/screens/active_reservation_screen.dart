import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';

class ActiveReservationScreen extends StatefulWidget {
  final String bayId;
  final String lotName;
  final String floorName;
  final double price;

  const ActiveReservationScreen({
    super.key,
    this.bayId = 'A-09',
    this.lotName = 'SLIIT FOC Smart Lot',
    this.floorName = 'Level 1',
    this.price = 300.00,
  });

  @override
  State<ActiveReservationScreen> createState() => _ActiveReservationScreenState();
}

class _ActiveReservationScreenState extends State<ActiveReservationScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  late String _currentBay;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 14 * 60 + 59; // 14:59
    _currentBay = widget.bayId;

    // Start 15-min TTL live ticker
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _onTtlExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTtlExpired() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hold Expired (15-min TTL)'),
        content: const Text('Slot has returned to the vacant pool due to auto-cancellation grace expiry.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Return to Map'),
          ),
        ],
      ),
    );
  }

  String get _timeFormatted {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    return _remainingSeconds / (15 * 60);
  }

  void _triggerPreArrivalSimulation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: AppTheme.aiIndigo),
            SizedBox(width: 8),
            Text('10-Min Pre-Arrival Event', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.aiIndigoBg, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                '⚡ AI Vision-Based Optimization Active',
                style: TextStyle(color: AppTheme.aiIndigo, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'CCTV YOLO detected Bay A-03 (right next to the elevator lobby) has just become vacant!',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Saves 35 meters walking distance\n• IoT gate barrier auto-armed for entry PIN: 4821\n• Free automatic upgrade',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep A-09', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _currentBay = 'A-03');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Switched to closer Bay A-03! Barrier authorized.'),
                  backgroundColor: AppTheme.availableGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.availableGreen, foregroundColor: Colors.white),
            child: const Text('Accept A-03 Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showEntryQrModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Dynamic Entry Pass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Scan at Entrance Barrier Scanner', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              width: 170,
              height: 170,
              child: QrImageView(
                data: 'SPS-RESERVATION-PK2481-BAY-$_currentBay-PIN-4821',
                version: QrVersions.auto,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Or Enter Keypad PIN: ', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('4821', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _cancelReservation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: const Text('You are within the 15-minute free grace period. Your slot will be released back to the vacant pool immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Slot')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reservation cancelled without penalty.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5484D), foregroundColor: Colors.white),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIVA TOP BAR (CONFIRMED · RESERVED)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.availableGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'CONFIRMED · RESERVED',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),

                      // Phone Support
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Titles
                  Text(
                    'Reservation #PK-2481 · ${widget.lotName}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bay $_currentBay is yours',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),

            // SCROLLABLE BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 2. COUNTDOWN RING (Banani CountdownRing.jsx Match)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Circular Progress Ring
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: _progress,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'TIME LEFT',
                                      style: TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _timeFormatted,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'of 15:00 hold',
                                      style: TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Hoarding Guard Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEEDA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.shield_outlined, color: Color(0xFFB34A00), size: 14),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Hoarding guard: expires to vacant pool at 00:00 unless you arrive.',
                                          style: TextStyle(color: Color(0xFFB34A00), fontSize: 10, fontWeight: FontWeight.bold, height: 1.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Progress percentage bar
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _progress,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(_progress * 100).toInt()}%',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Grace +2 min after arrival scan',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 9.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. ROUTE ETA CARD (Banani RouteEtaCard.jsx Match)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target · Bay $_currentBay',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                      ),
                                      Text(
                                        '${widget.lotName} · ${widget.floorName} · Row A',
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                                child: const Text('CONFIRMED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 3 Metric Boxes: Distance, ETA, Gate PIN
                          Row(
                            children: [
                              _buildRouteStat(Icons.directions_car, 'Distance', '3.4 km'),
                              const SizedBox(width: 8),
                              _buildRouteStat(Icons.timer_outlined, 'ETA', '14 min'),
                              const SizedBox(width: 8),
                              _buildRouteStat(Icons.lock_outline, 'Gate PIN', '4821'),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Two Action Buttons: Navigate & Entry QR
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Starting GPS navigation to SLIIT FOC Smart Lot...')),
                                    );
                                  },
                                  icon: const Icon(Icons.navigation_outlined, size: 16, color: Colors.black),
                                  label: const Text('Navigate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade50,
                                    side: const BorderSide(color: AppTheme.borderSubtle),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showEntryQrModal,
                                  icon: const Icon(Icons.qr_code, size: 16, color: Colors.black),
                                  label: const Text('Entry QR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade50,
                                    side: const BorderSide(color: AppTheme.borderSubtle),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. DEMO SIM BAR (Banani DemoSimBar.jsx Match - Viva Simulation Presentation Tool)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.science_outlined, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Viva demo simulation',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                ],
                              ),
                              Container(
                                width: 36,
                                height: 20,
                                decoration: BoxDecoration(color: AppTheme.availableGreen, borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.all(2),
                                child: const CircleAvatar(radius: 7, backgroundColor: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Simulated approach progress
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Simulate approach', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                      child: const Text('ETA: 8 min', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Timeline bar
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(3))),
                                    FractionallySizedBox(
                                      widthFactor: 0.45,
                                      child: Container(height: 6, decoration: BoxDecoration(color: AppTheme.availableGreen, borderRadius: BorderRadius.circular(3))),
                                    ),
                                    Align(
                                      alignment: const Alignment(-0.1, 0),
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.availableGreen, width: 2), shape: BoxShape.circle),
                                        child: const Icon(Icons.directions_car, size: 10, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Garage', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
                                    Text('You', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Trigger Pre-Arrival Event Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _triggerPreArrivalSimulation,
                              icon: const Icon(Icons.bolt, color: Colors.white, size: 18),
                              label: const Text('Trigger pre-arrival event', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.availableGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              'Fires gate-open + CCTV re-check on stage, no driving needed',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Reservation
                    TextButton(
                      onPressed: _cancelReservation,
                      child: const Text(
                        'Cancel reservation',
                        style: TextStyle(color: Color(0xFFE5484D), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
