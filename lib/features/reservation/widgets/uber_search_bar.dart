import 'package:flutter/material.dart';
import '../../../core/models/parking_destination.dart';
import '../../../core/theme/app_theme.dart';

class UberSearchBar extends StatefulWidget {
  final Function(ParkingDestination) onDestinationSelected;
  final String currentQuery;

  const UberSearchBar({
    super.key,
    required this.onDestinationSelected,
    this.currentQuery = '',
  });

  @override
  State<UberSearchBar> createState() => _UberSearchBarState();
}

class _UberSearchBarState extends State<UberSearchBar> {
  late TextEditingController _controller;
  bool _isDropdownOpen = false;
  List<ParkingDestination> _filteredDestinations = ParkingDestination.popularDestinations;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isDropdownOpen = true;
      if (query.isEmpty) {
        _filteredDestinations = ParkingDestination.popularDestinations;
      } else {
        final q = query.toLowerCase();
        _filteredDestinations = ParkingDestination.popularDestinations.where((d) =>
            d.name.toLowerCase().contains(q) || d.address.toLowerCase().contains(q)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Uber Search Capsule (From Screenshot 2)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppTheme.pureBlack, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  onTap: () => setState(() => _isDropdownOpen = true),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Looking to park?',
                    hintStyle: TextStyle(
                      color: AppTheme.pureBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // "Now" Capsule Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.pureBlack),
                    SizedBox(width: 6),
                    Text(
                      'Now',
                      style: TextStyle(
                        color: AppTheme.pureBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Uber Recent Destinations Card (From Screenshot 2)
        if (_isDropdownOpen) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredDestinations.length,
                separatorBuilder: (ctx, i) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (ctx, i) {
                  final dest = _filteredDestinations[i];
                  return InkWell(
                    onTap: () {
                      _controller.text = dest.name;
                      setState(() => _isDropdownOpen = false);
                      widget.onDestinationSelected(dest);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.access_time_filled, color: AppTheme.textSecondary, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dest.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dest.address,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
