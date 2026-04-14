import 'package:flutter/material.dart';

class HotspotMarker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final glowSize = isSelected ? 96.0 : 86.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: glowSize,
        height: glowSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: glowSize,
              height: glowSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.20),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.65),
                    blurRadius: 14,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
