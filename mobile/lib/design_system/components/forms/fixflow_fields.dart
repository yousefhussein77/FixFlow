import 'package:flutter/material.dart';

class FixFlowTextField extends StatefulWidget {
  const FixFlowTextField({
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.error,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.fieldKey,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint, helper, error;
  final int? maxLength;
  final int maxLines;
  final bool obscureText, enabled, readOnly;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Key? fieldKey;

  @override
  State<FixFlowTextField> createState() => _FixFlowTextFieldState();
}

class _FixFlowTextFieldState extends State<FixFlowTextField> {
  late bool obscured = widget.obscureText;

  @override
  void didUpdateWidget(covariant FixFlowTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) => TextField(
    key: widget.fieldKey,
    controller: widget.controller,
    enabled: widget.enabled,
    readOnly: widget.readOnly,
    obscureText: obscured,
    maxLength: widget.maxLength,
    maxLines: widget.obscureText ? 1 : widget.maxLines,
    keyboardType: widget.keyboardType,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      helperText: widget.helper,
      errorText: widget.error,
      prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
      suffixIcon: widget.obscureText
          ? IconButton(
              tooltip: obscured ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
              onPressed: () => setState(() => obscured = !obscured),
              icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
            )
          : null,
    ),
  );
}

class FixFlowDropdownField<T> extends StatelessWidget {
  const FixFlowDropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.error,
    super.key,
  });
  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? error;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    onChanged: onChanged,
    isExpanded: true,
    decoration: InputDecoration(labelText: label, errorText: error),
    items: [
      for (final item in items)
        DropdownMenuItem(value: item, child: Text(itemLabel(item))),
    ],
  );
}

class FixFlowSearchField extends StatelessWidget {
  const FixFlowSearchField({
    required this.label,
    this.controller,
    this.hint,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => FixFlowTextField(
    label: label,
    controller: controller,
    hint: hint,
    keyboardType: TextInputType.text,
    onChanged: onChanged,
    prefixIcon: Icons.search,
  );
}
