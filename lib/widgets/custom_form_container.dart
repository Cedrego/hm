import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_button.dart';
import './custom_edit_text.dart';

/// CustomFormContainer - A reusable form container component that supports both login and registration forms
/// with consistent styling, validation support, and flexible field configuration. Provides scrollable content
/// with Material Design styling including bordered container, proper spacing, and responsive button layouts.
class CustomFormContainer extends StatelessWidget {
  const CustomFormContainer({
    super.key,
    required this.title,
    required this.fields,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.descriptiveText,
    this.isFullWidthButtons,
  });

  /// Title text displayed at the top of the form
  final String title;

  /// List of form field configurations
  final List<CustomFormField> fields;

  /// Text for the primary action button
  final String primaryButtonText;

  /// Callback for primary button press
  final VoidCallback onPrimaryPressed;

  /// Optional text for secondary action button
  final String? secondaryButtonText;

  /// Optional callback for secondary button press
  final VoidCallback? onSecondaryPressed;

  /// Optional descriptive text between buttons
  final String? descriptiveText;

  /// Whether buttons should be full width or auto width
  final bool? isFullWidthButtons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.whiteA700,
        border: Border.all(color: appTheme.blueGray100, width: 1),
        borderRadius: BorderRadius.circular(8.h),
      ),
      padding: EdgeInsets.all(22.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: 20.h),
            ..._buildFormFields(),
            _buildPrimaryButton(),
            if (descriptiveText != null) _buildDescriptiveText(),
            if (secondaryButtonText != null) _buildSecondaryButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the form title
  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyleHelper.instance.headline24SemiBoldInter.copyWith(
        height: 1.25,
      ),
    );
  }

  /// Builds the form fields dynamically
  List<Widget> _buildFormFields() {
    List<Widget> widgets = [];

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];

      // Add spacing between fields (except first)
      if (i > 0) {
        widgets.add(SizedBox(height: field.topMargin ?? 16.h));
      }

      widgets.add(_buildFieldGroup(field));
    }

    return widgets;
  }

  /// Builds a field group with label and input
  Widget _buildFieldGroup(CustomFormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyleHelper.instance.title16RegularInter.copyWith(
            height: 1.25,
          ),
        ),
        SizedBox(height: 2.h),
        CustomEditText(
          controller: field.controller,
          hintText: field.hintText,
          keyboardType: field.keyboardType ?? TextInputType.text,
          obscureText: field.obscureText ?? false,
          validator: field.validator,
          margin: field.inputMargin,
          onChanged: field.onChanged,
        ),
      ],
    );
  }

  /// Builds the primary action button
  Widget _buildPrimaryButton() {
    return CustomButton(
      text: primaryButtonText,
      onPressed: onPrimaryPressed,
      isFullWidth: isFullWidthButtons ?? false,
      margin: EdgeInsets.only(
        top: 34.h,
        right: isFullWidthButtons == true ? 16.h : 20.h,
        left: isFullWidthButtons == true ? 16.h : 0,
      ),
    );
  }

  /// Builds optional descriptive text
  Widget _buildDescriptiveText() {
    return Container(
      margin: EdgeInsets.only(top: 16.h, right: 66.h),
      child: Text(
        descriptiveText!,
        textAlign: TextAlign.center,
        style: TextStyleHelper.instance.title16RegularInter.copyWith(
          height: 1.0,
        ),
      ),
    );
  }

  /// Builds optional secondary button
  Widget _buildSecondaryButton() {
    return CustomButton(
      text: secondaryButtonText!,
      onPressed: onSecondaryPressed,
      isFullWidth: isFullWidthButtons ?? false,
      margin: EdgeInsets.only(
        top: 12.h,
        right: 16.h,
        bottom: 8.h,
        left: isFullWidthButtons == true ? 16.h : 0,
      ),
    );
  }
}

/// Data model for form field configuration
class CustomFormField {
  CustomFormField({
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText,
    this.validator,
    this.onChanged,
    this.inputMargin,
    this.topMargin,
  });

  /// Field label text
  final String label;

  /// Placeholder text for input
  final String hintText;

  /// Text editing controller
  final TextEditingController? controller;

  /// Keyboard input type
  final TextInputType? keyboardType;

  /// Whether to obscure text (for passwords)
  final bool? obscureText;

  /// Field validator function
  final FormFieldValidator<String>? validator;

  /// Input change callback
  final Function(String)? onChanged;

  /// Margin for input field
  final EdgeInsetsGeometry? inputMargin;

  /// Top margin before field group
  final double? topMargin;
}
