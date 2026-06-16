import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Wraps content with max-width and centers on tablet/desktop so UI doesn't over-stretch.
class ResponsiveConstraint extends StatelessWidget {
  const ResponsiveConstraint({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isTablet = ResponsiveBreakpoints.of(context).between(MOBILE, TABLET);
    final maxW = (isDesktop ? maxWidth : (isTablet ? 800.0 : double.infinity))
        .toDouble();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

/// Responsive horizontal padding for body content.
double responsiveHorizontalPadding(BuildContext context) {
  return 14;
}

/// Responsive grid cross-axis count: mobile 2, tablet 3, desktop 4.
int responsiveGridCount(BuildContext context) {
  if (ResponsiveBreakpoints.of(context).largerThan(DESKTOP)) return 4;
  if (ResponsiveBreakpoints.of(context).largerThan(TABLET)) return 3;
  return 2;
}

/// Responsive list padding (horizontal).
EdgeInsets responsiveListPadding(BuildContext context) {
  final h = responsiveHorizontalPadding(context);
  return EdgeInsets.fromLTRB(h, 10, h, 72);
}
