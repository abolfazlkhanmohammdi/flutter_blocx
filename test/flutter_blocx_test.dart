import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

class TestStatelessWidget extends BlocxStatelessWidget {
  const TestStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Width: ${width(context)}', textDirection: TextDirection.ltr),
        Text('Height: ${height(context)}', textDirection: TextDirection.ltr),
        Text('ThemePrimary: ${colorScheme(context).primary}',
            textDirection: TextDirection.ltr),
      ],
    );
  }
}

class TestLocalizations extends BlocXLocalizations {
  @override
  String errorCodeMessage(BlocXErrorCode errorCode) =>
      'Error: ${errorCode.name}';

  @override
  String get close => 'Close';

  @override
  String get copyDetails => 'Copy details';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteItem => 'Delete item';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get areYouSureYouWantToDeleteThisItem =>
      'Are you sure you want to delete this item?';

  @override
  String dateRangeError(DateTime minDate, DateTime maxDate) =>
      'Date range error';

  @override
  String get details => 'Details';

  @override
  String get emptyListText => 'Empty';

  @override
  String get errorDetailsCopied => 'Copied';

  @override
  String exactLengthFieldError(int length) => 'Exact length error';

  @override
  String fileSizeMustBeSmallerThan(String format) => 'File size error';

  @override
  String greaterThanFieldError(int otherValue) => 'Greater than error';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get invalidPhoneNumber => 'Invalid phone';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String lengthRangeError(minLength, maxLength) => 'Length range error';

  @override
  String lessThanFieldError(int otherValue) => 'Less than error';

  @override
  String get loadingText => 'Loading...';

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
  String mustBeAfterDateField(String otherFieldName) => 'Must be after error';

  @override
  String mustBeBeforeDateField(String otherFieldName) => 'Must be before error';

  @override
  String numberRangeError(num minValue, num maxValue) => 'Number range error';

  @override
  String get onlyAlphanumericAllowed => 'Alphanumeric error';

  @override
  String get onlyNumbersAllowed => 'Numbers error';

  @override
  String get report => 'Report';

  @override
  String get selectedItemsMustBeUnique => 'Unique selection error';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get thisFieldIsRequired => 'Field required';

  @override
  String get tryAgain => 'Try again';

  @override
  String get valuesDoNotMatch => 'Values mismatch';
}

void main() {
  setUpAll(() {
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('BlocxStatelessWidget', () {
    testWidgets('provides context helpers for theme and screen dimensions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TestStatelessWidget(),
          ),
        ),
      );

      expect(find.textContaining('Width: 800.0'), findsOneWidget);
      expect(find.textContaining('Height: 600.0'), findsOneWidget);
      expect(find.textContaining('ThemePrimary:'), findsOneWidget);
    });
  });

  group('BlocxErrorWidget', () {
    testWidgets('renders readable error details and triggers callbacks',
        (tester) async {
      bool retried = false;
      bool reported = false;

      final error = ReadableError(
        title: 'Custom Error Title',
        message: 'Something broke in test',
        error: 'TestException',
        stackTrace: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxErrorWidget(
              error: error,
              onRetry: () => retried = true,
              onReport: () => reported = true,
              expandDetails: true,
            ),
          ),
        ),
      );

      expect(find.text('Custom Error Title'), findsOneWidget);
      expect(find.text('Something broke in test'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);

      await tester.ensureVisible(find.text('Try again'));
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);

      await tester.ensureVisible(find.text('Report'));
      await tester.tap(find.text('Report'));
      expect(reported, isTrue);
    });
  });

  group('BlocxSnackBar', () {
    testWidgets('shows floating snackbar with title and message',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    BlocxSnackBar.show(
                      context,
                      title: 'Success Title',
                      message: 'Operation completed successfully',
                      type: BlocXSnackbarType.info,
                    );
                  },
                  child: const Text('Show Snack'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snack'));
      await tester.pump();

      expect(find.text('Success Title'), findsOneWidget);
      expect(find.text('Operation completed successfully'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('TypeDef Export Verification', () {
    test('verifies casing aliases match expectations', () {
      expect(BlocxWidgetState, equals(BlocXWidgetState));
      expect(BlocxSnackbarType.error, equals(BlocXSnackbarType.error));
    });
  });
}
