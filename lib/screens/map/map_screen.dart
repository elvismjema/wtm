import 'package:flutter/material.dart';

import '../../data/demo_events.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map/event_preview_sheet.dart';
import '../../widgets/map/hotspot_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedEventId;

  void _openEvent(Event event) {
    setState(() {
      _selectedEventId = event.id;
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventPreviewSheet(event: event),
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
    return Scaffold(
      body: Stack(
        children: [
          const _FakeMapBackground(),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    for (final event in demoEvents)
                      Positioned(
                        left: event.mapX * constraints.maxWidth - 44,
                        top: event.mapY * constraints.maxHeight - 44,
                        child: HotspotMarker(
                          color: event.color,
                          isSelected: event.id == _selectedEventId,
                          onTap: () => _openEvent(event),
                        ),
                      ),
                    Positioned(
                      left: constraints.maxWidth * 0.50 - 10,
                      top: constraints.maxHeight * 0.52 - 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.7),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Discover',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeMapBackground extends StatelessWidget {
  const _FakeMapBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF11161D), Color(0xFF0A0E14), Color(0xFF070A0F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
          Positioned(
            left: -120,
            top: -90,
            child: _glowBlob(const Color(0x33176F6B), 280),
          ),
          Positioned(
            right: -90,
            top: 140,
            child: _glowBlob(const Color(0x332D4878), 220),
          ),
          Positioned(
            left: 40,
            bottom: 80,
            child: _glowBlob(const Color(0x333A2B63), 240),
          ),
        ],
      ),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 10)],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final major = Paint()
      ..color = const Color(0xFF1D2532).withValues(alpha: 0.36)
      ..strokeWidth = 1.2;

    final minor = Paint()
      ..color = const Color(0xFF19202D).withValues(alpha: 0.22)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }

    for (double x = 0; x < size.width; x += 108) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (double y = 0; y < size.height; y += 108) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
