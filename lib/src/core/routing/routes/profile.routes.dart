import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/users/presentation/pages/user_detail_page.dart';

part 'profile.routes.g.dart';

/// Current user's profile page route.
@TypedGoRoute<ProfileRoute>(path: ProfileRoute.path)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  static const path = '/profile';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}

/// Shows [UserDetailPage] for the signed-in user.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAuthProvider)?.user.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return UserDetailPage(userId: userId);
  }
}
