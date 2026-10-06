class ViolationRecord {
  final String id;
  final String slotOccupied;
  final String adjacentSlotEncroached;
  final String detectedVehicleType;
  final DateTime timestamp;
  final double confidenceScore;
  final bool alertAcknowledged;

  const ViolationRecord({
    required this.id,
    required this.slotOccupied,
    required this.adjacentSlotEncroached,
    required this.detectedVehicleType,
    required this.timestamp,
    required this.confidenceScore,
    this.alertAcknowledged = false,
  });
}
