import 'package:blocx_core/src/core/enum_error_codes.dart';
import 'package:blocx_flutter/flutter_blocx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'src/screens/splash/presentation/splash_screen.dart';

Future<void> main() async {
  BlocXLocalizations.localizations = ExampleLocalizations();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: SplashScreen(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.unknown,
  };
}

class ExampleLocalizations extends BlocXLocalizations {
  @override
  String errorCodeMessage(BlocXErrorCode errorCode) {
    return switch (errorCode) {
      BlocXErrorCode.checkingUniqueValue => "Checking unique value",
      BlocXErrorCode.unknown => "Unknown error",
      BlocXErrorCode.valueNotAvailable => "This value is not available",
      BlocXErrorCode.errorGettingInitialFormData => "Error getting initial form data",
    };
  }
}
