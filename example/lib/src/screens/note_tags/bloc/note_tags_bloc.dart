import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/use_case_get_user_note_tags.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class NoteTagsBloc extends ListBloc<NoteTag, User> with InfiniteListBlocMixin<NoteTag, User> {
  NoteTagsBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("Error", "An error occurred.");
  }

  @override
  PaginationUseCase<NoteTag, User>? get loadInitialPageUseCase => UseCaseGetUserNoteTags(
    queryInput: PaginationQuery(loadCount: loadCount, offset: 0, payload: payload),
  );

  @override
  PaginationUseCase<NoteTag, User>? get loadNextPageUseCase => UseCaseGetUserNoteTags(
    queryInput: PaginationQuery(loadCount: loadCount, offset: offset, payload: payload),
  );
}
