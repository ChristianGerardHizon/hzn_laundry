// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches customer history by token.

@ProviderFor(customerHistory)
final customerHistoryProvider = CustomerHistoryFamily._();

/// Fetches customer history by token.

final class CustomerHistoryProvider extends $FunctionalProvider<
        AsyncValue<CustomerHistory>, CustomerHistory, FutureOr<CustomerHistory>>
    with $FutureModifier<CustomerHistory>, $FutureProvider<CustomerHistory> {
  /// Fetches customer history by token.
  CustomerHistoryProvider._(
      {required CustomerHistoryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'customerHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerHistoryHash();

  @override
  String toString() {
    return r'customerHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CustomerHistory> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CustomerHistory> create(Ref ref) {
    final argument = this.argument as String;
    return customerHistory(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerHistoryHash() => r'5efebb83b397bb672c0ba143c058b02d06d3b992';

/// Fetches customer history by token.

final class CustomerHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CustomerHistory>, String> {
  CustomerHistoryFamily._()
      : super(
          retry: null,
          name: r'customerHistoryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches customer history by token.

  CustomerHistoryProvider call(
    String token,
  ) =>
      CustomerHistoryProvider._(argument: token, from: this);

  @override
  String toString() => r'customerHistoryProvider';
}

/// Fetches a single sale's detail (items + services) by token + saleId.

@ProviderFor(customerHistorySaleDetail)
final customerHistorySaleDetailProvider = CustomerHistorySaleDetailFamily._();

/// Fetches a single sale's detail (items + services) by token + saleId.

final class CustomerHistorySaleDetailProvider extends $FunctionalProvider<
        AsyncValue<CustomerHistorySaleDetail>,
        CustomerHistorySaleDetail,
        FutureOr<CustomerHistorySaleDetail>>
    with
        $FutureModifier<CustomerHistorySaleDetail>,
        $FutureProvider<CustomerHistorySaleDetail> {
  /// Fetches a single sale's detail (items + services) by token + saleId.
  CustomerHistorySaleDetailProvider._(
      {required CustomerHistorySaleDetailFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'customerHistorySaleDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerHistorySaleDetailHash();

  @override
  String toString() {
    return r'customerHistorySaleDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CustomerHistorySaleDetail> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CustomerHistorySaleDetail> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return customerHistorySaleDetail(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerHistorySaleDetailProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerHistorySaleDetailHash() =>
    r'51ebb16217e69b227ecce0f89c4bf6f42dcc92ef';

/// Fetches a single sale's detail (items + services) by token + saleId.

final class CustomerHistorySaleDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<CustomerHistorySaleDetail>,
            (
              String,
              String,
            )> {
  CustomerHistorySaleDetailFamily._()
      : super(
          retry: null,
          name: r'customerHistorySaleDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches a single sale's detail (items + services) by token + saleId.

  CustomerHistorySaleDetailProvider call(
    String token,
    String saleId,
  ) =>
      CustomerHistorySaleDetailProvider._(argument: (
        token,
        saleId,
      ), from: this);

  @override
  String toString() => r'customerHistorySaleDetailProvider';
}
