import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

enum TestCheckboxField { agree }

class TestCheckboxFormEntity
    extends BlocxBaseFormEntity<TestCheckboxFormEntity, TestCheckboxField> {
  final bool agree;
  const TestCheckboxFormEntity({this.agree = false});

  @override
  String get identifier => 'test-checkbox';

  @override
  TestCheckboxFormEntity updateByKey(TestCheckboxField key, dynamic value) =>
      TestCheckboxFormEntity(agree: value as bool? ?? false);

  @override
  dynamic getValueByKey(TestCheckboxField key) => agree;
}

class FakeCheckboxFormBloc
    extends BlocxFormBloc<TestCheckboxFormEntity, void, TestCheckboxField> {
  FakeCheckboxFormBloc() : super(const TestCheckboxFormEntity());

  @override
  BlocxUseCaseTask get submitUseCaseTask => throw UnimplementedError();
}

class TestCheckboxWidget extends BlocxFormWidget<void> {
  final FakeCheckboxFormBloc bloc;
  const TestCheckboxWidget({super.key, required this.bloc});

  @override
  State<TestCheckboxWidget> createState() => _TestCheckboxWidgetState();
}

class _TestCheckboxWidgetState extends BlocxFormWidgetState<
    TestCheckboxWidget, TestCheckboxFormEntity, void, TestCheckboxField> {
  @override
  BlocxFormBloc<TestCheckboxFormEntity, void, TestCheckboxField>
      get generateBloc => widget.bloc;

  @override
  List<TestCheckboxField> get keys => [TestCheckboxField.agree];

  @override
  Widget formWidget(BuildContext context,
      BlocxFormState<TestCheckboxFormEntity, TestCheckboxField> state) {
    return Column(
      children: [
        // 1. Without deprecated isChecked (options only)
        checkbox(
          key: TestCheckboxField.agree,
          options: const BlocxCheckboxOptions(
            isChecked: true,
            label: 'Option Only',
          ),
        ),
        // 2. With deprecated isChecked only
        // ignore: deprecated_member_use_from_same_package
        checkbox(
          key: TestCheckboxField.agree,
          isChecked: true,
        ),
        // 3. With both, isChecked overrides options.isChecked
        // ignore: deprecated_member_use_from_same_package
        checkbox(
          key: TestCheckboxField.agree,
          isChecked: true,
          options: const BlocxCheckboxOptions(
            isChecked: false,
            label: 'Overridden Option',
          ),
        ),
      ],
    );
  }
}

void main() {
  testWidgets('checkbox() works with options only, isChecked only, and both',
      (tester) async {
    final bloc = FakeCheckboxFormBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestCheckboxWidget(bloc: bloc),
        ),
      ),
    );

    expect(find.byType(BlocxFormCheckbox<TestCheckboxFormEntity, void, TestCheckboxField>),
        findsNWidgets(3));
    expect(find.text('Option Only'), findsOneWidget);
    expect(find.text('Overridden Option'), findsOneWidget);

    bloc.close();
  });
}
