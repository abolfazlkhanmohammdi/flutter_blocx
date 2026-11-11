import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_blocx/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../flutter_blocx_test.dart';

enum _ProfileField { username, notifications, role, tags, tier }

class _ProfileFormEntity
    extends BlocxBaseFormEntity<_ProfileFormEntity, _ProfileField> {
  final String username;
  final bool notifications;
  final String? role;
  final Set<String> tags;
  final String? tier;

  const _ProfileFormEntity({
    this.username = '',
    this.notifications = false,
    this.role,
    this.tags = const {},
    this.tier,
  });

  @override
  String get identifier => 'profile-form';

  @override
  dynamic getFormattedValueByKey(_ProfileField key) => null;

  @override
  _ProfileFormEntity updateByKey(_ProfileField key, dynamic value) =>
      switch (key) {
        _ProfileField.username => copyWith(username: value as String? ?? ''),
        _ProfileField.notifications => copyWith(
          notifications: value as bool? ?? false,
        ),
        _ProfileField.role => copyWith(
          role: value as String?,
          clearRole: value == null,
        ),
        _ProfileField.tags => copyWith(
          tags: value is Iterable
              ? value.whereType<String>().toSet()
              : const <String>{},
        ),
        _ProfileField.tier => copyWith(
          tier: value as String?,
          clearTier: value == null,
        ),
      };

  @override
  dynamic getValueByKey(_ProfileField key) => switch (key) {
    _ProfileField.username => username,
    _ProfileField.notifications => notifications,
    _ProfileField.role => role,
    _ProfileField.tags => tags,
    _ProfileField.tier => tier,
  };

  _ProfileFormEntity copyWith({
    String? username,
    bool? notifications,
    String? role,
    bool clearRole = false,
    Set<String>? tags,
    String? tier,
    bool clearTier = false,
  }) {
    return _ProfileFormEntity(
      username: username ?? this.username,
      notifications: notifications ?? this.notifications,
      role: clearRole ? null : (role ?? this.role),
      tags: tags ?? this.tags,
      tier: clearTier ? null : (tier ?? this.tier),
    );
  }
}

class _ProfileFormValidator
    extends BlocxFormValidator<_ProfileFormEntity, _ProfileField> {
  @override
  List<_ProfileField> formKeys() => [_ProfileField.username];

  @override
  List<BlocxFieldValidator<_ProfileFormEntity, _ProfileField, dynamic>>
  getValidatorsByKey(_ProfileFormEntity formData, _ProfileField key) =>
      switch (key) {
        _ProfileField.username => [
          BlocxStringRequiredValidator<_ProfileFormEntity, _ProfileField>(),
        ],
        _ => const [],
      };
}

class _ConfigurableSubmitUseCase extends BlocxBaseUseCase<Object?, String> {
  final Future<void> Function()? gate;
  int callCount = 0;

  _ConfigurableSubmitUseCase({this.gate});

  @override
  Future<BlocxUseCaseResult<String>> perform(Object? input) async {
    callCount++;
    if (gate != null) {
      await gate!();
    }
    return success('submitted-$callCount');
  }
}

class _ProfileFormBloc
    extends BlocxFormBloc<_ProfileFormEntity, void, _ProfileField>
    with
        BlocxFormSteppedMixin<_ProfileFormEntity, void, _ProfileField>,
        BlocxFormValidationMixin<_ProfileFormEntity, void, _ProfileField> {
  final _ConfigurableSubmitUseCase submitUseCase;

  _ProfileFormBloc({
    _ProfileFormEntity initial = const _ProfileFormEntity(),
    _ConfigurableSubmitUseCase? submitUseCase,
  }) : submitUseCase = submitUseCase ?? _ConfigurableSubmitUseCase(),
       super(initial);

  @override
  int get maxStep => 1;

  @override
  List<_ProfileField> get formKeysList => [_ProfileField.username];

  @override
  BlocxFormValidator<_ProfileFormEntity, _ProfileField> get validator =>
      _ProfileFormValidator();

  @override
  BlocxUseCaseTask<Object?, String> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, String>(
        useCase: submitUseCase,
        inputBuilder: () => formData.username,
      );
}

