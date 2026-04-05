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

String _$employeeReportHash() => r'933584b7ec3474ddf8fa94a684623f024135a062';

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

String _$salaryReportHash() => r'3055a5c4327efad009a1508380d71f287cc73673';
