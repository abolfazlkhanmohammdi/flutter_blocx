import 'package:blocx_core/blocx_core.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/src/form/widgets/blocx_form_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/screen_manager/screen_manager_state.dart';

abstract class FormWidgetState<W extends FormWidget<P>, F, P, E extends Enum> extends ScreenManagerState<W> {
  late final FormBloc<F, P, E> bloc;
  GlobalKey<FormState> formKey = GlobalKey();

  final Map<E, TextEditingController> _controllersMap = {};

  @override
  void initState() {
    bloc = generateBloc();
    bloc.add(FormEventInit(payload: widget.payload));
    super.initState();
  }

  FormBloc<F, P, E> generateBloc();

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
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

  void applyInitialDataToForm(F formData) {}

  void onFormSubmitted(FormStateFormSubmitted<F, E> state) {}

  P? get payload => widget.payload;

  void changeListener(dynamic data, E key) {
    bloc.add(FormEventUpdateData(data: data, key: key));
  }

  @override
  ScreenManagerCubit get managerCubit => bloc.screenManagerCubit;
}
