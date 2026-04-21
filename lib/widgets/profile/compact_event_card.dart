import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class CompactEventCard extends StatelessWidget {
  const CompactEventCard({super.key, required this.event});

  final Event event;

  String get _formattedDate {
    final dt = event.dateTime;
    final minute = dt.minute.toString().padLeft(2, '0');
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.month}/${dt.day} · $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassCardDecoration(radius: 16),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: event.color.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  event.category,
                  style: TextStyle(
                    color: event.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formattedDate,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.mutedText,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                event.locationName,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
