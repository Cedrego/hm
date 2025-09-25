import 'package:flutter/material.dart';

import '../core/app_export.dart';

/**
 * CustomEditText - A reusable text input field component with consistent styling
 * 
 * Features:
 * - Customizable placeholder text
 * - Multiple keyboard input types (email, text, phone, etc.)
 * - Validation support
 * - Consistent border and background styling
 * - Responsive design using SizeUtils
 * - Configurable margins and focus handling
 * 
 * @param controller - TextEditingController for managing text input
 * @param hintText - Placeholder text shown when field is empty
 * @param keyboardType - Type of keyboard to display (email, text, phone, etc.)
 * @param validator - Function to validate input text
 * @param margin - External spacing around the text field
 * @param focusNode - FocusNode for managing focus state
 * @param obscureText - Whether to hide text input (for passwords)
 * @param enabled - Whether the field is enabled for input
 * @param onChanged - Callback when text changes
 * @param onTap - Callback when field is tapped
 */
class CustomEditText extends StatelessWidget {
  CustomEditText({
    Key? key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.margin,
    this.focusNode,
    this.obscureText,
    this.enabled,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  /// Controller for managing the text input
  final TextEditingController? controller;

  /// Placeholder text displayed when the field is empty
  final String? hintText;

  /// Type of keyboard to display for input
  final TextInputType? keyboardType;

  /// Function to validate the input text
  final FormFieldValidator<String>? validator;

  /// External margin spacing around the text field
  final EdgeInsetsGeometry? margin;

  /// Focus node for managing focus state
  final FocusNode? focusNode;

  /// Whether to obscure the text (for password fields)
  final bool? obscureText;

  /// Whether the text field is enabled
  final bool? enabled;

  /// Callback function when text changes
  final Function(String)? onChanged;

  /// Callback function when field is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType ?? TextInputType.text,
        obscureText: obscureText ?? false,
        enabled: enabled ?? true,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyleHelper.instance.title16RegularInter
            .copyWith(color: appTheme.colorFF0000),
        decoration: InputDecoration(
          hintText: hintText ?? '',
          hintStyle: TextStyleHelper.instance.title16RegularInter
              .copyWith(color: appTheme.gray_400),
          contentPadding: EdgeInsets.only(
            top: 10.h,
            right: 16.h,
            bottom: 6.h,
            left: 16.h,
          ),
          filled: true,
          fillColor: appTheme.white_A700,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.blue_gray_100,
              width: 1.h,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.blue_gray_100,
              width: 1.h,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.blue_gray_100,
              width: 1.h,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
        ),
      ),
    );
  }
}
