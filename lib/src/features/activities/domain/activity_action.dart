import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'activity_action.mapper.dart';

/// The type of action performed on a record.
@MappableEnum()
enum ActivityAction {
  create,
  update,
  delete;

  String get displayName => switch (this) {
        ActivityAction.create => 'Created',
        ActivityAction.update => 'Updated',
        ActivityAction.delete => 'Deleted',
      };

  IconData get icon => switch (this) {
        ActivityAction.create => Icons.add_circle_outline,
        ActivityAction.update => Icons.edit_outlined,
        ActivityAction.delete => Icons.delete_outline,
      };

  Color get color => switch (this) {
        ActivityAction.create => Colors.green,
        ActivityAction.update => Colors.blue,
        ActivityAction.delete => Colors.red,
      };
}
