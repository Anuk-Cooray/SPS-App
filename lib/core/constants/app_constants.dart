/// Application Constants for AI Vision-Based Smart Parking System (SPS)
/// Project ID: J26-IT-335 (SLIIT IT4010 Research Project)
class AppConstants {
  static const String appName = 'SPS Smart Parking';
  static const String appVersion = '1.0.0';

  // Research Configuration Times
  static const int autoCancellationMinutes = 15; // 15-minute TTL auto-cancellation
  static const int reoptimizationWindowMinutes = 10; // 10-minute pre-arrival AI upgrade check
  static const int reoptimizationResponseSeconds = 60; // Driver accept/decline window

  // Pricing Parameters (LKR)
  static const double baseRatePerHour = 150.0;
  static const double peakHourMultiplier = 1.35;

  // Default Parking Lot Details
  static const String defaultLotName = 'Colombo City Mall Complex (Level B1)';
  static const int totalCapacity = 40;
}

enum SlotStatus {
  available, // Free to reserve (Green)
  reserved,  // Held under 15-min countdown (Amber)
  occupied,  // Vehicle parked via CCTV detection (Red)
  upgraded,  // Candidate suggested for AI re-optimization (Indigo/Purple)
  violation, // Multi-slot illegal parking detected (Pulsing Red)
}

enum VehicleType {
  car,
  suv,
  threeWheeler, // Specifically highlighted in research documentation for Sri Lankan context
  motorcycle,
}
