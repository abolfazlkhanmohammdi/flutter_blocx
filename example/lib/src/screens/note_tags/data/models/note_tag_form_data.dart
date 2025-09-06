class NoteTagFormData {
  final String name;
  final int userId;
  final int? tagId;

  const NoteTagFormData({required this.name, required this.userId, this.tagId});

  // Allows updating fields; pass `tagId: null` to clear it.
  NoteTagFormData copyWith({
    String? name,
    int? userId,
    Object? tagId = _noValue, // sentinel so we can distinguish "not passed" vs "null"
  }) {
    return NoteTagFormData(
      name: name ?? this.name,
      userId: userId ?? this.userId,
      tagId: identical(tagId, _noValue) ? this.tagId : tagId as int?,
    );
  }

  static const Object _noValue = Object();
}
