import 'package:flutter/material.dart';

import '../../app.dart';
import '../../services/ai_event_search.dart';
import '../../state/event_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/compact_event_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.onBackToMap});

  final VoidCallback? onBackToMap;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _moods = <String>[
    'All',
    'Party',
    'Chill',
    'Clubbing',
    'Food',
    'Sports',
    'Study',
    'Church',
    'Networking',
  ];

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _mood = 'All';
  String _distance = 'Any';
  String _time = 'Any';
  String _price = 'Any';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final results = store.aiSearch(
      query: _controller.text,
      mood: _mood,
      distance: _distance,
      time: _time,
      price: _price,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                        return;
                      }
                      widget.onBackToMap?.call();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.auto_awesome_rounded),
                        hintText: 'Ask for a vibe, plan, or place',
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _controller.clear,
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                scrollDirection: Axis.horizontal,
                itemCount: _moods.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  return ChoiceChip(
                    label: Text(mood),
                    selected: _mood == mood,
                    onSelected: (_) => setState(() => _mood = mood),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Filters'),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Distance',
                          value: _distance,
                          values: const ['Any', '1mi', '5mi', '10mi'],
                          onChanged: (v) => setState(() => _distance = v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Time',
                          value: _time,
                          values: const ['Any', 'Now', 'Tonight', 'Tomorrow'],
                          onChanged: (v) => setState(() => _time = v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Price',
                          value: _price,
                          values: const ['Any', 'Free', 'Paid'],
                          onChanged: (v) => setState(() => _price = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _controller.text.trim().isEmpty && results.isEmpty
                  ? _Suggestions(
                      onTap: (query) {
                        _controller.text = query;
                      },
                    )
                  : _SearchResults(
                      results: results,
                      hasQuery: _controller.text.trim().isNotEmpty,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: values
          .map((entry) => DropdownMenuItem(value: entry, child: Text(entry)))
          .toList(),
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const suggestions = <String>[
      'low-key things near me',
      'free food or snacks',
      'meet people tonight',
      'quiet study spots',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppTheme.glassCardDecoration(radius: 16),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'What are you in the mood for?',
                  style: TextStyle(color: AppColors.foreground),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Suggested searches',
          style: TextStyle(color: AppColors.mutedText),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final suggestion in suggestions)
          ListTile(
            onTap: () => onTap(suggestion),
            title: Text(suggestion),
            trailing: const Icon(Icons.north_west_rounded),
          ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.hasQuery});

  final List<EventSearchResult> results;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('No events match your filters.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 120),
      itemCount: results.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ResultsHeader(count: results.length, hasQuery: hasQuery);
        }
        final result = results[index - 1];
        final event = result.event;
        return InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.eventDetail,
            arguments: EventRouteArgs(eventId: event.id),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _ReasonChip(reason: result.reason),
              ),
              const SizedBox(height: AppSpacing.xs),
              CompactEventCard(event: event),
            ],
          ),
        );
      },
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count, required this.hasQuery});

  final int count;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          hasQuery ? 'AI picks' : 'Recommended for you',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          '$count found',
          style: const TextStyle(color: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              reason,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}
