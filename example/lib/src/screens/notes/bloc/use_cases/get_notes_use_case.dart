import 'dart:io';
import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/core/use_cases/base_pagination_use_case.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/data/models/repositories/note_repository.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class GetNotesUseCase extends BasePaginationUseCase<GetNotesInput, Note> {
  @override
  Future<UseCaseResult<BlocxPage<Note>>> perform(GetNotesInput input) async {
    var result = await NotesJsonRepository().getPaginated(
      offset: input.offset,
      limit: input.limit,
      tagId: input.noteTag?.id,
      userId: input.user?.id,
    );
    if (!result.ok) {
      throw HttpException("Could not search notes. Please try again later.");
    }
    var converted = result.data.map((e) => Note.fromMap(e)).toList();
    return successResult(items: converted, input: input);
  }
}

class GetNotesInput extends BlocxPaginationInput {
  final User? user;
  final NoteTag? noteTag;

  GetNotesInput({required super.limit, required super.offset, this.user, this.noteTag});
}
