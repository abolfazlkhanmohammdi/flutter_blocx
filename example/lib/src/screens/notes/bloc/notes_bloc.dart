import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/bloc/use_cases/get_notes_use_case.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class NotesBloc extends ListBloc<Note, (NoteTag, User)> with InfiniteListBlocMixin<Note, (NoteTag, User)> {
  NotesBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an error occurred while fetching notes");
  }

  @override
  PaginationUseCase<Note, (NoteTag, User)>? get loadInitialPageUseCase => GetNotesUseCase(
    queryInput: PaginationQuery(payload: payload, loadCount: loadCount, offset: 0),
  );
  @override
  PaginationUseCase<Note, (NoteTag, User)>? get loadNextPageUseCase => GetNotesUseCase(
    queryInput: PaginationQuery(payload: payload, loadCount: loadCount, offset: offset),
  );
}
