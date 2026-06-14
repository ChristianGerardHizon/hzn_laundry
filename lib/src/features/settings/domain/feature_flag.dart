import 'package:dart_mappable/dart_mappable.dart';

part 'feature_flag.mapper.dart';

@MappableClass()
class FeatureFlag with FeatureFlagMappable {
  const FeatureFlag({
    required this.id,
    required this.key,
    required this.enabled,
    this.description,
  });

  final String id;
  final String key;
  final bool enabled;
  final String? description;
}
