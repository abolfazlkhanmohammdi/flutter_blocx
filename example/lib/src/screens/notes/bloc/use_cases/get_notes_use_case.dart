import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

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
    if (noteTag != null) {
      return await noteTagNotes();
    }
    return await getAllNotes();
  }

  Future<UseCaseResult<Page<Note>>> noteTagNotes() async {
    var result = await NotesJsonRepository().getPaginated(
      offset: offset,
      limit: loadCount,
      tagId: noteTag!.id,
    );
    if (!result.ok) {
      return UseCaseResult.failure(StateError("error fetching notes"));
    }
    var converted = result.data.map((map) => Note.fromMap(map)).toList();
    for (int i = 0; i < converted.length; i++) {
      converted[i].user = user;
      converted[i].noteTag = noteTag;
    }
    return successResult(converted);
  }

  Future<UseCaseResult<Page<Note>>> getAllNotes() async {
    var notesResult = await NotesJsonRepository().getPaginated(offset: offset, limit: loadCount);
    if (!notesResult.ok) {
      return UseCaseResult.failure(StateError("error fetching notes"));
    }
    var notes = notesResult.data.map((map) => Note.fromMap(map)).toList();
    for (int i = 0; i < notes.length; i++) {
      var noteTagResult = await NoteTagJsonRepository().getById(notes[i].tagId);
      if (!noteTagResult.ok) {
        continue;
      }
      notes[i].noteTag = NoteTag.fromMap(noteTagResult.data.first);
      var userResult = await UserJsonRepository().getById(notes[i].noteTag!.userId);
      if (!userResult.ok) {
        continue;
      }
      notes[i].user = User.fromMap(userResult.data.first);
    }
    return successResult(notes);
  }
}
