import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/core/use_cases/base_use_case.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';

class DeleteNoteUseCase extends BaseUseCase<Note, bool> {
  @override
  Future<BlocxUseCaseResult<bool>> perform(Note input) async {
    var result = await NotesJsonRepository().delete(input.uuid);
    return UseCaseResult.success(result);
  }
}
