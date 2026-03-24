import 'package:flutter/material.dart';
import 'package:link_vault/core/res/colours.dart';

class CustomCollTextField extends StatefulWidget {
  const CustomCollTextField({
    required this.controller,
    required this.validator,
    this.labelText,
    super.key,
    this.onEditingCompleted,
    this.onSubmitted,
    this.onTapOutside,
    this.errorText,
    this.style,
    this.labelTextStyle,
    this.obscureText = false,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines,
    this.hintText = '',
  });
  final TextEditingController controller;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingCompleted;
  final void Function(PointerDownEvent)? onTapOutside;

  final String? errorText;
  final String? labelText;
  final bool obscureText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final TextStyle? labelTextStyle;
  final TextStyle? style;
  final int? maxLength;
  final int? maxLines;

  final String hintText;
  final String? Function(String?) validator;

  @override
  State<CustomCollTextField> createState() => _CustomCollTextFieldState();
}

class _CustomCollTextFieldState extends State<CustomCollTextField> {
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
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: RichText(
              text: TextSpan(
                text: widget.labelText,
                style: widget.labelTextStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: ColourPallette.black,
                    ),
                children: [
                  if (widget.isRequired)
                    TextSpan(
                      text: ' *',
                      style: widget.labelTextStyle?.copyWith(
                        color: ColourPallette.error,
                        fontSize: (widget.labelTextStyle?.fontSize ?? 16) - 2,
                      ),
                    ),
                ],
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          onEditingComplete: widget.onEditingCompleted,
          onFieldSubmitted: widget.onSubmitted,
          onTapOutside: widget.onTapOutside,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: _isObscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          // cursorHeight: 30,
          // cursorWidth: 2.0,
          cursorColor: ColourPallette.salemgreen,
          style: widget.style ??
              const TextStyle(
                color: ColourPallette.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
          decoration: InputDecoration(
            isDense: true,
            // contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            hintText: widget.hintText,
            errorText: widget.errorText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                    icon: _isObscure
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  )
                : null,
            labelStyle: const TextStyle(
              color: ColourPallette.salemgreen,
              fontWeight: FontWeight.w500,
            ),
            fillColor: ColourPallette.mystic.withOpacity(0.7),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: const BorderSide(
                color: ColourPallette.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Set the border radius here
              borderSide: BorderSide(
                color: ColourPallette.salemgreen.withOpacity(0.25),
                width: 1.5,
              ),
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
        ),
      ],
    );
  }
}
