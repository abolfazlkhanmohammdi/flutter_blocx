import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_collection_bloc.dart';

// --- Collection Test Helpers ---

class _DummyUseCase
    extends BlocxPaginatedUseCase<BlocxPaginatedInput, TestItemEntity> {
  @override
  Future<BlocxUseCaseResult<BlocxPage<TestItemEntity>>> perform(
    BlocxPaginatedInput input,
  ) async => success(const BlocxPage(items: [], limit: 10));
}

class PayloadCollectionBloc
    extends BlocxCollectionBloc<TestItemEntity, String> {
  final List<String?> initialPayloads = [];

  PayloadCollectionBloc() : super();

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, TestItemEntity>?
  get paginationTask => BlocxPaginatedUseCaseTask(
    useCase: _DummyUseCase(),
    inputBuilder: (offset, limit) =>
        BlocxPaginatedInput(offset: offset, limit: limit),
  );

  @override
  void add(BlocxCollectionEvent<TestItemEntity> event) {
    if (event is BlocxCollectionEventLoadInitialPage<TestItemEntity, String>) {
      initialPayloads.add(event.payload);
    }
    super.add(event);
  }
}

class TestPayloadCollectionWidget extends BlocxCollectionWidget<String> {
  final bool reloadEnabled;

  const TestPayloadCollectionWidget({
    super.key,
    required super.payload,
    super.bloc,
    this.reloadEnabled = true,
  });

  @override
  State<TestPayloadCollectionWidget> createState() =>
      _TestPayloadCollectionWidgetState();
}

class _TestPayloadCollectionWidgetState
    extends
        BlocxCollectionWidgetState<
          TestPayloadCollectionWidget,
          TestItemEntity,
          String
        > {
  @override
  bool get shouldReloadOnPayloadChange => widget.reloadEnabled;

  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.list,
    options: const InfiniteListOptions(),
  );

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) =>
      Text(item.title);
}

// --- Form Test Helpers ---

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

class TrackingFormBloc
    extends BlocxFormBloc<DemoFormEntity, String, DemoField> {
  final List<String?> initPayloads = [];

  TrackingFormBloc([super.initial = const DemoFormEntity()]);

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );

  @override
  void add(BlocxFormEvent event) {
    if (event is BlocxFormEventInit) {
      initPayloads.add(event.payload as String?);
    }
    super.add(event);
  }
}

class TestPayloadFormWidget extends BlocxFormWidget<String> {
  final bool reloadEnabled;

  const TestPayloadFormWidget({
    super.key,
    required super.payload,
    super.bloc,
    this.reloadEnabled = true,
  });

  @override
  State<TestPayloadFormWidget> createState() => _TestPayloadFormWidgetState();
}

class _TestPayloadFormWidgetState
    extends
        BlocxFormWidgetState<
          TestPayloadFormWidget,
          DemoFormEntity,
          String,
          DemoField
        > {
  @override
  bool get shouldReloadOnPayloadChange => widget.reloadEnabled;

  @override
  List<DemoField> get keys => DemoField.values;

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<DemoFormEntity, DemoField> state,
  ) {
    return Text('Payload: ${widget.payload ?? ""}');
  }
}

// --- Localizations ---

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

  group('BlocxCollectionWidgetState payload reload in didUpdateWidget', () {
    testWidgets(
      'reloads initial page when payload changes and shouldReloadOnPayloadChange is true',
      (tester) async {
        final bloc = PayloadCollectionBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadCollectionWidget(
                payload: 'initial_cat',
                bloc: bloc,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(bloc.initialPayloads, equals(['initial_cat']));

        // Update with changed payload
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadCollectionWidget(payload: 'new_cat', bloc: bloc),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(bloc.initialPayloads, equals(['initial_cat', 'new_cat']));

        bloc.close();
      },
    );

    testWidgets('does NOT reload initial page when payload is unchanged', (
      tester,
    ) async {
      final bloc = PayloadCollectionBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestPayloadCollectionWidget(payload: 'same_cat', bloc: bloc),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(bloc.initialPayloads, equals(['same_cat']));

      // Pump identical widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestPayloadCollectionWidget(payload: 'same_cat', bloc: bloc),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(bloc.initialPayloads, equals(['same_cat']));

      bloc.close();
    });

    testWidgets(
      'does NOT reload initial page when shouldReloadOnPayloadChange is false',
      (tester) async {
        final bloc = PayloadCollectionBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadCollectionWidget(
                payload: 'initial_cat',
                bloc: bloc,
                reloadEnabled: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(bloc.initialPayloads, equals(['initial_cat']));

        // Update with changed payload
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadCollectionWidget(
                payload: 'new_cat',
                bloc: bloc,
                reloadEnabled: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(bloc.initialPayloads, equals(['initial_cat']));

        bloc.close();
      },
    );
  });

  group('BlocxFormWidgetState payload reload in didUpdateWidget', () {
    testWidgets(
      're-initializes form when payload changes and shouldReloadOnPayloadChange is true',
      (tester) async {
        final formBloc = TrackingFormBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadFormWidget(payload: 'form_p1', bloc: formBloc),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(formBloc.initPayloads, equals(['form_p1']));

        // Update with changed payload
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadFormWidget(payload: 'form_p2', bloc: formBloc),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(formBloc.initPayloads, equals(['form_p1', 'form_p2']));

        formBloc.close();
      },
    );

    testWidgets('does NOT re-initialize form when payload is unchanged', (
      tester,
    ) async {
      final formBloc = TrackingFormBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestPayloadFormWidget(payload: 'same_p', bloc: formBloc),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(formBloc.initPayloads, equals(['same_p']));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestPayloadFormWidget(payload: 'same_p', bloc: formBloc),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(formBloc.initPayloads, equals(['same_p']));

      formBloc.close();
    });

    testWidgets(
      'does NOT re-initialize form when shouldReloadOnPayloadChange is false',
      (tester) async {
        final formBloc = TrackingFormBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadFormWidget(
                payload: 'form_p1',
                bloc: formBloc,
                reloadEnabled: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(formBloc.initPayloads, equals(['form_p1']));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestPayloadFormWidget(
                payload: 'form_p2',
                bloc: formBloc,
                reloadEnabled: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(formBloc.initPayloads, equals(['form_p1']));

        formBloc.close();
      },
    );
  });
}
