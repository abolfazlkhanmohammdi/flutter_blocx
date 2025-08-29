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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocConsumer<FormBloc<F, P, E>, FormBlocState<F, E>>(
        builder: blocBuilder,
        buildWhen: (_, c) => c.shouldRebuild,
        listener: blocListener,
        listenWhen: (_, c) => c.shouldListen,
      ),
    );
  }

  bool get wrapInList => false;

  String get registerText;

  String get submittingText;

  String get cancelButtonText => "cancel";

  void blocListener(BuildContext context, FormBlocState<F, E> state) {}

  Widget blocBuilder(BuildContext context, FormBlocState<F, E> state) {
    return Form(key: formKey, child: wrapInList ? listedForm(context, state) : columnForm(context, state));
  }

  Widget listedForm(BuildContext context, FormBlocState<F, E> state) {
    return Column(
      spacing: formVerticalSpacing,
      children: [
        ?topWidget(context, state),
        Expanded(child: ListView(children: formMembers(context, state))),
        bottomWidget(context, state),
      ],
    );
  }

  Widget columnForm(BuildContext context, FormBlocState<F, E> state) {
    return Column(
      spacing: formVerticalSpacing,

      children: [?topWidget(context, state), ...formMembers(context, state), bottomWidget(context, state)],
    );
  }

  Widget? topWidget(BuildContext context, FormBlocState<F, E> state) {
    return null;
  }

  List<Widget> formMembers(BuildContext context, FormBlocState<F, E> state);

  Widget bottomWidget(BuildContext context, FormBlocState<F, E> state) {
    return FormButtonRow(
      formState: state,
      registerText: registerText,
      registerSubmittingText: submittingText,
      popButtonText: cancelButtonText,
    );
  }

  BlocXFormTextField<F, P, E> textField(
    E key, {
    BlocXTextFieldOptions? options,
    FormFieldValidator? validator,
  }) {
    return BlocXFormTextField<F, P, E>(
      formKey: key,
      textFieldOptions: options ?? BlocXTextFieldOptions(),
      controller: getTextEditingController(key),
      validator: validator,
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
}
