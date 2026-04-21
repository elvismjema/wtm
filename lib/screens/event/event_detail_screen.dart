import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app.dart';
import '../../state/event_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final event = store.byId(eventId);

    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    final isJoined = store.isJoined(event.id);
    final isSaved = store.isSaved(event.id);

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              56,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  event.color.withValues(alpha: 0.95),
                  event.color.withValues(alpha: 0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(formatLongDateTime(event.dateTime)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(event.locationName),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${event.attendeeCount} attendees'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Host: ${event.hostName}'),
                  const SizedBox(height: AppSpacing.xl),
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    event.description,
                    style: const TextStyle(
                      height: 1.4,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isJoined
                            ? AppColors.primary
                            : AppColors.accent,
                        foregroundColor: isJoined ? Colors.black : Colors.white,
                      ),
                      onPressed: () => store.toggleJoined(event.id),
                      child: Text(isJoined ? 'Joined!' : 'Join'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => store.toggleSaved(event.id),
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                          label: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Check out ${event.title} at ${event.locationName} on ${formatLongDateTime(event.dateTime)}',
                              ),
                            );
                          },
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.story,
                        arguments: EventRouteArgs(eventId: event.id),
                      ),
                      child: const Text('View Story'),
                    ),
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
