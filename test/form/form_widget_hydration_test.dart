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

void main() {
  setUpAll(() {
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('U5 & U6: Form widget hydration & controller lifecycle', () {
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
  });
}
