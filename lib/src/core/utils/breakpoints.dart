import 'package:flutter/widgets.dart';

/// Centralized responsive breakpoint definitions.
///
/// Breakpoints follow Material Design 3 guidelines:
/// - Mobile (compact): 0-599px — bottom nav + drawer
/// - Tablet medium: 600-899px — nav rail (shell)
/// - Tablet large: 900-1199px — expandable sidebar
/// - Desktop (expanded): 1200px+
///
/// Content layouts use a separate [multiColumn] threshold so portrait tablets
/// (~600px window, ~520px content after the rail) get stacked/mobile content
/// while keeping tablet chrome.
abstract class Breakpoints {
  /// Mobile breakpoint (< 600px). Shell uses bottom nav below this.
  static const double mobile = 600;

  /// Minimum window/content width for side-by-side multi-column content
  /// (master-detail, POS split, kanban columns). Below this, use stacked layouts.
  static const double multiColumn = 840;

  /// Tablet large breakpoint (600px - 1200px shell chrome switch at this value).
  static const double tablet = 900;

  /// Desktop breakpoint (>= 1200px).
  static const double desktop = 1200;

  /// Minimum width for a kanban status column when shown side-by-side.
  static const double minKanbanColumnWidth = 260;

  /// Returns true if the screen width is less than [mobile] breakpoint.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  /// Returns true if the screen width is at least [mobile] breakpoint.
  /// Use for shell chrome (nav rail vs bottom nav), not for multi-column content.
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobile;

  /// Returns true if width is below [multiColumn] — prefer stacked/mobile content
  /// even when the shell shows a tablet nav rail (e.g. 600×1007 portrait).
  static bool isCompactContent(BuildContext context) =>
      MediaQuery.sizeOf(context).width < multiColumn;

  /// Returns true if [maxWidth] is wide enough for multi-column content layouts.
  /// Prefer this inside [LayoutBuilder] over window-only checks.
  static bool canUseMultiColumn(double maxWidth) =>
      maxWidth >= multiColumn;

  /// Returns true if the screen width supports multi-column content layouts.
  /// Window-based fallback for shells and route redirects.
  static bool isMultiColumnOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= multiColumn;

  /// Returns true if the screen width is at least [tablet] breakpoint.
  static bool isTabletLargeOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Returns true if the screen width is at least [desktop] breakpoint.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
