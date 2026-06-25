import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_session_invalidator.dart';
import 'core/config/theme/app_theme.dart';
import 'core/network/interceptor_init.dart';
import 'core/routing/app_router.dart';

class CoffeeshopApp extends ConsumerWidget {
  const CoffeeshopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authInterceptorInitializer);
    ref.watch(authSessionInvalidatorProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'CoffeeShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
