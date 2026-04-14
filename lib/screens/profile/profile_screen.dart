import 'package:flutter/material.dart';

import '../../data/demo_events.dart';
import '../../data/demo_user.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/compact_event_card.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_menu_tile.dart';
import '../../widgets/profile/stat_card.dart';
import '../../widgets/shared/section_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface.withValues(alpha: 0.92),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileHeader(
                name: demoUser.name,
                subtitle: '${demoUser.username} · ${demoUser.school}',
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  StatCard(
                    icon: Icons.edit_calendar_outlined,
                    value: demoUser.createdCount,
                    label: 'Created',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatCard(
                    icon: Icons.location_on_outlined,
                    value: demoUser.attendedCount,
                    label: 'Attended',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatCard(
                    icon: Icons.bookmark_outline,
                    value: demoUser.savedCount,
                    label: 'Saved',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const ProfileMenuTile(
                icon: Icons.event_note_outlined,
                title: 'My Events',
              ),
              const SizedBox(height: AppSpacing.sm),
              const ProfileMenuTile(
                icon: Icons.bookmark_border_rounded,
                title: 'Saved Events',
              ),
              const SizedBox(height: AppSpacing.sm),
              const ProfileMenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
              ),
              const SizedBox(height: AppSpacing.sm),
              const ProfileMenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionTitle(title: 'Your Events'),
              const SizedBox(height: AppSpacing.md),
              CompactEventCard(event: demoEvents[0]),
              const SizedBox(height: AppSpacing.sm),
              CompactEventCard(event: demoEvents[1]),
            ],
          ),
        ),
      ),
    );
  }
}
