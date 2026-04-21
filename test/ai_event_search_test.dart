import 'package:flutter_test/flutter_test.dart';
import 'package:whats_the_move/data/demo_events.dart';
import 'package:whats_the_move/services/ai_event_search.dart';

void main() {
  test('ranks exact food truck searches first', () {
    final results = AiEventSearch.search(
      events: demoEvents,
      query: 'food trucks',
      mood: 'All',
      distance: 'Any',
      time: 'Any',
      price: 'Any',
      now: DateTime(2026, 4, 24, 12),
    );

    expect(results, isNotEmpty);
    expect(results.first.event.title, 'Food Truck Fest');
  });

  test('uses vibe synonyms for low-key plans', () {
    final results = AiEventSearch.search(
      events: demoEvents,
      query: 'something low-key after class',
      mood: 'All',
      distance: '5mi',
      time: 'Any',
      price: 'Any',
      now: DateTime(2026, 4, 24, 12),
    );

    expect(results.map((result) => result.event.category), contains('Chill'));
  });
}
