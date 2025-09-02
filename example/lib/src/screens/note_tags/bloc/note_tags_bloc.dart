import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/delete_note_tag_use_case.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/get_user_note_tags_use_case.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class NoteTagsBloc extends ListBloc<NoteTag, User>
    with
        InfiniteListBlocMixin<NoteTag, User>,
        RefreshableListBlocMixin<NoteTag, User>,
        DeletableListBlocMixin<NoteTag, User>,
        HighlightableListBlocMixin<NoteTag, User> {
  NoteTagsBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("Error", "An error occurred.");
  }

  @override
  PaginationUseCase<NoteTag, User>? get loadInitialPageUseCase =>
      GetUserNoteTagsUseCase(loadCount: loadCount, offset: offset, user: payload!);

  @override
  PaginationUseCase<NoteTag, User>? get loadNextPageUseCase =>
      GetUserNoteTagsUseCase(loadCount: loadCount, offset: offset, user: payload!);

  @override
  BaseUseCase<bool>? deleteItemUseCase(NoteTag item) {
    return DeleteNoteTagUseCase(noteTag: item);
  }

  @override
  PaginationUseCase<NoteTag, User>? get refreshPageUseCase =>
      GetUserNoteTagsUseCase(loadCount: list.length, offset: 0, user: payload!);

  int sortByUpdateDate(NoteTag f, NoteTag s) {
    return s.updatedAt.millisecondsSinceEpoch.compareTo(f.updatedAt.millisecondsSinceEpoch);
  }
}
