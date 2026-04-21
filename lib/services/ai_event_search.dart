import '../models/event.dart';

class EventSearchResult {
  const EventSearchResult({
    required this.event,
    required this.score,
    required this.reason,
  });

  final Event event;
  final double score;
  final String reason;
}

class AiEventSearch {
  const AiEventSearch._();

  static List<EventSearchResult> search({
    required List<Event> events,
    required String query,
    required String mood,
    required String distance,
    required String time,
    required String price,
    DateTime? now,
  }) {
    final intent = _SearchIntent.from(query);
    final currentTime = now ?? DateTime.now();
    final filtered = events.where((event) {
      return _matchesMood(event, mood) &&
          _matchesDistance(event, distance) &&
          _matchesTime(event, time, currentTime) &&
          _matchesPrice(event, price);
    });

    final scored = <EventSearchResult>[];
    for (final event in filtered) {
      final score = _score(event, intent, currentTime);
      if (intent.hasQuery && score < 1.5) {
        continue;
      }
      scored.add(
        EventSearchResult(
          event: event,
          score: score,
          reason: _reasonFor(event, intent, currentTime),
        ),
      );
    }

    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return a.event.dateTime.compareTo(b.event.dateTime);
    });

    return scored;
  }

  static bool _matchesMood(Event event, String mood) {
    return mood == 'All' || event.category.toLowerCase() == mood.toLowerCase();
  }

  static bool _matchesDistance(Event event, String distance) {
    if (distance == 'Any') {
      return true;
    }
    final miles = switch (distance) {
      '1mi' => 1.0,
      '5mi' => 5.0,
      '10mi' => 10.0,
      _ => 999.0,
    };
    return event.distanceMiles <= miles;
  }

  static bool _matchesTime(Event event, String time, DateTime now) {
    if (time == 'Any') {
      return true;
    }
    if (time == 'Now') {
      final delta = event.dateTime.difference(now).inHours;
      return delta >= -2 && delta <= 2;
    }
    if (time == 'Tonight') {
      return _isSameDay(event.dateTime, now) && event.dateTime.hour >= 17;
    }
    if (time == 'Tomorrow') {
      return _isSameDay(event.dateTime, now.add(const Duration(days: 1)));
    }
    return true;
  }

  static bool _matchesPrice(Event event, String price) {
    if (price == 'Any') {
      return true;
    }
    final isFree = _isLikelyFree(event);
    return (price == 'Free' && isFree) || (price == 'Paid' && !isFree);
  }

  static double _score(Event event, _SearchIntent intent, DateTime now) {
    var score = 0.0;

    if (!intent.hasQuery) {
      score += 8 - event.distanceMiles.clamp(0, 8);
      score += (event.attendeeCount / 45).clamp(0, 4);
      final hoursAway = event.dateTime.difference(now).inHours;
      if (hoursAway >= 0 && hoursAway <= 72) {
        score += 4 - (hoursAway / 24);
      }
      return score;
    }

    final searchableText =
        '${event.title} ${event.category} ${event.description} '
                '${event.locationName} ${event.hostName}'
            .toLowerCase();

    if (searchableText.contains(intent.normalizedQuery)) {
      score += 9;
    }

    for (final term in intent.terms) {
      if (searchableText.contains(term)) {
        score += 2.4;
      }
    }

    if (intent.categories.contains(event.category.toLowerCase())) {
      score += 7;
    }

    for (final vibe in intent.vibes) {
      if (_eventVibes(event).contains(vibe)) {
        score += 3.2;
      }
    }

    if (intent.wantsFree && _isLikelyFree(event)) {
      score += 5;
    }
    if (intent.wantsFood && _eventVibes(event).contains('food')) {
      score += 4;
    }
    if (intent.wantsPopular) {
      score += (event.attendeeCount / 35).clamp(0, 5);
    }
    if (intent.wantsNearby) {
      score += (6 - event.distanceMiles).clamp(0, 6);
    }

    score += switch (intent.daypart) {
      _Daypart.any => 0,
      _Daypart.morning => event.dateTime.hour < 12 ? 3.5 : -1.5,
      _Daypart.afternoon =>
        event.dateTime.hour >= 12 && event.dateTime.hour < 17 ? 3.5 : -1.5,
      _Daypart.evening =>
        event.dateTime.hour >= 17 && event.dateTime.hour < 22 ? 3.5 : -1.5,
      _Daypart.lateNight => event.dateTime.hour >= 21 ? 3.5 : -1.5,
    };

    if (intent.wantsSoon) {
      final hoursAway = event.dateTime.difference(now).inHours;
      if (hoursAway >= -2 && hoursAway <= 8) {
        score += 4;
      } else if (hoursAway > 8 && hoursAway <= 36) {
        score += 2;
      }
    }

    score += (3 - event.distanceMiles).clamp(0, 3) * 0.35;
    return score;
  }

  static String _reasonFor(Event event, _SearchIntent intent, DateTime now) {
    if (!intent.hasQuery) {
      if (event.distanceMiles <= 1) {
        return 'Nearby pick';
      }
      if (event.attendeeCount >= 100) {
        return 'Popular tonight';
      }
      return 'Recommended';
    }

    if (intent.categories.contains(event.category.toLowerCase())) {
      return 'Matches ${event.category.toLowerCase()} vibe';
    }
    if (intent.wantsFree && _isLikelyFree(event)) {
      return 'Likely free';
    }
    if (intent.wantsNearby && event.distanceMiles <= 2) {
      return 'Close by';
    }
    if (intent.wantsSoon &&
        event.dateTime.difference(now).inHours >= -2 &&
        event.dateTime.difference(now).inHours <= 36) {
      return 'Happening soon';
    }
    for (final vibe in intent.vibes) {
      if (_eventVibes(event).contains(vibe)) {
        return 'Good ${vibe.replaceAll('-', ' ')} match';
      }
    }
    return 'AI match';
  }

  static Set<String> _eventVibes(Event event) {
    final text = '${event.title} ${event.category} ${event.description}'
        .toLowerCase();
    final vibes = <String>{event.category.toLowerCase()};

    void addIf(String vibe, List<String> words) {
      if (words.any(text.contains)) {
        vibes.add(vibe);
      }
    }

    addIf('food', ['food', 'coffee', 'snack', 'bites', 'truck']);
    addIf('low-key', ['quiet', 'casual', 'chill', 'blankets', 'yoga']);
    addIf('social', ['mixer', 'party', 'games', 'hangout', 'watch party']);
    addIf('career', ['startup', 'founders', 'resume', 'career', 'builders']);
    addIf('music', ['dj', 'music', 'open mic', 'poetry', 'acoustic']);
    addIf('active', ['soccer', 'basketball', 'run', 'yoga', '5k']);
    addIf('faith', ['worship', 'prayer', 'church']);

    return vibes;
  }

  static bool _isLikelyFree(Event event) {
    final text = '${event.category} ${event.description}'.toLowerCase();
    return event.category == 'Study' ||
        event.category == 'Church' ||
        text.contains('free') ||
        text.contains('open ');
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _SearchIntent {
  const _SearchIntent({
    required this.normalizedQuery,
    required this.terms,
    required this.categories,
    required this.vibes,
    required this.wantsNearby,
    required this.wantsSoon,
    required this.wantsFree,
    required this.wantsFood,
    required this.wantsPopular,
    required this.daypart,
  });

  final String normalizedQuery;
  final Set<String> terms;
  final Set<String> categories;
  final Set<String> vibes;
  final bool wantsNearby;
  final bool wantsSoon;
  final bool wantsFree;
  final bool wantsFood;
  final bool wantsPopular;
  final _Daypart daypart;

  bool get hasQuery => normalizedQuery.isNotEmpty;

  factory _SearchIntent.from(String query) {
    final normalized = query.trim().toLowerCase();
    final terms = normalized
        .split(RegExp(r'[^a-z0-9]+'))
        .where((term) => term.length > 2)
        .where((term) => !_stopWords.contains(term))
        .toSet();
    final categories = <String>{};
    final vibes = <String>{};

    void matchCategory(String category, List<String> words) {
      if (words.any(normalized.contains)) {
        categories.add(category);
      }
    }

    void matchVibe(String vibe, List<String> words) {
      if (words.any(normalized.contains)) {
        vibes.add(vibe);
      }
    }

    matchCategory('party', ['party', 'pregame', 'rooftop']);
    matchCategory('clubbing', ['club', 'clubbing', 'dj', 'dance', 'late']);
    matchCategory('chill', ['chill', 'low key', 'low-key', 'relax', 'movie']);
    matchCategory('food', ['food', 'eat', 'dinner', 'lunch', 'bites']);
    matchCategory('sports', ['sport', 'game', 'soccer', 'basketball', 'run']);
    matchCategory('study', ['study', 'homework', 'exam', 'quiet', 'library']);
    matchCategory('church', ['church', 'worship', 'prayer', 'faith']);
    matchCategory('networking', ['network', 'career', 'startup', 'founder']);

    matchVibe('food', ['food', 'eat', 'coffee', 'snack', 'bites']);
    matchVibe('low-key', ['chill', 'low key', 'low-key', 'quiet', 'relax']);
    matchVibe('social', ['meet people', 'friends', 'hang', 'social']);
    matchVibe('career', ['career', 'resume', 'founder', 'startup', 'network']);
    matchVibe('music', ['music', 'dj', 'open mic', 'poetry', 'acoustic']);
    matchVibe('active', ['workout', 'run', 'soccer', 'basketball', 'yoga']);
    matchVibe('faith', ['church', 'worship', 'prayer', 'faith']);

    return _SearchIntent(
      normalizedQuery: normalized,
      terms: terms,
      categories: categories,
      vibes: vibes,
      wantsNearby: _containsAny(normalized, ['near', 'nearby', 'close']),
      wantsSoon: _containsAny(normalized, ['now', 'soon', 'tonight', 'today']),
      wantsFree: _containsAny(normalized, ['free', 'cheap', 'no cost']),
      wantsFood: _containsAny(normalized, ['food', 'eat', 'snack', 'bites']),
      wantsPopular: _containsAny(normalized, ['popular', 'busy', 'crowd']),
      daypart: _daypartFor(normalized),
    );
  }

  static bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }

  static _Daypart _daypartFor(String text) {
    if (_containsAny(text, ['morning', 'breakfast', 'sunrise'])) {
      return _Daypart.morning;
    }
    if (_containsAny(text, ['afternoon', 'lunch'])) {
      return _Daypart.afternoon;
    }
    if (_containsAny(text, ['evening', 'tonight', 'dinner', 'sunset'])) {
      return _Daypart.evening;
    }
    if (_containsAny(text, ['late', 'after dark', 'midnight'])) {
      return _Daypart.lateNight;
    }
    return _Daypart.any;
  }
}

enum _Daypart { any, morning, afternoon, evening, lateNight }

const _stopWords = <String>{
  'the',
  'and',
  'for',
  'with',
  'near',
  'tonight',
  'today',
  'tomorrow',
  'that',
  'this',
  'somewhere',
  'something',
};
