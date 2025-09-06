part of 'splash_bloc.dart';

sealed class SplashState extends BaseState {
  const SplashState({required super.shouldRebuild, required super.shouldListen});
}

final class SplashStateDataLoaded extends SplashState {
  const SplashStateDataLoaded() : super(shouldListen: true, shouldRebuild: false);
}

final class SplashStateLoading extends SplashState {
  const SplashStateLoading() : super(shouldRebuild: true, shouldListen: false);
}
