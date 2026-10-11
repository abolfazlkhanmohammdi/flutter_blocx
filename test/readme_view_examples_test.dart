import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/src/form/blocx_form_view.dart';
import 'package:flutter_blocx/src/screen_manager/blocx_error_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_collection_bloc.dart';

enum DemoField { title }

class DemoFormEntity extends BlocxBaseFormEntity<DemoFormEntity, DemoField> {
  final String title;

  const DemoFormEntity({this.title = ''});

  @override
  String get identifier => 'demo-form';

  @override
  DemoFormEntity updateByKey(DemoField key, dynamic value) => switch (key) {
    DemoField.title => DemoFormEntity(title: value as String),
  };

  @override
  dynamic getValueByKey(DemoField key) => switch (key) {
    DemoField.title => title,
  };
}

class _DummySubmitUseCase extends BlocxBaseUseCase<Object?, Object?> {
  @override
  Future<BlocxUseCaseResult<Object?>> perform(Object? input) async =>
      success(null);
}

class DemoFormBloc extends BlocxFormBloc<DemoFormEntity, void, DemoField> {
  DemoFormBloc([super.initial = const DemoFormEntity()]);

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
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

  testWidgets('README BlocxCollectionView snippet builds and renders', (
    tester,
  ) async {
    final productsBloc = FakeCollectionBloc(
      initialItems: const [TestItemEntity(id: '1', title: 'Product 1')],
    );
    productsBloc.add(
      BlocxCollectionEventLoadInitialPage<TestItemEntity, void>(payload: null),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocxCollectionView<TestItemEntity, void>(
            bloc: productsBloc,
            settings: CollectionSettings(
              type: CollectionWidgetStateType.list,
              options: const InfiniteListOptions(),
            ),
            itemBuilder: (context, item) => Text(item.title),
            emptyWidget: (context, state) =>
                const Center(child: Text('No products available')),
            errorWidget: (context, state) => BlocxErrorWidget(
              error: ReadableError(message: state.message),
              onRetry: () => productsBloc.add(
                BlocxCollectionEventLoadInitialPage(payload: null),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Product 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    productsBloc.close();
  });

  testWidgets('README BlocxFormView snippet builds and renders', (
    tester,
  ) async {
    final profileBloc = DemoFormBloc(const DemoFormEntity(title: 'Alice'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocxFormView<DemoFormEntity, void, DemoField>(
            bloc: profileBloc,
            builder: (context, state) =>
                Column(children: [Text('Form Name: ${state.formData.title}')]),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Form Name: Alice'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    profileBloc.close();
  });
}
