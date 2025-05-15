import 'package:flutter/material.dart';
import 'package:link_vault/core/res/colours.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    required this.controller,
    required this.labelText,
    required this.validator,
    super.key,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Icon? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscure = false;

  @override
  void initState() {
    _isObscure = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final appTheme = Theme.of(context);
    final colorScheme = appTheme.colorScheme;
    final textTheme = appTheme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            widget.labelText,
            style: textTheme.titleMedium,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          cursorColor: colorScheme.primary,
          style: textTheme.titleMedium,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            isDense: false,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() {
                      _isObscure = !_isObscure;
                    }),
                    icon: _isObscure
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  )
                : null,
            labelStyle: textTheme.titleSmall,
            // fillColor: colorScheme.surface,
            // fillColor: colorScheme.secondary,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              // borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: BorderSide(color: colorScheme.error),
            ),
          ),
          obscureText: _isObscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
        ),
      ],
    );
  }
}
