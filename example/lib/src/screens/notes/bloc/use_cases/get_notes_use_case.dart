import 'dart:io';

import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class GetNotesUseCase extends PaginationUseCase<Note, (NoteTag, User)> {
  final User? user;
  final NoteTag? noteTag;

  GetNotesUseCase({
    required super.loadCount,
    required super.offset,
    required this.user,
    required this.noteTag,
  });

  @override
  Future<UseCaseResult<Page<Note>>> perform() async {
    var result = await NotesJsonRepository().getPaginated(
      offset: offset,
      limit: loadCount,
      tagId: noteTag?.id,
      userId: user?.id,
    );
    if (!result.ok) {
      throw HttpException("Could not search notes. Please try again later.");
    }
    var converted = result.data.map((e) => Note.fromMap(e)).toList();
    return successResult(converted);
  }
}
