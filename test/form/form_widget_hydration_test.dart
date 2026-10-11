import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../flutter_blocx_test.dart';

enum TestFormField { name, bio }

class TestFormEntity
    extends BlocxBaseFormEntity<TestFormEntity, TestFormField> {
  final String name;
  final String bio;

  const TestFormEntity({this.name = '', this.bio = ''});

  @override
  String get identifier => 'test-form';

  @override
  TestFormEntity updateByKey(TestFormField key, dynamic value) => switch (key) {
    TestFormField.name => TestFormEntity(name: value as String, bio: bio),
    TestFormField.bio => TestFormEntity(name: name, bio: value as String),
  };

  @override
  dynamic getValueByKey(TestFormField key) => switch (key) {
    TestFormField.name => name,
    TestFormField.bio => bio,
  };
}

class _DummySubmitUseCase extends BlocxBaseUseCase<Object?, Object?> {
  @override
  Future<BlocxUseCaseResult<Object?>> perform(Object? input) async =>
      success(null);
}

class FakeFormBloc extends BlocxFormBloc<TestFormEntity, void, TestFormField> {
  FakeFormBloc([super.initial = const TestFormEntity()]);

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
}

class TestFormWidget extends BlocxFormWidget<void> {
  const TestFormWidget({super.key, super.bloc});

  @override
  State<TestFormWidget> createState() => _TestFormWidgetState();
}

class _TestFormWidgetState
    extends
        BlocxFormWidgetState<
          TestFormWidget,
          TestFormEntity,
          void,
          TestFormField
        > {
  @override
  List<TestFormField> get keys => [TestFormField.name, TestFormField.bio];

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<TestFormEntity, TestFormField> state,
  ) {
    return Column(
      children: [
        textField(TestFormField.name),
        textField(TestFormField.bio),
        submitButton('Save', formState: state),
        formButtonRow('Save Row', formState: state),
      ],
    );
  }
}

class ToggleableFieldsFormWidget extends StatefulWidget {
  final FakeFormBloc bloc;

  const ToggleableFieldsFormWidget({super.key, required this.bloc});

  @override
  State<ToggleableFieldsFormWidget> createState() =>
      _ToggleableFieldsFormWidgetState();
}

class _ToggleableFieldsFormWidgetState
    extends State<ToggleableFieldsFormWidget> {
  bool showBio = false;

  void toggleBio() {
    setState(() {
      showBio = !showBio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InnerToggleableFormWidget(
      bloc: widget.bloc,
      showBio: showBio,
      onToggle: toggleBio,
    );
  }
}

class _InnerToggleableFormWidget extends BlocxFormWidget<void> {
  final bool showBio;
  final VoidCallback onToggle;

  const _InnerToggleableFormWidget({
    required super.bloc,
    required this.showBio,
    required this.onToggle,
  });

  @override
  State<_InnerToggleableFormWidget> createState() =>
      _InnerToggleableFormWidgetState();
}

class _InnerToggleableFormWidgetState
    extends
        BlocxFormWidgetState<
          _InnerToggleableFormWidget,
          TestFormEntity,
          void,
          TestFormField
        > {
  @override
  List<TestFormField> get keys => [TestFormField.name, TestFormField.bio];

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<TestFormEntity, TestFormField> state,
  ) {
    return Column(
      children: [
        textField(TestFormField.name),
        if (widget.showBio) textField(TestFormField.bio),
        ElevatedButton(onPressed: widget.onToggle, child: const Text('Toggle')),
      ],
    );
  }
}

class FakeSteppedFormBloc
    extends BlocxFormBloc<TestFormEntity, void, TestFormField>
    with BlocxFormSteppedMixin<TestFormEntity, void, TestFormField> {
  FakeSteppedFormBloc([super.initial = const TestFormEntity()]);

  @override
  int get maxStep => 1;

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
}

class SteppedFormWidget extends BlocxFormWidget<void> {
  const SteppedFormWidget({super.key, super.bloc});

  @override
  State<SteppedFormWidget> createState() => _SteppedFormWidgetState();
}

class _SteppedFormWidgetState
    extends
        BlocxFormWidgetState<
          SteppedFormWidget,
          TestFormEntity,
          void,
          TestFormField
        > {
  @override
  List<TestFormField> get keys => [TestFormField.name, TestFormField.bio];

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<TestFormEntity, TestFormField> state,
  ) {
    final currentStep = state.step;
    return Column(
      children: [
        if (currentStep == 0) textField(TestFormField.name),
        if (currentStep == 1) textField(TestFormField.bio),
      ],
    );
  }
}

