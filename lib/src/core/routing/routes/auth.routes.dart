import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/pages/auth_loading_page.dart';
import '../../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/scope_recovery_page.dart';
import '../../../features/auth/presentation/pages/splash_page.dart';

part 'auth.routes.g.dart';

/// Splash page route - shown during auth initialization.
@TypedGoRoute<SplashRoute>(path: SplashRoute.path)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  static const path = '/splash';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}

/// Login page route.
@TypedGoRoute<LoginRoute>(path: LoginRoute.path)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  static const path = '/login';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

/// Forgot password page route.
@TypedGoRoute<ForgotPasswordRoute>(path: ForgotPasswordRoute.path)
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  static const path = '/forgot-password';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordPage();
  }
}

/// Auth loading page route - shown while login is in progress.
@TypedGoRoute<AuthLoadingRoute>(path: AuthLoadingRoute.path)
class AuthLoadingRoute extends GoRouteData with $AuthLoadingRoute {
  const AuthLoadingRoute();

  static const path = '/auth-loading';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthLoadingPage();
  }
}

/// Post-auth recovery when org/branch scope cannot resolve a home path.
@TypedGoRoute<ScopeRecoveryRoute>(path: ScopeRecoveryRoute.path)
class ScopeRecoveryRoute extends GoRouteData with $ScopeRecoveryRoute {
  const ScopeRecoveryRoute();

  static const path = '/scope-recovery';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ScopeRecoveryPage();
  }
}
