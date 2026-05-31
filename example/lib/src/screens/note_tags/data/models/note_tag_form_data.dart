import 'package:blocx_core/form_bloc.dart';
import 'package:example/src/screens/note_tags/bloc/form/note_tag_form_bloc.dart';

class NoteTagFormData extends BlocxBaseFormEntity<NoteTagFormData, NoteTagFormKey> {
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

  @override
  NoteTagFormData updateByKey(NoteTagFormKey key, value) {
    switch (key) {
      case NoteTagFormKey.name:
        return copyWith(name: value as String);

      case NoteTagFormKey.userId:
        return copyWith(userId: value as int);

      case NoteTagFormKey.tagId:
        return copyWith(tagId: value);
    }
  }

  @override
  dynamic getValueByKey(NoteTagFormKey key) {
    switch (key) {
      case NoteTagFormKey.name:
        return name;

      case NoteTagFormKey.userId:
        return userId;

      case NoteTagFormKey.tagId:
        return tagId;
    }
  }

  @override
  String get identifier => throw UnimplementedError();

  @override
  getFormattedValueByKey(NoteTagFormKey key) {
    // TODO: implement getFormattedValueByKey
    throw UnimplementedError();
  }
}
