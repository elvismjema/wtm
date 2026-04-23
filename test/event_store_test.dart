import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_the_move/state/event_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('created events are persisted and loaded by a new store', () async {
    final store = EventStore();
    await store.ready;

    final created = await store.addEvent(
      title: 'Campus Pop Up',
      description: 'Late night food and music.',
      category: 'Food',
      dateTime: DateTime(2026, 5, 1, 20),
      locationName: 'Student Union',
    );

    final reloadedStore = EventStore();
    await reloadedStore.ready;

    expect(reloadedStore.byId(created.id), isNotNull);
    expect(reloadedStore.createdEvents, hasLength(1));
    expect(reloadedStore.createdEvents.single.title, 'Campus Pop Up');
  });

  test('saved state for a created event survives app reload', () async {
    final store = EventStore();
    await store.ready;

    final created = await store.addEvent(
      title: 'Open Gym Run',
      description: '',
      category: 'Sports',
      dateTime: DateTime(2026, 5, 2, 18, 30),
      locationName: 'Rec Center',
    );
    await store.toggleSaved(created.id);

    final reloadedStore = EventStore();
    await reloadedStore.ready;

    expect(reloadedStore.isSaved(created.id), isTrue);
    expect(
      reloadedStore.savedEvents.map((event) => event.id),
      contains(created.id),
    );
  });

  test('bad locally stored event data does not block valid events', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'created_events': <String>[
        'not json',
        '{"id":"evt_valid","title":"Valid Event","category":"Study",'
            '"description":"Bring notes.","locationName":"Library",'
            '"dateTime":"2026-05-03T14:00:00.000","color":4287346175,'
            '"mapX":0.5,"mapY":0.5,"latitude":35.4676,"longitude":-97.5164,'
            '"distanceMiles":1.2,"attendeeCount":3,"hostName":"You",'
            '"createdByUser":true}',
      ],
    });

    final store = EventStore();
    await store.ready;

    expect(store.createdEvents, hasLength(1));
    expect(store.createdEvents.single.id, 'evt_valid');
  });
}
