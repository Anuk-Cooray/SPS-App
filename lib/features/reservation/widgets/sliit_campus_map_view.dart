import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';

enum MapDisplayMode {
  sliitCampus,
  colomboCity,
}

class SliitCampusMapView extends StatefulWidget {
  final MapDisplayMode mode;
  final Function(MapDisplayMode) onModeChanged;
  final Function(String lotName, int availableCount) onLotTapped;

  const SliitCampusMapView({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onLotTapped,
  });

  @override
  State<SliitCampusMapView> createState() => _SliitCampusMapViewState();
}

class _SliitCampusMapViewState extends State<SliitCampusMapView> {
  late final MapController _mapController;
  bool _isSatellite = false;

  // Real Geographic Coordinates
  static const LatLng _sliitCoordinates = LatLng(6.9147, 79.9733); // SLIIT Malabe Campus
  static const LatLng _colomboCoordinates = LatLng(6.9175, 79.8597); // Colombo City Centre

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant SliitCampusMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      if (widget.mode == MapDisplayMode.sliitCampus) {
        _mapController.move(_sliitCoordinates, 16.5);
      } else {
        _mapController.move(_colomboCoordinates, 15.5);
      }
    }
  }

  String get _tileUrl {
    if (_isSatellite) {
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
    return 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_outlined, color: AppTheme.pureBlack, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Map & Region Settings',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppTheme.borderSubtle, height: 20),

              // Section 1: Target Location / Campus
              const Text(
                'TARGET REGION',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),

              // SLIIT Malabe Option
              InkWell(
                onTap: () {
                  widget.onModeChanged(MapDisplayMode.sliitCampus);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.mode == MapDisplayMode.sliitCampus ? AppTheme.backgroundLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.mode == MapDisplayMode.sliitCampus ? AppTheme.pureBlack : AppTheme.borderSubtle,
                      width: widget.mode == MapDisplayMode.sliitCampus ? 2 : 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text('🎓', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SLIIT Malabe Campus', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            Text('Faculty of Computing & Engineering (New Kandy Rd)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: AppTheme.availableGreen, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Colombo City Option
              InkWell(
                onTap: () {
                  widget.onModeChanged(MapDisplayMode.colomboCity);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.mode == MapDisplayMode.colomboCity ? AppTheme.backgroundLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.mode == MapDisplayMode.colomboCity ? AppTheme.pureBlack : AppTheme.borderSubtle,
                      width: widget.mode == MapDisplayMode.colomboCity ? 2 : 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text('🏙️', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Colombo City Hub', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            Text('Colombo City Centre & Galle Road', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: Map Style (Streets vs Satellite)
              const Text(
                'MAP STYLE',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isSatellite = false);
                        setModalState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isSatellite ? AppTheme.pureBlack : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: !_isSatellite ? AppTheme.pureBlack : AppTheme.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🗺️ Streets',
                          style: TextStyle(
                            color: !_isSatellite ? Colors.white : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isSatellite = true);
                        setModalState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSatellite ? AppTheme.pureBlack : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isSatellite ? AppTheme.pureBlack : AppTheme.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🛰️ Satellite',
                          style: TextStyle(
                            color: _isSatellite ? Colors.white : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Project attribution
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.textMuted, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'SLIIT Research Project (IT4010) • J26-IT-335\nSupervised by Dr. Mahesh Liyanwatte',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.mode == MapDisplayMode.sliitCampus ? _sliitCoordinates : _colomboCoordinates;
    final initialZoom = widget.mode == MapDisplayMode.sliitCampus ? 16.5 : 15.5;

    return Stack(
      children: [
        // 1. Real Geographic Map (flutter_map)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: initialZoom,
            minZoom: 12,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.sps.smart_parking_app',
            ),

            // Real Smart Parking Location Pins
            MarkerLayer(
              markers: [
                // SLIIT FOC Smart Lot
                Marker(
                  point: const LatLng(6.9142, 79.9729),
                  width: 140,
                  height: 48,
                  child: GestureDetector(
                    onTap: () => widget.onLotTapped('Faculty of Computing (FOC) Lot - A02', 14),
                    child: _buildPinCard('FOC SMART LOT', '14 Open', AppTheme.availableGreen),
                  ),
                ),

                // SLIIT Engineering Lot
                Marker(
                  point: const LatLng(6.9135, 79.9745),
                  width: 130,
                  height: 48,
                  child: GestureDetector(
                    onTap: () => widget.onLotTapped('Engineering Complex Lot - E04', 8),
                    child: _buildPinCard('ENG LOT (E1)', '8 Open', AppTheme.availableGreen),
                  ),
                ),

                // Colombo City Centre Pin
                Marker(
                  point: const LatLng(6.9175, 79.8597),
                  width: 130,
                  height: 48,
                  child: GestureDetector(
                    onTap: () => widget.onLotTapped('Colombo City Centre (CCC) Level B1', 18),
                    child: _buildPinCard('CCC LOT B1', '18 Open', AppTheme.availableGreen),
                  ),
                ),

                // One Galle Face Pin
                Marker(
                  point: const LatLng(6.9244, 79.8453),
                  width: 130,
                  height: 48,
                  child: GestureDetector(
                    onTap: () => widget.onLotTapped('One Galle Face (OGF) Multi-Tier', 24),
                    child: _buildPinCard('OGF TOWER', '24 Open', AppTheme.availableGreen),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 2. Floating Circular Settings Button (Clean Uber Style)
        Positioned(
          top: 105,
          right: 16,
          child: GestureDetector(
            onTap: _showSettingsModal,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 3)),
                ],
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: const Icon(Icons.settings_outlined, color: AppTheme.pureBlack, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCard(String title, String openText, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8),
              ),
              Text(
                openText,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
