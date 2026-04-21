import 'package:flutter/material.dart';

import 'app.dart';
import 'state/event_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = EventStore();
  runApp(EventStoreProvider(store: store, child: const WhatsTheMoveApp()));
}
