import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_collection_bloc.dart';

class TestRowItem extends BlocxCollectionItem<TestItemEntity, void> {
  const TestRowItem({required super.item, super.key});

  @override
  Widget buildContent(BuildContext context, TestItemEntity item) {
    final idx = index(context);
    return Text('Row: ${item.title} at $idx');
  }
}

class TestItemCollectionWidget extends BlocxCollectionWidget<void> {
  final Widget Function(BuildContext context, TestItemEntity item)?
  customItemBuilder;

  const TestItemCollectionWidget({
    super.key,
    super.bloc,
    this.customItemBuilder,
  });

  @override
  State<TestItemCollectionWidget> createState() =>
      _TestItemCollectionWidgetState();
}

class _TestItemCollectionWidgetState
    extends
        BlocxCollectionWidgetState<
          TestItemCollectionWidget,
          TestItemEntity,
          void
        > {
  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.list,
    options: const InfiniteListOptions(),
  );

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) {
    if (widget.customItemBuilder != null) {
      return widget.customItemBuilder!(context, item);
    }
    return TestRowItem(item: item);
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

  group('U3: Direct index passing and identifier-based index lookup', () {
    testWidgets(
      'BlocxCollectionItem.index matches by identifier even for modified copies',
      (tester) async {
        final bloc = FakeCollectionBloc(
          initialItems: [
            const TestItemEntity(id: '0', title: 'Zero'),
            const TestItemEntity(id: '1', title: 'One'),
            const TestItemEntity(id: '2', title: 'Two'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestItemCollectionWidget(
                bloc: bloc,
                customItemBuilder: (context, item) {
                  // Pass a modified copy with distinct memory reference
                  final copyWithModifiedTitle = TestItemEntity(
                    id: item.identifier,
                    title: '${item.title} Modified',
                  );
                  return TestRowItem(item: copyWithModifiedTitle);
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Row: Zero Modified at 0'), findsOneWidget);
        expect(find.text('Row: One Modified at 1'), findsOneWidget);
        expect(find.text('Row: Two Modified at 2'), findsOneWidget);
      },
    );

    testWidgets(
      'InfiniteList builds items passing direct index to itemBuilder',
      (tester) async {
        final bloc = FakeCollectionBloc(
          initialItems: [
            const TestItemEntity(id: 'a', title: 'Alpha'),
            const TestItemEntity(id: 'b', title: 'Beta'),
            const TestItemEntity(id: 'c', title: 'Gamma'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestItemCollectionWidget(
                bloc: bloc,
                customItemBuilder: (context, item) {
                  return ListTile(title: Text('Item: ${item.title}'));
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Item: Alpha'), findsOneWidget);
        expect(find.text('Item: Beta'), findsOneWidget);
        expect(find.text('Item: Gamma'), findsOneWidget);
      },
    );
  });
}
