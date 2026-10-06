import '../constants/app_constants.dart';

class ParkingSlot {
  final String id;
  final String slotNumber;
  final String section;
  final int walkingDistanceMeters; // Walking distance to main pedestrian mall exit
  final VehicleType supportedType;
  final SlotStatus status;
  final bool isNearElevator;

  const ParkingSlot({
    required this.id,
    required this.slotNumber,
    required this.section,
    required this.walkingDistanceMeters,
    required this.supportedType,
    required this.status,
    this.isNearElevator = false,
  });

  ParkingSlot copyWith({
    String? id,
    String? slotNumber,
    String? section,
    int? walkingDistanceMeters,
    VehicleType? supportedType,
    SlotStatus? status,
    bool? isNearElevator,
  }) {
    return ParkingSlot(
      id: id ?? this.id,
      slotNumber: slotNumber ?? this.slotNumber,
      section: section ?? this.section,
      walkingDistanceMeters: walkingDistanceMeters ?? this.walkingDistanceMeters,
      supportedType: supportedType ?? this.supportedType,
      status: status ?? this.status,
      isNearElevator: isNearElevator ?? this.isNearElevator,
    );
  }
}
