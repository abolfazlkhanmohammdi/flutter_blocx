import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_blocx/testing.dart';
import 'package:flutter_test/flutter_test.dart';

enum _PasswordField { password, plainSecret, customSuffixPassword }

class _PasswordFormEntity
    extends BlocxBaseFormEntity<_PasswordFormEntity, _PasswordField> {
  final String password;
  final String plainSecret;
  final String customSuffixPassword;

  const _PasswordFormEntity({
    this.password = '',
    this.plainSecret = '',
    this.customSuffixPassword = '',
  });

  @override
  String get identifier => 'password-form';

  @override
  _PasswordFormEntity updateByKey(_PasswordField key, dynamic value) =>
      switch (key) {
        _PasswordField.password => _PasswordFormEntity(
          password: value as String? ?? '',
          plainSecret: plainSecret,
          customSuffixPassword: customSuffixPassword,
        ),
        _PasswordField.plainSecret => _PasswordFormEntity(
          password: password,
          plainSecret: value as String? ?? '',
          customSuffixPassword: customSuffixPassword,
        ),
        _PasswordField.customSuffixPassword => _PasswordFormEntity(
          password: password,
          plainSecret: plainSecret,
          customSuffixPassword: value as String? ?? '',
        ),
      };

  @override
  dynamic getValueByKey(_PasswordField key) => switch (key) {
    _PasswordField.password => password,
    _PasswordField.plainSecret => plainSecret,
    _PasswordField.customSuffixPassword => customSuffixPassword,
  };
}

class _DummySubmitUseCase extends BlocxBaseUseCase<Object?, Object?> {
  @override
  Future<BlocxUseCaseResult<Object?>> perform(Object? input) async =>
      success(null);
}

class _PasswordFormBloc
    extends BlocxFormBloc<_PasswordFormEntity, void, _PasswordField> {
  _PasswordFormBloc([super.initial = const _PasswordFormEntity()]);

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
}

class _PasswordFormScreen extends BlocxFormWidget<void> {
  const _PasswordFormScreen({super.bloc});

  @override
  State<_PasswordFormScreen> createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState
    extends
        BlocxFormWidgetState<
          _PasswordFormScreen,
          _PasswordFormEntity,
          void,
          _PasswordField
        > {
  @override
  List<_PasswordField> get keys => _PasswordField.values;

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<_PasswordFormEntity, _PasswordField> state,
  ) {
    return Column(
      children: [
        passwordField(_PasswordField.password, labelText: 'Password'),
        textField(
          _PasswordField.plainSecret,
          labelText: 'PIN',
          obscureText: true,
        ),
        passwordField(
          _PasswordField.customSuffixPassword,
          labelText: 'Custom Suffix Password',
          suffix: const Icon(Icons.lock, key: ValueKey('custom_suffix_icon')),
        ),
      ],
    );
  }
}

void main() {
  group('BlocxLocal<T>', () {
    testWidgets('manages initialValue, setValue, update, and onChanged', (
      tester,
    ) async {
      final changes = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxLocal<int>(
              initialValue: 1,
              onChanged: changes.add,
              builder: (context, count, setValue, update) {
                return Column(
                  children: [
                    Text('Count: $count'),
                    ElevatedButton(
                      onPressed: () => update((current) => current + 1),
                      child: const Text('Increment'),
                    ),
                    ElevatedButton(
                      onPressed: () => setValue(10),
                      child: const Text('Set Ten'),
                    ),
                    ElevatedButton(
                      onPressed: () => setValue(count),
                      child: const Text('Set Same'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 1'), findsOneWidget);
      expect(changes, isEmpty);

      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('Count: 2'), findsOneWidget);
      expect(changes, equals([2]));

      // Setting the same value is a no-op and does not re-fire onChanged.
      await tester.tap(find.text('Set Same'));
      await tester.pump();
      expect(changes, equals([2]));

      await tester.tap(find.text('Set Ten'));
      await tester.pump();
      expect(find.text('Count: 10'), findsOneWidget);
      expect(changes, equals([2, 10]));
    });

    testWidgets(
      'disposes internal ValueNotifier on unmount and safely ignores late callbacks',
      (tester) async {
        late void Function(String) capturedSetValue;
        late void Function(String Function(String)) capturedUpdate;
        var changesCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocxLocal<String>(
                initialValue: 'initial',
                onChanged: (_) => changesCount++,
                builder: (context, value, setValue, update) {
                  capturedSetValue = setValue;
                  capturedUpdate = update;
                  return Text(value);
                },
              ),
            ),
          ),
        );

        expect(find.text('initial'), findsOneWidget);

        // Unmount triggers State.dispose() -> ValueNotifier.dispose().
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        expect(find.text('initial'), findsNothing);

        // Calling captured callbacks after unmount must guard `!mounted` cleanly.
        expect(() => capturedSetValue('after-dispose'), returnsNormally);
        expect(
          () => capturedUpdate((curr) => '$curr-updated'),
          returnsNormally,
        );
        expect(changesCount, equals(0));
      },
    );
  });

  group('BlocxUiToggle', () {
    testWidgets('toggles and sets boolean state while invoking onChanged', (
      tester,
    ) async {
      final changes = <bool>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocxUiToggle(
              initialValue: false,
              onChanged: changes.add,
              builder: (context, isActive, toggle, setValue) {
                return Column(
                  children: [
                    Text(isActive ? 'Expanded' : 'Collapsed'),
                    ElevatedButton(
                      onPressed: toggle,
                      child: const Text('Toggle'),
                    ),
                    ElevatedButton(
                      onPressed: () => setValue(false),
                      child: const Text('Collapse'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Collapsed'), findsOneWidget);

      await tester.tap(find.text('Toggle'));
      await tester.pump();
      expect(find.text('Expanded'), findsOneWidget);

      await tester.tap(find.text('Collapse'));
      await tester.pump();
      expect(find.text('Collapsed'), findsOneWidget);
      expect(changes, equals([true, false]));
    });
  });

  group('Password field obscure toggle', () {
    testWidgets(
      'passwordField enables visibility toggle with semantic finder key and preserves suffix precedence',
      (tester) async {
        final bloc = _PasswordFormBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: _PasswordFormScreen(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        final passwordFinder = find.blocxField(_PasswordField.password);
        expect(passwordFinder, findsOneWidget);

        // Toggle exists for passwordField, not for plain textField or explicit-suffix field.
        final toggleFinder = find.blocxObscureToggle(_PasswordField.password);
        expect(toggleFinder, findsOneWidget);
        expect(
          find.blocxObscureToggle(_PasswordField.plainSecret),
          findsNothing,
        );
        expect(
          find.blocxObscureToggle(_PasswordField.customSuffixPassword),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('custom_suffix_icon')),
          findsOneWidget,
        );

        EditableText passwordEditable() => tester.widget<EditableText>(
          find.descendant(
            of: passwordFinder,
            matching: find.byType(EditableText),
          ),
        );

        expect(passwordEditable().obscureText, isTrue);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

        await tester.enterText(passwordFinder, 's3cr3t!');
        await tester.pump();
        // Clear button must not replace obscure toggle on obscured fields.
        expect(find.byIcon(Icons.clear), findsNothing);
        expect(toggleFinder, findsOneWidget);

        await tester.tap(toggleFinder);
        await tester.pump();
        expect(passwordEditable().obscureText, isFalse);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

        await tester.tap(toggleFinder);
        await tester.pump();
        expect(passwordEditable().obscureText, isTrue);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );
  });
}
