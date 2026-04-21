import 'package:flutter_test/flutter_test.dart';
import 'package:whats_the_move/app.dart';
import 'package:whats_the_move/state/event_store.dart';

void main() {
  testWidgets('App loads map and bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(
      EventStoreProvider(store: EventStore(), child: const WhatsTheMoveApp()),
    );
    await tester.pump();

    expect(find.text('Search events, vibes, or places'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
