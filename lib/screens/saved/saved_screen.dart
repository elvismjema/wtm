import 'package:flutter/material.dart';

import '../../app.dart';
import '../../state/event_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/compact_event_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, this.onExploreMap});

  final VoidCallback? onExploreMap;

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final savedEvents = store.savedEvents;

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
              Row(
                children: [
                  const Icon(Icons.bookmark_rounded),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Saved Events',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Text('${savedEvents.length}'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (savedEvents.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_border_rounded, size: 48),
                        const SizedBox(height: AppSpacing.sm),
                        const Text('No saved events yet'),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: onExploreMap,
                          child: const Text('Explore the map'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: savedEvents.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final event = savedEvents[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.eventDetail,
                          arguments: EventRouteArgs(eventId: event.id),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: CompactEventCard(event: event),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
