import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:whats_the_move/screens/search/search_screen.dart';
import 'package:whats_the_move/state/event_store.dart';
import 'package:whats_the_move/theme/app_theme.dart';

void main() {
  testWidgets('Search screen loads AI search controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      EventStoreProvider(
        store: EventStore(enableCloudSync: false),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ask for a vibe, plan, or place'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsWidgets);
    expect(find.text('Recommended for you'), findsOneWidget);
  });
}
