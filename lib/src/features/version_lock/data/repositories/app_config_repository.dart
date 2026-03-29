import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../domain/app_config.dart';
import '../dto/app_config_dto.dart';

part 'app_config_repository.g.dart';

/// Read-only repository for fetching version config from the external
/// version-manager service at https://version-manager.fly.dev.
abstract class AppConfigRepository {
  /// Fetches the version record for the hizonelaundry application.
  ///
  /// Returns `null` if no record exists.
  FutureEither<AppConfig?> fetch();
}

/// Provides the [AppConfigRepository] instance.
@Riverpod(keepAlive: true)
AppConfigRepository appConfigRepository(Ref ref) {
  return AppConfigRepositoryImpl();
}

/// Implementation of [AppConfigRepository] using the external version-manager.
class AppConfigRepositoryImpl implements AppConfigRepository {
  static const _baseUrl = 'https://version-manager.fly.dev';

  static const _appId = 'ex29s5w2t8j8v29';

  @override
  FutureEither<AppConfig?> fetch() async {
    return TaskEither.tryCatch(
      () async {
        final uri = Uri.parse(
          '$_baseUrl/api/collections/versions/records'
          '?filter=application="$_appId"'
          '&perPage=1',
        );

        final response = await http.get(uri).timeout(
              const Duration(seconds: 10),
            );

        if (response.statusCode != 200) return null;

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final items = json['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) return null;

        final dto =
            AppConfigDto.fromJson(items.first as Map<String, dynamic>);
        return dto.toEntity();
      },
      Failure.handle,
    ).run();
  }
}
