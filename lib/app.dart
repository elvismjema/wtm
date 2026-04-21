import 'package:flutter/material.dart';

import 'screens/camera/camera_screen.dart';
import 'screens/create/create_event_screen.dart';
import 'screens/event/event_detail_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/saved/saved_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/story/story_view_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/shared/glass_bottom_nav.dart';

class AppRoutes {
  static const map = '/map';
  static const search = '/search';
  static const saved = '/saved';
  static const profile = '/profile';
  static const camera = '/camera';
  static const create = '/create';
  static const eventDetail = '/event';
  static const story = '/story';
}

class EventRouteArgs {
  const EventRouteArgs({required this.eventId});

  final String eventId;
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
        final name = settings.name ?? AppRoutes.map;
        final args = settings.arguments;

        if (name == AppRoutes.camera) {
          return MaterialPageRoute<void>(
            builder: (_) => const CameraScreen(),
            settings: settings,
          );
        }

        if (name == AppRoutes.create) {
          return MaterialPageRoute<void>(
            builder: (_) => const CreateEventScreen(),
            settings: settings,
          );
        }

        if (name == AppRoutes.eventDetail) {
          if (args is! EventRouteArgs) {
            return _fallback(settings);
          }
          return MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(eventId: args.eventId),
            settings: settings,
          );
        }

        if (name == AppRoutes.story) {
          if (args is! EventRouteArgs) {
            return _fallback(settings);
          }
          return MaterialPageRoute<void>(
            builder: (_) => StoryViewScreen(eventId: args.eventId),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => AppShell(initialRoute: name),
          settings: settings,
        );
      },
    );
  }

  MaterialPageRoute<void> _fallback(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const AppShell(initialRoute: AppRoutes.map),
      settings: settings,
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
  static const _tabRoutes = <String>[
    AppRoutes.map,
    AppRoutes.search,
    AppRoutes.saved,
    AppRoutes.profile,
  ];

  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = _routeToIndex(widget.initialRoute);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRoute != widget.initialRoute) {
      _activeIndex = _routeToIndex(widget.initialRoute);
    }
  }

  int _routeToIndex(String route) {
    final index = _tabRoutes.indexOf(route);
    return index == -1 ? 0 : index;
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return MapScreen(
          onOpenSearch: () => _setActiveTab(1),
          onOpenCreate: () => Navigator.of(context).pushNamed(AppRoutes.create),
        );
      case 1:
        return SearchScreen(onBackToMap: () => _setActiveTab(0));
      case 2:
        return SavedScreen(onExploreMap: () => _setActiveTab(0));
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _setActiveTab(int index) {
    if (_activeIndex == index) {
      return;
    }
    setState(() {
      _activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _activeIndex,
              children: List<Widget>.generate(_tabRoutes.length, _buildScreen),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNav(
              currentIndex: _activeIndex,
              onTap: _setActiveTab,
              onCameraTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.camera),
            ),
          ),
        ],
      ),
    );
  }
}
