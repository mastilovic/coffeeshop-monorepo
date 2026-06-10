import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (BuildContext context, GoRouterState state) {
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
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Events')),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('New Event')),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => Scaffold(
                      body: Center(
                        child: Text(
                            'Event ${state.pathParameters['id']}'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shops',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Shops')),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => Scaffold(
                      body: Center(
                        child:
                            Text('Shop ${state.pathParameters['id']}'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reservations',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Reservations')),
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
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Users')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
