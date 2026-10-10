import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:flutter/cupertino.dart';

/// Base [StatefulWidget] for screens hosting a [BlocxCollectionBloc].
///
/// Accepts an optional [payload] for initial page loading and an optional
/// [bloc] for dependency injection. When [bloc] is provided, it is used
/// directly and is not closed on dispose by default.
abstract class BlocxCollectionWidget<Payload> extends StatefulWidget {
  /// Optional payload passed during initial page loading.
  final Payload? payload;

  /// Optional collection bloc instance for dependency injection.
  final BlocxCollectionBloc<BlocxBaseEntity, Payload>? bloc;

  /// Creates a collection widget.
  const BlocxCollectionWidget({super.key, this.payload, this.bloc});
}
