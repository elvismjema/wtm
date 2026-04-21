import 'package:flutter/material.dart';

class HotspotMarker extends StatefulWidget {
  const HotspotMarker({
    super.key,
    required this.color,
    this.onTap,
    this.isSelected = false,
  });

  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  State<HotspotMarker> createState() => _HotspotMarkerState();
}

class _HotspotMarkerState extends State<HotspotMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = 1 + (_controller.value * 0.5);
          final glowOpacity = widget.isSelected ? 0.45 : 0.26;

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: glowOpacity),
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.8),
                      blurRadius: widget.isSelected ? 16 : 10,
                      spreadRadius: widget.isSelected ? 3 : 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
