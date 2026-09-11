// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches employee report data for the selected date range.

@ProviderFor(employeeReport)
final employeeReportProvider = EmployeeReportProvider._();

/// Fetches employee report data for the selected date range.

final class EmployeeReportProvider extends $FunctionalProvider<
        AsyncValue<EmployeeReportData>,
        EmployeeReportData,
        FutureOr<EmployeeReportData>>
    with
        $FutureModifier<EmployeeReportData>,
        $FutureProvider<EmployeeReportData> {
  /// Fetches employee report data for the selected date range.
  EmployeeReportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeeReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeReportHash();

  @$internal
  @override
  $FutureProviderElement<EmployeeReportData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<EmployeeReportData> create(Ref ref) {
    return employeeReport(ref);
  }
}

String _$employeeReportHash() => r'bdcab5f7c14cdb3aefe49d04789cbc50344e4474';

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

String _$salaryReportHash() => r'92da2fd9488a72b3cda12f1d6eda0e83c917329c';
