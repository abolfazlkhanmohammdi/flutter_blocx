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

// Widget under test for DI collection widget with constructor bloc
class ConstructorInjectedCollectionWidget extends BlocxCollectionWidget<void> {
  const ConstructorInjectedCollectionWidget({
    super.key,
    super.bloc,
  });

  @override
  State<ConstructorInjectedCollectionWidget> createState() =>
      _ConstructorInjectedCollectionWidgetState();
}

class _ConstructorInjectedCollectionWidgetState
    extends BlocxCollectionWidgetState<ConstructorInjectedCollectionWidget,
        TestItemEntity, void> {
  @override
  CollectionSettings get settings => CollectionSettings(
        type: CollectionWidgetStateType.list,
        options: const InfiniteListOptions(),
      );

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) =>
      Text(item.title);
}

// Widget under test for DI collection widget with ancestor context.read
class ContextInjectedCollectionWidget extends BlocxCollectionWidget<void> {
  const ContextInjectedCollectionWidget({super.key});

  @override
  State<ContextInjectedCollectionWidget> createState() =>
      _ContextInjectedCollectionWidgetState();
}

class _ContextInjectedCollectionWidgetState extends BlocxCollectionWidgetState<
    ContextInjectedCollectionWidget, TestItemEntity, void> {
  @override
  CollectionSettings get settings => CollectionSettings(
        type: CollectionWidgetStateType.list,
        options: const InfiniteListOptions(),
      );

  @override
  Widget itemBuilder(BuildContext context, TestItemEntity item) =>
      Text(item.title);
}

// Widget under test for DI form widget with constructor bloc
class ConstructorInjectedFormWidget extends BlocxFormWidget<void> {
  const ConstructorInjectedFormWidget({
    super.key,
    super.bloc,
  });

  @override
  State<ConstructorInjectedFormWidget> createState() =>
      _ConstructorInjectedFormWidgetState();
}

class _ConstructorInjectedFormWidgetState extends BlocxFormWidgetState<
    ConstructorInjectedFormWidget, DemoFormEntity, void, DemoField> {
  @override
  List<DemoField> get keys => DemoField.values;

  @override
  Widget formWidget(
      BuildContext context, BlocxFormState<DemoFormEntity, DemoField> state) {
    return Text('Form initialized: ${state.formData.title}');
  }
}

// Widget under test for DI form widget with context.read
class ContextInjectedFormWidget extends BlocxFormWidget<void> {
  const ContextInjectedFormWidget({super.key});

  @override
  State<ContextInjectedFormWidget> createState() =>
      _ContextInjectedFormWidgetState();
}

