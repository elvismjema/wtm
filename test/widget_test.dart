import 'package:flutter_test/flutter_test.dart';

import 'package:whats_the_move/app.dart';

void main() {
  testWidgets('App loads to map screen by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WhatsTheMoveApp());
    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
  });
}
