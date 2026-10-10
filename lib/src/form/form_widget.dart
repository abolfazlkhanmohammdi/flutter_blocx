import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/cupertino.dart';

/// Base [StatefulWidget] for screens hosting a [BlocxFormBloc].
///
/// Accepts an optional [payload] for form initialization and an optional
/// [bloc] for dependency injection. When [bloc] is provided, it is used
/// directly and is not closed on dispose by default.
abstract class BlocxFormWidget<P> extends StatefulWidget {
  /// Optional payload passed during form initialization.
  final P? payload;

  /// Optional form bloc instance for dependency injection.
  final BlocxFormBloc<dynamic, P, dynamic>? bloc;

  /// Creates a form widget.
  const BlocxFormWidget({super.key, this.payload, this.bloc});
}
