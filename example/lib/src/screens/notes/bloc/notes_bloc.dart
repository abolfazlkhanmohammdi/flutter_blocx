import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:example/src/core/blocs/collection_bloc.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/bloc/use_cases/delete_note_use_case.dart';
import 'package:example/src/screens/notes/bloc/use_cases/get_notes_use_case.dart';
import 'package:example/src/screens/notes/bloc/use_cases/search_notes_use_case.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class NotesBloc extends CollectionBloc<Note, (NoteTag, User)>
    with
        BlocxCollectionInfiniteMixin<Note, (NoteTag, User)>,
        BlocxCollectionRefreshableMixin<Note, (NoteTag, User)>,
        BlocxCollectionExpandableMixin<Note, (NoteTag, User)>,
        BlocxCollectionHighlightableMixin<Note, (NoteTag, User)>,
        BlocxCollectionDeletableMixin<Note, (NoteTag, User)>,
        BlocxCollectionSelectableMixin<Note, (NoteTag, User)>,
        BlocxCollectionScrollableMixin<Note, (NoteTag, User)>,
        BlocxCollectionSearchableMixin<Note, (NoteTag, User)> {
  NotesBloc() : super();

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, Note>?
  get refreshPageUseCaseTask => BlocxPaginatedUseCaseTask(
    useCase: GetNotesUseCase(),
    inputBuilder: (offset, limit) =>
        GetNotesInput(limit: limit, offset: offset),
  );

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, Note>? get paginationTask =>
      BlocxPaginatedUseCaseTask(
        useCase: GetNotesUseCase(),
        inputBuilder: (offset, limit) =>
            GetNotesInput(limit: limit, offset: offset),
      );

  @override
  BlocxUseCaseTask<Object?, bool>? deleteItemTask(Note item) =>
      BlocxUseCaseTask(useCase: DeleteNoteUseCase(), inputBuilder: () => item);

  @override
  BlocxPaginatedUseCaseTask<BlocxSearchInput, Note>? get searchUseCaseTask =>
      BlocxPaginatedUseCaseTask(
        useCase: SearchNotesUseCase(),
        inputBuilder: (offset, limit) => SearchNotesInput(
          searchText: searchText,
          limit: limit,
          offset: offset,
        ),
      );

  @override
  bool get isSingleSelect => false;
}
