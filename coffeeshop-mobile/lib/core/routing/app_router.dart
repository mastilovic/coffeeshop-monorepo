import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/events/event_create_screen.dart';
import '../../features/events/event_detail_screen.dart';
import '../../features/events/event_list_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reservations/reservation_list_screen.dart';
import '../../features/shop_details/shop_detail_screen.dart';
import '../../features/shops/shop_create_screen.dart';
import '../../features/shops/shop_list_screen.dart';
import '../../features/users/user_list_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_service.dart';
import '../auth/user_role.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier();
  ref.onDispose(refresh.dispose);

  ref.listen(authNotifierProvider, (_, __) => refresh.notify());

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/dashboard',
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      final bool isAuthenticated =
          authState.status == AuthStatus.authenticated;
      final bool isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }

      // Role-based route guards for owner-only routes.
      if (isAuthenticated) {
        final role = authState.role;
        final isShopOwner = role == UserRole.shop_owner ||
            role == UserRole.admin;
        final isOwnerOnlyRoute = state.matchedLocation == '/events/new' ||
            state.matchedLocation == '/shops/new';

        if (isOwnerOnlyRoute && !isShopOwner) {
          return state.matchedLocation == '/events/new'
              ? '/events'
              : '/shops';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const EventCreateScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EventDetailScreen(eventId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shops',
                builder: (context, state) => const ShopListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ShopCreateScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ShopDetailScreen(shopId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reservations',
                builder: (context, state) => ReservationListScreen(
                  initialShopId: state.uri.queryParameters['shopId'],
                  initialEventId: state.uri.queryParameters['eventId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserListScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
