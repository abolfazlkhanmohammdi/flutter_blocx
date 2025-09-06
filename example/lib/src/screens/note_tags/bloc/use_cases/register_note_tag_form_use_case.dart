import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_data.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class RegisterNoteTagUseCase extends BaseUseCase<NoteTag> {
  final NoteTagFormData formData;

  RegisterNoteTagUseCase({required this.formData});

  @override
  Future<UseCaseResult<NoteTag>> perform() async {
    var registerResult = await NoteTagJsonRepository().create(formData: formData);
    if (!registerResult.ok) {
      return UseCaseResult.failure(StateError("Failed to register note tag"));
    }
    return UseCaseResult.success(NoteTag.fromMap(registerResult.data.first));
  }
}
