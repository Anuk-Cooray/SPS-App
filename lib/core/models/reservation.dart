import '../constants/app_constants.dart';

enum ReservationState {
  pendingArrival, // Under 15-minute countdown
  reoptimizing,   // 10-minute AI pre-arrival window active
  checkedIn,      // Arrived at lot / barrier lowered
  completed,      // Paid and exited
  autoCancelled,  // 15-minute TTL elapsed without check-in
  cancelledByDriver,
}

class Reservation {
  final String id;
  final String slotId;
  final String slotNumber;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final DateTime bookedAt;
  final DateTime expiresAt; // bookedAt + 15 minutes
  final DateTime estimatedArrival; // ETA from driver GPS
  final ReservationState state;
  final String? upgradeSlotId; // Suggested closer slot if re-optimization triggers
  final String? upgradeSlotNumber;
  final int? metersSaved;

  const Reservation({
    required this.id,
    required this.slotId,
    required this.slotNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.bookedAt,
    required this.expiresAt,
    required this.estimatedArrival,
    required this.state,
    this.upgradeSlotId,
    this.upgradeSlotNumber,
    this.metersSaved,
  });

  Reservation copyWith({
    String? id,
    String? slotId,
    String? slotNumber,
    String? vehicleNumber,
    VehicleType? vehicleType,
    DateTime? bookedAt,
    DateTime? expiresAt,
    DateTime? estimatedArrival,
    ReservationState? state,
    String? upgradeSlotId,
    String? upgradeSlotNumber,
    int? metersSaved,
  }) {
    return Reservation(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      slotNumber: slotNumber ?? this.slotNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      bookedAt: bookedAt ?? this.bookedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      state: state ?? this.state,
      upgradeSlotId: upgradeSlotId ?? this.upgradeSlotId,
      upgradeSlotNumber: upgradeSlotNumber ?? this.upgradeSlotNumber,
      metersSaved: metersSaved ?? this.metersSaved,
    );
  }
}
