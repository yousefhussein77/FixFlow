import 'package:flutter/material.dart';

import '../../tokens/fixflow_spacing.dart';
import '../content/fixflow_surfaces.dart';

class FixFlowHistoryItem extends StatelessWidget {
  const FixFlowHistoryItem({
    required this.title,
    required this.timestamp,
    this.details,
    this.icon = Icons.history,
    super.key,
  });
  final String title, timestamp;
  final String? details;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: details == null ? null : Text(details!),
    trailing: Text(timestamp, style: Theme.of(context).textTheme.bodySmall),
  );
}

class FixFlowCommentItem extends StatelessWidget {
  const FixFlowCommentItem({
    required this.author,
    required this.role,
    required this.content,
    required this.timestamp,
    super.key,
  });
  final String author, role, content, timestamp;

  @override
  Widget build(BuildContext context) => FixFlowSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FixFlowAvatar(name: author),
            const SizedBox(width: FixFlowSpacing.xs),
            Expanded(
              child: Text(
                author,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(role, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: FixFlowSpacing.xs),
        Text(content),
        const SizedBox(height: FixFlowSpacing.xs),
        Text(timestamp, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class FixFlowPhotoTile extends StatelessWidget {
  const FixFlowPhotoTile({
    required this.label,
    this.image,
    this.loading = false,
    this.error,
    super.key,
  });
  final String label;
  final ImageProvider? image;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) => Semantics(
    image: image != null,
    label: label,
    child: AspectRatio(
      aspectRatio: 4 / 3,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!, textAlign: TextAlign.center))
            : image == null
            ? const Center(child: Icon(Icons.image_outlined, size: 48))
            : Image(image: image!, fit: BoxFit.cover),
      ),
    ),
  );
}
