import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

enum TestField { username, email, password }

class TestFormEntity extends BlocxBaseFormEntity<TestFormEntity, TestField> {
  final String username;
  final String email;
  final String password;

  const TestFormEntity({
    this.username = '',
    this.email = '',
    this.password = '',
  });

  @override
  String get identifier => 'test-form';

  @override
  TestFormEntity updateByKey(TestField key, dynamic value) => switch (key) {
    TestField.username => TestFormEntity(
      username: value as String? ?? '',
      email: email,
      password: password,
    ),
    TestField.email => TestFormEntity(
      username: username,
      email: value as String? ?? '',
      password: password,
    ),
    TestField.password => TestFormEntity(
      username: username,
      email: email,
      password: value as String? ?? '',
    ),
  };

  @override
  dynamic getValueByKey(TestField key) => switch (key) {
    TestField.username => username,
    TestField.email => email,
    TestField.password => password,
  };
}

class _DummySubmitUseCase extends BlocxBaseUseCase<Object?, Object?> {
  @override
  Future<BlocxUseCaseResult<Object?>> perform(Object? input) async =>
      success(null);
}

class TestFormBloc extends BlocxFormBloc<TestFormEntity, void, TestField> {
  TestFormBloc() : super(const TestFormEntity());

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
}

class FocusTestFormWidget extends BlocxFormWidget<void> {
  final FocusNode? customFocusNode;

  const FocusTestFormWidget({super.key, super.bloc, this.customFocusNode});

  @override
  State<FocusTestFormWidget> createState() => FocusTestFormWidgetState();
}

class FocusTestFormWidgetState
    extends
        BlocxFormWidgetState<
          FocusTestFormWidget,
          TestFormEntity,
          void,
          TestField
        > {
  @override
  List<TestField> get keys => [
    TestField.username,
    TestField.email,
    TestField.password,
  ];

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<TestFormEntity, TestField> state,
  ) {
    return Column(
      children: [
        textField(TestField.username, focusNode: widget.customFocusNode),
        textField(TestField.email),
        dropdown<String>(
          TestField.password,
          items: const [DropdownMenuItem(value: 'p1', child: Text('Pass 1'))],
        ),
      ],
    );
  }
}

class DummyLocalizations extends BlocXLocalizations {
  @override
  String errorCodeMessage(BlocXErrorCode errorCode) => 'Error';
  @override
  String get close => 'Close';
  @override
  String get copyDetails => 'Copy';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get deleteItem => 'Delete';
  @override
  String get areYouSure => 'Are you sure?';
  @override
  String get areYouSureYouWantToDeleteThisItem => 'Are you sure?';
  @override
  String dateRangeError(DateTime minDate, DateTime maxDate) => 'Date error';
  @override
  String get details => 'Details';
  @override
  String get emptyListText => 'No items available';
  @override
  String get errorDetailsCopied => 'Copied';
  @override
  String exactLengthFieldError(int length) => 'Length error';
  @override
  String fileSizeMustBeSmallerThan(String format) => 'Size error';
  @override
  String greaterThanFieldError(int otherValue) => 'Greater error';
  @override
  String get invalidEmail => 'Invalid email';
  @override
  String get invalidPhoneNumber => 'Invalid phone';
  @override
  String get invalidUrl => 'Invalid URL';
  @override
  String lengthRangeError(minLength, maxLength) => 'Range error';
  @override
  String lessThanFieldError(int otherValue) => 'Less error';
  @override
  String get loadingText => 'Loading items...';
  @override
  String maxDateError(DateTime maxDate) => 'Max date error';
  @override
  String maxLengthError(maxLength) => 'Max length error';
  @override
  String maxNumberOfItemsCanBeSelected(int max) => 'Max select error';
  @override
  String maxValueError(num maxValue) => 'Max value error';
  @override
  String minDateError(DateTime minDate) => 'Min date error';
  @override
  String minLengthError(maxLength) => 'Min length error';
  @override
  String minNumberOfItemsMustBeSelected(int min) => 'Min select error';
  @override
  String minValueError(num minValue) => 'Min value error';
  @override
  String mustBeAfterDateField(String otherFieldName) => 'After error';
  @override
  String mustBeBeforeDateField(String otherFieldName) => 'Before error';
  @override
  String numberRangeError(num minValue, num maxValue) => 'Number error';
  @override
  String get onlyAlphanumericAllowed => 'Alphanumeric error';
  @override
  String get onlyNumbersAllowed => 'Numbers error';
  @override
  String get report => 'Report';
  @override
  String get selectedItemsMustBeUnique => 'Unique error';
  @override
  String get somethingWentWrong => 'Something went wrong';
  @override
  String get thisFieldIsRequired => 'Required';
  @override
  String get tryAgain => 'Try again';
  @override
  String get valuesDoNotMatch => 'Mismatch';
}

void main() {
  setUpAll(() {
    BlocXLocalizations.localizations = DummyLocalizations();
  });

  group('FocusNode wiring and requestFocusOnError declaration order', () {
    testWidgets(
      'textField and dropdown automatically attach managed FocusNodes by default',
      (tester) async {
        final formBloc = TestFormBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: FocusTestFormWidget(bloc: formBloc)),
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<FocusTestFormWidgetState>(
          find.byType(FocusTestFormWidget),
        );

        final emailNode = state.getFocusNode(TestField.email);
        final dropdownNode = state.getFocusNode(TestField.password);

        // Verify that requesting focus on email FocusNode focuses the email text field
        emailNode.requestFocus();
        await tester.pump();
        expect(emailNode.hasFocus, isTrue);

        // Verify that requesting focus on dropdown FocusNode works
        dropdownNode.requestFocus();
        await tester.pump();
        expect(dropdownNode.hasFocus, isTrue);

        formBloc.close();
      },
    );

    testWidgets('textField respects custom focusNode when supplied', (
      tester,
    ) async {
      final formBloc = TestFormBloc();
      final customNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FocusTestFormWidget(
              bloc: formBloc,
              customFocusNode: customNode,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      customNode.requestFocus();
      await tester.pump();
      expect(customNode.hasFocus, isTrue);

      formBloc.close();
      customNode.dispose();
    });

    testWidgets(
      'requestFocusOnError focuses first error in keys declaration order, not map order',
      (tester) async {
        final formBloc = TestFormBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: FocusTestFormWidget(bloc: formBloc)),
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<FocusTestFormWidgetState>(
          find.byType(FocusTestFormWidget),
        );

        final emailNode = state.getFocusNode(TestField.email);
        final passwordNode = state.getFocusNode(TestField.password);

        // Create an error map where password comes before email in map iteration
        final testState = BlocxFormState<TestFormEntity, TestField>(
          formData: const TestFormEntity(),
          errors: {
            TestField.password: {'Password is weak'},
            TestField.email: {'Email is invalid'},
          },
          fieldsFetchingInfo: {},
          checkingUniqueFields: {},
          isFormValid: false,
          step: 0,
          shouldRebuild: true,
          shouldListen: false,
        );

        state.requestFocusOnError(testState);
        await tester.pump();

        // In keys order: [username, email, password] -> email must have focus!
        expect(emailNode.hasFocus, isTrue);
        expect(passwordNode.hasFocus, isFalse);

        formBloc.close();
      },
    );
  });
}
