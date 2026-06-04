import 'dart:async';

import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:example/src/core/blocs/form_bloc.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/check_unique_note_tag_name_use_case.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/register_note_tag_form_use_case.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/update_note_tag_form_use_case.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_data.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_payload.dart';

class NoteTagFormBloc extends FormBloc<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey>
    with BlocxUniqueFieldValidatorMixin<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey> {
  NoteTagFormBloc() : super(NoteTagFormData(name: "", userId: -1));

  @override
  FutureOr<NoteTagFormData> applyPayloadToFormData(NoteTagFormPayload payload) {
    return NoteTagFormData(
      name: payload.toBeEdited?.name ?? "",
      userId: payload.userId,
      tagId: payload.toBeEdited?.id,
    );
  }

  @override
  bool get isUpdate => payload!.toBeEdited != null;

  @override
  BlocxUseCaseTask<BlocxBaseUseCase<NoteTagFormData, NoteTag>, NoteTagFormData> get submitUseCaseTask =>
      BlocxUseCaseTask(
        useCase: isUpdate ? UpdateNoteTagUseCase() : RegisterNoteTagUseCase(),
        inputBuilder: () => formData,
      );

  @override
  List<NoteTagFormKey> get uniqueFieldKeys => [NoteTagFormKey.name];

  @override
  BlocxUseCaseTask<BlocxBaseUseCase<dynamic, bool>, dynamic>? useCaseIsUniqueValueAvailable(
    NoteTagFormKey key,
    value,
  ) {
    var result = switch (key) {
      NoteTagFormKey.name => BlocxUseCaseTask(
        useCase: CheckUniqueNoteTagNameUseCase(),
        inputBuilder: () => value,
      ),
      _ => null,
    };
    return result;
  }
}

enum NoteTagFormKey { name, userId, tagId }
