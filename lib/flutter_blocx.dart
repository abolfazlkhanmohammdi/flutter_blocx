import 'package:flutter/widgets.dart';
import 'package:blocx_core/blocx_core.dart';

import 'src/core/base/bloc_x_widget_state.dart';

export 'blocx_collection_item_state.dart';
export 'form_widget.dart';
export 'list_widget.dart';
export 'src/core/base/bloc_x_widget_state.dart';
export 'src/core/localizations/loc_provider.dart';
export 'src/core/mixins/hide_on_scroll_fab_mixin.dart';
export 'src/core/widgets/blocx_stateless_widget.dart';
export 'src/screen_manager/blocx_error_widget.dart';
export 'src/screen_manager/blocx_screen_manager_state.dart';
export 'src/widgets/blocx_search_field.dart';
export 'src/widgets/blocx_snack_bar.dart';
export 'src/widgets/confirm_action_widget.dart';

/// Typedef aliases for consistent `Blocx...` casing.
typedef BlocxWidgetState<W extends StatefulWidget> = BlocXWidgetState<W>;
typedef BlocxSnackbarType = BlocXSnackbarType;
