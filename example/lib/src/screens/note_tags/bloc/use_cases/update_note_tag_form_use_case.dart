import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_data.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class UpdateNoteTagUseCase extends BaseUseCase<NoteTag> {
  final NoteTagFormData formData;
  UpdateNoteTagUseCase({required this.formData});

  @override
  Future<UseCaseResult<NoteTag>> perform() async {
    var updateResult = await NoteTagJsonRepository().update(formData.tagId!, name: formData.name);
    if (!updateResult.ok) {
      return UseCaseResult.failure(StateError("Failed to register note tag"));
    }
    return UseCaseResult.success(NoteTag.fromMap(updateResult.data.first));
  }
}
