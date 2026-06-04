import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
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
  BlocxPaginatedUseCaseTask<BlocxPaginatedUseCase<BlocxPaginationInput, Note>, BlocxPaginationInput>?
  get refreshPageUseCaseTask => BlocxPaginatedUseCaseTask(
    useCase: GetNotesUseCase(),
    inputBuilder: (offset, limit) => GetNotesInput(limit: limit, offset: offset),
  );

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedUseCase<BlocxPaginationInput, Note>, BlocxPaginationInput>?
  get paginationTask => BlocxPaginatedUseCaseTask(
    useCase: GetNotesUseCase(),
    inputBuilder: (offset, limit) => GetNotesInput(limit: limit, offset: offset),
  );

  @override
  BlocxBaseUseCase<Note, bool>? get deleteItemUseCase => DeleteNoteUseCase();

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedUseCase<BlocxSearchInput, Note>, BlocxSearchInput>?
  get searchUseCaseTask => BlocxPaginatedUseCaseTask(
    useCase: SearchNotesUseCase(),
    inputBuilder: (offset, limit) => SearchNotesInput(searchText: searchText, limit: limit, offset: offset),
  );

  @override
  bool get isSingleSelect => false;
}
