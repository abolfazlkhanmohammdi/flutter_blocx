import 'package:example/src/screens/note_tags/data/models/note_tag.dart';

class NoteTagFormPayload {
  final NoteTag? toBeEdited;
  final int userId;

  NoteTagFormPayload({this.toBeEdited, required this.userId});
}
