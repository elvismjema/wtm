import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../services/auth_service.dart';
import '../../state/event_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/profile_menu_tile.dart';
import '../../widgets/profile/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.signOut();
      // AuthGate rebuilds automatically — no manual navigation needed.
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not sign out. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();
    final profileName =
        (displayName != null && displayName.isNotEmpty) ? displayName : email ?? 'User';
    final profileSubtitle = email ?? '';

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
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.hotspotCyan, AppColors.hotspotPink],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person_outline_rounded, size: 30),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(profileSubtitle),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  StatCard(
                    icon: Icons.edit_calendar_outlined,
                    value: store.createdCount,
                    label: 'Created',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatCard(
                    icon: Icons.check_circle_outline_rounded,
                    value: store.joinedCount,
                    label: 'Joined',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatCard(
                    icon: Icons.bookmark_outline,
                    value: store.savedCount,
                    label: 'Saved',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileMenuTile(
                icon: Icons.event_note_outlined,
                title: 'My Events',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.myEvents),
              ),
              const SizedBox(height: AppSpacing.sm),
              ProfileMenuTile(
                icon: Icons.check_circle_outline_rounded,
                title: 'Joined Events',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.joined),
              ),
              const SizedBox(height: AppSpacing.sm),
              ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
