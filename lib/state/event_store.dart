import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_events.dart';
import '../models/event.dart';
import '../services/ai_event_search.dart';
import '../theme/app_colors.dart';

class EventStore extends ChangeNotifier {
  EventStore({
    bool enableCloudSync = true,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _enableCloudSync = enableCloudSync,
       _auth = auth,
       _firestore = firestore {
    _loadFuture = _load();
    if (_enableCloudSync) {
      final firebaseAuth = _auth ?? FirebaseAuth.instance;
      _authSub = firebaseAuth.authStateChanges().listen(_handleAuthChanged);
    }
  }

  static const _savedKey = 'saved_event_ids';
  static const _joinedKey = 'joined_event_ids';
  static const _createdKey = 'created_events';
  static const _oklahomaCenter = (lat: 35.4676, lng: -97.5164);
  static const _geocodingApiKey = String.fromEnvironment(
    'GOOGLE_GEOCODING_API_KEY',
  );

  final Set<String> _savedEventIds = <String>{};
  final Set<String> _joinedEventIds = <String>{};
  final List<Event> _createdEvents = <Event>[];
  final bool _enableCloudSync;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  late final Future<void> _loadFuture;
  StreamSubscription<User?>? _authSub;
  String? _currentUserId;

  bool _hydrated = false;

  bool get isHydrated => _hydrated;
  Future<void> get ready => _loadFuture;

  List<Event> get events => <Event>[...demoEvents, ..._createdEvents];

  List<Event> get savedEvents =>
      events.where((event) => _savedEventIds.contains(event.id)).toList();

  List<Event> get createdEvents => List<Event>.from(_createdEvents);

  int get savedCount => _savedEventIds.length;
  int get joinedCount => _joinedEventIds.length;
  int get createdCount => _createdEvents.length;

  bool isSaved(String eventId) => _savedEventIds.contains(eventId);
  bool isJoined(String eventId) => _joinedEventIds.contains(eventId);

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Event? byId(String id) {
    for (final event in events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  Future<void> toggleSaved(String eventId) async {
    await _loadFuture;
    await _ensureCurrentAuthUserLoaded();

    if (_savedEventIds.contains(eventId)) {
      _savedEventIds.remove(eventId);
    } else {
      _savedEventIds.add(eventId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> toggleJoined(String eventId) async {
    await _loadFuture;
    await _ensureCurrentAuthUserLoaded();

    if (_joinedEventIds.contains(eventId)) {
      _joinedEventIds.remove(eventId);
    } else {
      _joinedEventIds.add(eventId);
    }
    notifyListeners();
    await _persist();
  }

  Future<Event> addEvent({
    required String title,
    required String description,
    required String category,
    required DateTime dateTime,
    required String locationName,
  }) async {
    await _loadFuture;
    await _ensureCurrentAuthUserLoaded();

    final random = Random();
    final color = _colorForCategory(category);
    final geocoded = await _geocodeLocation(locationName);
    final latitude = geocoded?.$1 ?? _oklahomaCenter.lat;
    final longitude = geocoded?.$2 ?? _oklahomaCenter.lng;
    final event = Event(
      id: 'evt_user_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      description: description.isEmpty ? 'No description yet.' : description,
      locationName: locationName,
      dateTime: dateTime,
      color: color,
      mapX: 0.2 + random.nextDouble() * 0.6,
      mapY: 0.2 + random.nextDouble() * 0.6,
      latitude: latitude,
      longitude: longitude,
      distanceMiles: 0.3 + random.nextDouble() * 3,
      attendeeCount: 1,
      hostName: 'You',
      createdByUser: true,
    );

    _createdEvents.insert(0, event);
    _savedEventIds.add(event.id);
    notifyListeners();
    await _persist();
    await _saveCreatedEventToCloud(event);
    return event;
  }

  Future<(double, double)?> _geocodeLocation(String locationName) async {
    if (_geocodingApiKey.isEmpty) {
      return null;
    }

    try {
      final query = '$locationName, Oklahoma';
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'address': query,
        'key': _geocodingApiKey,
      });

      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final payload = await response.transform(utf8.decoder).join();
      client.close(force: true);

      if (response.statusCode != HttpStatus.ok) {
        return null;
      }

      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final status = decoded['status'] as String? ?? '';
      if (status != 'OK') {
        return null;
      }

      final results = decoded['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return null;
      }

      final first = results.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        return null;
      }

      return (lat, lng);
    } catch (_) {
      return null;
    }
  }

  List<Event> search({
    required String query,
    required String mood,
    required String distance,
    required String time,
    required String price,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final now = DateTime.now();

    return events.where((event) {
      if (normalizedQuery.isNotEmpty) {
        final haystack =
            '${event.title} ${event.description} ${event.locationName}'
                .toLowerCase();
        if (!haystack.contains(normalizedQuery)) {
          return false;
        }
      }

      if (mood != 'All' && event.category.toLowerCase() != mood.toLowerCase()) {
        return false;
      }

      if (distance != 'Any') {
        final miles = switch (distance) {
          '1mi' => 1.0,
          '5mi' => 5.0,
          '10mi' => 10.0,
          _ => 999.0,
        };
        if (event.distanceMiles > miles) {
          return false;
        }
      }

      if (time != 'Any') {
        if (time == 'Now') {
          final delta = event.dateTime.difference(now).inHours;
          if (delta < -2 || delta > 2) {
            return false;
          }
        }
        if (time == 'Tonight') {
          if (event.dateTime.day != now.day || event.dateTime.hour < 17) {
            return false;
          }
        }
        if (time == 'Tomorrow') {
          final tomorrow = now.add(const Duration(days: 1));
          if (event.dateTime.day != tomorrow.day ||
              event.dateTime.month != tomorrow.month ||
              event.dateTime.year != tomorrow.year) {
            return false;
          }
        }
      }

      if (price != 'Any') {
        // Demo-only filter approximation without a full pricing model.
        final isFree = event.category == 'Study' || event.category == 'Church';
        if (price == 'Free' && !isFree) {
          return false;
        }
        if (price == 'Paid' && isFree) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<EventSearchResult> aiSearch({
    required String query,
    required String mood,
    required String distance,
    required String time,
    required String price,
  }) {
    return AiEventSearch.search(
      events: events,
      query: query,
      mood: mood,
      distance: distance,
      time: time,
      price: price,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _savedEventIds
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey(_savedKey, null)) ?? <String>[]);

    _joinedEventIds
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey(_joinedKey, null)) ?? <String>[]);

    _createdEvents
      ..clear()
      ..addAll(
        _decodeEvents(
          prefs.getStringList(_prefsKey(_createdKey, null)) ?? <String>[],
        ),
      );

    _hydrated = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey(_savedKey, _currentUserId),
      _savedEventIds.toList(),
    );
    await prefs.setStringList(
      _prefsKey(_joinedKey, _currentUserId),
      _joinedEventIds.toList(),
    );
    await prefs.setStringList(
      _prefsKey(_createdKey, _currentUserId),
      _createdEvents.map((event) => jsonEncode(event.toJson())).toList(),
    );
  }

  Future<void> _handleAuthChanged(User? user) async {
    await _loadFuture;

    if (user == null) {
      _currentUserId = null;
      _savedEventIds.clear();
      _joinedEventIds.clear();
      _createdEvents.clear();
      notifyListeners();
      return;
    }

    if (_currentUserId == user.uid) {
      return;
    }

    _currentUserId = user.uid;
    await _loadCreatedEventsForUser(user.uid);
  }

  Future<void> _ensureCurrentAuthUserLoaded() async {
    if (!_enableCloudSync) {
      return;
    }

    final user = (_auth ?? FirebaseAuth.instance).currentUser;
    if (user == null || _currentUserId == user.uid) {
      return;
    }

    _currentUserId = user.uid;
    await _loadCreatedEventsForUser(user.uid);
  }

  Future<void> _loadCreatedEventsForUser(String userId) async {
    await _loadAccountEventIds(userId);

    final localEvents = await _loadLocalCreatedEvents(userId);
    var events = localEvents;

    try {
      final snapshot = await _createdEventsCollection(
        userId,
      ).orderBy('dateTime').get();
      final cloudEvents = <Event>[];
      for (final doc in snapshot.docs) {
        try {
          cloudEvents.add(Event.fromJson(doc.data()));
        } catch (_) {
          // Ignore one bad cloud record instead of hiding all account events.
        }
      }
      if (cloudEvents.isNotEmpty) {
        events = cloudEvents.reversed.toList();
      } else if (localEvents.isNotEmpty) {
        await _saveCreatedEventsToCloud(userId, localEvents);
      }
    } catch (_) {
      events = localEvents;
    }

    _createdEvents
      ..clear()
      ..addAll(events);
    _savedEventIds.addAll(events.map((event) => event.id));
    await _persist();
    notifyListeners();
  }

  Future<void> _loadAccountEventIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    _savedEventIds
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey(_savedKey, userId)) ?? <String>[]);

    _joinedEventIds
      ..clear()
      ..addAll(
        prefs.getStringList(_prefsKey(_joinedKey, userId)) ?? <String>[],
      );
  }

  Future<List<Event>> _loadLocalCreatedEvents(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedEvents =
        prefs.getStringList(_prefsKey(_createdKey, userId)) ??
        prefs.getStringList(_createdKey) ??
        <String>[];
    return _decodeEvents(encodedEvents);
  }

  List<Event> _decodeEvents(List<String> encodedEvents) {
    final events = <Event>[];
    for (final jsonString in encodedEvents) {
      try {
        events.add(
          Event.fromJson(jsonDecode(jsonString) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore one bad local record instead of dropping the whole store.
      }
    }
    return events;
  }

  Future<void> _saveCreatedEventToCloud(Event event) async {
    final userId = _currentUserId;
    if (!_enableCloudSync || userId == null) {
      return;
    }

    try {
      await _createdEventsCollection(userId).doc(event.id).set(event.toJson());
    } catch (_) {
      // Keep the local copy if cloud sync is unavailable.
    }
  }

  Future<void> _saveCreatedEventsToCloud(
    String userId,
    List<Event> events,
  ) async {
    try {
      final batch = (_firestore ?? FirebaseFirestore.instance).batch();
      final collection = _createdEventsCollection(userId);
      for (final event in events) {
        batch.set(collection.doc(event.id), event.toJson());
      }
      await batch.commit();
    } catch (_) {
      // Local account-scoped storage remains the fallback.
    }
  }

  CollectionReference<Map<String, dynamic>> _createdEventsCollection(
    String userId,
  ) {
    return (_firestore ?? FirebaseFirestore.instance)
        .collection('users')
        .doc(userId)
        .collection('created_events');
  }

  String _prefsKey(String baseKey, String? userId) {
    if (userId == null) {
      return baseKey;
    }
    return '${baseKey}_$userId';
  }

  Color _colorForCategory(String category) {
    final value = category.toLowerCase();
    if (value == 'party' || value == 'clubbing') {
      return AppColors.hotspotPink;
    }
    if (value == 'food') {
      return AppColors.hotspotOrange;
    }
    if (value == 'sports') {
      return AppColors.hotspotOrange;
    }
    if (value == 'study' || value == 'networking') {
      return AppColors.hotspotPurple;
    }
    return AppColors.hotspotCyan;
  }
}

class EventStoreProvider extends InheritedNotifier<EventStore> {
  const EventStoreProvider({
    super.key,
    required EventStore store,
    required super.child,
  }) : super(notifier: store);

  static EventStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<EventStoreProvider>();
    assert(provider != null, 'EventStoreProvider not found in context');
    return provider!.notifier!;
  }
}
