import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_collection_bloc.dart';

class TestScrollCollectionWidget extends BlocxCollectionWidget<void> {
  final FakeCollectionBloc bloc;
  final CollectionWidgetStateType type;
  final VoidCallback? onLoadMoreTriggered;

  const TestScrollCollectionWidget({
    super.key,
    required this.bloc,
    this.type = CollectionWidgetStateType.list,
    this.onLoadMoreTriggered,
  });

  @override
  State<TestScrollCollectionWidget> createState() =>
      _TestScrollCollectionWidgetState();
}

class _TestScrollCollectionWidgetState extends BlocxCollectionWidgetState<
    TestScrollCollectionWidget, TestItemEntity, void> {
  @override
  BlocxCollectionBloc<TestItemEntity, void> get generateBloc => widget.bloc;

  @override
  CollectionSettings get settings => CollectionSettings(
        type: widget.type,
        options: widget.type == CollectionWidgetStateType.sliverList
            ? const SliverInfiniteListOptions(loadMoreTriggerItemDistance: 1)
            : const InfiniteListOptions(loadMoreTriggerItemDistance: 1),
      );

  @override
  void loadNextPage() {
    widget.onLoadMoreTriggered?.call();
    super.loadNextPage();
  }

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) {
    return SizedBox(
      height: 60,
      child: Text('Item: ${item.title}'),
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

  group('U4: Scroll extent load more fallback', () {
    testWidgets('InfiniteList triggers loadNextPage via scroll extent fallback',
        (tester) async {
      bool loadMoreTriggered = false;
      final bloc = FakeCollectionBloc(
        initialItems: List.generate(
          30,
          (i) => TestItemEntity(id: '$i', title: 'Row $i'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: TestScrollCollectionWidget(
                bloc: bloc,
                type: CollectionWidgetStateType.list,
                onLoadMoreTriggered: () {
                  loadMoreTriggered = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(loadMoreTriggered, isFalse);

      // Scroll toward the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(loadMoreTriggered, isTrue);
    });

    testWidgets(
        'SliverInfiniteList triggers loadNextPage via scroll extent fallback',
        (tester) async {
      bool loadMoreTriggered = false;
      final bloc = FakeCollectionBloc(
        initialItems: List.generate(
          30,
          (i) => TestItemEntity(id: '$i', title: 'Row $i'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: TestScrollCollectionWidget(
                bloc: bloc,
                type: CollectionWidgetStateType.sliverList,
                onLoadMoreTriggered: () {
                  loadMoreTriggered = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(loadMoreTriggered, isFalse);

      // Scroll toward the bottom
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(loadMoreTriggered, isTrue);
    });
  });
}
