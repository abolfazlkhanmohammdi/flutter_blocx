import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_collection_bloc.dart';

class _CustomTestLoc extends BlocXLocalizations {
  @override
  String get searchingText => 'Recherche en cours...';

  @override
  String get searchHint => 'Rechercher ici...';

  @override
  String get areYouSure => '';

  @override
  String get areYouSureYouWantToDeleteThisItem => '';

  @override
  String get cancel => '';

  @override
  String get close => '';

  @override
  String get copyDetails => '';

  @override
  String dateRangeError(DateTime minDate, DateTime maxDate) => '';

  @override
  String get delete => '';

  @override
  String get deleteItem => '';

  @override
  String get details => '';

  @override
  String get emptyListText => '';

  @override
  String errorCodeMessage(BlocXErrorCode errorCode) => '';

  @override
  String get errorDetailsCopied => '';

  @override
  String exactLengthFieldError(int length) => '';

  @override
  String fileSizeMustBeSmallerThan(String format) => '';

  @override
  String greaterThanFieldError(int otherValue) => '';

  @override
  String get invalidEmail => '';

  @override
  String get invalidPhoneNumber => '';

  @override
  String get invalidUrl => '';

  @override
  String lengthRangeError(minLength, maxLength) => '';

  @override
  String lessThanFieldError(int otherValue) => '';

  @override
  String get loadingText => 'Chargement...';

  @override
  String maxDateError(DateTime maxDate) => '';

  @override
  String maxLengthError(maxLength) => '';

  @override
  String maxNumberOfItemsCanBeSelected(int max) => '';

  @override
  String maxValueError(num maxValue) => '';

  @override
  String minDateError(DateTime minDate) => '';

  @override
  String minLengthError(maxLength) => '';

  @override
  String minNumberOfItemsMustBeSelected(int min) => '';

  @override
  String minValueError(num minValue) => '';

  @override
  String mustBeAfterDateField(String otherFieldName) => '';

  @override
  String mustBeBeforeDateField(String otherFieldName) => '';

  @override
  String numberRangeError(num minValue, num maxValue) => '';

  @override
  String get onlyAlphanumericAllowed => '';

  @override
  String get onlyNumbersAllowed => '';

  @override
  String get report => '';

  @override
  String get selectedItemsMustBeUnique => '';

  @override
  String get somethingWentWrong => '';

  @override
  String get thisFieldIsRequired => '';

  @override
  String get tryAgain => '';

  @override
  String get valuesDoNotMatch => '';
}

class TestLocalizedCollectionWidget extends BlocxCollectionWidget<void> {
  const TestLocalizedCollectionWidget({super.key, super.bloc});

  @override
  State<TestLocalizedCollectionWidget> createState() =>
      _TestLocalizedCollectionWidgetState();
}

class _TestLocalizedCollectionWidgetState
    extends
        BlocxCollectionWidgetState<
          TestLocalizedCollectionWidget,
          TestItemEntity,
          void
        > {
  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.list,
    options: const InfiniteListOptions(),
  );

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) =>
      Text(item.title);
}

void main() {
  group('L5: Localization for searching text and search hint', () {
    late BlocXLocalizations previousLoc;

    setUp(() {
      previousLoc = BlocXLocalizations.localizations;
      BlocXLocalizations.localizations = _CustomTestLoc();
    });

    tearDown(() {
      BlocXLocalizations.localizations = previousLoc;
    });

    testWidgets('BlocxSearchField displays localized hintText by default', (
      tester,
    ) async {
      final bloc = FakeCollectionBloc();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxSearchField<TestItemEntity, void>(
              bloc: bloc,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Rechercher ici...'), findsOneWidget);
      controller.dispose();
      bloc.close();
    });

    testWidgets(
      'BlocxCollectionWidgetState defaults searchingText to loc.searchingText',
      (tester) async {
        final bloc = FakeCollectionBloc(
          initialItems: [const TestItemEntity(id: '1', title: 'Item 1')],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TestLocalizedCollectionWidget(bloc: bloc)),
          ),
        );

        await tester.pumpAndSettle();
        final state = tester.state<_TestLocalizedCollectionWidgetState>(
          find.byType(TestLocalizedCollectionWidget),
        );
        expect(state.searchingText, equals('Recherche en cours...'));
        bloc.close();
      },
    );
  });
}
