import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/flutter_blocx.dart';
import 'package:blocx_flutter/form_widget.dart';
import 'package:blocx_flutter/src/form/widgets/blocx_form_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FormWidgetState<W extends FormWidget<P>, F, P, E extends Enum> extends BlocXWidgetState<W> {
  final FormBloc<F, P, E> bloc;
  GlobalKey<FormState> formKey = GlobalKey();

  final Map<E, TextEditingController> _controllersMap = {};

  FormWidgetState({required this.bloc});

  @override
  void initState() {
    super.initState();
    bloc.add(FormEventInit(payload: widget.payload));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocConsumer<FormBloc<F, P, E>, FormBlocState<F, E>>(
        builder: _blocBuilder,
        buildWhen: (_, c) => c.shouldRebuild,
        listener: blocListener,
        listenWhen: (_, c) => c.shouldListen,
      ),
    );
  }

  void blocListener(BuildContext context, FormBlocState<F, E> state) {
    if (state is FormStateApplyInitialDataToForm) {
      applyInitialDataToForm(state.formData);
    } else if (state is FormStateFormSubmitted<F, E>) {
      onFormSubmitted(state);
    }
  }

  Widget _blocBuilder(BuildContext context, FormBlocState<F, E> state) {
    return Form(key: formKey, child: formWidget(context, state));
  }

  BlocXFormTextField<F, P, E> textField(
    E key, {
    BlocXTextFieldOptions? options,
    FormFieldValidator? validator,
    TextFieldType? type,
  }) {
    return BlocXFormTextField<F, P, E>(
      formKey: key,
      textFieldOptions: options ?? BlocXTextFieldOptions(),
      controller: getTextEditingController(key),
      validator: validator,
      textFieldType: type ?? TextFieldType.filled,
    );
  }

  BlocxFormCheckbox<F, P, E> checkbox({
    required E key,
    required bool isChecked,
    BlocxCheckboxOptions? options,
  }) {
    return BlocxFormCheckbox<F, P, E>(
      formKey: key,
      options: options ?? BlocxCheckboxOptions(isChecked: isChecked),
    );
  }

  TextEditingController getTextEditingController(E key) {
    bool contains = _controllersMap.containsKey(key);
    if (!contains) {
      var controller = TextEditingController();
      _controllersMap[key] = controller;
      return controller;
    }
    return _controllersMap[key]!;
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _controllersMap.values) {
      controller.dispose();
    }
  }

  double get formVerticalSpacing => 16;

  bool additionalValidityChecks(FormBlocState<F, E> state) {
    return true;
  }

  isFormValid(FormBlocState<F, E> state) {
    return (formKey.currentState?.validate() ?? true) && additionalValidityChecks(state);
  }

  formWidget(BuildContext context, FormBlocState<F, E> state);

  bool get isUpdate => widget.payload != null;

  void applyInitialDataToForm(F formData);

  void onFormSubmitted(FormStateFormSubmitted<F, E> state);

  P? get payload => widget.payload;
}