class _InvertedLayoutFormScreen extends BlocxFormWidget<void> {
  final VoidCallback? onCancel;

  const _InvertedLayoutFormScreen({super.bloc, this.onCancel});

  @override
  State<_InvertedLayoutFormScreen> createState() =>
      _InvertedLayoutFormScreenState();
}

class _InvertedLayoutFormScreenState
    extends
        BlocxFormWidgetState<
          _InvertedLayoutFormScreen,
          _ProfileFormEntity,
          void,
          _ProfileField
        > {
  @override
  List<_ProfileField> get keys => [_ProfileField.username];

  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inverted Form'),
        actions: [
          BlocxFormSubmitBuilder<_ProfileFormEntity, void, _ProfileField>(
            onCancel: widget.onCancel,
            builder: (context, state, submitForm, cancelForm) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    key: const ValueKey('appbar_cancel'),
                    onPressed: cancelForm,
                    child: const Text('AppBar Cancel'),
                  ),
                  TextButton(
                    key: const ValueKey('appbar_save'),
                    onPressed: submitForm,
                    child: Text(
                      state.isSubmittingForm ? 'SavingTop...' : 'SaveTop',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomAppBar(
        child: stepBuilder(
          builder: (context, state, controls) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${controls.currentStep + 1} of ${controls.maxStep + 1}',
                  key: const ValueKey('step_indicator'),
                ),
                TextButton(
                  key: const ValueKey('prev_step_btn'),
                  onPressed: controls.previousStep,
                  child: const Text('Back'),
                ),
                TextButton(
                  key: const ValueKey('next_step_btn'),
                  onPressed: controls.nextStep,
                  child: const Text('Next'),
                ),
                TextButton(
                  key: const ValueKey('goto_step_1_btn'),
                  onPressed: () => controls.goToStep(1),
                  child: const Text('Jump 2'),
                ),
                submitBuilder(
                  builder: (context, state, submitForm, cancelForm) {
                    return ElevatedButton(
                      key: const ValueKey('bottom_submit'),
                      onPressed: submitForm,
                      child: state.isSubmittingForm
                          ? const Text('SubmittingBottom...')
                          : const Text('SubmitBottom'),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<_ProfileFormEntity, _ProfileField> state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          textField(_ProfileField.username, labelText: 'Username'),
          switchField(
            _ProfileField.notifications,
            label: 'Email alerts',
            subtitle: 'Receive daily summary',
          ),
          chipField<String>(
            _ProfileField.role,
            labelText: 'Role',
            options: const [
              BlocxChipOption(value: 'admin', label: 'Admin'),
              BlocxChipOption(value: 'member', label: 'Member'),
            ],
          ),
          chipField<String>(
            _ProfileField.tags,
            labelText: 'Tags',
            multiSelect: true,
            options: const [
              BlocxChipOption(value: 'vip', label: 'VIP'),
              BlocxChipOption(value: 'beta', label: 'Beta'),
            ],
          ),
          segmentedField<String>(
            _ProfileField.tier,
            labelText: 'Tier',
            segments: const [
              BlocxSegmentOption(value: 'free', label: 'Free'),
              BlocxSegmentOption(value: 'pro', label: 'Pro'),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(() {
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('BlocxFormSubmitBuilder & BlocxFormScope', () {
    testWidgets(
      'AppBar and bottomNavigationBar submit builders submit form and disable while submitting',
      (tester) async {
        final submitUseCase = _ConfigurableSubmitUseCase(
          gate: () async => Future<void>.delayed(const Duration(seconds: 1)),
        );
        final bloc = _ProfileFormBloc(
          initial: const _ProfileFormEntity(username: 'alice'),
          submitUseCase: submitUseCase,
        );

        await tester.pumpWidget(
          MaterialApp(home: _InvertedLayoutFormScreen(bloc: bloc)),
        );
        await tester.pumpAndSettle();

        // Scope resolves both AppBar & bottomNavigationBar submit builders without explicit bloc.
        expect(find.text('SaveTop'), findsOneWidget);
        expect(find.text('SubmitBottom'), findsOneWidget);

        // Tap AppBar submit button.
        await tester.tap(find.byKey(const ValueKey('appbar_save')));
        await tester.pump();

        // While submitting, both builders reflect isSubmittingForm and set submitForm == null.
        expect(find.text('SavingTop...'), findsOneWidget);
        expect(find.text('SubmittingBottom...'), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('appbar_save')))
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<ElevatedButton>(
                find.byKey(const ValueKey('bottom_submit')),
              )
              .onPressed,
          isNull,
        );

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(submitUseCase.callCount, equals(1));
        expect(find.text('SaveTop'), findsOneWidget);
        expect(find.text('SubmitBottom'), findsOneWidget);

        // Also trigger bottom bar submit button.
        await tester.tap(find.byKey(const ValueKey('bottom_submit')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(submitUseCase.callCount, equals(2));

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );

    testWidgets(
      'disableWhenInvalid gates submitForm and resetOnCancel resets formData inside BlocxFormView',
      (tester) async {
        final bloc = _ProfileFormBloc();
        bloc.add(BlocxFormEventInit<void>(payload: null));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocxFormView<_ProfileFormEntity, void, _ProfileField>(
                bloc: bloc,
                builder: (context, state) {
                  return BlocxFormSubmitBuilder<
                    _ProfileFormEntity,
                    void,
                    _ProfileField
                  >(
                    disableWhenInvalid: true,
                    resetOnCancel: true,
                    builder: (context, submitState, submitForm, cancelForm) {
                      return Column(
                        children: [
                          Text('Name: ${submitState.formData.username}'),
                          ElevatedButton(
                            key: const ValueKey('view_submit'),
                            onPressed: submitForm,
                            child: const Text('Save'),
                          ),
                          OutlinedButton(
                            key: const ValueKey('view_cancel'),
                            onPressed: cancelForm,
                            child: const Text('Reset'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially username is empty -> validation rule marks invalid -> disableWhenInvalid keeps onPressed null.
        expect(
          tester
              .widget<ElevatedButton>(find.byKey(const ValueKey('view_submit')))
              .onPressed,
          isNull,
        );

        // Populate valid username -> submitForm becomes non-null.
        bloc.add(
          BlocxFormEventUpdateData(data: 'bob', key: _ProfileField.username),
        );
        await tester.pumpAndSettle();
        expect(find.text('Name: bob'), findsOneWidget);
        expect(
          tester
              .widget<ElevatedButton>(find.byKey(const ValueKey('view_submit')))
              .onPressed,
          isNotNull,
        );

        // Tap Reset -> dispatches BlocxFormEventReset -> reverts to initial empty username.
        await tester.tap(find.byKey(const ValueKey('view_cancel')));
        await tester.pumpAndSettle();
        expect(find.text('Name: '), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );

    testWidgets('onCancel custom callback fires on cancelForm', (tester) async {
      var cancelCalls = 0;
      final bloc = _ProfileFormBloc(
        initial: const _ProfileFormEntity(username: 'alice'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _InvertedLayoutFormScreen(
            bloc: bloc,
            onCancel: () => cancelCalls++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('appbar_cancel')));
      await tester.pump();
      expect(cancelCalls, equals(1));

      await tester.pumpWidget(const SizedBox());
      bloc.close();
    });

    testWidgets('default cancelForm calls Navigator.maybePop on pushed route', (
      tester,
    ) async {
      final bloc = _ProfileFormBloc(
        initial: const _ProfileFormEntity(username: 'alice'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => _InvertedLayoutFormScreen(bloc: bloc),
                  ),
                );
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('appbar_cancel')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('appbar_cancel')));
      await tester.pumpAndSettle();
      expect(find.text('Open Form'), findsOneWidget);
      expect(find.byKey(const ValueKey('appbar_cancel')), findsNothing);

      await tester.pumpWidget(const SizedBox());
      bloc.close();
    });
  });

  group('BlocxFormStepBuilder & expanded form fields', () {
    testWidgets(
      'stepBuilder exposes step state and next/previous/goToStep controls',
      (tester) async {
        final bloc = _ProfileFormBloc(
          initial: const _ProfileFormEntity(username: 'alice'),
        );

        await tester.pumpWidget(
          MaterialApp(home: _InvertedLayoutFormScreen(bloc: bloc)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Step 1 of 2'), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('prev_step_btn')))
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('next_step_btn')))
              .onPressed,
          isNotNull,
        );

        await tester.tap(find.byKey(const ValueKey('next_step_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Step 2 of 2'), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('next_step_btn')))
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('prev_step_btn')))
              .onPressed,
          isNotNull,
        );

        await tester.tap(find.byKey(const ValueKey('prev_step_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Step 1 of 2'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('goto_step_1_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Step 2 of 2'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );

    testWidgets(
      'switchField, chipField (single & multi), and segmentedField update bloc state and show errors',
      (tester) async {
        final bloc = _ProfileFormBloc();

        await tester.pumpWidget(
          MaterialApp(home: _InvertedLayoutFormScreen(bloc: bloc)),
        );
        await tester.pumpAndSettle();

        // Switch field updates boolean value.
        final switchFinder = find.blocxSwitch(_ProfileField.notifications);
        expect(switchFinder, findsOneWidget);
        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
        expect(bloc.formData.notifications, isTrue);

        // Single-select chipField updates and allows deselect.
        expect(find.blocxField(_ProfileField.role), findsOneWidget);
        await tester.ensureVisible(find.blocxFilter('admin'));
        await tester.tap(find.blocxFilter('admin'));
        await tester.pumpAndSettle();
        expect(bloc.formData.role, equals('admin'));

        await tester.tap(find.blocxFilter('admin'));
        await tester.pumpAndSettle();
        expect(bloc.formData.role, isNull);

        // Multi-select chipField maintains Set<String>.
        await tester.ensureVisible(find.blocxFilter('vip'));
        await tester.tap(find.blocxFilter('vip'));
        await tester.pumpAndSettle();
        await tester.tap(find.blocxFilter('beta'));
        await tester.pumpAndSettle();
        expect(bloc.formData.tags, equals({'vip', 'beta'}));

        await tester.tap(find.blocxFilter('vip'));
        await tester.pumpAndSettle();
        expect(bloc.formData.tags, equals({'beta'}));

        // Segmented field mounts cleanly with empty initial selection and updates value.
        final segmentedFinder = find.blocxField(_ProfileField.tier);
        expect(segmentedFinder, findsOneWidget);
        await tester.ensureVisible(find.text('Pro'));
        await tester.tap(find.text('Pro'));
        await tester.pumpAndSettle();
        expect(bloc.formData.tier, equals('pro'));

        // Field-level error displays beneath switch, chip, and segmented fields.
        bloc.add(
          BlocxFormEventSetErrorToField(
            key: _ProfileField.notifications,
            message: 'Switch error',
          ),
        );
        bloc.add(
          BlocxFormEventSetErrorToField(
            key: _ProfileField.tags,
            message: 'Chip error',
          ),
        );
        bloc.add(
          BlocxFormEventSetErrorToField(
            key: _ProfileField.tier,
            message: 'Segment error',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Switch error'), findsOneWidget);
        expect(find.text('Chip error'), findsOneWidget);
        expect(find.text('Segment error'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );
  });
}
