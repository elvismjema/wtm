import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
            children: [
              Container(
                decoration: AppTheme.glassCardDecoration(radius: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.mutedText),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Search events, categories, places...',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
