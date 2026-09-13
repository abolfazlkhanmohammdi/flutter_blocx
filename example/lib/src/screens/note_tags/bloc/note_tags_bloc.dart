import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:example/src/core/blocs/collection_bloc.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/delete_note_tag_use_case.dart';
import 'package:example/src/screens/note_tags/bloc/use_cases/get_user_note_tags_use_case.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class NoteTagsBloc extends CollectionBloc<NoteTag, User>
    with
        BlocxCollectionInfiniteMixin<NoteTag, User>,
        BlocxCollectionRefreshableMixin<NoteTag, User>,
        BlocxCollectionDeletableMixin<NoteTag, User>,
        BlocxCollectionHighlightableMixin<NoteTag, User> {
  @override
  BlocxUseCaseTask<Object?, bool>? deleteItemTask(NoteTag item) =>
      BlocxUseCaseTask(
        useCase: DeleteNoteTagUseCase(),
        inputBuilder: () => item,
      );

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, NoteTag>? get paginationTask {
    return BlocxPaginatedUseCaseTask(
      useCase: GetUserNoteTagsUseCase(),
      inputBuilder: (offset, limit) => GetUserNoteTagsInput(
        limit: limit,
        offset: offset,
        userId: payload!.id,
      ),
    );
  }
}
