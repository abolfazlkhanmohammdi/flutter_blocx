import 'package:blocx_flutter/flutter_blocx.dart';
import 'package:example/src/screens/splash/bloc/splash_bloc.dart';
import 'package:example/src/screens/users/presentation/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends BlocXWidgetState<SplashScreen> {
  SplashBloc bloc = SplashBloc();
  @override
  void initState() {
    bloc.add(SplashEventInit());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<SplashBloc>(
        create: (_) => bloc,
        child: BlocConsumer<SplashBloc, SplashState>(
          builder: blocBuilder,
          buildWhen: (_, c) => c.shouldRebuild,
          listener: blocListener,
          listenWhen: (_, c) => c.shouldListen,
        ),
      ),
    );
  }

  Widget blocBuilder(BuildContext context, SplashState state) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SizedBox.square(
            dimension: width / 2,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
          ),
        ),
        Text('Blocx Notes!', style: textTheme.displaySmall, textAlign: TextAlign.center),
        Text("Now loading, please wait...", textAlign: TextAlign.center, style: textTheme.bodyLarge),
        Center(child: SizedBox.square(dimension: 40, child: CircularProgressIndicator())),
      ],
    );
  }

  void blocListener(BuildContext context, SplashState state) {
    if (state is SplashStateDataLoaded) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => UsersScreen()));
    }
  }
}
