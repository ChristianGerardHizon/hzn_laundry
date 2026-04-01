/// Utility functions for semantic version comparison.
///
/// Handles standard `major.minor.patch` format (e.g., "1.2.3").
abstract class VersionUtils {
  /// Compares two semantic version strings.
  ///
  /// Returns:
  /// - negative if [a] < [b]
  /// - zero if [a] == [b]
  /// - positive if [a] > [b]
  static int compare(String a, String b) {
    final partsA = _parse(a);
    final partsB = _parse(b);

    for (var i = 0; i < 3; i++) {
      final diff = partsA[i] - partsB[i];
      if (diff != 0) return diff;
    }

    return 0;
  }

  /// Returns true if [current] is below [target].
  static bool isBelow(String current, String target) {
    return compare(current, target) < 0;
  }

  /// Parses a version string into [major, minor, patch].
  ///
  /// Handles missing parts gracefully (e.g., "1.2" → [1, 2, 0]).
  static List<int> _parse(String version) {
    final parts = version.split('.');
    return [
      parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0,
      parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
    ];
  }
}
