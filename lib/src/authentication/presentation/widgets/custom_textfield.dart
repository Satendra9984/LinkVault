import 'package:flutter/material.dart';
import 'package:link_vault/core/res/colours.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    required this.controller,
    required this.labelText,
    required this.validator,
    super.key,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            widget.labelText,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          cursorColor: ColourPallette.salemgreen,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            isDense: true,
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
            labelStyle: const TextStyle(
              color: ColourPallette.salemgreen,
              fontWeight: FontWeight.w500,
            ),
            
            fillColor: ColourPallette.mystic.withOpacity(0.5),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              // borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: const BorderSide(color: Colors.red),
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
