import 'package:flutter/material.dart';

import '../../tokens/fixflow_spacing.dart';

class FixFlowSurface extends StatelessWidget {
  const FixFlowSurface({
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(FixFlowSpacing.sm),
    super.key,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    button: onTap != null,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class FixFlowMetadataRow extends StatelessWidget {
  const FixFlowMetadataRow({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });
  final String label, value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: FixFlowSpacing.half),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: FixFlowSpacing.xs),
        ],
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class FixFlowAvatar extends StatelessWidget {
  const FixFlowAvatar({required this.name, this.image, super.key});
  final String name;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty
        ? '?'
        : trimmed.characters.first.toUpperCase();
    return Semantics(
      image: true,
      label: name,
      child: CircleAvatar(
        foregroundImage: image,
        child: image == null ? Text(initial) : null,
      ),
    );
  }
}
