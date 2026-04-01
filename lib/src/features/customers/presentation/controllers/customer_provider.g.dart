// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single customer by ID.

@ProviderFor(customer)
final customerProvider = CustomerFamily._();

/// Provider for a single customer by ID.

final class CustomerProvider extends $FunctionalProvider<AsyncValue<Customer?>,
        Customer?, FutureOr<Customer?>>
    with $FutureModifier<Customer?>, $FutureProvider<Customer?> {
  /// Provider for a single customer by ID.
  CustomerProvider._(
      {required CustomerFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'customerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerHash();

  @override
  String toString() {
    return r'customerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Customer?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Customer?> create(Ref ref) {
    final argument = this.argument as String;
    return customer(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerHash() => r'ba8bd2ddd392a3a1073e638f41219b2ceea70105';

/// Provider for a single customer by ID.

final class CustomerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Customer?>, String> {
  CustomerFamily._()
      : super(
          retry: null,
          name: r'customerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single customer by ID.

  CustomerProvider call(
    String id,
  ) =>
      CustomerProvider._(argument: id, from: this);

  @override
  String toString() => r'customerProvider';
}