class _ContextInjectedFormWidgetState extends BlocxFormWidgetState<
    ContextInjectedFormWidget, DemoFormEntity, void, DemoField> {
  @override
  List<DemoField> get keys => DemoField.values;

  @override
  Widget formWidget(
      BuildContext context, BlocxFormState<DemoFormEntity, DemoField> state) {
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

  group('L2: Composable BlocxCollectionView & BlocxFormView', () {
    testWidgets(
        'BlocxCollectionView renders items standalone without BlocxCollectionWidgetState',
        (tester) async {
      final bloc = FakeCollectionBloc(
        initialItems: const [
          TestItemEntity(id: '1', title: 'First Item'),
          TestItemEntity(id: '2', title: 'Second Item'),
        ],
      );
      bloc.add(
        BlocxCollectionEventLoadInitialPage<TestItemEntity, void>(
          payload: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxCollectionView<TestItemEntity, void>(
              bloc: bloc,
              settings: CollectionSettings(
                type: CollectionWidgetStateType.list,
                options: const InfiniteListOptions(),
              ),
              itemBuilder: (context, item) => ListTile(
                key: ValueKey(item.id),
                title: Text(item.title),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('First Item'), findsOneWidget);
      expect(find.text('Second Item'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      bloc.close();
    });

    testWidgets('BlocxCollectionView renders topWidget and bottomWidget',
        (tester) async {
      final bloc = FakeCollectionBloc(
        initialItems: const [
          TestItemEntity(id: '1', title: 'Item 1'),
        ],
      );
      bloc.add(
        BlocxCollectionEventLoadInitialPage<TestItemEntity, void>(
          payload: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxCollectionView<TestItemEntity, void>(
              bloc: bloc,
              settings: CollectionSettings(
                type: CollectionWidgetStateType.list,
                options: const InfiniteListOptions(),
              ),
              topWidget: (context, state) => const Text('TOP_HEADER'),
              bottomWidget: (context, state) => const Text('BOTTOM_FOOTER'),
              itemBuilder: (context, item) => Text(item.title),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('TOP_HEADER'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('BOTTOM_FOOTER'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      bloc.close();
    });

    testWidgets('BlocxCollectionView renders empty widget when list is empty',
        (tester) async {
      final bloc = FakeCollectionBloc(initialItems: const []);
      bloc.add(
        BlocxCollectionEventLoadInitialPage<TestItemEntity, void>(
          payload: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxCollectionView<TestItemEntity, void>(
              bloc: bloc,
              settings: CollectionSettings(
                type: CollectionWidgetStateType.list,
                options: const InfiniteListOptions(),
              ),
              itemBuilder: (context, item) => Text(item.title),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Default empty widget renders Icons.data_object_rounded
      expect(find.byIcon(Icons.data_object_rounded), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      bloc.close();
    });

    testWidgets('BlocxFormView renders standalone without BlocxFormWidgetState',
        (tester) async {
      final formBloc =
          DemoFormBloc(const DemoFormEntity(title: 'Standalone Profile'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxFormView<DemoFormEntity, void, DemoField>(
              bloc: formBloc,
              builder: (context, state) {
                return Text('Value: ${state.formData.title}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Value: Standalone Profile'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      formBloc.close();
    });
  });

  group('L3: DI-friendly construction for Collection and Form widgets', () {
    testWidgets(
        'BlocxCollectionWidget resolves bloc from constructor widget.bloc without subclass generateBloc override',
        (tester) async {
      final bloc = FakeCollectionBloc(
        initialItems: const [
          TestItemEntity(id: '1', title: 'Constructor DI Item'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConstructorInjectedCollectionWidget(bloc: bloc),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Constructor DI Item'), findsOneWidget);

      // Verify that when widget is disposed, bloc is not automatically closed because it was externally provided
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(bloc.isClosed, isFalse);

      bloc.close();
    });

    testWidgets(
        'BlocxCollectionWidget resolves bloc from ancestor context.read without subclass generateBloc override',
        (tester) async {
      final bloc = FakeCollectionBloc(
        initialItems: const [
          TestItemEntity(id: '1', title: 'Context DI Item'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<BlocxCollectionBloc<TestItemEntity, void>>.value(
              value: bloc,
              child: const ContextInjectedCollectionWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Context DI Item'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(bloc.isClosed, isFalse);

      bloc.close();
    });

    testWidgets(
        'BlocxFormWidget resolves bloc from constructor widget.bloc without subclass generateBloc override',
        (tester) async {
      final formBloc =
          DemoFormBloc(const DemoFormEntity(title: 'Injected Form'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConstructorInjectedFormWidget(bloc: formBloc),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Form initialized: Injected Form'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(formBloc.isClosed, isFalse);

      formBloc.close();
    });

    testWidgets(
        'BlocxFormWidget resolves bloc from ancestor context.read without subclass generateBloc override',
        (tester) async {
      final formBloc =
          DemoFormBloc(const DemoFormEntity(title: 'Context Form'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<
                BlocxFormBloc<DemoFormEntity, void, DemoField>>.value(
              value: formBloc,
              child: const ContextInjectedFormWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Form initialized: Context Form'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(formBloc.isClosed, isFalse);

      formBloc.close();
    });
  });
}
