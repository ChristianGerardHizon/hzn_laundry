// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches salary report data for the selected month and period.

@ProviderFor(salaryReport)
final salaryReportProvider = SalaryReportProvider._();

/// Fetches salary report data for the selected month and period.

final class SalaryReportProvider extends $FunctionalProvider<
        AsyncValue<EmployeeReportData>,
        EmployeeReportData,
        FutureOr<EmployeeReportData>>
    with
        $FutureModifier<EmployeeReportData>,
        $FutureProvider<EmployeeReportData> {
  /// Fetches salary report data for the selected month and period.
  SalaryReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'salaryReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$salaryReportHash();

  @$internal
  @override
  $FutureProviderElement<EmployeeReportData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<EmployeeReportData> create(Ref ref) {
    return salaryReport(ref);
  }
}

String _$salaryReportHash() => r'4e421943d8b86f125ec92e376d2203a095a11d92';
