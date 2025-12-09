import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/src/form/widgets/blocx_form_checkbox.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/screen_manager/screen_manager_state.dart';

abstract class BlocxFormWidgetState<
  W extends FormWidget<P>,
  F extends BaseFormEntity<F, E>,
  P,
  E extends Enum
>
    extends ScreenManagerState<W> {
  late final BlocxFormBloc<F, P, E> bloc;

  final Map<E, TextEditingController> _controllersMap = {};

  @override
  void initState() {
    bloc = generateBloc();
    bloc.add(BlocxFormEventInit(payload: widget.payload));
    super.initState();
  }

  BlocxFormBloc<F, P, E> generateBloc();

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<BlocxFormBloc<F, P, E>, BlocxFormState<F, E>>(
        builder: _blocBuilder,
        buildWhen: (_, c) => c.shouldRebuild,
        listener: blocListener,
        listenWhen: (_, c) => c.shouldListen,
      ),
    );
  }

  @mustCallSuper
  void blocListener(BuildContext context, BlocxFormState<F, E> state) {
    if (state is BlocxFormStateApplyInitialDataToForm) {
      applyInitialDataToForm(state.formData);
    } else if (state is BlocxFormStateFormSubmitted<F, E>) {
      onFormSubmitted(state);
    } else if (state is BlocxFormStateFormUpdated) {
      onFormUpdated(state.formData);
    }
  }

  Widget _blocBuilder(BuildContext context, BlocxFormState<F, E> state) {
    return formWidget(context, state);
  }

  BlocXFormTextField<F, P, E> textField(
    E key, {
    BlocXTextFieldOptions? options,
    FormFieldValidator? validator,
    TextFieldType? type,
  }) {
    return BlocXFormTextField<F, P, E>(
      key: ValueKey(key),
      formKey: key,
      textFieldOptions: options ?? BlocXTextFieldOptions(),
      controller: getTextEditingController(key),
      validator: validator,
      textFieldType: type ?? TextFieldType.filled,
    );
  }

  BlocXFormDropdown<F, P, E, T> dropdown<T>(
    E key, {
    BlocXDropdownOptions? options,
    required List<DropdownMenuItem<T>> items,
  }) {
    return BlocXFormDropdown<F, P, E, T>(
      formKey: key,
      items: items,
      options: options ?? BlocXDropdownOptions(),
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

  TextEditingController? _getTextEditingControllerIfExists(E key) {
    return _controllersMap[key];
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _controllersMap.values) {
      controller.dispose();
    }
    if (autoCloseBloc) {
      bloc.close();
    }
  }

  double get formVerticalSpacing => 16;

  bool get isValid => bloc.state.errors.isEmpty;

  formWidget(BuildContext context, BlocxFormState<F, E> state);

  bool get isUpdate => widget.payload != null;

  void applyInitialDataToForm(F formData) {
    for (E key in keys) {
      var controller = _getTextEditingControllerIfExists(key);
      if (controller == null) continue;
      controller.text = formData.getFormattedValueByKey(key) ?? formData.getValueByKey(key);
    }
  }

  void onFormSubmitted(BlocxFormStateFormSubmitted<F, E> state) {}

  void submit() {
    bloc.add(BlocxFormEventSubmit());
  }

  P? get payload => widget.payload;

  void changeListener(dynamic data, E key) {
    bloc.add(BlocxFormEventUpdateData(data: data, key: key));
  }

  @override
  ScreenManagerCubit get managerCubit => bloc.screenManagerCubit;
  AutovalidateMode get autovalidateMode => AutovalidateMode.onUserInteraction;

  void setErrorToField(E key, String message) {
    bloc.add(BlocxFormEventSetErrorToField(message: message, key: key));
  }

  void setTimedErrorToField(E key, String message, {Duration? duration}) {
    bloc.add(BlocxFormEventSetTimedErrorToField(message: message, key: key, duration: duration));
  }

  void clearFieldError(E key, {String? message}) {
    bloc.add(BlocxFormEventClearFieldError(key: key, message: message));
  }

  bool get autoCloseBloc => true;

  void onFormUpdated(F formData) {}

  List<E> get keys;
}
