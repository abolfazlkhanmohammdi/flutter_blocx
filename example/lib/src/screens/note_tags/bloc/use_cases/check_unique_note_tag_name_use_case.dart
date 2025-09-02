import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class CheckUniqueNoteTagNameUseCase extends BaseUseCase<bool> {
  final String name;

  CheckUniqueNoteTagNameUseCase({required this.name});
  @override
  Future<UseCaseResult<bool>> perform() async {
    var result = await NoteTagJsonRepository().isNameAvailable(name);
    return UseCaseResult.success(result);
  }
}
