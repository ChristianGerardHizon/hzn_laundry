// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for a single service by ID.

@ProviderFor(service)
final serviceProvider = ServiceFamily._();

/// Provider for a single service by ID.

final class ServiceProvider extends $FunctionalProvider<AsyncValue<Service?>,
        Service?, FutureOr<Service?>>
    with $FutureModifier<Service?>, $FutureProvider<Service?> {
  /// Provider for a single service by ID.
  ServiceProvider._(
      {required ServiceFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'serviceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceHash();

  @override
  String toString() {
    return r'serviceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Service?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Service?> create(Ref ref) {
    final argument = this.argument as String;
    return service(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceHash() => r'95e92e3cc1ce7de21fe9cda745ee122ca014a745';

/// Provider for a single service by ID.

final class ServiceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Service?>, String> {
  ServiceFamily._()
      : super(
          retry: null,
          name: r'serviceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a single service by ID.

  ServiceProvider call(
    String id,
  ) =>
      ServiceProvider._(argument: id, from: this);

  @override
  String toString() => r'serviceProvider';
}
