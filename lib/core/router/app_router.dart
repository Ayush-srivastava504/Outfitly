import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/analytics_screen.dart';
import '../../data/community/community_api.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/community/community_screens.dart';
import '../../features/dashboard/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/outfit_creator/outfit_creator_screen.dart';
import '../../features/outfit_creator/outfit_detail_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/recommendations/suggestions.dart';
import '../../features/settings/settings_screens.dart';
import '../../features/try_on/try_on_screen.dart';
import '../../features/wardrobe/item_detail_screen.dart';
import '../../features/wardrobe/item_form_screen.dart';
import '../../features/wardrobe/wardrobe_screen.dart';
import '../prefs/app_prefs.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ValueNotifier(ref.read(appPrefsProvider).onboardingDone);
  ref.listen(appPrefsProvider.select((p) => p.onboardingDone), (_, v) => onboarded.value = v);
  ref.onDispose(onboarded.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded.value && !atOnboarding) return '/onboarding';
      if (onboarded.value && atOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeScreen(),
                routes: [GoRoute(path: 'suggestions', parentNavigatorKey: _rootKey, builder: (_, _) => const SuggestionsScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wardrobe',
                builder: (_, _) => const WardrobeScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootKey,
                    builder: (_, s) => ItemFormScreen(sourcePaths: (s.extra as List?)?.cast<String>() ?? const []),
                    redirect: (_, s) => (s.extra is List && (s.extra as List).isNotEmpty) ? null : '/wardrobe',
                  ),
                  GoRoute(
                    path: 'item/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (_, s) => ItemDetailScreen(id: s.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: _rootKey,
                        builder: (_, s) => ItemFormScreen(editId: s.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (_, s) => CreateTab(initialItemIds: (s.extra as List?)?.cast<String>() ?? const []),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (_, _) => const CommunityTab(),
                routes: [
                  GoRoute(path: 'me', parentNavigatorKey: _rootKey, builder: (_, _) => const MyCommunityScreen()),
                  GoRoute(path: 'account', parentNavigatorKey: _rootKey, builder: (_, _) => const CommunityAccountScreen()),
                  GoRoute(path: 'profile', parentNavigatorKey: _rootKey, builder: (_, _) => const ProfileEditScreen()),
                  GoRoute(
                    path: 'user/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (_, s) => UserWardrobeScreen(userId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'post',
                    parentNavigatorKey: _rootKey,
                    builder: (_, s) => PostViewerScreen(post: s.extra! as CommunityPost),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(path: 'analytics', parentNavigatorKey: _rootKey, builder: (_, _) => const AnalyticsScreen()),
                  GoRoute(path: 'settings', parentNavigatorKey: _rootKey, builder: (_, _) => const SettingsScreen()),
                  GoRoute(path: 'preferences', parentNavigatorKey: _rootKey, builder: (_, _) => const PreferencesScreen()),
                  GoRoute(path: 'backup', parentNavigatorKey: _rootKey, builder: (_, _) => const BackupScreen()),
                  GoRoute(path: 'premium', parentNavigatorKey: _rootKey, builder: (_, _) => const PremiumScreen()),
                  GoRoute(path: 'privacy', parentNavigatorKey: _rootKey, builder: (_, _) => const PrivacyScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/calendar', parentNavigatorKey: _rootKey, builder: (_, _) => const CalendarScreen()),
      GoRoute(
        path: '/try-on',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => TryOnScreen(initialItemIds: (s.extra as List?)?.cast<String>() ?? const []),
      ),
      GoRoute(
        path: '/outfit/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => OutfitDetailScreen(id: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootKey,
            builder: (_, s) => EditOutfitScreen(outfitId: s.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => PopScope(
    // Back from another tab returns Home before exiting the app.
    canPop: shell.currentIndex == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && shell.currentIndex != 0) shell.goBranch(0);
    },
    child: Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checkroom_outlined), selectedIcon: Icon(Icons.checkroom), label: 'Wardrobe'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    ),
  );
}
