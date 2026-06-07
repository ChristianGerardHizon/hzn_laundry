import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/pdf/pdf_task_runner.dart';
import '../../../settings/presentation/controllers/branch_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/add_ons_summary.dart';
import '../../domain/sales_summary.dart';
import '../controllers/dashboard_date_override_provider.dart';
import '../controllers/today_incentive_controller.dart';
import 'dashboard_summary_pdf.dart';

/// Print/export-to-PDF icon button for a single dashboard breakdown section.
///
/// Lives inside a breakdown modal header (Total Sales, Payments Received,
/// Outstanding, or Today's Incentive) and prints ONLY that section's list.
///
/// Provide exactly one of [salesItems] (with [sectionTitle]) or [incentive].
class DashboardSectionPrintButton extends ConsumerWidget {
  const DashboardSectionPrintButton.sales({
    super.key,
    required this.sectionTitle,
    required List<SalesSummaryItem> this.salesItems,
    required num this.total,
    this.color,
  })  : incentive = null,
        addOns = null;

  const DashboardSectionPrintButton.incentive({
    super.key,
    required TodayIncentiveSummary this.incentive,
    this.color,
  })  : sectionTitle = "Today's Incentive",
        salesItems = null,
        total = null,
        addOns = null;

  const DashboardSectionPrintButton.addOns({
    super.key,
    required AddOnsSummaryData this.addOns,
    this.color,
  })  : sectionTitle = 'Add-ons Sold',
        salesItems = null,
        total = null,
        incentive = null;

  final String sectionTitle;
  final List<SalesSummaryItem>? salesItems;
  final num? total;
  final TodayIncentiveSummary? incentive;
  final AddOnsSummaryData? addOns;
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
          if (incentive != null) {
            return DashboardSectionPdfPayload.fromIncentive(
              incentive: incentive!,
              businessName: branch?.name,
              reportDate: reportDate,
              generatedAt: DateTime.now(),
              isDateOverridden: isOverridden,
            );
          }
          if (addOns != null) {
            return DashboardSectionPdfPayload.fromAddOns(
              summary: addOns!,
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
