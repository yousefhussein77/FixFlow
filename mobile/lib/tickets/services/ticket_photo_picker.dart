import 'package:flutter/services.dart';

import '../models/ticket_models.dart';

class TicketPhotoPicker {
  const TicketPhotoPicker({
    MethodChannel channel = const MethodChannel('fixflow/ticket_photos'),
  }) : _channel = channel;

  final MethodChannel _channel;

  Future<List<SelectedPhoto>> pick() async {
    final values =
        await _channel.invokeListMethod<Map<Object?, Object?>>('pickPhotos', {
          'max': 5,
        }) ??
        const [];
    return values
        .map(
          (value) => SelectedPhoto(
            name: value['name'] as String,
            mimeType: value['mimeType'] as String,
            bytes: value['bytes'] as Uint8List,
          ),
        )
        .toList();
  }
}
