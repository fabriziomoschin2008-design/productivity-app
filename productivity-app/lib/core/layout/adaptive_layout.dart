import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdaptiveLayout {
  AdaptiveLayout._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 900;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static double dialogWidth(
    BuildContext context,
    double preferredWidth, {
    double horizontalMargin = 32,
  }) {
    final availableWidth = MediaQuery.sizeOf(context).width - horizontalMargin;
    return math.min(preferredWidth, math.max(280, availableWidth));
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return isPhone(context)
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 28, vertical: 24);
  }

  static double editorHorizontalPadding(BuildContext context) {
    return isPhone(context) ? 16 : 40;
  }

  static double sidePanelWidth(
    BuildContext context, {
    double desktopWidth = 272,
  }) {
    return isCompact(context) ? double.infinity : desktopWidth;
  }
}
