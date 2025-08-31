import 'dart:async';
import 'dart:math';

import 'package:bloc/src/bloc.dart';
import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';
part 'splash_bloc_event.dart';
part 'splash_bloc_state.dart';

class SplashBloc extends BaseBloc<SplashEvent, SplashState> {
  Random random = Random();
  SplashBloc() : super(SplashStateLoading(), ScreenManagerCubit()) {
    on<SplashEventInit>(init);
  }

  Future<void> init(SplashEventInit event, Emitter<SplashState> emit) async {
    var userSeedResult = await UserJsonRepository().seed(count: random.nextInt(90) + 60);
    var noteTagsResult = await NoteTagJsonRepository().seedForUsers(
      userSeedResult.data,
      perUser: random.nextInt(4) + 20,
    );
    await NotesJsonRepository().seedForTags(noteTagsResult.data);
    await Future.delayed(Duration(seconds: 3));
    emit(SplashStateDataLoaded());
  }
}
