import 'package:flutter/material.dart';

import '../../app.dart';
import '../../state/event_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/compact_event_card.dart';

class JoinedScreen extends StatelessWidget {
  const JoinedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final joinedEvents = store.joinedEvents;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('Joined Events'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: joinedEvents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 48),
                      SizedBox(height: AppSpacing.sm),
                      Text("You haven't joined any events yet"),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: joinedEvents.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final event = joinedEvents[index];
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
      ),
    );
  }
}
