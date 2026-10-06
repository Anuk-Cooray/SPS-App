import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/parking_slot.dart';
import '../../../core/models/reservation.dart';

/// Service managing the Dynamic Slot Re-optimization and Reservation Model
/// Sub-Objective Owner: Cooray T.C.M.G.A.I (IT23328020)
class ReservationService extends ChangeNotifier {
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;

  ReservationService._internal() {
    _initMockSlots();
  }

  final List<ParkingSlot> _slots = [];
  Reservation? _activeReservation;
  Timer? _autoCancelTimer;
  Timer? _reoptTimer;

  List<ParkingSlot> get slots => List.unmodifiable(_slots);
  Reservation? get activeReservation => _activeReservation;

  void _initMockSlots() {
    _slots.addAll([
      // Section A: Close to Main Exit (10m - 25m)
      const ParkingSlot(id: 's-a01', slotNumber: 'A-01', section: 'A', walkingDistanceMeters: 10, supportedType: VehicleType.car, status: SlotStatus.occupied),
      const ParkingSlot(id: 's-a02', slotNumber: 'A-02', section: 'A', walkingDistanceMeters: 15, supportedType: VehicleType.car, status: SlotStatus.available, isNearElevator: true),
      const ParkingSlot(id: 's-a03', slotNumber: 'A-03', section: 'A', walkingDistanceMeters: 20, supportedType: VehicleType.threeWheeler, status: SlotStatus.available),
      const ParkingSlot(id: 's-a04', slotNumber: 'A-04', section: 'A', walkingDistanceMeters: 25, supportedType: VehicleType.car, status: SlotStatus.available),

      // Section B: Mid-range (35m - 60m)
      const ParkingSlot(id: 's-b01', slotNumber: 'B-01', section: 'B', walkingDistanceMeters: 40, supportedType: VehicleType.car, status: SlotStatus.available),
      const ParkingSlot(id: 's-b02', slotNumber: 'B-02', section: 'B', walkingDistanceMeters: 45, supportedType: VehicleType.suv, status: SlotStatus.occupied),
      const ParkingSlot(id: 's-b03', slotNumber: 'B-03', section: 'B', walkingDistanceMeters: 55, supportedType: VehicleType.car, status: SlotStatus.available),
      const ParkingSlot(id: 's-b04', slotNumber: 'B-04', section: 'B', walkingDistanceMeters: 60, supportedType: VehicleType.threeWheeler, status: SlotStatus.available),

      // Section C: Outer Periphery (75m - 120m)
      const ParkingSlot(id: 's-c01', slotNumber: 'C-01', section: 'C', walkingDistanceMeters: 80, supportedType: VehicleType.car, status: SlotStatus.available),
      const ParkingSlot(id: 's-c02', slotNumber: 'C-02', section: 'C', walkingDistanceMeters: 90, supportedType: VehicleType.car, status: SlotStatus.occupied),
      const ParkingSlot(id: 's-c03', slotNumber: 'C-03', section: 'C', walkingDistanceMeters: 105, supportedType: VehicleType.suv, status: SlotStatus.available),
      const ParkingSlot(id: 's-c04', slotNumber: 'C-04', section: 'C', walkingDistanceMeters: 120, supportedType: VehicleType.car, status: SlotStatus.available),
    ]);
  }

