part of 'splash_bloc.dart';

@immutable
sealed class SplashState {
  final bool shouldRebuild;
  final bool shouldListen;

  const SplashState({required this.shouldRebuild, required this.shouldListen});
}

final class SplashStateDataLoaded extends SplashState {
  const SplashStateDataLoaded()
    : super(shouldListen: true, shouldRebuild: false);
}

final class SplashStateLoading extends SplashState {
  const SplashStateLoading() : super(shouldRebuild: true, shouldListen: false);
}
