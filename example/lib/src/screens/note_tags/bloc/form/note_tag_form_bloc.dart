import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/check_unique_note_tag_name_use_case.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/register_note_tag_form_use_case.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/update_note_tag_form_use_case.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_data.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_payload.dart';

class NoteTagFormBloc extends FormBloc<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey>
    with UniqueFieldValidatorMixin<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey> {
  NoteTagFormBloc() : super(ScreenManagerCubit(), NoteTagFormData(name: "", userId: -1));

  // @override
  // bool get isUpdate => payload!;
  @override
  NoteTagFormData applyPayloadToFormData(NoteTagFormPayload payload) {
    return NoteTagFormData(
      name: payload.toBeEdited?.name ?? "",
      userId: payload.userId,
      tagId: payload.toBeEdited?.id,
    );
  }

  @override
  bool get isUpdate => payload!.toBeEdited != null;
  @override
  BaseUseCase get submitUseCase =>
      isUpdate ? UpdateNoteTagUseCase(formData: formData) : RegisterNoteTagUseCase(formData: formData);

  @override
  NoteTagFormData updateFormData(NoteTagFormKey key, data) {
    return switch (key) {
      NoteTagFormKey.name => formData.copyWith(name: data),
    };
  }

  @override
  List<NoteTagFormKey> get uniqueFieldKeys => [NoteTagFormKey.name];

  @override
  BaseUseCase<bool> useCaseIsUniqueValueAvailable(NoteTagFormKey key, value) {
    return switch (key) {
      NoteTagFormKey.name => CheckUniqueNoteTagNameUseCase(name: value),
    };
  }
}

enum NoteTagFormKey { name }
