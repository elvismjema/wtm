import 'package:flutter/material.dart';

import 'screens/map/map_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/saved/saved_screen.dart';
import 'screens/search/search_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/shared/glass_bottom_nav.dart';

class AppRoutes {
  static const map = '/map';
  static const search = '/search';
  static const saved = '/saved';
  static const profile = '/profile';
}

class WhatsTheMoveApp extends StatelessWidget {
  const WhatsTheMoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "What's The Move",
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.map,
      onGenerateRoute: (settings) {
        final route = settings.name ?? AppRoutes.map;
        return MaterialPageRoute<void>(
          builder: (_) => AppShell(initialRoute: route),
          settings: settings,
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late String _activeRoute;

  static const _tabRoutes = <String>[
    AppRoutes.map,
    AppRoutes.search,
    '/camera',
    AppRoutes.saved,
    AppRoutes.profile,
  ];

  @override
  void initState() {
    super.initState();
    _activeRoute = _normalize(widget.initialRoute);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRoute != widget.initialRoute) {
      _activeRoute = _normalize(widget.initialRoute);
    }
  }

  String _normalize(String route) {
    if (_tabRoutes.contains(route)) {
      return route;
    }
    return AppRoutes.map;
  }

  int get _activeIndex {
    final index = _tabRoutes.indexOf(_activeRoute);
    return index >= 0 ? index : 0;
  }

  void _onTabSelected(int index) {
    final route = _tabRoutes[index];
    setState(() {
      _activeRoute = route;
    });
  }

  Widget _screenForIndex(int index) {
    switch (index) {
      case 0:
        return const MapScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const _CameraPlaceholderScreen();
      case 3:
        return const SavedScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const MapScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _activeIndex;

    // Later: hide this nav on /story/* and /camera full-screen capture routes.
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: List<Widget>.generate(_tabRoutes.length, _screenForIndex),
      ),
      extendBody: true,
      bottomNavigationBar: GlassBottomNav(
        currentIndex: index,
        onTap: _onTabSelected,
      ),
    );
  }
}

class _CameraPlaceholderScreen extends StatelessWidget {
  const _CameraPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Camera (Coming Soon)'));
  }
}
