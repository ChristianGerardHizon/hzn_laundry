import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization_list_filter.dart';
import 'package:hzn_laundry/src/features/organizations/domain/organization_platform_stats.dart';

OrganizationPlatformStats _org(
  String name, {
  String? slug,
  String? status,
  num revenue = 0,
  int orders = 0,
  int customers = 0,
}) {
  return OrganizationPlatformStats(
    id: name,
    name: name,
    slug: slug ?? name.toLowerCase().replaceAll(' ', '-'),
    branchCount: 1,
    memberCount: 1,
    orderCount: orders,
    customerCount: customers,
    revenue: revenue,
    subscriptionStatus: status,
  );
}

void main() {
  final orgs = [
    _org('Alpha', status: 'active', revenue: 100, orders: 5, customers: 2),
    _org('Bravo', status: 'grace', revenue: 300, orders: 1, customers: 9),
    _org('Charlie', status: 'locked', revenue: 200, orders: 9, customers: 1),
    _org('Delta', status: 'cancelled', revenue: 50),
    _org('Echo'),
  ];

  test('buckets cancelled and missing subscriptions as other', () {
    expect(orgStatusBucket(orgs[3]), OrgStatusFilter.other);
    expect(orgStatusBucket(orgs[4]), OrgStatusFilter.other);
  });

  test('orgStatusCounts counts every bucket', () {
    final counts = orgStatusCounts(orgs);
    expect(counts[OrgStatusFilter.all], 5);
    expect(counts[OrgStatusFilter.active], 1);
    expect(counts[OrgStatusFilter.grace], 1);
    expect(counts[OrgStatusFilter.locked], 1);
    expect(counts[OrgStatusFilter.other], 2);
  });

  test('sorts by revenue descending by default', () {
    final result = filterAndSortOrgs(orgs);
    expect(result.map((o) => o.name), [
      'Bravo',
      'Charlie',
      'Alpha',
      'Delta',
      'Echo',
    ]);
  });

  test('sorts by orders, customers and name', () {
    expect(
      filterAndSortOrgs(orgs, sort: OrgSortKey.orders).first.name,
      'Charlie',
    );
    expect(
      filterAndSortOrgs(orgs, sort: OrgSortKey.customers).first.name,
      'Bravo',
    );
    expect(
      filterAndSortOrgs(orgs, sort: OrgSortKey.name).map((o) => o.name),
      ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo'],
    );
  });

  test('filters by status bucket', () {
    final result = filterAndSortOrgs(orgs, status: OrgStatusFilter.other);
    expect(result.map((o) => o.name), ['Delta', 'Echo']);
  });

  test('search matches name or slug, case-insensitively', () {
    expect(filterAndSortOrgs(orgs, query: '  CHAR ').single.name, 'Charlie');
    final bySlug = [_org('Acme Laundry', slug: 'zzz-slug')];
    expect(filterAndSortOrgs(bySlug, query: 'ZZZ'), hasLength(1));
  });

  test('search and status filter combine', () {
    final result = filterAndSortOrgs(
      orgs,
      query: 'a',
      status: OrgStatusFilter.active,
    );
    expect(result.single.name, 'Alpha');
  });
}
