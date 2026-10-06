import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'active_reservation_screen.dart';

enum BayStatus { free, taken, hold, picked }

class ParkingBayItem {
  final String id;
  final BayStatus status;
  final bool isBest;
  final double score;
  final String walkDist;
  final String turnEase;
  final String doorSide;

  const ParkingBayItem({
    required this.id,
    required this.status,
    this.isBest = false,
    this.score = 8.5,
    this.walkDist = '60m',
    this.turnEase = '8.0 / 10',
    this.doorSide = 'Standard',
  });
}

class BaySelectionScreen extends StatefulWidget {
  final String lotName;
  final double lotPrice;
  final String duration;

  const BaySelectionScreen({
    super.key,
    this.lotName = 'SLIIT FOC Smart Lot',
    this.lotPrice = 300.00,
    this.duration = '2h',
  });

  @override
  State<BaySelectionScreen> createState() => _BaySelectionScreenState();
}

class _BaySelectionScreenState extends State<BaySelectionScreen> {
  String _selectedFloor = 'Level 1';
  late String _selectedBayId;
  late ParkingBayItem _selectedBay;

  // 24 Bays matching Banani design (A-07 to A-30)
  final List<ParkingBayItem> _bays = const [
    // Row 1
    ParkingBayItem(id: 'A-07', status: BayStatus.free, score: 9.0, walkDist: '50m', turnEase: '8.5 / 10', doorSide: 'Wide'),
    ParkingBayItem(id: 'A-08', status: BayStatus.free, score: 9.2, walkDist: '48m', turnEase: '8.7 / 10', doorSide: 'Wide'),
    ParkingBayItem(id: 'A-09', status: BayStatus.picked, isBest: true, score: 9.4, walkDist: '45m', turnEase: '8.9 / 10', doorSide: 'Wide'),
    ParkingBayItem(id: 'A-10', status: BayStatus.free, score: 8.9, walkDist: '55m', turnEase: '8.4 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-11', status: BayStatus.taken),
    ParkingBayItem(id: 'A-12', status: BayStatus.taken),
    // Row 2
    ParkingBayItem(id: 'A-13', status: BayStatus.free, score: 8.6, walkDist: '65m', turnEase: '8.1 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-14', status: BayStatus.free, score: 8.7, walkDist: '62m', turnEase: '8.2 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-15', status: BayStatus.free, score: 8.8, walkDist: '58m', turnEase: '8.3 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-16', status: BayStatus.free, score: 8.5, walkDist: '70m', turnEase: '7.9 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-17', status: BayStatus.hold),
    ParkingBayItem(id: 'A-18', status: BayStatus.taken),
    // Row 3
    ParkingBayItem(id: 'A-19', status: BayStatus.taken),
    ParkingBayItem(id: 'A-20', status: BayStatus.free, score: 8.3, walkDist: '78m', turnEase: '7.7 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-21', status: BayStatus.free, score: 8.4, walkDist: '75m', turnEase: '7.8 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-22', status: BayStatus.hold),
    ParkingBayItem(id: 'A-23', status: BayStatus.free, score: 8.1, walkDist: '85m', turnEase: '7.5 / 10', doorSide: 'Standard'),
    ParkingBayItem(id: 'A-24', status: BayStatus.free, score: 8.2, walkDist: '82m', turnEase: '7.6 / 10', doorSide: 'Standard'),
    // Row 4
    ParkingBayItem(id: 'A-25', status: BayStatus.free, score: 7.9, walkDist: '95m', turnEase: '7.2 / 10', doorSide: 'Compact'),
    ParkingBayItem(id: 'A-26', status: BayStatus.taken),
    ParkingBayItem(id: 'A-27', status: BayStatus.free, score: 7.8, walkDist: '98m', turnEase: '7.1 / 10', doorSide: 'Compact'),
    ParkingBayItem(id: 'A-28', status: BayStatus.free, score: 7.7, walkDist: '102m', turnEase: '7.0 / 10', doorSide: 'Compact'),
    ParkingBayItem(id: 'A-29', status: BayStatus.taken),
    ParkingBayItem(id: 'A-30', status: BayStatus.free, score: 7.6, walkDist: '105m', turnEase: '6.9 / 10', doorSide: 'Compact'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedBay = _bays.firstWhere((b) => b.id == 'A-09');
    _selectedBayId = _selectedBay.id;
  }

  void _onSelectBay(ParkingBayItem bay) {
    if (bay.status == BayStatus.taken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bay ${bay.id} is currently occupied.'), duration: const Duration(seconds: 1)),
      );
      return;
    }
    if (bay.status == BayStatus.hold) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bay ${bay.id} is on 15-min hold by another user.'), duration: const Duration(seconds: 1)),
      );
      return;
    }

    setState(() {
      _selectedBayId = bay.id;
      _selectedBay = bay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIVA TOP BAR (Banani VivaTopBar.jsx Match)
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

                      // CCTV LIVE Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3.5, backgroundColor: AppTheme.availableGreen),
                            SizedBox(width: 6),
                            Text(
                              'CCTV LIVE',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),

                      // Bell Action
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Header Titles
                  Text(
                    '${widget.lotName} · $_selectedFloor',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Select your bay',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT: FloorSelector + BayMatrix
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. FLOOR SELECTOR (Banani FloorSelector.jsx Match)
                    Row(
                      children: [
                        _buildFloorChip('Level 1', '42 free'),
                        const SizedBox(width: 8),
                        _buildFloorChip('Level 2', '18 free'),
                        const SizedBox(width: 8),
                        _buildFloorChip('Outdoor', '9 free'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3. LIVE BAY MATRIX (Banani BayMatrix.jsx Match)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Matrix Title & Vision Synced
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.document_scanner_outlined, size: 16, color: Colors.black),
                                  SizedBox(width: 6),
                                  Text(
                                    'Live bay matrix',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.availableGreen, shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Vision synced 4s ago',
                                    style: TextStyle(color: AppTheme.availableGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Lobby & North Entry Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business, size: 14, color: Colors.black),
                                    SizedBox(width: 6),
                                    Text('Lobby / Elevator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ],
                                ),
                                Text(
                                  'North entry · closest = best score',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 24 Bays Grid (6 cols x 4 rows)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _bays.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (context, idx) {
                              final bay = _bays[idx];
                              return _buildBayCell(bay);
                            },
                          ),

                          const SizedBox(height: 10),

                          // Drive Aisle Marker
                          const Center(
                            child: Text(
                              'Drive aisle · one-way →',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          const SizedBox(height: 10),

                          // Color Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildLegendItem(const Color(0xFF06C167), 'Available'),
                              _buildLegendItem(const Color(0xFFE5484D), 'Occupied'),
                              _buildLegendItem(const Color(0xFFF5B301), 'Reserved'),
                              _buildLegendItem(const Color(0xFF277EFF), 'Recommended'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. BAY META CARD (Banani BayMetaCard.jsx Match - Bottom Sticky)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBay.isBest ? 'RECOMMENDED BAY' : 'SELECTED BAY',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bay ${_selectedBay.id}',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_selectedFloor · Row A · Covered · EV ready',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                          ),
                        ],
                      ),
                      // AI Score Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _selectedBay.score.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                            Text(
                              'score',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Metrics Row
                  Row(
                    children: [
                      _buildMetaMetric('Walk', _selectedBay.walkDist),
                      const SizedBox(width: 8),
                      _buildMetaMetric('Turn ease', _selectedBay.turnEase),
                      const SizedBox(width: 8),
                      _buildMetaMetric('Door side', _selectedBay.doorSide),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Big Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActiveReservationScreen(
                              bayId: _selectedBay.id,
                              lotName: widget.lotName,
                              floorName: _selectedFloor,
                              price: widget.lotPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.availableGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Reserve Bay ${_selectedBay.id} · LKR ${widget.lotPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorChip(String title, String subtitle) {
    final bool isSelected = _selectedFloor == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFloor = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.black : AppTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
              ),
              Text(
                subtitle,
                style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.availableGreen, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBayCell(ParkingBayItem bay) {
    final bool isPicked = _selectedBayId == bay.id;

    Color bg;
    Color border;
    Color textCol;
    Widget? iconWidget;

    if (isPicked) {
      bg = const Color(0xFF277EFF);
      border = Colors.black;
      textCol = Colors.white;
      iconWidget = const Icon(Icons.directions_car, color: Colors.white, size: 14);
    } else {
      switch (bay.status) {
        case BayStatus.free:
          bg = const Color(0xFF06C167).withOpacity(0.14);
          border = const Color(0xFF06C167);
          textCol = Colors.black;
          iconWidget = const Icon(Icons.add, color: Color(0xFF06C167), size: 13);
          break;
        case BayStatus.taken:
          bg = const Color(0xFFE5484D).withOpacity(0.12);
          border = const Color(0xFFE5484D).withOpacity(0.4);
          textCol = Colors.grey;
          iconWidget = Icon(Icons.directions_car_filled, color: Colors.grey.shade400, size: 13);
          break;
        case BayStatus.hold:
          bg = const Color(0xFFF5B301).withOpacity(0.18);
          border = const Color(0xFFF5B301);
          textCol = const Color(0xFF92400E);
          iconWidget = const Icon(Icons.access_time_rounded, color: Color(0xFFF5B301), size: 13);
          break;
        case BayStatus.picked:
          bg = const Color(0xFF277EFF);
          border = Colors.black;
          textCol = Colors.white;
          iconWidget = const Icon(Icons.directions_car, color: Colors.white, size: 14);
          break;
      }
    }

    return GestureDetector(
      onTap: () => _onSelectBay(bay),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: isPicked ? 2 : 1.5),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconWidget != null) iconWidget,
                const SizedBox(height: 2),
                Text(
                  bay.id,
                  style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ],
            ),
          ),
          if (bay.isBest && !isPicked)
            Positioned(
              top: -6,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                child: const Text('BEST', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildMetaMetric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
