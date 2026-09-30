import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/foundation/paginated_state.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/core/packages/theme/app_themes.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_laundry/src/features/users/domain/user.dart';
import 'package:hzn_laundry/src/features/users/presentation/controllers/paginated_users_controller.dart';
import 'package:hzn_laundry/src/features/users/presentation/widgets/user_list_panel.dart';

class _FakeUsers extends PaginatedUsersController {
  _FakeUsers(this._state);

  final PaginatedState<User> _state;

  @override
  Future<PaginatedState<User>> build() async => _state;
}

class _FakeOrg extends CurrentOrganizationController {
  @override
  Future<Organization?> build() async => null;
}

void main() {
  const alice = User(
    id: 'u1',
    name: 'Alice Reyes',
    email: 'alice@example.com',
    roleName: 'Admin',
  );

  Future<void> pump(
    WidgetTester tester, {
    required bool showHeader,
    List<User> users = const [alice],
  }) async {
    final state = PaginatedState<User>(
      items: users,
      currentPage: 1,
      totalItems: users.length,
      totalPages: 1,
      hasReachedEnd: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paginatedUsersControllerProvider.overrideWith(() => _FakeUsers(state)),
          currentOrganizationControllerProvider.overrideWith(_FakeOrg.new),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppThemes.dark().data,
            home: Consumer(
              builder: (context, ref, _) {
                final async = ref.watch(paginatedUsersControllerProvider);
                return Scaffold(
                  body: async.when(
                    data: (s) => UserListPanel(
                      showHeader: showHeader,
                      paginatedState: s,
                      selectedId: null,
                      onUserTap: (_) {},
                      onRefresh: () async {},
                      onLoadMore: () {},
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => Text('$e'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('showHeader: false does not repeat the Users title',
      (tester) async {
    await pump(tester, showHeader: false);

    expect(find.text('Users'), findsNothing);
    expect(find.textContaining('total'), findsNothing);
    // Row content is still there.
    expect(find.text('Alice Reyes'), findsOneWidget);
    expect(find.text('alice@example.com'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('showHeader: true renders the title and a count pill',
      (tester) async {
    await pump(tester, showHeader: true);

    expect(find.text('Users'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('empty list shows the empty state instead of only a footer',
      (tester) async {
    await pump(tester, showHeader: false, users: const []);

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('End of the list'), findsNothing);
  });
}
