import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A controller-free text field that responds to external [initialValue] changes
/// via [didUpdateWidget], following the Form BLoC Architecture pattern.
///
/// The parent screen owns ZERO controllers. All state lives in the Notifier.
/// When the Notifier loads existing data (edit mode), [didUpdateWidget] fires
/// and updates the internal controller automatically — no postFrameCallback needed
/// in the screen itself.
///
/// Usage:
/// ```dart
/// SmartFormField(
///   hint: 'Item title',
///   initialValue: state.title,
///   onChanged: notifier.updateTitle,
/// )
/// ```
class SmartFormField extends StatefulWidget {
  final String? initialValue;
  final String hint;
  final String? label; // Optional micro-label above the field
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final String? errorText;
  final Widget? suffix; // e.g. a chevron or clear button
  final bool readOnly;
  final VoidCallback? onTap;
  final TextStyle? style;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const SmartFormField({
    super.key,
    this.initialValue,
    required this.hint,
    this.label,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.errorText,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.style,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  State<SmartFormField> createState() => _SmartFormFieldState();
}

class _SmartFormFieldState extends State<SmartFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  /// Core of the pattern: respond to external value changes.
  /// This fires when the Notifier updates state (e.g., loading an existing item).
  @override
  void didUpdateWidget(SmartFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller if the parent's explicitly provided initialValue
    // has changed, AND it's different from what the user has currently typed.
    // This allows Riverpod state to update without hijacking the active cursor.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      if (!_focusNode.hasFocus) {
        final newValue = widget.initialValue ?? '';
        // Safe update: preserve cursor position at end
        _controller.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          keyboardType: widget.maxLines > 1
              ? TextInputType.multiline
              : widget.keyboardType,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          style: widget.style ??
              TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.grey[400],
              fontSize: 15,
            ),
            errorText: widget.errorText,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            suffixIcon: widget.suffix,
          ),
        ),
      ],
    );
  }
}
