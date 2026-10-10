import 'package:blocx_core/form_bloc.dart';

import 'src/form/widgets/blocx_dropdown_menu.dart';
import 'src/form/widgets/blocx_form_text_field.dart';

export 'src/form/blocx_form_view.dart';
export 'src/form/blocx_form_widget_state.dart';
export 'src/form/form_widget.dart';
export 'src/form/widgets/blocx_dropdown_menu.dart';
export 'src/form/widgets/blocx_form_button_row.dart';
export 'src/form/widgets/blocx_form_checkbox.dart';
export 'src/form/widgets/blocx_form_register_button.dart';
export 'src/form/widgets/blocx_form_text_field.dart';

/// Typedef aliases for consistent `Blocx...` casing.
typedef BlocxFormTextField<
  F extends BlocxBaseFormEntity<F, E>,
  P,
  E extends Enum
> = BlocXFormTextField<F, P, E>;

typedef BlocxFormDropdown<
  F extends BlocxBaseFormEntity<F, E>,
  P,
  E extends Enum,
  T
> = BlocXFormDropdown<F, P, E, T>;

typedef BlocxTextFieldOptions = BlocXTextFieldOptions;
typedef BlocxDropdownOptions = BlocXDropdownOptions;