void main() {
  setUpAll(() {
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('U5 & U6 / U-C.1: Form widget hydration & controller lifecycle', () {
    testWidgets(
      'applyInitialDataToForm preserves cursor selection when text matches',
      (tester) async {
        final bloc = FakeFormBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TestFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<_TestFormWidgetState>(
          find.byType(TestFormWidget),
        );
        final controller = state.getTextEditingController(TestFormField.name);

        // User types and places cursor in the middle
        controller.value = const TextEditingValue(
          text: 'Antigravity',
          selection: TextSelection.collapsed(offset: 4),
        );

        // Hydrate with identical text
        state.applyInitialDataToForm(
          const TestFormEntity(name: 'Antigravity', bio: 'Bio details'),
        );

        // Selection must remain intact (not reset to 0 or end)
        expect(controller.text, equals('Antigravity'));
        expect(controller.selection.baseOffset, equals(4));

        // Hydrate with updated text, cursor should be clamped and preserved
        state.applyInitialDataToForm(
          const TestFormEntity(name: 'Anti', bio: 'Bio details'),
        );
        expect(controller.text, equals('Anti'));
        expect(controller.selection.baseOffset, equals(4));

        // Hydrate with shorter text, cursor clamped to end
        state.applyInitialDataToForm(
          const TestFormEntity(name: 'An', bio: 'Bio details'),
        );
        expect(controller.text, equals('An'));
        expect(controller.selection.baseOffset, equals(2));
      },
    );

    testWidgets('submitButton and formButtonRow accept snapshot formState', (
      tester,
    ) async {
      final bloc = FakeFormBloc(const TestFormEntity(name: 'Test Name'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TestFormWidget(bloc: bloc)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Save Row'), findsOneWidget);
    });

    testWidgets(
      'getTextEditingController hydrates value from current form data when requested late',
      (tester) async {
        final bloc = FakeFormBloc(
          const TestFormEntity(name: 'Initial Name', bio: 'Hydrated Bio'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TestFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<_TestFormWidgetState>(
          find.byType(TestFormWidget),
        );

        // Controller for bio was created and pre-hydrated from bloc.formData
        final bioController = state.getTextEditingController(TestFormField.bio);
        expect(bioController.text, equals('Hydrated Bio'));
      },
    );

    testWidgets(
      'U-C.1 (a & c): field B built after setState toggle hydrates from formData and does not overwrite typed text in field A',
      (tester) async {
        final bloc = FakeFormBloc(
          const TestFormEntity(name: 'Init A', bio: 'Hydrated Late Bio'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ToggleableFieldsFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        // Field B is not yet built
        expect(find.text('Hydrated Late Bio'), findsNothing);

        // User types text into field A
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'User Typed Into Field A');
        await tester.pumpAndSettle();

        // Toggle to reveal field B
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();

        // (a) Field B is now built and hydrated with formData value
        expect(find.text('Hydrated Late Bio'), findsOneWidget);

        // (c) Text in field A is preserved and not overwritten
        expect(find.text('User Typed Into Field A'), findsOneWidget);
      },
    );

    testWidgets(
      'U-C.1 (b): stepped form step 2 fields appear after step change with the right hydrated text',
      (tester) async {
        final bloc = FakeSteppedFormBloc(
          const TestFormEntity(name: 'Step 1 Name', bio: 'Step 2 Hydrated Bio'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SteppedFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        // Step 1: name field is visible, bio is not
        expect(find.text('Step 1 Name'), findsOneWidget);
        expect(find.text('Step 2 Hydrated Bio'), findsNothing);

        // Transition to step 2
        bloc.add(BlocxFormEventNextStep());
        await tester.pumpAndSettle();

        // Step 2: bio field is rendered with hydrated value
        expect(find.text('Step 2 Hydrated Bio'), findsOneWidget);
        expect(find.text('Step 1 Name'), findsNothing);
      },
    );
  });
}
