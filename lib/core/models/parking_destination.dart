class ParkingDestination {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int totalAvailableSpots;
  final String primaryLotName;
  final String hourlyRate;
  final bool isSLIIT;

  const ParkingDestination({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalAvailableSpots,
    required this.primaryLotName,
    required this.hourlyRate,
    this.isSLIIT = false,
  });

  static List<ParkingDestination> get popularDestinations => const [
    ParkingDestination(
      id: 'dest-sliit',
      name: 'Sri Lanka Institute of Information Technology',
      address: 'SLIIT Malabe Campus, New Kandy Rd, Malabe',
      latitude: 6.9147,
      longitude: 79.9733,
      totalAvailableSpots: 22,
      primaryLotName: 'Faculty of Computing (FOC) Smart Lot',
      hourlyRate: 'Free (Student/Staff)',
      isSLIIT: true,
    ),
    ParkingDestination(
      id: 'dest-sjh',
      name: 'Sri Jayewardenepura General Hospital',
      address: 'Hospital Rd, Sri Jayewardenepura Kotte',
      latitude: 6.8649,
      longitude: 79.9192,
      totalAvailableSpots: 12,
      primaryLotName: 'SJH Outpatient & Visitor Parking',
      hourlyRate: 'LKR 100/h',
    ),
    ParkingDestination(
      id: 'dest-ccc',
      name: 'Colombo City Centre (CCC)',
      address: 'Sir James Pieris Mawatha, Colombo 02',
      latitude: 6.9175,
      longitude: 79.8597,
      totalAvailableSpots: 18,
      primaryLotName: 'CCC Basement Level B1',
      hourlyRate: 'LKR 150/h',
    ),
    ParkingDestination(
      id: 'dest-ogf',
      name: 'One Galle Face Mall & Tower',
      address: 'Galle Road, Colombo 01',
      latitude: 6.9244,
      longitude: 79.8453,
      totalAvailableSpots: 24,
      primaryLotName: 'OGF Multi-Tier Car Park',
      hourlyRate: 'LKR 200/h',
    ),
  ];
}
