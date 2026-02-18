import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
      textAlignVertical: TextAlignVertical.center,
      style: AppTheme.bodyLarge.copyWith(
        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
        height: 1.0, // Critical for vertical alignment with contentPadding
      ),
      cursorColor: AppTheme.primaryColor,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: AppTheme.bodyMedium.copyWith(
          color:
              (isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary)
                  .withOpacity(0.8),
        ),
        floatingLabelStyle: AppTheme.bodyMedium.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        hintStyle: AppTheme.bodyMedium.copyWith(
          color:
              (isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary)
                  .withOpacity(0.6),
        ),
        errorText: errorText,
        filled: true,
        fillColor: isDark ? AppTheme.darkSurface : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: 18, // Slightly more vertical space for a premium feel
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.primaryColor, size: 20)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: AppTheme.primaryColor, size: 20),
                onPressed: onSuffixTap,
              )
            : null,
      ),
    );
  }
}
