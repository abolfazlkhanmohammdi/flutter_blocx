import 'dart:io';

import 'package:blocx_core/blocx_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'src/screens/splash/presentation/splash_screen.dart';

Future<void> main() async {
  BlocXLocalizations.localizations = ExampleLocalizations();
  HttpOverrides.global = MyHttpOverrides();
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
      BlocXErrorCode.fieldCannotBeEmpty => "This field cannot be empty",
    };
  }

  @override
  String get close => "Close";

  @override
  String get copyDetails => "Copy details";

  @override
  String dateRangeError(DateTime minDate, DateTime maxDate) {
    return "Date must be between $minDate and $maxDate";
  }

  @override
  String get details => "Details";

  @override
  String get emptyListText => "No items found";

  @override
  String get errorDetailsCopied => "Error details copied";

  @override
  String exactLengthFieldError(int length) {
    return "Must be exactly $length characters";
  }

  @override
  String fileSizeMustBeSmallerThan(String format) {
    return "File size must be smaller than $format";
  }

  @override
  String greaterThanFieldError(int otherValue) {
    return "Must be greater than $otherValue";
  }

  @override
  String get invalidEmail => "Invalid email address";

  @override
  String get invalidPhoneNumber => "Invalid phone number";

  @override
  String get invalidUrl => "Invalid URL";

  @override
  String lengthRangeError(minLength, maxLength) {
    return "Length must be between $minLength and $maxLength characters";
  }

  @override
  String lessThanFieldError(int otherValue) {
    return "Must be less than $otherValue";
  }

  @override
  String get loadingText => "Loading...";

  @override
  String maxDateError(DateTime maxDate) {
    return "Date must be on or before $maxDate";
  }

  @override
  String maxLengthError(maxLength) {
    return "Must be at most $maxLength characters";
  }

  @override
  String maxNumberOfItemsCanBeSelected(int max) {
    return "You can select up to $max items";
  }

  @override
  String maxValueError(num maxValue) {
    return "Must be ≤ $maxValue";
  }

  @override
  String minDateError(DateTime minDate) {
    return "Date must be on or after $minDate";
  }

  @override
  String minLengthError(maxLength) {
    return "Must be at least $maxLength characters";
  }

  @override
  String minNumberOfItemsMustBeSelected(int min) {
    return "Select at least $min items";
  }

  @override
  String minValueError(num minValue) {
    return "Must be ≥ $minValue";
  }

  @override
  String mustBeAfterDateField(String otherFieldName) {
    return "Must be after $otherFieldName";
  }

  @override
  String mustBeBeforeDateField(String otherFieldName) {
    return "Must be before $otherFieldName";
  }

  @override
  String numberRangeError(num minValue, num maxValue) {
    return "Must be between $minValue and $maxValue";
  }

  @override
  String get onlyAlphanumericAllowed => "Only alphanumeric characters allowed";

  @override
  String get onlyNumbersAllowed => "Only numbers allowed";

  @override
  String get report => "Report";

  @override
  String get selectedItemsMustBeUnique => "Selected items must be unique";

  @override
  String get somethingWentWrong => "Something went wrong";

  @override
  String get thisFieldIsRequired => "This field is required";

  @override
  String get tryAgain => "Try again";

  @override
  String get valuesDoNotMatch => "Values do not match";
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (_, __, ___) => true;
  }
}
