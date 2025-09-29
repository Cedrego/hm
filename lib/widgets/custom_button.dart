import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// CustomButton - A reusable button component with consistent styling
/// 
/// A customizable button widget that supports both auto-width and full-width layouts
/// with consistent Material Design styling including background color, text styling,
/// border radius, and padding.
/// 
/// @param text - The text to display on the button
/// @param onPressed - Callback function called when button is pressed
/// @param isFullWidth - Whether button should take full available width
/// @param margin - Optional margin around the button
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth,
    this.margin,
  });

  /// The text to display on the button
  final String text;

  /// Callback function called when button is pressed
  final VoidCallback? onPressed;

  /// Whether button should take full available width (defaults to false for auto width)
  final bool? isFullWidth;

  /// Optional margin around the button
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: (isFullWidth ?? false) ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.blueGray900,
          foregroundColor: appTheme.gray100,
          padding: EdgeInsets.symmetric(
            vertical: 8.h,
            horizontal: 30.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.h),
            side: BorderSide(
              color: appTheme.blueGray900,
              width: 1.h,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyleHelper.instance.title16RegularInter
              .copyWith(color: appTheme.gray100, height: 20.h / 16.fSize),
        ),
      ),
    );
  }
}
