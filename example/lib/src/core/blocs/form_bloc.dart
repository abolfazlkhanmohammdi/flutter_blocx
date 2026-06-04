import 'package:blocx_core/form_bloc.dart';

abstract class FormBloc<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>
    extends BlocxFormBloc<F, P, E> {
  FormBloc(super.initialFormData);
}
