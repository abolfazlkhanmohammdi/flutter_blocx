import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/src/form/widgets/blocx_form_checkbox.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_screen_manager_state.dart';

/// Base state class for screens that host a [BlocxFormBloc].
///
/// Extends [BlocxScreenManagerState] so all screen-manager side-effects
/// (snackBars, error pages, pop) are handled automatically.
///
/// ## Minimal implementation
///
/// 1. Create a [BlocxFormWidget] subclass that carries the payload [P].
/// 2. Extend [BlocxFormWidgetState] with the matching type parameters.
/// 3. Implement [generateBloc] to instantiate the bloc.
/// 4. Implement [formWidget] to build the form UI from the current state.
/// 5. Implement [keys] to list every field enum value that has a
///    [TextEditingController] (used for [applyInitialDataToForm]).
///
/// ```dart
/// class LoginScreenState
///     extends BlocxFormWidgetState<LoginScreen, LoginForm, void, LoginField> {
///   @override
///   BlocxFormBloc<LoginForm, void, LoginField> generateBloc() => LoginBloc();
///
///   @override
///   Widget formWidget(BuildContext context, BlocxFormState<LoginForm, LoginField> state) {
///     return Column(children: [
///       textField(LoginField.email),
///       textField(LoginField.password),
///       BlocxFormRegisterButton(state: state, buttonText: 'Login', submitText: 'Logging in…', onPressed: submit),
///     ]);
///   }
///
///   @override
///   List<LoginField> get keys => LoginField.values;
/// }
/// ```
///
/// ## Type parameters
///
/// - [W]: The [BlocxFormWidget] subclass this state belongs to.
/// - [F]: The immutable form entity. Must extend [BlocxBaseFormEntity].
/// - [P]: The optional payload type for edit/update forms. Use `void` for
///   create-only forms.
/// - [E]: The field enum type.
abstract class BlocxFormWidgetState<W extends BlocxFormWidget<P>, F extends BlocxBaseFormEntity<F, E>, P,
    E extends Enum> extends BlocxScreenManagerState<W> {
  /// The form bloc that drives this screen.
  ///
  /// Initialised in [initState] via [generateBloc].
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

  /// Reacts to listen-only form states.
  ///
  /// Handles:
  /// - [BlocxFormStateApplyInitialDataToForm]: hydrates text controllers via
  ///   [applyInitialDataToForm].
  /// - [BlocxFormStateFormSubmitted]: calls [onFormSubmitted].
  /// - [BlocxFormStateFormUpdated]: calls [onFormUpdated].
  ///
  /// Override and call `super` to add additional listener logic.
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

  /// Builds a [BlocXFormTextField] pre-wired to [key].
  ///
  /// The controller is managed by this state — do not create one manually.
  /// Pass [options] to customise appearance and behaviour, [validator] for
  /// native [TextFormField] validation, and [type] to switch between
  /// filled/outlined/underlined styles.
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

  /// Builds a [BlocXFormDropdown] pre-wired to [key].
  ///
  /// Pass [items] as the list of [DropdownMenuItem]s and [options] to
  /// customise the decoration.
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

  /// Builds a [BlocxFormCheckbox] pre-wired to [key].
  ///
  /// Pass [isChecked] to set the initial checked state. Use [options] for
  /// label text, styling, and layout.
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

  /// Returns the [TextEditingController] for [key], creating one if needed.
  ///
  /// Controllers are disposed automatically in [dispose].
  TextEditingController getTextEditingController(E key) {
    return _controllersMap.putIfAbsent(key, TextEditingController.new);
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
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    if (autoCloseBloc) bloc.close();
  }

  /// Vertical spacing between form fields. Defaults to `16`.
  double get formVerticalSpacing => 16;

  /// Whether the current form state passes all validation rules.
  bool get isValid => bloc.state.isValid;

  /// Builds the form UI from the current [state].
  ///
  /// This is the primary build method — replace the bloc builder output with
  /// your column of fields, buttons, and other widgets.
  formWidget(BuildContext context, BlocxFormState<F, E> state);

  /// Whether this screen is in update/edit mode (payload is non-null).
  bool get isUpdate => widget.payload != null;

  /// Hydrates [TextEditingController]s from [formData] after init.
  ///
  /// Called automatically when [BlocxFormStateApplyInitialDataToForm] is
  /// emitted. Uses [getFormattedValueByKey] with fallback to [getValueByKey]
  /// for each key in [keys].
  void applyInitialDataToForm(F formData) {
    for (E key in keys) {
      final controller = _getTextEditingControllerIfExists(key);
      if (controller == null) continue;
      controller.text = formData.getFormattedValueByKey(key) ?? formData.getValueByKey(key);
    }
  }

  /// Called when [BlocxFormStateFormSubmitted] is emitted.
  ///
  /// Override to navigate away, show a success banner, or trigger analytics.
  void onFormSubmitted(BlocxFormStateFormSubmitted<F, E> state) {}

  /// Dispatches [BlocxFormEventSubmit] to the bloc.
  ///
  /// Wire this to your submit button's `onPressed`.
  void submit() {
    bloc.add(BlocxFormEventSubmit());
  }

  /// The current widget payload, if any.
  P? get payload => widget.payload;

  /// Dispatches a field update event for [key] with [data].
  ///
  /// Use this when a field widget cannot use the built-in helpers
  /// ([textField], [dropdown], [checkbox]) and needs to report changes
  /// manually.
  void changeListener(dynamic data, E key) {
    bloc.add(BlocxFormEventUpdateData(data: data, key: key));
  }

  @override
  ScreenManagerCubit get managerCubit => bloc.screenManagerCubit;

  /// The auto-validate mode passed to form fields. Defaults to
  /// [AutovalidateMode.onUserInteraction].
  AutovalidateMode get autovalidateMode => AutovalidateMode.onUserInteraction;

  /// Manually sets a validation error on [key] with [message].
  ///
  /// Useful for server-side errors returned after submission.
  void setErrorToField(E key, String message) {
    bloc.add(BlocxFormEventSetErrorToField(message: message, key: key));
  }

  /// Sets a timed validation error on [key] that auto-clears after [duration].
  void setTimedErrorToField(E key, String message, {Duration? duration}) {
    bloc.add(BlocxFormEventSetTimedErrorToField(message: message, key: key, duration: duration));
  }

  /// Clears the error for [key].
  ///
  /// Pass [message] to clear only a specific error string; omit it to clear
  /// all errors for the field.
  void clearFieldError(E key, {String? message}) {
    bloc.add(BlocxFormEventClearFieldError(key: key, message: message));
  }

  /// Whether [bloc] is closed when this state is disposed. Defaults to `true`.
  ///
  /// Set to `false` when the bloc outlives this widget (e.g. it is provided
  /// by an ancestor [BlocProvider]).
  bool get autoCloseBloc => true;

  /// Called when [BlocxFormStateFormUpdated] is emitted.
  ///
  /// Override to react to every field change (e.g. update a character counter
  /// or enable/disable other UI elements).
  void onFormUpdated(F formData) {}

  /// The list of field enum values that have managed [TextEditingController]s.
  ///
  /// Used by [applyInitialDataToForm] to hydrate controllers on init.
  /// Return all values whose fields are created via [textField].
  List<E> get keys;

  /// Returns the [FocusNode] for [key], creating one if needed.
  ///
  /// Focus nodes are disposed automatically in [dispose].
  FocusNode getFocusNode(E key) {
    return _focusNodes.putIfAbsent(key, FocusNode.new);
  }

  void _requestFocusOnError(BlocxFormState<F, E> state) {
    if (state.errors.isNotEmpty) {
      final firstErrorKey = state.errors.keys.first;
      _focusNodes[firstErrorKey]?.requestFocus();
    }
  }

  /// The current form state.
  BlocxFormState get state => bloc.state;
}
