import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_collection_bloc.dart';

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

class ContextInjectedCollectionWidget extends BlocxCollectionWidget<void> {
  const ContextInjectedCollectionWidget({super.key});

  @override
  State<ContextInjectedCollectionWidget> createState() =>
      _ContextInjectedCollectionWidgetState();
}

class _ContextInjectedCollectionWidgetState
    extends
        BlocxCollectionWidgetState<
          ContextInjectedCollectionWidget,
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

class ContextInjectedFormWidget extends BlocxFormWidget<void> {
  const ContextInjectedFormWidget({super.key});

  @override
  State<ContextInjectedFormWidget> createState() =>
      _ContextInjectedFormWidgetState();
}

class _ContextInjectedFormWidgetState
    extends
        BlocxFormWidgetState<
          ContextInjectedFormWidget,
          DemoFormEntity,
          void,
          DemoField
        > {
  @override
  List<DemoField> get keys => DemoField.values;

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<DemoFormEntity, DemoField> state,
  ) {
    return Text('Form initialized: ${state.formData.title}');
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

  group('DI Provider type resolution and descriptive error handling', () {
    testWidgets(
      'throws informative FlutterError when collection bloc is provided under concrete type rather than BlocxCollectionBloc',
      (tester) async {
        final bloc = FakeCollectionBloc(
          initialItems: const [TestItemEntity(id: '1', title: 'Test 1')],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<FakeCollectionBloc>.value(
                value: bloc,
                child: const ContextInjectedCollectionWidget(),
              ),
            ),
          ),
        );

        final dynamic exception = tester.takeException();
        expect(exception, isA<FlutterError>());
        final message = (exception as FlutterError).message;
        expect(message, contains('BlocxCollectionBloc<TestItemEntity, void>'));
        expect(message, contains('BlocProvider<BlocxCollectionBloc<'));

        bloc.close();
      },
    );

    testWidgets(
      'throws informative FlutterError when form bloc is provided under concrete type rather than BlocxFormBloc',
      (tester) async {
        final formBloc = DemoFormBloc(const DemoFormEntity(title: 'Form 1'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<DemoFormBloc>.value(
                value: formBloc,
                child: const ContextInjectedFormWidget(),
              ),
            ),
          ),
        );

        final dynamic exception = tester.takeException();
        expect(exception, isA<FlutterError>());
        final message = (exception as FlutterError).message;
        expect(
          message,
          contains('BlocxFormBloc<DemoFormEntity, void, DemoField>'),
        );
        expect(message, contains('BlocProvider<BlocxFormBloc<'));

        formBloc.close();
      },
    );

    testWidgets(
      'resolves successfully when collection bloc is provided as BlocxCollectionBloc',
      (tester) async {
        final bloc = FakeCollectionBloc(
          initialItems: const [
            TestItemEntity(id: '1', title: 'Proper DI Item'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body:
                  BlocProvider<BlocxCollectionBloc<TestItemEntity, void>>.value(
                    value: bloc,
                    child: const ContextInjectedCollectionWidget(),
                  ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Proper DI Item'), findsOneWidget);

        bloc.close();
      },
    );

    testWidgets(
      'resolves successfully when form bloc is provided as BlocxFormBloc',
      (tester) async {
        final formBloc = DemoFormBloc(
          const DemoFormEntity(title: 'Proper Form'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body:
                  BlocProvider<
                    BlocxFormBloc<DemoFormEntity, void, DemoField>
                  >.value(
                    value: formBloc,
                    child: const ContextInjectedFormWidget(),
                  ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Form initialized: Proper Form'), findsOneWidget);

        formBloc.close();
      },
    );
  });
}
