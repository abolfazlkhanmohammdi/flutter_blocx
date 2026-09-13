import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_screen_manager_state.dart';

/// Base state class for screens that host a [BlocxFormBloc].
///
/// Extends [BlocxScreenManagerState] so all screen-manager side effects,
/// such as snackbars, error pages, and pop events, are handled automatically.
///
/// Type parameters:
///
/// - [W]: The [BlocxFormWidget] subclass this state belongs to.
/// - [F]: The immutable form entity type.
/// - [P]: The optional payload type for edit/update forms.
/// - [E]: The form field enum type.
abstract class BlocxFormWidgetState<
    W extends BlocxFormWidget<P>,
    F extends BlocxBaseFormEntity<F, E>,
    P,
    E extends Enum> extends BlocxScreenManagerState<W> {
  /// The form bloc that drives this screen.
  ///
  /// Initialised in [initState] by [generateBloc].
  late final BlocxFormBloc<F, P, E> bloc;

  final Map<E, TextEditingController> _controllersMap = {};
  final Map<E, FocusNode> _focusNodes = {};

  @override
  void initState() {
    bloc = generateBloc();
    bloc.add(BlocxFormEventInit(payload: widget.payload));
    super.initState();
  }

  /// Instantiates the [BlocxFormBloc] for this screen.
  ///
  /// Called once in [initState]. Inject dependencies here.
  BlocxFormBloc<F, P, E> generateBloc();

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocProvider<BlocxFormBloc<F, P, E>>.value(
      value: bloc,
      child: BlocConsumer<BlocxFormBloc<F, P, E>, BlocxFormState<F, E>>(
        builder: _blocBuilder,
        buildWhen: (_, current) => current.shouldRebuild,
        listener: blocListener,
        listenWhen: (_, current) => current.shouldListen,
      ),
    );
  }

  /// Reacts to listen-only form states.
  ///
  /// Override this method to add screen-specific side effects, but call
  /// `super.blocListener(context, state)` to preserve built-in behaviour.
  @mustCallSuper
  void blocListener(BuildContext context, BlocxFormState<F, E> state) {
    if (state is BlocxFormStateApplyInitialDataToForm<F, E>) {
      applyInitialDataToForm(state.formData);
    } else if (state is BlocxFormStateFormSubmitted<F, E>) {
      onFormSubmitted(state);
    } else if (state is BlocxFormStateFormUpdated<F, E>) {
      onFormUpdated(
          state.formData, state.updatedKey, state.oldValue, state.newValue);
    }
  }

  Widget _blocBuilder(BuildContext context, BlocxFormState<F, E> state) {
    return formWidget(context, state);
  }

  /// Builds a [BlocXFormTextField] connected to [key].
  ///
  /// The returned text field uses a managed [TextEditingController].
  ///
  /// Frequently used values can be passed directly. Direct parameters override
  /// their corresponding values in [options].
  BlocXFormTextField<F, P, E> textField(
    E key, {
    BlocXTextFieldOptions? options,
    FormFieldValidator<String>? validator,
    TextFieldType? type,
    String? labelText,
    String? hintText,
    String? helperText,
    Widget? prefix,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool? obscureText,
    bool? enabled,
    bool? autofocus,
    bool? showClearButton,
    int? maxLines,
    int? errorMaxLines,
    int? minLines,
    int? maxLength,
  }) {
    final resolvedOptions = (options ?? const BlocXTextFieldOptions()).copyWith(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        prefix: prefix,
        suffix: suffix,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        enabled: enabled,
        autofocus: autofocus,
        showClearButton: showClearButton,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        errorMaxLines: errorMaxLines);

    return BlocXFormTextField<F, P, E>(
      key: ValueKey<E>(key),
      formKey: key,
      textFieldOptions: resolvedOptions,
      controller: getTextEditingController(key),
      validator: validator,
      textFieldType: type ?? defaultTextFieldType,
    );
  }

  /// Builds a [BlocxFormRegisterButton] connected to the current form [state].
  BlocxFormRegisterButton<F, P, E> submitButton(
    String buttonText, {
    String? submitText,
    BlocxFormRegisterButtonOptions? options,
    VoidCallback? onPressed,
    RegisterButtonType? type,
  }) {
    return BlocxFormRegisterButton<F, P, E>(
      state: state,
      buttonText: buttonText,
      submitText: submitText ?? buttonText,
      onPressed: onPressed,
      type: type ?? RegisterButtonType.filled,
      buttonOptions: options ?? const BlocxFormRegisterButtonOptions(),
    );
  }

  /// Builds a [BlocxFormButtonRow] connected to the current form [state].
  BlocxFormButtonRow<F, P, E> formButtonRow(
    String registerText, {
    String? registerSubmittingText,
    String? secondButtonText,
    BlocxFormButtonRowOptions? options,
    VoidCallback? onRegisterPressed,
    VoidCallback? onSecondButtonPressed,
    RegisterButtonType? registerType,
  }) {
    return BlocxFormButtonRow<F, P, E>(
      formState: state,
      registerText: registerText,
      registerSubmittingText: registerSubmittingText ?? registerText,
      secondButtonText:
          secondButtonText ?? BlocXLocalizations.localizations.cancel,
      onRegisterPressed: state.isValid ? onRegisterPressed : null,
      onSecondButtonPressed: onSecondButtonPressed,
      registerType: registerType ?? RegisterButtonType.filled,
      options: options ?? const BlocxFormButtonRowOptions(),
    );
  }

  /// Builds a [BlocXFormDropdown] connected to [key].
  BlocXFormDropdown<F, P, E, T> dropdown<T>(
    E key, {
    BlocXDropdownOptions? options,
    required List<DropdownMenuItem<T>> items,
  }) {
    return BlocXFormDropdown<F, P, E, T>(
      formKey: key,
      items: items,
      options: options ?? const BlocXDropdownOptions(),
    );
  }

  /// Builds a [BlocxFormCheckbox] connected to [key].
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

  /// Returns the managed [TextEditingController] for [key].
  ///
  /// Creates the controller if it does not already exist.
  TextEditingController getTextEditingController(E key) {
    return _controllersMap.putIfAbsent(key, TextEditingController.new);
  }

  TextEditingController? _getTextEditingControllerIfExists(E key) {
    return _controllersMap[key];
  }

  @override
  void dispose() {
    for (final controller in _controllersMap.values) {
      controller.dispose();
    }
    _controllersMap.clear();

    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();

    if (autoCloseBloc) {
      bloc.close();
    }

    super.dispose();
  }

  /// Vertical spacing between form fields.
  double get formVerticalSpacing => 16;

  /// Whether the current form state has no validation errors.
  bool get isValid => bloc.state.isValid;

  /// Builds the form UI from the current [state].
  Widget formWidget(BuildContext context, BlocxFormState<F, E> state);

  /// Whether this screen is in update/edit mode.
  bool get isUpdate => widget.payload != null;

  /// Hydrates managed text controllers from [formData].
  ///
  /// Called automatically when [BlocxFormStateApplyInitialDataToForm] is
  /// emitted.
  void applyInitialDataToForm(F formData) {
    for (final key in keys) {
      final controller = _getTextEditingControllerIfExists(key);
      if (controller == null) continue;

      final value =
          formData.getFormattedValueByKey(key) ?? formData.getValueByKey(key);

      controller.text = value?.toString() ?? '';
    }
  }

  /// Called when [BlocxFormStateFormSubmitted] is emitted.
  void onFormSubmitted(BlocxFormStateFormSubmitted<F, E> state) {}

  /// Dispatches [BlocxFormEventSubmit].
  void submit() {
    bloc.add(BlocxFormEventSubmit());
  }

  /// The current widget payload.
  P? get payload => widget.payload;

  /// Dispatches a manual field update for [key].
  void changeListener(dynamic data, E key) {
    bloc.add(BlocxFormEventUpdateData<E>(data: data, key: key));
  }

  @override
  ScreenManagerCubit get managerCubit => bloc.screenManagerCubit;

  /// The default [AutovalidateMode] for native form fields.
  AutovalidateMode get autovalidateMode => AutovalidateMode.onUserInteraction;

  /// Adds a persistent error to [key].
  void setErrorToField(E key, String message) {
    bloc.add(BlocxFormEventSetErrorToField<E>(message: message, key: key));
  }

  /// Adds a timed error to [key].
  void setTimedErrorToField(E key, String message, {Duration? duration}) {
    bloc.add(
      BlocxFormEventSetTimedErrorToField<E>(
        message: message,
        key: key,
        duration: duration,
      ),
    );
  }

  /// Clears errors for [key].
  ///
  /// Pass [message] to clear only one specific error.
  void clearFieldError(E key, {String? message}) {
    bloc.add(BlocxFormEventClearFieldError<E>(key: key, message: message));
  }

  /// Whether [bloc] is closed when this state is disposed.
  bool get autoCloseBloc => true;

  /// Called when [BlocxFormStateFormUpdated] is emitted.
  void onFormUpdated(F formData, E updatedKey, oldValue, newValue) {}

  /// The list of field keys controlled by managed text controllers.
  List<E> get keys;

  /// Returns the managed [FocusNode] for [key].
  ///
  /// Creates the focus node if it does not already exist.
  FocusNode getFocusNode(E key) {
    return _focusNodes.putIfAbsent(key, FocusNode.new);
  }

  /// Focuses the first form field that currently has an error.
  void requestFocusOnError(BlocxFormState<F, E> state) {
    if (state.errors.isEmpty) return;

    final firstErrorKey = state.errors.keys.first;
    _focusNodes[firstErrorKey]?.requestFocus();
  }

  /// The current form state.
  BlocxFormState<F, E> get state => bloc.state;
  TextFieldType get defaultTextFieldType => TextFieldType.filled;
}
