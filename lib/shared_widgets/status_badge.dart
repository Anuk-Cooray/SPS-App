import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final SlotStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case SlotStatus.available:
        bg = AppTheme.availableGreen.withOpacity(0.15);
        fg = AppTheme.availableGreen;
        label = 'AVAILABLE';
        break;
      case SlotStatus.reserved:
        bg = AppTheme.reservedAmber.withOpacity(0.15);
        fg = AppTheme.reservedAmber;
        label = 'RESERVED (15m)';
        break;
      case SlotStatus.occupied:
        bg = AppTheme.occupiedRed.withOpacity(0.15);
        fg = AppTheme.occupiedRed;
        label = 'OCCUPIED';
        break;
      case SlotStatus.upgraded:
        bg = AppTheme.reoptIndigo.withOpacity(0.2);
        fg = AppTheme.reoptIndigo;
        label = 'AI UPGRADE';
        break;
      case SlotStatus.violation:
        bg = AppTheme.violationDarkRed.withOpacity(0.25);
        fg = const Color(0xFFF87171);
        label = 'VIOLATION';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
