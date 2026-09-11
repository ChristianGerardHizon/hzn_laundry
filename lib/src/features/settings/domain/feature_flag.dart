import 'package:dart_mappable/dart_mappable.dart';

part 'feature_flag.mapper.dart';

abstract class FeatureFlagKeys {
  static const emailUpdatesEnabled = 'emailUpdatesEnabled';
  static const requireMachine = 'requireMachine';
  static const requirePack = 'requirePack';
  static const requireStorage = 'requireStorage';
  static const consumableUsage = 'consumableUsage';
}

@MappableClass()
class FeatureFlag with FeatureFlagMappable {
  const FeatureFlag({
    required this.id,
    required this.key,
    required this.enabled,
    this.description,
    this.organizationId,
  });

  final String id;
  final String key;
  final bool enabled;
  final String? description;
  final String? organizationId;
}
