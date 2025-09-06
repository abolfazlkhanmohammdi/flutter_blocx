import 'dart:convert';

class ResponseWrapper<T> {
  final bool ok;
  final List<T> data;

  const ResponseWrapper({required this.ok, required this.data});

  factory ResponseWrapper.fromMap(Map<String, dynamic> map, T Function(dynamic json) itemFromJson) {
    return ResponseWrapper<T>(
      ok: map['ok'] as bool? ?? false,
      data: (map['data'] as List<dynamic>? ?? []).map((e) => itemFromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toMap(Object Function(T item) itemToJson) {
    return {'ok': ok, 'data': data.map(itemToJson).toList()};
  }

  String toJson(Object Function(T item) itemToJson) => jsonEncode(toMap(itemToJson));

  static ResponseWrapper<T> fromJson<T>(String source, T Function(dynamic json) itemFromJson) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return ResponseWrapper.fromMap(map, itemFromJson);
  }

  @override
  String toString() => 'ResponseWrapper(ok:$ok, data:${data.length})';
}
