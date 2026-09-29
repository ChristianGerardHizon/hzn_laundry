import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_laundry/src/core/i18n/strings.g.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization_list_filter.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization_platform_stats.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/widgets/super_admin/org_list_toolbar.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/widgets/super_admin/org_stats_card.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/widgets/super_admin/platform_kpi_section.dart';
import 'package:hzn_laundry/src/features/organizations/presentation/widgets/super_admin/subscription_health_strip.dart';
import 'package:intl/intl.dart';

void main() {
  final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  final compact = NumberFormat.compact();

  final orgs = [
    OrganizationPlatformStats(
      id: '1',
      name: 'A Very Long Organization Name That Should Ellipsize Nicely',
      slug: 'a-very-long-organization-name-that-should-ellipsize-nicely',
      branchCount: 12,
      memberCount: 34,
      orderCount: 123456,
      customerCount: 7890,
      revenue: 813245,
      subscriptionStatus: 'grace',
      graceEndsAt: DateTime.now().add(const Duration(days: 3)),
      pendingPaymentCount: 2,
      packageName: 'Basic',
    ),
    const OrganizationPlatformStats(
      id: '2',
      name: 'Zeta',
      slug: 'zeta',
      branchCount: 1,
      memberCount: 1,
      orderCount: 0,
      customerCount: 0,
      revenue: 0,
      subscriptionStatus: 'active',
    ),
  ];

  Widget harness(double width, Widget child) {
    return TranslationProvider(
      child: ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final width in [360.0, 700.0, 960.0]) {
    testWidgets('dashboard widgets lay out at ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final t = AppLocale.en.buildSync();
      final query = ValueNotifier('');
      final status = ValueNotifier(OrgStatusFilter.all);
      final sort = ValueNotifier(OrgSortKey.revenue);
      final counts = orgStatusCounts(orgs);

      await tester.pumpWidget(
        harness(
          width,
          Column(
            children: [
              PlatformKpiSection(
                summary: const OrganizationPlatformSummary(
                  organizationCount: 2,
                  orderCount: 123456,
                  customerCount: 7890,
                  revenue: 813245,
                ),
                currency: currency,
                compact: compact,
                t: t,
              ),
              SubscriptionHealthStrip(
                counts: counts,
                selected: status.value,
                onSelected: (f) => status.value = f,
                t: t,
              ),
              OrgListToolbar(
                query: query,
                status: status,
                sort: sort,
                counts: counts,
              ),
              for (final org in orgs)
                OrgStatsCard(
                  org: org,
                  currency: currency,
                  compact: compact,
                  t: t,
                  onTap: () {},
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Any RenderFlex overflow would surface as a test exception.
      expect(tester.takeException(), isNull);
      expect(find.text('Zeta'), findsOneWidget);
      expect(find.textContaining('Grace ends in 3 days'), findsOneWidget);
      expect(find.text('2 pending payments'), findsOneWidget);
    });
  }

  testWidgets('toolbar chips and search drive the shared notifiers',
      (tester) async {
    tester.view.physicalSize = const Size(700, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final query = ValueNotifier('');
    final status = ValueNotifier(OrgStatusFilter.all);
    final sort = ValueNotifier(OrgSortKey.revenue);

    await tester.pumpWidget(
      harness(
        700,
        OrgListToolbar(
          query: query,
          status: status,
          sort: sort,
          counts: orgStatusCounts(orgs),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Grace'));
    await tester.pumpAndSettle();
    expect(status.value, OrgStatusFilter.grace);

    // Tapping the selected chip again falls back to "All".
    await tester.tap(find.textContaining('Grace'));
    await tester.pumpAndSettle();
    expect(status.value, OrgStatusFilter.all);

    await tester.enterText(find.byType(TextField), 'zeta');
    expect(query.value, 'zeta');

    // External change (e.g. "Clear filters") is mirrored back into the field.
    query.value = '';
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name (A-Z)').last);
    await tester.pumpAndSettle();
    expect(sort.value, OrgSortKey.name);
  });
}
