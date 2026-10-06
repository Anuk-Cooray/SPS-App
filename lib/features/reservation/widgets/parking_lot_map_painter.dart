import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/parking_slot.dart';
import '../../../core/theme/app_theme.dart';

class ParkingLotMapView extends StatelessWidget {
  final List<ParkingSlot> slots;
  final String? selectedSlotId;
  final Function(ParkingSlot) onSlotTapped;

  const ParkingLotMapView({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSlotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.mapAsphalt,
      child: Stack(
        children: [
          // Background Vector Map Layout
          Positioned.fill(
            child: CustomPaint(
              painter: _MapRoadsPainter(),
            ),
          ),

          // Top Mall Entrance Header
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.pureBlack,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.meeting_room_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MALL PEDESTRIAN ENTRANCE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        Text(
                          'Main Elevators to Shopping Concourse',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Entry and Exit Gate Badges
          Positioned(
            top: 75,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.availableGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('ENTRY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ),
          Positioned(
            top: 180,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.occupiedRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('EXIT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ),

          // Parking Bays Section (Row 1 & Row 2)
          Positioned(
            top: 105,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: slots.take(4).map((slot) => _buildBayItem(slot)).toList(),
            ),
          ),

          Positioned(
            top: 215,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: slots.skip(4).take(4).map((slot) => _buildBayItem(slot)).toList(),
            ),
          ),

          // Map Legend (Floating right)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: AppTheme.availableGreen, text: 'Open'),
                  SizedBox(width: 8),
                  _LegendDot(color: AppTheme.reservedAmber, text: 'Reserved'),
                  SizedBox(width: 8),
                  _LegendDot(color: AppTheme.occupiedRed, text: 'Occupied'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBayItem(ParkingSlot slot) {
    final bool isSelected = slot.id == selectedSlotId;
    final bool isAvailable = slot.status == SlotStatus.available;

    Color bg;
    Color border;
    Color text;

    switch (slot.status) {
      case SlotStatus.available:
        bg = isSelected ? AppTheme.pureBlack : AppTheme.availableGreenBg;
        border = isSelected ? AppTheme.pureBlack : AppTheme.availableGreen;
        text = isSelected ? Colors.white : AppTheme.availableGreen;
        break;
      case SlotStatus.reserved:
        bg = AppTheme.reservedAmberBg;
        border = AppTheme.reservedAmber;
        text = AppTheme.reservedAmber;
        break;
      case SlotStatus.occupied:
      case SlotStatus.violation:
        bg = AppTheme.occupiedRedBg;
        border = AppTheme.occupiedRed;
        text = AppTheme.occupiedRed;
        break;
      default:
        bg = Colors.white;
        border = AppTheme.borderSubtle;
        text = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTap: isAvailable ? () => onSlotTapped(slot) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 86,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: isSelected ? 2.5 : 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              slot.slotNumber,
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (slot.isNearElevator)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.availableGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'BEST',
                  style: TextStyle(color: text, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            Text(
              '${slot.walkingDistanceMeters}m',
              style: TextStyle(
                color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lanePaint = Paint()
      ..color = AppTheme.mapLane
      ..style = PaintingStyle.fill;

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Horizontal Driving Lanes
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 65, size.width, 35), const Radius.circular(8)),
      lanePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 195, size.width, 35), const Radius.circular(8)),
      lanePaint,
    );

    // Dashed centerlines
    double dashWidth = 6;
    double dashSpace = 6;
    double startX = 10;
    while (startX < size.width - 10) {
      canvas.drawLine(Offset(startX, 82), Offset(startX + dashWidth, 82), dashPaint);
      canvas.drawLine(Offset(startX, 212), Offset(startX + dashWidth, 212), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
