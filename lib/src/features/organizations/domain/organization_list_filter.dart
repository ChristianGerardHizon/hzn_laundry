import '../../subscriptions/domain/subscription_status.dart';
import 'organization_platform_stats.dart';

/// Status buckets used to filter the Super Admin organization list.
enum OrgStatusFilter {
  all,
  active,
  grace,
  locked,

  /// Cancelled or no subscription at all.
  other;

  bool matches(OrganizationPlatformStats org) =>
      this == OrgStatusFilter.all || orgStatusBucket(org) == this;
}

/// Sort keys for the Super Admin organization list.
enum OrgSortKey {
  revenue,
  orders,
  customers,
  name,
}

/// Maps an organization's subscription to a filter bucket ([all] is never
/// returned).
OrgStatusFilter orgStatusBucket(OrganizationPlatformStats org) {
  final raw = org.subscriptionStatus;
  if (raw == null || raw.isEmpty) return OrgStatusFilter.other;
  return switch (SubscriptionStatus.fromString(raw)) {
    SubscriptionStatus.active => OrgStatusFilter.active,
    SubscriptionStatus.grace => OrgStatusFilter.grace,
    SubscriptionStatus.locked => OrgStatusFilter.locked,
    SubscriptionStatus.cancelled => OrgStatusFilter.other,
  };
}

/// Number of organizations per status bucket (including [OrgStatusFilter.all]).
Map<OrgStatusFilter, int> orgStatusCounts(
  List<OrganizationPlatformStats> orgs,
) {
  final counts = {for (final f in OrgStatusFilter.values) f: 0};
  counts[OrgStatusFilter.all] = orgs.length;
  for (final org in orgs) {
    final bucket = orgStatusBucket(org);
    counts[bucket] = counts[bucket]! + 1;
  }
  return counts;
}

/// Applies search (name or slug), status filter and sorting.
///
/// Numeric sorts are descending; name sort is A-Z. Ties fall back to name.
// TODO: Support sorting by created date once it is part of the stats payload.
List<OrganizationPlatformStats> filterAndSortOrgs(
  List<OrganizationPlatformStats> orgs, {
  String query = '',
  OrgStatusFilter status = OrgStatusFilter.all,
  OrgSortKey sort = OrgSortKey.revenue,
}) {
  final q = query.trim().toLowerCase();
  final result = orgs.where((o) {
    if (!status.matches(o)) return false;
    if (q.isEmpty) return true;
    return o.name.toLowerCase().contains(q) || o.slug.toLowerCase().contains(q);
  }).toList();

  int byName(OrganizationPlatformStats a, OrganizationPlatformStats b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  result.sort((a, b) {
    final primary = switch (sort) {
      OrgSortKey.revenue => b.revenue.compareTo(a.revenue),
      OrgSortKey.orders => b.orderCount.compareTo(a.orderCount),
      OrgSortKey.customers => b.customerCount.compareTo(a.customerCount),
      OrgSortKey.name => byName(a, b),
    };
    return primary != 0 ? primary : byName(a, b);
  });
  return result;
}
