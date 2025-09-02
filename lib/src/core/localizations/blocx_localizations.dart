import 'package:blocx_core/blocx_core.dart';

abstract class BlocXLocalizations {
  static BlocXLocalizations? _loc;
  static set localizations(value) => _loc = value;
  static BlocXLocalizations get localizations => _loc ?? _DefaultLocalizations();

  String errorCodeMessage(BlocXErrorCode errorCode);
}

class _DefaultLocalizations extends BlocXLocalizations {
  @override
  String errorCodeMessage(BlocXErrorCode errorCode) {
    return switch (errorCode) {
      BlocXErrorCode.checkingUniqueValue => "Checking unique value, please wait...",
      BlocXErrorCode.unknown => "Unknown error",
      BlocXErrorCode.valueNotAvailable => "Value not available",
      BlocXErrorCode.errorGettingInitialFormData => "Error getting initial form data",
    };
  }
}
