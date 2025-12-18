import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: child,
      );
    }

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

