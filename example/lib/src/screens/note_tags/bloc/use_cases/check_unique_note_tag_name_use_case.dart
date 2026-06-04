import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/core/use_cases/base_use_case.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class CheckUniqueNoteTagNameUseCase extends BaseUseCase<String, bool> {
  @override
  Future<BlocxUseCaseResult<bool>> perform(String name) async {
    var result = await NoteTagJsonRepository().isNameAvailable(name);
    return UseCaseResult.success(result);
  }
}
