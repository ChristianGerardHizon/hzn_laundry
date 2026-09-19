import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/pdf/pdf_task_runner.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/add_ons_summary.dart';
import '../../domain/consumables_usage_summary.dart';
import '../../domain/loads_summary.dart';
import '../../domain/packs_summary.dart';
import '../../domain/sales_summary.dart';
import '../controllers/dashboard_date_override_provider.dart';
import 'dashboard_summary_pdf.dart';

/// Print/export-to-PDF icon button for a single dashboard breakdown section.
///
/// Lives inside a breakdown modal header (Total Sales, Payments Received,
/// Outstanding, etc.) and prints ONLY that section's list.
class DashboardSectionPrintButton extends ConsumerWidget {
  const DashboardSectionPrintButton.sales({
    super.key,
    required this.sectionTitle,
    required List<SalesSummaryItem> this.salesItems,
    required num this.total,
    this.color,
  })  : addOns = null,
        consumables = null,
        showConsumableCost = false,
        loads = null,
        packs = null;

  const DashboardSectionPrintButton.addOns({
    super.key,
    required AddOnsSummaryData this.addOns,
    this.color,
  })  : sectionTitle = 'Add-ons Sold',
        salesItems = null,
        total = null,
        consumables = null,
        showConsumableCost = false,
        loads = null,
        packs = null;

  const DashboardSectionPrintButton.consumables({
    super.key,
    required ConsumablesUsageSummaryData this.consumables,
    this.showConsumableCost = false,
    this.color,
  })  : sectionTitle = 'Consumables used',
        salesItems = null,
        total = null,
        addOns = null,
        loads = null,
        packs = null;

  const DashboardSectionPrintButton.loads({
    super.key,
    required LoadsSummaryData this.loads,
    this.color,
  })  : sectionTitle = 'Loads',
        salesItems = null,
        total = null,
        addOns = null,
        consumables = null,
        showConsumableCost = false,
        packs = null;

  const DashboardSectionPrintButton.packs({
    super.key,
    required TotalPacksSummary this.packs,
    this.color,
  })  : sectionTitle = 'Total Packs',
        salesItems = null,
        total = null,
        addOns = null,
        consumables = null,
        showConsumableCost = false,
        loads = null;

  final String sectionTitle;
  final List<SalesSummaryItem>? salesItems;
  final num? total;
  final AddOnsSummaryData? addOns;
  final ConsumablesUsageSummaryData? consumables;
  final bool showConsumableCost;
  final LoadsSummaryData? loads;
  final TotalPacksSummary? packs;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> handlePrint() async {
      final branchId = ref.read(currentBranchIdProvider);
      final branch = branchId != null
          ? await ref.read(branchProvider(branchId).future)
          : null;
      final reportDate = ref.read(dashboardEffectiveDateProvider);
      final isOverridden = ref.read(isDashboardDateOverriddenProvider);

      if (!context.mounted) return;

      final result = await runPdfTask<DashboardSectionPdfPayload>(
        context: context,
        message: 'Generating $sectionTitle...',
        preload: () async {
          if (addOns != null) {
            return DashboardSectionPdfPayload.fromAddOns(
              summary: addOns!,
              businessName: branch?.name,
              reportDate: reportDate,
              generatedAt: DateTime.now(),
              isDateOverridden: isOverridden,
            );
          }
          if (consumables != null) {
            return DashboardSectionPdfPayload.fromConsumables(
              summary: consumables!,
              showCost: showConsumableCost,
              businessName: branch?.name,
              reportDate: reportDate,
              generatedAt: DateTime.now(),
              isDateOverridden: isOverridden,
            );
          }
          if (loads != null) {
            return DashboardSectionPdfPayload.fromLoads(
              summary: loads!,
              businessName: branch?.name,
              reportDate: reportDate,
              generatedAt: DateTime.now(),
              isDateOverridden: isOverridden,
            );
          }
          if (packs != null) {
            return DashboardSectionPdfPayload.fromPacks(
              summary: packs!,
              businessName: branch?.name,
              reportDate: reportDate,
              generatedAt: DateTime.now(),
              isDateOverridden: isOverridden,
            );
          }
          if (sectionTitle == 'Total Sales') {
            return DashboardSectionPdfPayload.fromTotalSales(
              items: salesItems!,
              total: total!,
              businessName: branch?.name,
              reportDate: reportDate,
              generatedAt: DateTime.now(),
              isDateOverridden: isOverridden,
            );
          }
          return DashboardSectionPdfPayload.fromSales(
            sectionTitle: sectionTitle,
            items: salesItems!,
            total: total!,
            businessName: branch?.name,
            reportDate: reportDate,
            generatedAt: DateTime.now(),
            isDateOverridden: isOverridden,
          );
        },
        generate: buildDashboardSectionPdf,
      );

      if (result is! PdfTaskSuccess) return;

      await Printing.layoutPdf(
        name: sectionTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
        onLayout: (_) async => result.bytes,
      );
    }

    return IconButton(
      onPressed: handlePrint,
      icon: const Icon(Icons.print_outlined),
      tooltip: 'Print $sectionTitle',
      color: color,
    );
  }
}
