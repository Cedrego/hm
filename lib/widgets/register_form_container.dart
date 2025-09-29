import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_edit_text.dart';

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

class RegisterFormContainer extends StatelessWidget {
  const RegisterFormContainer({
    super.key,
    required this.title,
    required this.fields,
  });

  final String title;
  final List<CustomFormField> fields;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.whiteA700,
        border: Border.all(
          color: appTheme.blueGray100,
          width: 1,
        ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyleHelper.instance.headline24SemiBoldInter
          .copyWith(height: 1.25),
    );
  }

  List<Widget> _buildFormFields() {
    List<Widget> widgets = [];

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];

      if (i > 0) {
        widgets.add(SizedBox(height: field.topMargin ?? 16.h));
      }

      widgets.add(_buildFieldGroup(field));
    }

    return widgets;
  }

  Widget _buildFieldGroup(CustomFormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyleHelper.instance.title16RegularInter
              .copyWith(height: 1.25),
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
}