import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app.dart';
import '../../state/event_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map/event_preview_sheet.dart';
import '../../widgets/map/hotspot_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedEventId;
  late final AnimationController _userPulse;

  @override
  void initState() {
    super.initState();
    _userPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _userPulse.dispose();
    super.dispose();
  }

  void _openPreview(String eventId) {
    final store = EventStoreProvider.of(context);
    final event = store.byId(eventId);
    if (event == null) {
      return;
    }

    setState(() {
      _selectedEventId = eventId;
    });

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return EventPreviewSheet(
          event: event,
          onClose: () => Navigator.of(context).pop(),
          onViewStory: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRoutes.story,
              arguments: EventRouteArgs(eventId: event.id),
            );
          },
          onViewDetails: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRoutes.eventDetail,
              arguments: EventRouteArgs(eventId: event.id),
            );
          },
        );
      },
    ).whenComplete(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedEventId = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final events = store.events;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(41.8818, -87.6231),
              initialZoom: 13.7,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.whats_the_move',
              ),
              MarkerLayer(
                markers: [
                  for (final event in events)
                    Marker(
                      point: LatLng(event.latitude, event.longitude),
                      width: 56,
                      height: 56,
                      child: HotspotMarker(
                        color: event.color,
                        isSelected: event.id == _selectedEventId,
                        onTap: () => _openPreview(event.id),
                      ),
                    ),
                  Marker(
                    point: const LatLng(41.8818, -87.6231),
                    width: 52,
                    height: 52,
                    child: AnimatedBuilder(
                      animation: _userPulse,
                      builder: (context, _) {
                        final scale = 1 + (_userPulse.value * 0.5);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.hotspotCyan.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.hotspotCyan,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.hotspotCyan.withValues(
                                      alpha: 0.8,
                                    ),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: GestureDetector(
                onTap: widget.onOpenSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: AppTheme.glassCardDecoration(radius: 14),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.mutedText),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Search events, vibes, or places',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
