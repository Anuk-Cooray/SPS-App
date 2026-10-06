import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/parking_slot.dart';
import '../../../core/models/reservation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/countdown_timer_widget.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/status_badge.dart';
import '../services/reservation_service.dart';
import '../widgets/upgrade_offer_dialog.dart';

class ReservationHomeScreen extends StatefulWidget {
  const ReservationHomeScreen({super.key});

  @override
  State<ReservationHomeScreen> createState() => _ReservationHomeScreenState();
}

class _ReservationHomeScreenState extends State<ReservationHomeScreen> {
  final ReservationService _reservationService = ReservationService();
  VehicleType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _reservationService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _reservationService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _showBookingModal(ParkingSlot slot) {
    final vehicleController = TextEditingController(text: 'WP CAA-4821');
    VehicleType chosenType = slot.supportedType;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Slot ${slot.slotNumber}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatusBadge(status: slot.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Section ${slot.section} • ${slot.walkingDistanceMeters}m to Pedestrian Mall Exit',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const Divider(color: AppTheme.darkBorder, height: 32),
              const Text(
                'Vehicle License Plate Number',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: vehicleController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.darkSurface,
                  prefixIcon: const Icon(Icons.directions_car, color: AppTheme.reoptIndigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vehicle Category',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: VehicleType.values.map((vt) {
                  final isSelected = chosenType == vt;
                  String label = vt.name.toUpperCase();
                  if (vt == VehicleType.threeWheeler) label = 'THREE-WHEELER';
                  return ChoiceChip(
                    label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary, fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppTheme.reoptIndigo,
                    backgroundColor: AppTheme.darkSurface,
                    onSelected: (val) {
                      if (val) setModalState(() => chosenType = vt);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.reservedAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.reservedAmber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.reservedAmber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '15-Minute Auto-Release Policy: Your spot is reserved for 15 mins upon confirmation. Unused spots are automatically released.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Confirm & Hold Spot (15 Mins)',
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppTheme.availableGreen,
                  onPressed: () {
                    final success = _reservationService.bookSlot(
                      slotId: slot.id,
                      vehicleNumber: vehicleController.text.trim(),
                      vehicleType: chosenType,
                    );
                    Navigator.pop(ctx);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Slot ${slot.slotNumber} reserved! 15-min countdown started.'),
                          backgroundColor: AppTheme.availableGreen,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerSimulatedUpgrade() {
    final triggered = _reservationService.runReoptimizationCheck();
    if (!triggered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No closer slot currently vacant for re-optimization.'),
          backgroundColor: AppTheme.darkCard,
        ),
      );
      return;
    }

    final res = _reservationService.activeReservation;
    if (res != null && res.upgradeSlotNumber != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => UpgradeOfferDialog(
          currentSlot: res.slotNumber,
          upgradedSlot: res.upgradeSlotNumber!,
          metersSaved: res.metersSaved ?? 35,
          onAccept: () {
            _reservationService.acceptUpgrade();
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upgraded successfully to Slot ${res.upgradeSlotNumber}!'),
                backgroundColor: AppTheme.reoptIndigo,
              ),
            );
          },
          onDecline: () {
            _reservationService.declineUpgrade();
            Navigator.pop(ctx);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeRes = _reservationService.activeReservation;
    final allSlots = _reservationService.slots;

    final filteredSlots = _selectedFilter == null
        ? allSlots
        : allSlots.where((s) => s.supportedType == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_parking_rounded, color: AppTheme.reoptIndigo, size: 24),
            SizedBox(width: 8),
            Text('Dynamic Slot Reservation'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Slot Grid',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Reservation Banner (if present)
            if (activeRes != null && activeRes.state != ReservationState.autoCancelled)
              _buildActiveReservationCard(activeRes),

            if (activeRes != null && activeRes.state == ReservationState.autoCancelled)
              _buildAutoCancelledBanner(),

            const SizedBox(height: 16),

            // Parking Complex Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppConstants.defaultLotName,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CCTV AI Monitored • Automated Bollards',
                              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.availableGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${allSlots.where((s) => s.status == SlotStatus.available).length} FREE',
                          style: const TextStyle(
                            color: AppTheme.availableGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Vehicle Category Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Parking Space',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_selectedFilter != null)
                  TextButton(
                    onPressed: () => setState(() => _selectedFilter = null),
                    child: const Text('Clear Filter', style: TextStyle(color: AppTheme.reoptIndigo, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Vehicles'),
                    selected: _selectedFilter == null,
                    onSelected: (val) => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Car / Sedan'),
                    selected: _selectedFilter == VehicleType.car,
                    onSelected: (val) => setState(() => _selectedFilter = val ? VehicleType.car : null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('SUV / Van'),
                    selected: _selectedFilter == VehicleType.suv,
                    onSelected: (val) => setState(() => _selectedFilter = val ? VehicleType.suv : null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Three-Wheeler (Tuk-Tuk)'),
                    selected: _selectedFilter == VehicleType.threeWheeler,
                    onSelected: (val) => setState(() => _selectedFilter = val ? VehicleType.threeWheeler : null),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slot Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (ctx, index) {
                final slot = filteredSlots[index];
                return _buildSlotCard(slot);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCard(ParkingSlot slot) {
    final bool isAvailable = slot.status == SlotStatus.available;

    return InkWell(
      onTap: isAvailable ? () => _showBookingModal(slot) : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAvailable ? AppTheme.availableGreen.withOpacity(0.4) : AppTheme.darkBorder,
            width: isAvailable ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot.slotNumber,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                StatusBadge(status: slot.status),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${slot.walkingDistanceMeters}m to exit',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot.supportedType == VehicleType.threeWheeler ? 'Three-Wheeler' : slot.supportedType.name.toUpperCase(),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                ),
                if (isAvailable)
                  const Text(
                    'TAP TO HOLD',
                    style: TextStyle(color: AppTheme.availableGreen, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveReservationCard(Reservation res) {
    final bool isPending = res.state == ReservationState.pendingArrival;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.reoptIndigo.withOpacity(0.6), width: 1.5),
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
                    child: const Icon(Icons.directions_car_rounded, color: AppTheme.reoptIndigo, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE RESERVATION',
                        style: TextStyle(color: AppTheme.reoptIndigo, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                      ),
                      Text(
                        'Slot ${res.slotNumber} • ${res.vehicleNumber}',
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              StatusBadge(status: res.state == ReservationState.checkedIn ? SlotStatus.occupied : SlotStatus.reserved),
            ],
          ),
          const SizedBox(height: 14),

          if (isPending) ...[
            CountdownTimerWidget(
              targetTime: res.expiresAt,
              label: '15-Minute Auto-Cancellation TTL',
              onTimerExpired: () {
                _reservationService.autoCancelExpiredReservation();
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Test 10m AI Upgrade',
                    icon: Icons.auto_awesome,
                    backgroundColor: AppTheme.reoptIndigo,
                    onPressed: _triggerSimulatedUpgrade,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Check In (Arrived)',
                    icon: Icons.login_rounded,
                    backgroundColor: AppTheme.availableGreen,
                    onPressed: () {
                      _reservationService.checkIn();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checked in! Smart barrier lowered, fee clock started.'),
                          backgroundColor: AppTheme.availableGreen,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else if (res.state == ReservationState.checkedIn) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.availableGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.availableGreen, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vehicle parked in Slot. Barrier verified by IoT sensor. Billing timer active.',
                      style: TextStyle(color: AppTheme.availableGreen, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _reservationService.cancelActiveReservation(),
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.occupiedRed, size: 16),
              label: const Text('Release / Cancel Booking', style: TextStyle(color: AppTheme.occupiedRed, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCancelledBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.occupiedRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.occupiedRed.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_off_rounded, color: AppTheme.occupiedRed, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Auto-Cancelled (No-Show)',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'The 15-minute window expired without check-in. The slot was recycled back to the pool to prevent space hoarding.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
            onPressed: () => _reservationService.cancelActiveReservation(),
          ),
        ],
      ),
    );
  }
}
