// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'can_add_employee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the UI may offer "Add Employee" (employee limit not reached).
/// The server enforces the same rule.

@ProviderFor(canAddEmployee)
final canAddEmployeeProvider = CanAddEmployeeProvider._();

/// Whether the UI may offer "Add Employee" (employee limit not reached).
/// The server enforces the same rule.

final class CanAddEmployeeProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the UI may offer "Add Employee" (employee limit not reached).
  /// The server enforces the same rule.
  CanAddEmployeeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canAddEmployeeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canAddEmployeeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canAddEmployee(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canAddEmployeeHash() => r'2474bee502bb4b125483b37de6d7bb17e2f19daf';
