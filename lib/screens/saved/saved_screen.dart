import 'package:flutter/material.dart';

import '../../data/demo_events.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/compact_event_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved Events',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              CompactEventCard(event: demoEvents[2]),
              const SizedBox(height: AppSpacing.sm),
              CompactEventCard(event: demoEvents[5]),
            ],
          ),
        ),
      ),
    );
  }
}
