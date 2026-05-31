import 'package:blocx_core/form_bloc.dart';
import 'package:example/src/screens/note_tags/bloc/form/note_tag_form_bloc.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_data.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_payload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/form_widget.dart';

class NoteTagForm extends BlocxFormWidget<NoteTagFormPayload> {
  const NoteTagForm({super.key, required super.payload});

  @override
  State<NoteTagForm> createState() => _NoteTagFormState();
}

class _NoteTagFormState
    extends BlocxFormWidgetState<NoteTagForm, NoteTagFormData, NoteTagFormPayload, NoteTagFormKey> {
  _NoteTagFormState();

  @override
  formWidget(BuildContext context, BlocxFormState<NoteTagFormData, NoteTagFormKey> state) {
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
          BlocxFormButtonRow<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey>(
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
  void onFormSubmitted(BlocxFormStateFormSubmitted<NoteTagFormData, NoteTagFormKey> state) {
    Navigator.of(context).pop(state.submittedData);
  }

  @override
  bool get isUpdate => payload?.toBeEdited != null;

  @override
  BlocxFormBloc<NoteTagFormData, NoteTagFormPayload, NoteTagFormKey> generateBloc() => NoteTagFormBloc();

  @override
  List<NoteTagFormKey> get keys => NoteTagFormKey.values;
}
