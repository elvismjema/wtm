import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const Spacer(),
                      const Icon(Icons.flash_on_rounded),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.filter_rounded),
                        SizedBox(height: AppSpacing.md),
                        Icon(Icons.music_note_rounded),
                        SizedBox(height: AppSpacing.md),
                        Icon(Icons.text_fields_rounded),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Photo'),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Video',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Story',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.surface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.flip_camera_ios_rounded),
                    ],
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1;

    final thirdsX = size.width / 3;
    final thirdsY = size.height / 3;

    canvas.drawLine(Offset(thirdsX, 0), Offset(thirdsX, size.height), paint);
    canvas.drawLine(
      Offset(thirdsX * 2, 0),
      Offset(thirdsX * 2, size.height),
      paint,
    );
    canvas.drawLine(Offset(0, thirdsY), Offset(size.width, thirdsY), paint);
    canvas.drawLine(
      Offset(0, thirdsY * 2),
      Offset(size.width, thirdsY * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
