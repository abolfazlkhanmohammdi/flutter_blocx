import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class DeleteNoteTagUseCase extends BaseUseCase<bool> {
  final NoteTag noteTag;
  DeleteNoteTagUseCase({required this.noteTag});
  @override
  Future<UseCaseResult<bool>> perform() async {
    var result = await NoteTagJsonRepository().delete(noteTag.id);
    if (!result.ok) {
      return UseCaseResult.failure(
        StateError("Failed to delete note tag. Please try again later."),
        stackTrace: StackTrace.current,
      );
    }
    return UseCaseResult.success(true);
  }
}
