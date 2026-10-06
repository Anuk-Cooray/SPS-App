import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/parking_destination.dart';
import '../../../core/theme/app_theme.dart';
import '../services/reservation_service.dart';

class ReservationHomeScreen extends StatefulWidget {
  const ReservationHomeScreen({super.key});

  @override
  State<ReservationHomeScreen> createState() => _ReservationHomeScreenState();
}

class _ReservationHomeScreenState extends State<ReservationHomeScreen> {
  final ReservationService _reservationService = ReservationService();
  late final MapController _mapController;

  bool _isSatellite = false;
  String _selectedDuration = '2h';
  int _selectedHours = 2;
  int _selectedCardIndex = 1;
  String _selectedLotName = 'SLIIT FOC Smart Lot';
  double _selectedLotTotal = 300.00;

  static const LatLng _sliitCenter = LatLng(6.9147, 79.9733);
  static const LatLng _focLotPos = LatLng(6.9142, 79.9729);
  static const LatLng _engLotPos = LatLng(6.9135, 79.9745);
  static const LatLng _adminLotPos = LatLng(6.9152, 79.9738);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  String get _tileUrl {
    if (_isSatellite) {
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
    return 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  }

  void _onDurationSelect(String label, int hours) {
    setState(() {
      _selectedDuration = label;
      _selectedHours = hours;
      double rate = _selectedCardIndex == 1 ? 150.00 : (_selectedCardIndex == 2 ? 120.00 : 100.00);
      _selectedLotTotal = rate * hours;
    });
  }

  void _onCardSelect(int index, String name, double total) {
    setState(() {
      _selectedCardIndex = index;
      _selectedLotName = name;
      _selectedLotTotal = total;
    });
  }

  void _bookParking() {
    _reservationService.bookSlot(
      slotId: 's-a02',
      vehicleNumber: 'WP CAA-4821',
      vehicleType: VehicleType.car,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booked $_selectedLotName! 15-min cancellation grace period active.'),
        backgroundColor: AppTheme.availableGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. LIVE GIS REAL-WORLD MAP
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _sliitCenter,
                  initialZoom: 16.5,
                  minZoom: 13,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileUrl,
                    userAgentPackageName: 'com.sps.smart_parking_app',
                  ),

                  // Dotted Navigation Route to Best Match
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: const [
                          LatLng(6.9125, 79.9715),
                          LatLng(6.9135, 79.9722),
                          LatLng(6.9142, 79.9729),
                        ],
                        strokeWidth: 3.5,
                        color: Colors.black,
                        isDotted: true,
                      ),
                    ],
                  ),

                  // Floating Price Bubbles (LKR 150, 120, 100, 180, 200)
                  MarkerLayer(
                    markers: [
                      // Best Match (SLIIT FOC Lot - LKR 150)
                      Marker(
                        point: _focLotPos,
                        width: 58,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _onCardSelect(1, 'SLIIT FOC Smart Lot', 150.00 * _selectedHours),
                          child: _buildPriceBubble('150', isPrimary: true),
                        ),
                      ),
                      // SLIIT Eng Lot (LKR 120)
                      Marker(
                        point: _engLotPos,
                        width: 58,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _onCardSelect(2, 'SLIIT Engineering Lot', 120.00 * _selectedHours),
                          child: _buildPriceBubble('120', isHighlight: true),
                        ),
                      ),
                      // Admin Visitor Lot (LKR 100)
                      Marker(
                        point: _adminLotPos,
                        width: 58,
                        height: 38,
                        child: GestureDetector(
                          onTap: () => _onCardSelect(3, 'Admin Visitor Tower', 100.00 * _selectedHours),
                          child: _buildPriceBubble('100'),
                        ),
                      ),
                      // Additional nearby spots
                      Marker(
                        point: const LatLng(6.9160, 79.9720),
                        width: 58,
                        height: 38,
                        child: _buildPriceBubble('180'),
                      ),
                      Marker(
                        point: const LatLng(6.9130, 79.9750),
                        width: 58,
                        height: 38,
                        child: _buildPriceBubble('200'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. TOP FLOATING BAR (Search + Filter & Bell + Filter Pills)
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Capsule with Black Search Circle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        // Black round search button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        // Two-line destination
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Where to park?',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'SLIIT Malabe — Faculty of Computing',
                                style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Filter & Bell Buttons
                        _buildCircleAction(Icons.tune_rounded, () {
                          setState(() => _isSatellite = !_isSatellite);
                        }),
                        const SizedBox(width: 6),
                        _buildCircleAction(Icons.notifications_outlined, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Surge demand 1.4x active due to peak hours.')),
                          );
                        }, hasDot: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Floating Filter Pills Row (Now · 2h, Navigate, QR entry)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Now · 2h
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Now · $_selectedDuration',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Navigate Pill
                        GestureDetector(
                          onTap: () => _mapController.move(_sliitCenter, 16.5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderSubtle),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.near_me_outlined, color: Colors.black, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Navigate',
                                  style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // QR Entry Pill
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Single-use gate entry QR generated.')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderSubtle),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'QR entry',
                                  style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. MAP CONTROLS ON RIGHT (Recenter & Satellite Toggle)
            Positioned(
              right: 14,
              top: 125,
              child: Column(
                children: [
                  _buildMapFloatingBtn(Icons.my_location_rounded, () {
                    _mapController.move(_sliitCenter, 16.5);
                  }),
                  const SizedBox(height: 8),
                  _buildMapFloatingBtn(Icons.layers_outlined, () {
                    setState(() => _isSatellite = !_isSatellite);
                  }),
                ],
              ),
            ),

            // 4. FLOATING GREEN CHIP ("4 min · 0.6 mi to cheapest")
            Positioned(
              left: 20,
              bottom: 375,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: AppTheme.availableGreen,
                      child: Icon(Icons.directions_car, color: Colors.white, size: 11),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '4 min · 0.6 km to best match',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

            // 5. DRAGGABLE BOTTOM SHEET (Reference Image Match)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 20, offset: const Offset(0, -4)),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 34,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Header: "How long?" + "High demand · 1.4x" surge badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'How long?',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.reservedAmberBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.reservedAmber.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⚡ ', style: TextStyle(fontSize: 10)),
                              Text(
                                'High demand · 1.4x',
                                style: TextStyle(color: AppTheme.reservedAmber, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Duration pills row: 1h, 2h (black), 4h, All day, Calendar
                    Row(
                      children: [
                        _buildDurationPill('1h', 1),
                        const SizedBox(width: 6),
                        _buildDurationPill('2h', 2),
                        const SizedBox(width: 6),
                        _buildDurationPill('4h', 4),
                        const SizedBox(width: 6),
                        _buildDurationPill('All day', 8),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_today_outlined, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Time subtitle
                    const Row(
                      children: [
                        Icon(Icons.access_time, size: 13, color: AppTheme.textMuted),
                        SizedBox(width: 6),
                        Text(
                          'Today 2:30 PM – 4:30 PM · Prices update live',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Parking Cards List Header
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('6 spots near you', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        Row(
                          children: [
                            Text('Sort: Recommended', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                            Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Card 1: Main Selected Card (Solid Black Border)
                    _buildParkingCard(
                      index: 1,
                      title: 'SLIIT FOC Smart Lot',
                      badge: 'CHEAPEST',
                      rating: '★ 4.8',
                      details: 'Covered · EV · 2 min walk',
                      priceUnit: 'LKR 150.00',
                      priceTotal: 'LKR ${_selectedLotTotal.toStringAsFixed(2)} · $_selectedDuration',
                      iconText: 'P',
                      isSelected: _selectedCardIndex == 1,
                    ),
                    const SizedBox(height: 8),

                    // Card 2: Open Now
                    _buildParkingCard(
                      index: 2,
                      title: 'SLIIT Engineering Lot',
                      badge: 'OPEN NOW',
                      rating: '★ 4.5',
                      details: 'Outdoor · 4 min walk',
                      priceUnit: 'LKR 120.00',
                      priceTotal: 'LKR ${(120.00 * _selectedHours).toStringAsFixed(2)} · $_selectedDuration',
                      iconData: Icons.directions_car_rounded,
                      isSelected: _selectedCardIndex == 2,
                    ),
                    const SizedBox(height: 10),

                    // Big Black Sticky Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _bookParking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Book $_selectedLotName · LKR ${_selectedLotTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Security / Cancellation Subtitle
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 13, color: AppTheme.textMuted),
                          SizedBox(width: 6),
                          Text(
                            'Free cancellation · 15 min grace TTL',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
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

  Widget _buildCircleAction(IconData icon, VoidCallback onTap, {bool hasDot = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 16),
          ),
          if (hasDot)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapFloatingBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3)),
          ],
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Icon(icon, color: Colors.black, size: 18),
      ),
    );
  }

  Widget _buildPriceBubble(String text, {bool isPrimary = false, bool isHighlight = false}) {
    Color bg = Colors.white;
    Color fg = Colors.black;
    Border? border = Border.all(color: AppTheme.borderSubtle);

    if (isPrimary) {
      bg = Colors.black;
      fg = Colors.white;
      border = Border.all(color: Colors.white, width: 2);
    } else if (isHighlight) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
      border = Border.all(color: const Color(0xFFFCD34D));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: border,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 6),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'LKR $text',
            style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 9.5),
          ),
        ),
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildDurationPill(String label, int hours) {
    final bool isSelected = _selectedDuration == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onDurationSelect(label, hours),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.black : AppTheme.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParkingCard({
    required int index,
    required String title,
    required String badge,
    required String rating,
    required String details,
    required String priceUnit,
    required String priceTotal,
    String? iconText,
    IconData? iconData,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        final parts = priceTotal.split(' ');
        final val = parts.length > 1 ? double.tryParse(parts[1]) : 300.00;
        _onCardSelect(index, title, val ?? 300.00);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.black : AppTheme.borderSubtle, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: iconText != null
                  ? Text(iconText, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w900))
                  : Icon(iconData, color: isSelected ? Colors.white : Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$rating · $details', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.directions_walk, size: 12, color: AppTheme.textMuted),
                      SizedBox(width: 2),
                      Text('Navigate', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.qr_code, size: 12, color: AppTheme.textMuted),
                      SizedBox(width: 2),
                      Text('QR entry', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(priceUnit, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text(priceTotal, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
