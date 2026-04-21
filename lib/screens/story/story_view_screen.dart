import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../state/event_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        return;
      }
      setState(() {
        _index = (_index + 1) % 3;
      });
    });
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % 3;
    });
    _startTimer();
  }

  void _prev() {
    setState(() {
      _index = (_index - 1 + 3) % 3;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final store = EventStoreProvider.of(context);
    final event = store.byId(widget.eventId);

    if (event == null) {
      return const Scaffold(body: Center(child: Text('Story not found')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      event.color.withValues(alpha: 0.6),
                      const Color(0xFF020308),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(child: GestureDetector(onTap: _prev)),
                  Expanded(child: GestureDetector(onTap: _next)),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: List<Widget>.generate(3, (barIndex) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              right: barIndex == 2 ? 0 : AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: barIndex <= _index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(event.locationName),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: AppTheme.glassCardDecoration(
                              radius: 14,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Send message',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.favorite_border_rounded),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.send_rounded),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            AppRoutes.eventDetail,
                            arguments: EventRouteArgs(eventId: event.id),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('View Full Event'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
