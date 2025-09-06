import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';

class DeleteNoteUseCase extends BaseUseCase<bool> {
  final Note note;
  DeleteNoteUseCase({required this.note});
  @override
  Future<UseCaseResult<bool>> perform() async {
    var result = await NotesJsonRepository().delete(note.uuid);
    return UseCaseResult.success(result);
  }
}
