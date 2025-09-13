import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

enum InputFieldType {
  text,
  email,
  password,
  number,
  multiline,
  date,
  search,
}

class CustomInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final InputFieldType type;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const CustomInputField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.type = InputFieldType.text,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onTap,
    this.onChanged,
    this.keyboardType,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppStyles.paddingS),
        ],
        _buildTextField(),
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: AppStyles.paddingXS),
          _buildHelperText(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        text: widget.label!,
        style: AppStyles.labelMedium(context).copyWith(
          color: _isFocused
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (widget.required)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.type == InputFieldType.password ? _obscureText : false,
      keyboardType: widget.keyboardType ?? _getKeyboardType(),
      textInputAction: widget.textInputAction ?? _getTextInputAction(),
      maxLines: _getMaxLines(),
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
      validator: widget.validator,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: AppStyles.bodyLarge(context).copyWith(
        color: widget.enabled
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppStyles.bodyLarge(context).copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _isFocused
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
        suffixIcon: _buildSuffixIcon(),
        errorText: widget.errorText,
        filled: true,
        fillColor: widget.enabled
            ? (_isFocused
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Theme.of(context).colorScheme.surfaceVariant)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.paddingM,
          vertical: AppStyles.paddingM,
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == InputFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.type == InputFieldType.search) {
      return Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
    
    if (widget.suffixIcon != null && widget.onSuffixIconPressed != null) {
      return IconButton(
        icon: widget.suffixIcon!,
        onPressed: widget.onSuffixIconPressed,
      );
    }
    
    return widget.suffixIcon;
  }

  Widget _buildHelperText() {
    final text = widget.errorText ?? widget.helperText;
    final color = widget.errorText != null
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Text(
      text!,
      style: AppStyles.labelSmall(context).copyWith(color: color),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case InputFieldType.email:
        return TextInputType.emailAddress;
      case InputFieldType.number:
        return TextInputType.number;
      case InputFieldType.multiline:
        return TextInputType.multiline;
      case InputFieldType.date:
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case InputFieldType.multiline:
        return TextInputAction.newline;
      case InputFieldType.search:
        return TextInputAction.search;
      default:
        return TextInputAction.next;
    }
  }

  int? _getMaxLines() {
    if (widget.maxLines != null) return widget.maxLines;
    
    switch (widget.type) {
      case InputFieldType.multiline:
        return 3;
      case InputFieldType.password:
        return 1;
      default:
        return 1;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case InputFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }
}

// Widgets spécialisés
class SearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      type: InputFieldType.search,
      hint: hint ?? 'Rechercher...',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
    );
  }
}

class PasswordField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool required;

  const PasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      type: InputFieldType.password,
      label: label ?? 'Mot de passe',
      hint: hint,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      required: required,
      prefixIcon: Icons.lock_outline,
    );
  }
}