import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';

class TestScreenManagerScreen extends StatefulWidget {
  final ScreenManagerCubit cubit;
  final VoidCallback? onRetryCallback;
  final VoidCallback? onPopCallback;

  const TestScreenManagerScreen({
    super.key,
    required this.cubit,
    this.onRetryCallback,
    this.onPopCallback,
  });

  @override
  State<TestScreenManagerScreen> createState() =>
      _TestScreenManagerScreenState();
}

class _TestScreenManagerScreenState
    extends BlocxScreenManagerState<TestScreenManagerScreen> {
  @override
  ScreenManagerCubit get managerCubit => widget.cubit;

  @override
  void onRetry(BuildContext context) {
    super.onRetry(context);
    widget.onRetryCallback?.call();
  }

  @override
  void onPop(BuildContext context) {
    if (widget.onPopCallback != null) {
      widget.onPopCallback!();
      return;
    }
    super.onPop(context);
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return const Center(child: Text('Main Content'));
  }
}

void main() {
  group('L1: ScreenManager full-page error retry', () {
    late ScreenManagerCubit cubit;

    setUp(() {
      cubit = ScreenManagerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets(
        'errorWidget passes onRetry which calls managerCubit.clearError and onRetry hook',
        (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestScreenManagerScreen(
              cubit: cubit,
              onRetryCallback: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);

      // Trigger full-page error
      cubit.displayErrorWidget(ReadableError(message: 'Server down'));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsNothing);
      expect(find.byType(BlocxErrorWidget), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      // Tap 'Try again'
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      // Main content should be restored and callback invoked
      expect(retryCalled, isTrue);
      expect(find.byType(BlocxErrorWidget), findsNothing);
      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets(
        'errorWidgetByErrorCode passes onRetry which clears error and restores main content',
        (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestScreenManagerScreen(
              cubit: cubit,
              onRetryCallback: () => retryCalled = true,
            ),
          ),
        ),
      );

      // Trigger error by error code
      cubit.displayErrorWidgetByErrorCode(BlocXErrorCode.unknown);
      await tester.pumpAndSettle();

      expect(find.byType(BlocxErrorWidget), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(retryCalled, isTrue);
      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets(
        'L4: onPop hook is invoked when cubit emits ScreenManagerCubitStatePop',
        (tester) async {
      var popCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestScreenManagerScreen(
              cubit: cubit,
              onPopCallback: () => popCalled = true,
            ),
          ),
        ),
      );

      expect(popCalled, isFalse);
      cubit.pop();
      await tester.pumpAndSettle();

      expect(popCalled, isTrue);
    });
  });
}