  /// Reserve an initial slot (Starts 15-minute countdown timer)
  bool bookSlot({
    required String slotId,
    required String vehicleNumber,
    required VehicleType vehicleType,
    int estimatedArrivalMinutes = 15,
  }) {
    final slotIndex = _slots.indexWhere((s) => s.id == slotId);
    if (slotIndex == -1 || _slots[slotIndex].status != SlotStatus.available) {
      return false;
    }

    final chosenSlot = _slots[slotIndex];
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: AppConstants.autoCancellationMinutes));
    final arrivalTime = now.add(Duration(minutes: estimatedArrivalMinutes));

    _slots[slotIndex] = chosenSlot.copyWith(status: SlotStatus.reserved);

    _activeReservation = Reservation(
      id: 'res-${now.millisecondsSinceEpoch}',
      slotId: chosenSlot.id,
      slotNumber: chosenSlot.slotNumber,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      bookedAt: now,
      expiresAt: expiresAt,
      estimatedArrival: arrivalTime,
      state: ReservationState.pendingArrival,
    );

    // Start 15-minute auto cancellation countdown timer
    _autoCancelTimer?.cancel();
    _autoCancelTimer = Timer(const Duration(minutes: AppConstants.autoCancellationMinutes), () {
      autoCancelExpiredReservation();
    });

    notifyListeners();
    return true;
  }

  /// 15-Minute Auto-Cancellation Logic: Automatically release unutilized hoarded bookings
  void autoCancelExpiredReservation() {
    if (_activeReservation == null || _activeReservation!.state == ReservationState.checkedIn) {
      return;
    }

    final slotIndex = _slots.indexWhere((s) => s.id == _activeReservation!.slotId);
    if (slotIndex != -1) {
      _slots[slotIndex] = _slots[slotIndex].copyWith(status: SlotStatus.available);
    }

    _activeReservation = _activeReservation!.copyWith(
      state: ReservationState.autoCancelled,
    );
    _autoCancelTimer?.cancel();
    _reoptTimer?.cancel();

    notifyListeners();
  }

  /// AI-Based Pre-Arrival Re-Optimization Check (Evaluated during final 10 mins before arrival)
  /// Looks for closer / superior vacant slots (e.g. from early departures or cancelled bookings)
  bool runReoptimizationCheck() {
    if (_activeReservation == null || _activeReservation!.state != ReservationState.pendingArrival) {
      return false;
    }

    final currentSlot = _slots.firstWhere((s) => s.id == _activeReservation!.slotId);

    // Find available slots with shorter walking distance to exit
    final betterSlots = _slots.where((s) =>
        s.status == SlotStatus.available &&
        s.supportedType == _activeReservation!.vehicleType &&
        s.walkingDistanceMeters < currentSlot.walkingDistanceMeters).toList();

    if (betterSlots.isEmpty) {
      return false;
    }

    // Sort by shortest walking distance to exit
    betterSlots.sort((a, b) => a.walkingDistanceMeters.compareTo(b.walkingDistanceMeters));
    final bestCandidate = betterSlots.first;
    final metersSaved = currentSlot.walkingDistanceMeters - bestCandidate.walkingDistanceMeters;

    _activeReservation = _activeReservation!.copyWith(
      state: ReservationState.reoptimizing,
      upgradeSlotId: bestCandidate.id,
      upgradeSlotNumber: bestCandidate.slotNumber,
      metersSaved: metersSaved,
    );

    notifyListeners();
    return true;
  }

  /// Driver accepts proposed AI upgrade
  void acceptUpgrade() {
    if (_activeReservation == null || _activeReservation!.upgradeSlotId == null) return;

    final oldSlotIndex = _slots.indexWhere((s) => s.id == _activeReservation!.slotId);
    final newSlotIndex = _slots.indexWhere((s) => s.id == _activeReservation!.upgradeSlotId);

    if (oldSlotIndex != -1) {
      // Release old slot back to public pool
      _slots[oldSlotIndex] = _slots[oldSlotIndex].copyWith(status: SlotStatus.available);
    }

    if (newSlotIndex != -1) {
      // Hold newly assigned upgraded slot
      _slots[newSlotIndex] = _slots[newSlotIndex].copyWith(status: SlotStatus.reserved);
    }

    _activeReservation = _activeReservation!.copyWith(
      slotId: _activeReservation!.upgradeSlotId,
      slotNumber: _activeReservation!.upgradeSlotNumber,
      state: ReservationState.pendingArrival,
      upgradeSlotId: null,
      upgradeSlotNumber: null,
    );

    notifyListeners();
  }

  /// Driver rejects upgrade; original slot is safely retained
  void declineUpgrade() {
    if (_activeReservation == null) return;

    _activeReservation = _activeReservation!.copyWith(
      state: ReservationState.pendingArrival,
      upgradeSlotId: null,
      upgradeSlotNumber: null,
    );

    notifyListeners();
  }

  /// Driver arrives and checks in (stops auto-cancellation, starts occupancy)
  void checkIn() {
    if (_activeReservation == null) return;

    final slotIndex = _slots.indexWhere((s) => s.id == _activeReservation!.slotId);
    if (slotIndex != -1) {
      _slots[slotIndex] = _slots[slotIndex].copyWith(status: SlotStatus.occupied);
    }

    _activeReservation = _activeReservation!.copyWith(
      state: ReservationState.checkedIn,
    );
    _autoCancelTimer?.cancel();
    notifyListeners();
  }

  void cancelActiveReservation() {
    if (_activeReservation == null) return;

    final slotIndex = _slots.indexWhere((s) => s.id == _activeReservation!.slotId);
    if (slotIndex != -1) {
      _slots[slotIndex] = _slots[slotIndex].copyWith(status: SlotStatus.available);
    }

    _activeReservation = null;
    _autoCancelTimer?.cancel();
    _reoptTimer?.cancel();
    notifyListeners();
  }
}
