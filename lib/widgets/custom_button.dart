import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? customColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final padding = _getPadding();
    final textStyle = _getTextStyle(context);

    Widget child = _buildChild(colors.textColor, textStyle);

    if (type == ButtonType.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colors.textColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          ),
        ),
        child: child,
      );
    }

    if (type == ButtonType.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textColor,
          side: BorderSide(color: colors.borderColor, width: 1.5),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.textColor,
        elevation: type == ButtonType.secondary ? 0 : AppStyles.elevationS,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
        ),
      ),
      child: child,
    );
  }

  Widget _buildChild(Color textColor, TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: textColor,
          ),
          const SizedBox(width: AppStyles.paddingS),
          Text(
            text,
            style: textStyle.copyWith(
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle.copyWith(
        color: textColor,
      ),
      textAlign: fullWidth ? TextAlign.center : null,
    );
  }

  _ButtonColors _getColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    
    switch (type) {
      case ButtonType.primary:
        return _ButtonColors(
          backgroundColor: customColor ?? colorScheme.primary,
          textColor: colorScheme.onPrimary,
          borderColor: customColor ?? colorScheme.primary,
        );
      
      case ButtonType.secondary:
        return _ButtonColors(
          backgroundColor: customColor?.withOpacity(0.1) ?? colorScheme.surfaceVariant,
          textColor: customColor ?? colorScheme.onSurfaceVariant,
          borderColor: customColor ?? colorScheme.outline,
        );
      
      case ButtonType.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: customColor ?? colorScheme.primary,
          borderColor: customColor ?? colorScheme.primary,
        );
      
      case ButtonType.text:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: customColor ?? colorScheme.primary,
          borderColor: Colors.transparent,
        );
      
      case ButtonType.danger:
        return _ButtonColors(
          backgroundColor: customColor ?? colorScheme.error,
          textColor: colorScheme.onError,
          borderColor: customColor ?? colorScheme.error,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingM,
          vertical: AppStyles.paddingS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingL,
          vertical: AppStyles.paddingM,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingXL,
          vertical: AppStyles.paddingL,
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return AppStyles.labelSmall(context);
      case ButtonSize.medium:
        return AppStyles.labelLarge(context);
      case ButtonSize.large:
        return AppStyles.titleMedium(context);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppStyles.iconS;
      case ButtonSize.medium:
        return AppStyles.iconM;
      case ButtonSize.large:
        return AppStyles.iconL;
    }
  }
}

class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

// Boutons spécialisés
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: CustomButton(
        text: text,
        onPressed: onPressed,
        type: ButtonType.primary,
        icon: icon,
        isLoading: isLoading,
        fullWidth: fullWidth,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: CustomButton(
        text: text,
        onPressed: onPressed,
        type: ButtonType.secondary,
        icon: icon,
        isLoading: isLoading,
        fullWidth: fullWidth,
      ),
    );
  }
}