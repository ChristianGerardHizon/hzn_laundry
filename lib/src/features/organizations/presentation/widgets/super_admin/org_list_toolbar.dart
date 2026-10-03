import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/i18n/strings.g.dart';
import '../../../domain/organization_list_filter.dart';

/// Search, status filter chips and sort menu for the organization list.
///
/// State is owned by the caller so other widgets (e.g. the health strip) can
/// drive the same filters; the form fields mirror the notifiers.
class OrgListToolbar extends HookConsumerWidget {
  const OrgListToolbar({
    super.key,
    required this.query,
    required this.status,
    required this.sort,
    required this.counts,
  });

  final ValueNotifier<String> query;
  final ValueNotifier<OrgStatusFilter> status;
  final ValueNotifier<OrgSortKey> sort;
  final Map<OrgStatusFilter, int> counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final queryText = useValueListenable(query);

    // Keep form fields in sync when filters change from outside the toolbar
    // (health strip taps, "Clear filters").
    useEffect(() {
      void sync() {
        final fields = formKey.currentState?.fields;
        final search = fields?['search'];
        if (search != null && search.value != query.value) {
          search.didChange(query.value);
        }
        final chips = fields?['status'];
        if (chips != null && chips.value != status.value) {
          chips.didChange(status.value);
        }
      }

      query.addListener(sync);
      status.addListener(sync);
      return () {
        query.removeListener(sync);
        status.removeListener(sync);
      };
    }, [query, status]);

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );

    final searchField = FormBuilderTextField(
      name: 'search',
      initialValue: query.value,
      onChanged: (v) => query.value = v ?? '',
      style: TextStyle(color: scheme.onSurface),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: t.organizations.searchOrganizations,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
        suffixIcon: queryText.isEmpty
            ? null
            : IconButton(
                tooltip: t.organizations.clearFilters,
                icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                onPressed: () => query.value = '',
              ),
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary),
      ),
    );

    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 8),
              _SortMenu(sort: sort, t: t),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: t.organizations.filterByStatus,
            container: true,
            child: FormBuilderChoiceChips<OrgStatusFilter>(
              name: 'status',
              initialValue: status.value,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              spacing: 8,
              runSpacing: 4,
              showCheckmark: true,
              checkmarkColor: scheme.primary,
              selectedColor: scheme.primary.withValues(alpha: 0.2),
              backgroundColor: scheme.surfaceContainerLow,
              side: BorderSide(color: scheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelStyle: TextStyle(
                color: scheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              // Tapping the selected chip deselects it; treat that as "All".
              onChanged: (v) => status.value = v ?? OrgStatusFilter.all,
              options: [
                for (final f in OrgStatusFilter.values)
                  FormBuilderChipOption<OrgStatusFilter>(
                    value: f,
                    child: Text('${_filterLabel(t, f)}  ${counts[f] ?? 0}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _filterLabel(Translations t, OrgStatusFilter f) => switch (f) {
        OrgStatusFilter.all => t.organizations.filterAll,
        OrgStatusFilter.active => t.subscriptions.statusActive,
        OrgStatusFilter.grace => t.subscriptions.statusGrace,
        OrgStatusFilter.locked => t.subscriptions.statusLocked,
        OrgStatusFilter.other => t.organizations.filterOther,
      };
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.sort, required this.t});

  final ValueNotifier<OrgSortKey> sort;
  final Translations t;

  String _label(OrgSortKey k) => switch (k) {
        OrgSortKey.revenue => t.organizations.sortRevenue,
        OrgSortKey.orders => t.organizations.sortOrders,
        OrgSortKey.customers => t.organizations.sortCustomers,
        OrgSortKey.name => t.organizations.sortName,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<OrgSortKey>(
      valueListenable: sort,
      builder: (context, current, _) {
        return PopupMenuButton<OrgSortKey>(
          tooltip: '${t.organizations.sortBy}: ${_label(current)}',
          initialValue: current,
          onSelected: (k) => sort.value = k,
          color: scheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          itemBuilder: (_) => [
            for (final k in OrgSortKey.values)
              PopupMenuItem<OrgSortKey>(
                value: k,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: k == current
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: scheme.primary,
                            )
                          : null,
                    ),
                    Text(_label(k)),
                  ],
                ),
              ),
          ],
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort, color: scheme.primary),
                if (MediaQuery.sizeOf(context).width >= 560) ...[
                  const SizedBox(width: 8),
                  Text(
                    _label(current),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
