import 'dart:convert';
import 'dart:isolate';

// Sample DTO for parser illustration
class ItemDto {
  final int id;
  final String title;

  const ItemDto({required this.id, required this.title});

  factory ItemDto.fromJson(Map<String, dynamic> json) => ItemDto(
        id: json['id'] as int,
        title: json['title'] as String,
      );
}

abstract final class LargePayloadParser {
  /// Offloads heavy JSON decoding and DTO mapping to a separate Isolate in ONE batch
  static Future<List<ItemDto>> parseItemsPayload(String rawJson) async {
    return Isolate.run(() {
      // Executed entirely on a background Isolate
      final List<dynamic> decodedList = jsonDecode(rawJson) as List<dynamic>;

      // Batch mapping inside the isolate loop
      return decodedList
          .map((json) => ItemDto.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
}
