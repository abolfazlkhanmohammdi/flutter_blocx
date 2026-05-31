import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/core/use_cases/base_pagination_use_case.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';

class GetUserNoteTagsUseCase extends BasePaginationUseCase<GetUserNoteTagsInput, NoteTag> {
  @override
  Future<UseCaseResult<BlocxPage<NoteTag>>> perform(GetUserNoteTagsInput input) async {
    var result = await NoteTagJsonRepository().getPaginated(
      offset: input.offset,
      limit: input.limit,
      userId: input.userId,
    );
    if (!result.ok) {
      return UseCaseResult.failure(StateError("error fetching note tags"), stackTrace: StackTrace.current);
    }
    var converted = result.data.map((map) => NoteTag.fromMap(map)).toList();
    return successResult(items: converted, input: input);
  }
}

class GetUserNoteTagsInput extends BlocxPaginationInput {
  final int userId;
  GetUserNoteTagsInput({required super.limit, required super.offset, required this.userId});
}
