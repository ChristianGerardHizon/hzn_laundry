import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'failure.mapper.dart';

@MappableClass(discriminatorKey: 'type')
sealed class Failure with FailureMappable {
  final dynamic message;
  final StackTrace? stackTrace;
  final String? identifier;

  const Failure(this.message, this.stackTrace, this.identifier);

  /// Short user-facing copy. Never includes stack traces or raw exception dumps.
  String get messageString => displayErrorMessage(message);

  /// Resolves any thrown/[Failure] value to a short UI string.
  static String displayErrorMessage(Object? error) {
    if (error == null) return 'Something went wrong';
    if (error is Failure) return displayErrorMessage(error.message);
    if (error is ClientException) {
      final msg = error.response['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
      return 'Server request has failed';
    }
    if (error is JsonUnsupportedObjectError) return 'Unsupported object';
    if (error is String) {
      final trimmed = error.trim();
      if (trimmed.isEmpty) return 'Something went wrong';
      // Reject dumps that look like exception/stack traces
      if (trimmed.contains('ClientException') ||
          trimmed.contains('stackTrace') ||
          trimmed.contains('\n#') ||
          trimmed.startsWith('Error: GenericFailure')) {
        return 'Something went wrong';
      }
      return trimmed;
    }
    return 'Something went wrong';
  }

  static const fromMap = FailureMapper.fromMap;
  static const fromJson = FailureMapper.fromJson;

  static Failure handle(Object error, StackTrace stackTrace) {
    debugPrint(error.toString());
    debugPrint(stackTrace.toString());

    if (error is Failure) {
      return error;
    }

    if (error is MapperException) {
      return MapperFailure(error, stackTrace, 'mapper_error');
    }

    // Handle known auth-related errors
    if (error is ClientException) {
      debugPrint(error.response.toString());

      final code = error.statusCode;
      final message = error.response['message']?.toString() ?? '';
      if (code == 401 ||
          code == 403 ||
          (code == 400 && message.toLowerCase().contains('authenticate'))) {
        return AuthFailure(error, stackTrace, 'auth_error');
      }
    }

    // Handle user-cancelled errors (e.g., platform cancel actions)
    if (error.toString().contains('User cancelled')) {
      return CancelledFailure(error, stackTrace, 'user_cancelled');
    }

    // Report non-trivial errors to Sentry
    Sentry.captureException(error, stackTrace: stackTrace);

    // Handle presentation-related errors (UI layer)
    if (error is FormatException || error is StateError) {
      return PresentationFailure(error, stackTrace, 'presentation_error');
    }

    // Catch-all fallback
    return GenericFailure(error, stackTrace, 'generic_error');
  }
}

@MappableClass()
class PocketbaseFailure extends Failure with PocketbaseFailureMappable {
  const PocketbaseFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class AuthFailure extends Failure with AuthFailureMappable {
  const AuthFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class PresentationFailure extends Failure with PresentationFailureMappable {
  const PresentationFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class DataFailure extends Failure with DataFailureMappable {
  const DataFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class CancelledFailure extends Failure with CancelledFailureMappable {
  const CancelledFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class NoAuthFailure extends Failure with NoAuthFailureMappable {
  const NoAuthFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class GenericFailure extends Failure with GenericFailureMappable {
  const GenericFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}

@MappableClass()
class MapperFailure extends Failure with MapperFailureMappable {
  const MapperFailure([
    dynamic message,
    StackTrace? stackTrace,
    String? identifier,
  ]) : super(message, stackTrace, identifier);
}
