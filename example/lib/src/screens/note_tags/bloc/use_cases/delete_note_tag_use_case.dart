import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/core/use_cases/base_use_case.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class DeleteNoteTagUseCase extends BaseUseCase<NoteTag, bool> {
  @override
  Future<BlocxUseCaseResult<bool>> perform(NoteTag noteTag) async {
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
