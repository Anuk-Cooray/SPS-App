import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetTime;
  final VoidCallback onTimerExpired;
  final String label;

  const CountdownTimerWidget({
    super.key,
    required this.targetTime,
    required this.onTimerExpired,
    this.label = 'Auto-Release Countdown',
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final difference = widget.targetTime.difference(now);
    if (difference.isNegative || difference == Duration.zero) {
      setState(() {
        _remainingTime = Duration.zero;
      });
      _timer?.cancel();
      widget.onTimerExpired();
    } else {
      setState(() {
        _remainingTime = difference;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    final bool isWarning = _remainingTime.inMinutes < 5;
    final bool isCritical = _remainingTime.inMinutes < 2;

    final Color timerColor = isCritical
        ? AppTheme.occupiedRed
        : (isWarning ? AppTheme.reservedAmber : AppTheme.availableGreen);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: timerColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: timerColor, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$minutes:$seconds',
                style: TextStyle(
                  color: timerColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
