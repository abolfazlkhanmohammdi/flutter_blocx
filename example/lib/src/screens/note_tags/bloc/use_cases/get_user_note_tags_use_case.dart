import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class GetUserNoteTagsUseCase extends PaginationUseCase<NoteTag, User> {
  final User user;
  GetUserNoteTagsUseCase({required this.user, required super.loadCount, required super.offset});

  @override
  Future<UseCaseResult<Page<NoteTag>>> perform() async {
    var result = await NoteTagJsonRepository().getPaginated(
      offset: offset,
      limit: loadCount,
      userId: user.id,
    );
    if (!result.ok) {
      return UseCaseResult.failure(StateError("error fetching note tags"), stackTrace: StackTrace.current);
    }
    var converted = result.data.map((map) => NoteTag.fromMap(map)).toList();
    return successResult(converted);
  }
}
