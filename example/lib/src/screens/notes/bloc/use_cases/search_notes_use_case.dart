import 'dart:io';
import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/core/use_cases/base_search_use_case.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class SearchNotesUseCase extends BaseSearchUseCase<SearchNotesInput, Note> {
  @override
  Future<UseCaseResult<BlocxPage<Note>>> perform(SearchNotesInput input) async {
    var result = await NotesJsonRepository().searchNotes(
      input.searchText,
      input.limit,
      input.offset,
      input.user,
      input.noteTag,
    );
    if (!result.ok) {
      throw HttpException("Could not search notes. Please try again later.");
    }
    var converted = result.data.map((e) => Note.fromMap(e)).toList();
    return successResult(items: converted, input: input);
  }
}

class SearchNotesInput extends BlocxSearchInput {
  final User? user;
  final NoteTag? noteTag;

  SearchNotesInput({
    required super.searchText,
    required super.limit,
    required super.offset,
    this.user,
    this.noteTag,
  });
}
