import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary || type == ButtonType.secondary
                    ? Colors.white
                    : theme.colorScheme.primary,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.spacingS),
        ],
        Text(label, style: AppTheme.button),
      ],
    );

    final button = switch (type) {
      ButtonType.primary => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: content,
        ),
      ButtonType.secondary => ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
          ),
          child: content,
        ),
      ButtonType.outline => OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          child: content,
        ),
      ButtonType.text => TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: content,
        ),
    };

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: button,
      );
    }

    return button;
  }
}

