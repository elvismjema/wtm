import 'package:flutter/material.dart';

import '../../app.dart';
import '../../state/event_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/compact_event_card.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final createdEvents = store.createdEvents;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('My Events'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: createdEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_note_outlined, size: 48),
                      const SizedBox(height: AppSpacing.sm),
                      const Text("You haven't created any events yet"),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.create),
                        child: const Text('Create an event'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: createdEvents.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final event = createdEvents[index];
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
