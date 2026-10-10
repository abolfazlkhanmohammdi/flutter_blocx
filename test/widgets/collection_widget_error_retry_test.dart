import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_collection_bloc.dart';

class TestCollectionWidget extends BlocxCollectionWidget<void> {
  const TestCollectionWidget({super.key, super.bloc});

  @override
  State<TestCollectionWidget> createState() => _TestCollectionWidgetState();
}

class _TestCollectionWidgetState
    extends
        BlocxCollectionWidgetState<TestCollectionWidget, TestItemEntity, void> {
  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.list,
    options: const InfiniteListOptions(),
  );

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) {
    return ListTile(key: ValueKey(item.id), title: Text(item.title));
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

  group('U1: Collection error state and retry UI', () {
    testWidgets(
      'renders BlocxErrorWidget with retry button when initial page fails, and retrying loads data',
      (tester) async {
        final bloc = FakeCollectionBloc(
          initialItems: [
            const TestItemEntity(id: '1', title: 'Product 1'),
            const TestItemEntity(id: '2', title: 'Product 2'),
          ],
          shouldFail: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TestCollectionWidget(bloc: bloc)),
          ),
        );

        // Wait for initial async load failure
        await tester.pumpAndSettle();

        // Prior to fix, it renders emptyWidget or loadingWidget, NOT BlocxErrorWidget
        expect(find.byType(BlocxErrorWidget), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('No items available'), findsNothing);

        // Tap 'Try again' after fixing server issue
        bloc.shouldFail = false;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();

        // Now items should be rendered
        expect(find.byType(BlocxErrorWidget), findsNothing);
        expect(find.text('Product 1'), findsOneWidget);
        expect(find.text('Product 2'), findsOneWidget);
      },
    );
  });
}
