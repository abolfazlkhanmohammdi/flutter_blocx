import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/bloc/use_cases/delete_note_use_case.dart';
import 'package:example/src/screens/notes/bloc/use_cases/get_notes_use_case.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/users/data/models/user.dart';

import 'use_cases/search_notes_use_case.dart';

class NotesBloc extends ListBloc<Note, (NoteTag, User)>
    with
        InfiniteListBlocMixin<Note, (NoteTag, User)>,
        RefreshableListBlocMixin<Note, (NoteTag, User)>,
        ExpandableListBlocMixin<Note, (NoteTag, User)>,
        HighlightableListBlocMixin<Note, (NoteTag, User)>,
        DeletableListBlocMixin<Note, (NoteTag, User)>,
        SelectableListBlocMixin<Note, (NoteTag, User)>,
        ScrollableListBlocMixin<Note, (NoteTag, User)>,
        SearchableListBlocMixin<Note, (NoteTag, User)> {
  NotesBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an error occurred while fetching notes");
  }

  @override
  PaginationUseCase<Note, (NoteTag, User)>? get loadInitialPageUseCase =>
      GetNotesUseCase(user: payload?.$2, noteTag: payload?.$1, loadCount: loadCount, offset: 0);
  @override
  PaginationUseCase<Note, (NoteTag, User)>? get loadNextPageUseCase =>
      GetNotesUseCase(user: payload?.$2, noteTag: payload?.$1, loadCount: loadCount, offset: offset);

  @override
  PaginationUseCase<Note, (NoteTag, User)>? get refreshPageUseCase =>
      GetNotesUseCase(user: payload?.$2, noteTag: payload?.$1, loadCount: list.length, offset: 0);
  @override
  BaseUseCase<bool>? deleteItemUseCase(Note item) {
    return DeleteNoteUseCase(note: item);
  }

  @override
  SearchUseCase<Note>? searchUseCase(String searchText, {int? loadCount, int? offset}) {
    return SearchNotesUseCase(
      searchText: searchText,
      loadCount: loadCount ?? this.loadCount,
      offset: offset ?? this.offset,
      user: payload?.$2,
      tag: payload?.$1,
    );
  }

  @override
  bool get isSingleSelect => false;
}
