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
    bloc = (widget.bloc as BlocxFormBloc<F, P, E>?) ?? generateBloc;
    bloc.add(BlocxFormEventInit(payload: widget.payload));
    super.initState();
  }

  @override
  void onRetry(BuildContext context) {
    super.onRetry(context);
    reload();
  }

  /// Re-initializes the form with [widget.payload].
  void reload() {
    bloc.add(BlocxFormEventInit(payload: widget.payload));
  }

  bool _isBlocFromContext = false;

  /// Instantiates or resolves the [BlocxFormBloc] for this screen.
  ///
  /// Defaults to resolving [BlocxFormBloc] from the nearest ancestor
  /// [BuildContext] via [context.read]. Override this getter to instantiate a
  /// specific bloc subtype manually.
  BlocxFormBloc<F, P, E> get generateBloc {
    _isBlocFromContext = true;
    return context.read<BlocxFormBloc<F, P, E>>();
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return BlocxFormView<F, P, E>(
      bloc: bloc,
      builder: _blocBuilder,
      listener: blocListener,
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
  ///
  /// ### Validation Precedence
  /// - **BlocX Reactive Validation (Recommended):** Defined on the bloc using
  ///   [BlocxFormValidator]. Validation errors are streamed into `state.errors`
  ///   and displayed via [InputDecoration.errorText].
  /// - **Flutter `validator` Hook:** An optional [FormFieldValidator] passed
  ///   here. When a parent [FormState.validate] executes, an error returned by
  ///   this hook takes visual precedence in [FormFieldState]. If this hook returns
  ///   `null`, any active bloc-level error for [key] remains displayed.
  BlocXFormTextField<F, P, E> textField(E key,
      {BlocXTextFieldOptions? options,
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
      TypeConverter? converter}) {
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
        typeConverter: converter);
  }

  /// Builds a [BlocxFormRegisterButton] connected to the current form [state].
  ///
  /// Pass [formState] to bind directly to a specific state snapshot instead of
  /// resolving from the bloc.
  BlocxFormRegisterButton<F, P, E> submitButton(
    String buttonText, {
    String? submitText,
    BlocxFormRegisterButtonOptions? options,
    VoidCallback? onPressed,
    RegisterButtonType? type,
    BlocxFormState<F, E>? formState,
  }) {
    return BlocxFormRegisterButton<F, P, E>(
      state: formState ?? state,
      buttonText: buttonText,
      submitText: submitText ?? buttonText,
      onPressed: onPressed,
      type: type ?? RegisterButtonType.filled,
      buttonOptions: options ?? const BlocxFormRegisterButtonOptions(),
    );
  }

  /// Builds a [BlocxFormButtonRow] connected to the current form [state].
  ///
  /// Pass [formState] to bind directly to a specific state snapshot instead of
  /// resolving from the bloc.
  BlocxFormButtonRow<F, P, E> formButtonRow(
    String registerText, {
    String? registerSubmittingText,
    String? secondButtonText,
    BlocxFormButtonRowOptions? options,
    VoidCallback? onRegisterPressed,
    VoidCallback? onSecondButtonPressed,
    RegisterButtonType? registerType,
    BlocxFormState<F, E>? formState,
  }) {
    final effectiveState = formState ?? state;
    return BlocxFormButtonRow<F, P, E>(
      formState: effectiveState,
      registerText: registerText,
      registerSubmittingText: registerSubmittingText ?? registerText,
      secondButtonText:
          secondButtonText ?? BlocXLocalizations.localizations.cancel,
      onRegisterPressed: effectiveState.isValid ? onRegisterPressed : null,
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
  ///
  /// Specify checked state and display options via [options].
  /// The [isChecked] parameter is deprecated in favor of `options.isChecked`.
  BlocxFormCheckbox<F, P, E> checkbox({
    required E key,
    @Deprecated(
      'Specify isChecked inside BlocxCheckboxOptions instead. '
      'This parameter will be removed in 2.0.0.',
    )
    bool? isChecked,
    BlocxCheckboxOptions? options,
  }) {
    final effectiveOptions = options != null
        ? (isChecked != null ? options.copyWith(isChecked: isChecked) : options)
        : BlocxCheckboxOptions(isChecked: isChecked ?? false);

    return BlocxFormCheckbox<F, P, E>(
      formKey: key,
      options: effectiveOptions,
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
  ///
  /// Updates controller text only when changed to avoid resetting the cursor,
  /// and preserves existing cursor selection (clamped to the new text length).
  void applyInitialDataToForm(F formData) {
    for (final key in keys) {
      final controller = _getTextEditingControllerIfExists(key);
      if (controller == null) continue;

      final value =
          formData.getFormattedValueByKey(key) ?? formData.getValueByKey(key);

      final newText = value?.toString() ?? '';
      if (controller.text != newText) {
        final currentSelection = controller.selection;
        final newOffset = currentSelection.isValid
            ? currentSelection.baseOffset.clamp(0, newText.length)
            : newText.length;

        controller.value = controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newOffset),
          composing: TextRange.empty,
        );
      }
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
  ///
  /// Defaults to `false` when [widget.bloc] was provided externally or resolved
  /// from ancestor context, and `true` when created internally.
  bool get autoCloseBloc => widget.bloc == null && !_isBlocFromContext;

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
