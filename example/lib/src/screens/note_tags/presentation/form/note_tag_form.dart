import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/bloc/form/note_tag_form_bloc.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_data.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_payload.dart';
import 'package:flutter/material.dart';
import 'package:blocx_flutter/form_widget.dart';

class NoteTagForm extends FormWidget<NoteTagFormPayload> {
  const NoteTagForm({super.key, required super.payload});

  @override
  State<NoteTagForm> createState() => _NoteTagFormState();
}

class _NoteTagFormState
    extends FormWidgetState<NoteTagForm, NoteTagFormData, NoteTagFormPayload, NoteTagFormKey> {
  _NoteTagFormState() : super(bloc: NoteTagFormBloc());

  @override
  formWidget(BuildContext context, FormBlocState<NoteTagFormData, NoteTagFormKey> state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isUpdate ? "Edit note tag ${payload!.toBeEdited!.name}" : "Create a new Note Tag",
            style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
          ),
          textField(
            NoteTagFormKey.name,
            type: TextFieldType.outlined,
            options: BlocXTextFieldOptions(maxLines: 10, minLines: 1),
          ),
          FormButtonRow<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey>(
            isFormValid: isFormValid(state),
            formState: state,
            registerText: isUpdate ? "Edit" : "Register",
            registerSubmittingText: "Registering...",
          ),
        ],
      ),
    );
  }

  @override
  void applyInitialDataToForm(NoteTagFormData formData) {
    getTextEditingController(NoteTagFormKey.name).text = formData.name;
  }

  @override
  void onFormSubmitted(FormStateFormSubmitted<NoteTagFormData, NoteTagFormKey> state) {
    Navigator.of(context).pop(state.submittedData);
  }

  @override
  bool get isUpdate => payload?.toBeEdited != null;
}
