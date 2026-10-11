import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../flutter_blocx_test.dart';

enum RoleFormField { role }

class RoleFormEntity
    extends BlocxBaseFormEntity<RoleFormEntity, RoleFormField> {
  final String role;

  const RoleFormEntity({this.role = ''});

  @override
  String get identifier => 'role-form';

  @override
  RoleFormEntity updateByKey(RoleFormField key, dynamic value) => switch (key) {
    RoleFormField.role => RoleFormEntity(role: (value as String?) ?? ''),
  };

  @override
  dynamic getValueByKey(RoleFormField key) => switch (key) {
    RoleFormField.role => role,
  };
}

class _DummySubmitUseCase extends BlocxBaseUseCase<Object?, Object?> {
  @override
  Future<BlocxUseCaseResult<Object?>> perform(Object? input) async =>
      success(null);
}

class FakeRoleFormBloc
    extends BlocxFormBloc<RoleFormEntity, void, RoleFormField> {
  FakeRoleFormBloc([super.initial = const RoleFormEntity()]);

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
}

class RoleFormWidget extends BlocxFormWidget<void> {
  const RoleFormWidget({super.key, super.bloc});

  @override
  State<RoleFormWidget> createState() => _RoleFormWidgetState();
}

class _RoleFormWidgetState
    extends
        BlocxFormWidgetState<
          RoleFormWidget,
          RoleFormEntity,
          void,
          RoleFormField
        > {
  @override
  List<RoleFormField> get keys => [RoleFormField.role];

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<RoleFormEntity, RoleFormField> state,
  ) {
    return Column(
      children: [
        dropdown<String>(
          RoleFormField.role,
          items: const [
            DropdownMenuItem(value: 'alpha', child: Text('Alpha')),
            DropdownMenuItem(value: 'beta', child: Text('Beta')),
            DropdownMenuItem(value: 'gamma', child: Text('Gamma')),
          ],
        ),
      ],
    );
  }
}

class _EventCountingObserver extends BlocObserver {
  int updateDataCount = 0;

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is BlocxFormEventUpdateData) {
      updateDataCount++;
    }
  }
}

void main() {
  setUpAll(() {
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('U-B: BlocXFormDropdown bloc binding', () {
    testWidgets('1. formData role = beta before first build shows Beta', (
      tester,
    ) async {
      final bloc = FakeRoleFormBloc(const RoleFormEntity(role: 'beta'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RoleFormWidget(bloc: bloc)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets(
      '2. programmatic BlocxFormEventUpdateData updates dropdown to Gamma',
      (tester) async {
        final bloc = FakeRoleFormBloc(const RoleFormEntity(role: 'beta'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: RoleFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        bloc.add(
          BlocxFormEventUpdateData(data: 'gamma', key: RoleFormField.role),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gamma'), findsOneWidget);
      },
    );

    testWidgets(
      '3. user selects Alpha -> updates bloc.formData and dispatches exactly one UpdateData event',
      (tester) async {
        final previousObserver = Bloc.observer;
        final observer = _EventCountingObserver();
        Bloc.observer = observer;
        addTearDown(() => Bloc.observer = previousObserver);

        final bloc = FakeRoleFormBloc(const RoleFormEntity(role: 'beta'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: RoleFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Alpha').last);
        await tester.pumpAndSettle();

        expect(bloc.formData.role, equals('alpha'));
        expect(find.text('Alpha'), findsOneWidget);
        expect(observer.updateDataCount, equals(1));
      },
    );

    testWidgets(
      '4. formData role = unknown (not in items) renders empty selection without throwing',
      (tester) async {
        final bloc = FakeRoleFormBloc(const RoleFormEntity(role: 'unknown'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: RoleFormWidget(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final field = tester.widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        );
        expect(field.initialValue, isNull);
      },
    );

    testWidgets('5. bloc sets value back to empty string -> dropdown clears', (
      tester,
    ) async {
      final bloc = FakeRoleFormBloc(const RoleFormEntity(role: 'beta'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RoleFormWidget(bloc: bloc)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsOneWidget);

      bloc.add(BlocxFormEventUpdateData(data: '', key: RoleFormField.role));
      await tester.pumpAndSettle();

      expect(find.text('Beta'), findsNothing);
    });
  });
}
