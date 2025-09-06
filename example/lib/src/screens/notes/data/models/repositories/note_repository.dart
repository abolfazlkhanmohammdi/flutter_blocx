import 'package:example/src/core/data/fake_repository.dart';
import 'package:example/src/core/data/response_wrapper.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/repositories/note_tag_repository.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

typedef Json = Map<String, dynamic>;

class NotesJsonRepository extends FakeRepository {
  NotesJsonRepository._();
  static final NotesJsonRepository _instance = NotesJsonRepository._();
  factory NotesJsonRepository() => _instance;

  final List<Json> _notes = <Json>[];

  Json _newNoteJson({
    required int tagId,
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'uuid': uuid,
      'tagId': tagId,
      'title': title ?? faker.lorem.sentence(),
      'content': content ?? faker.lorem.sentences(faker.randomGenerator.integer(4, min: 1)).join(' '),
      'isPinned': isPinned ?? faker.randomGenerator.boolean(),
      'isArchived': isArchived ?? false,
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? createdAt ?? now).toIso8601String(),
    };
  }

  void _ensureAtLeastForTag(int tagId, int count) {
    while (_notes.where((n) => n['tagId'] == tagId).length < count) {
      _notes.add(_newNoteJson(tagId: tagId));
    }
  }

  Future<ResponseWrapper<int>> seedForTags(List<int> tagIds, {int perTag = 10}) async {
    final ids = <String>[];
    for (final tid in tagIds) {
      for (int i = 0; i < perTag; i++) {
        final n = _newNoteJson(tagId: tid);
        _notes.add(n);
        ids.add(n['uuid'] as String);
      }
    }
    return ResponseWrapper(ok: true, data: []);
  }

  Future<ResponseWrapper<Json>> clear() async {
    _notes.clear();
    return const ResponseWrapper(ok: true, data: <Json>[]);
  }

  Future<ResponseWrapper<Json>> getPaginated({
    required int offset,
    int limit = 20,
    int? tagId,
    List<int>? tagIds,
    int? userId,
    List<int>? userIds,
    String? query,
    bool? isPinned,
    bool? isArchived,
    bool generateOnDemand = false,
  }) async {
    await randomWaitFuture;

    final tagsResp = await NoteTagJsonRepository().getAll();
    final usersResp = await UserJsonRepository().getAll();

    final tagList = tagsResp.data.cast<Json>();
    final userList = usersResp.data.cast<Json>();

    final Map<int, Json> tagById = {for (final t in tagList) (t['id'] as num).toInt(): t};
    final Map<int, Json> userById = {for (final u in userList) (u['id'] as num).toInt(): u};

    Iterable<Json> results = _notes;

    if (generateOnDemand) {
      if (tagId != null) {
        _ensureAtLeastForTag(tagId, offset + limit);
      } else if (tagIds != null && tagIds.isNotEmpty) {
        for (final tid in tagIds) {
          _ensureAtLeastForTag(tid, offset + limit);
        }
      }
    }

    if (tagId != null) {
      results = results.where((n) => (n['tagId'] as num?)?.toInt() == tagId);
    } else if (tagIds != null && tagIds.isNotEmpty) {
      final set = tagIds.toSet();
      results = results.where((n) => set.contains((n['tagId'] as num?)?.toInt()));
    }

    if (userId != null || (userIds != null && userIds.isNotEmpty)) {
      final Set<int> allowedUsers = {if (userId != null) userId, if (userIds != null) ...userIds}.toSet();

      results = results.where((n) {
        final t = tagById[(n['tagId'] as num?)?.toInt() ?? -1];
        final tagUserId = (t?['userId'] as num?)?.toInt();
        return tagUserId != null && allowedUsers.contains(tagUserId);
      });
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((n) {
        final title = (n['title'] as String?)?.toLowerCase() ?? '';
        final content = (n['content'] as String?)?.toLowerCase() ?? '';

        final tagJson = tagById[(n['tagId'] as num?)?.toInt() ?? -1];
        final tagName = (tagJson?['name'] as String?)?.toLowerCase() ?? '';

        final uid = (tagJson?['userId'] as num?)?.toInt();
        final userJson = uid != null ? userById[uid] : null;
        final displayName = (userJson?['displayName'] as String?)?.toLowerCase() ?? '';
        final username = (userJson?['username'] as String?)?.toLowerCase() ?? '';

        return title.contains(q) ||
            content.contains(q) ||
            tagName.contains(q) ||
            displayName.contains(q) ||
            username.contains(q);
      });
    }

    if (isPinned != null) results = results.where((n) => n['isPinned'] == isPinned);
    if (isArchived != null) results = results.where((n) => n['isArchived'] == isArchived);

    final list = results.toList();
    final safeOffset = offset.clamp(0, list.length);
    final end = (safeOffset + limit).clamp(0, list.length);
    final slice = list.sublist(safeOffset, end);

    final enriched = slice.map((n) {
      final tagJson = tagById[(n['tagId'] as num?)?.toInt() ?? -1];
      final uid = (tagJson?['userId'] as num?)?.toInt();
      final userJson = uid != null ? userById[uid] : null;

      return <String, dynamic>{
        ...n,
        if (uid != null) 'userId': uid,
        if (tagJson != null) 'noteTag': tagJson,
        if (userJson != null) 'user': userJson,
      };
    }).toList();

    return ResponseWrapper(ok: true, data: enriched);
  }

  Future<ResponseWrapper<Json>> getAll() async {
    await randomWaitFuture;
    return ResponseWrapper(ok: true, data: _notes);
  }

  Future<ResponseWrapper<Json>> getById(int noteId) async {
    await randomWaitFuture;
    final idx = _notes.indexWhere((e) => e['id'] == noteId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);
    return ResponseWrapper(ok: true, data: <Json>[_notes[idx]]);
  }

  Future<ResponseWrapper<Json>> create({
    required int tagId,
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
  }) async {
    await randomWaitFuture;
    final n = _newNoteJson(
      tagId: tagId,
      title: title,
      content: content,
      isPinned: isPinned,
      isArchived: isArchived,
    );
    _notes.add(n);
    return ResponseWrapper(ok: true, data: <Json>[n]);
  }

  Future<ResponseWrapper<Json>> update(
    int noteId, {
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
  }) async {
    await randomWaitFuture;
    final idx = _notes.indexWhere((e) => e['id'] == noteId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final current = Map<String, dynamic>.from(_notes[idx]);
    final updated = {
      ...current,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (isPinned != null) 'isPinned': isPinned,
      if (isArchived != null) 'isArchived': isArchived,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _notes[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }

  Future<bool> delete(String uuid) async {
    await randomWaitFuture;
    final idx = _notes.indexWhere((e) => e['uuid'] == uuid);
    if (idx == -1) return false;
    _notes.removeAt(idx);
    return true;
  }

  Future<ResponseWrapper<Json>> togglePinned(int noteId) async {
    await randomWaitFuture;
    final idx = _notes.indexWhere((e) => e['id'] == noteId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);
    final current = Map<String, dynamic>.from(_notes[idx]);
    final updated = {
      ...current,
      'isPinned': !(current['isPinned'] as bool? ?? false),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _notes[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }

  Future<ResponseWrapper<Json>> toggleArchived(int noteId) async {
    await randomWaitFuture;
    final idx = _notes.indexWhere((e) => e['id'] == noteId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);
    final current = Map<String, dynamic>.from(_notes[idx]);
    final updated = {
      ...current,
      'isArchived': !(current['isArchived'] as bool? ?? false),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _notes[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }

  Future<ResponseWrapper<Json>> searchNotes(
    String searchText,
    int loadCount,
    int offset,
    User? user,
    NoteTag? tag,
  ) async {
    await randomWaitFuture;

    final tagsResp = await NoteTagJsonRepository().getAll();
    final usersResp = await UserJsonRepository().getAll();

    final tagList = tagsResp.data.cast<Json>();
    final userList = usersResp.data.cast<Json>();

    final Map<int, Json> tagById = {for (final t in tagList) (t['id'] as num).toInt(): t};
    final Map<int, Json> userById = {for (final u in userList) (u['id'] as num).toInt(): u};

    Iterable<Json> results = _notes;

    if (tag != null) {
      results = results.where((n) => (n['tagId'] as num?)?.toInt() == tag.id);
    }

    if (user != null) {
      results = results.where((n) {
        final t = tagById[(n['tagId'] as num?)?.toInt() ?? -1];
        final tagUserId = (t?['userId'] as num?)?.toInt();
        return tagUserId == user.id;
      });
    }

    final q = searchText.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((n) {
        final title = (n['title'] as String?)?.toLowerCase() ?? '';
        final content = (n['content'] as String?)?.toLowerCase() ?? '';

        final t = tagById[(n['tagId'] as num?)?.toInt() ?? -1];
        final tagName = (t?['name'] as String?)?.toLowerCase() ?? '';

        final userId = (t?['userId'] as num?)?.toInt();
        final u = userId != null ? userById[userId] : null;
        final displayName = (u?['displayName'] as String?)?.toLowerCase() ?? '';
        final username = (u?['username'] as String?)?.toLowerCase() ?? '';

        return title.contains(q) ||
            content.contains(q) ||
            tagName.contains(q) ||
            displayName.contains(q) ||
            username.contains(q);
      });
    }

    final list = results.toList();
    final safeOffset = offset.clamp(0, list.length);
    final end = (safeOffset + loadCount).clamp(0, list.length);
    final slice = list.sublist(safeOffset, end);

    final enriched = slice.map((n) {
      final tagJson = tagById[(n['tagId'] as num?)?.toInt() ?? -1];
      final uid = (tagJson?['userId'] as num?)?.toInt();
      final userJson = uid != null ? userById[uid] : null;

      return <String, dynamic>{
        ...n,
        if (tagJson != null) 'noteTag': tagJson,
        if (userJson != null) 'user': userJson,
        if (uid != null) 'userId': uid,
      };
    }).toList();

    return ResponseWrapper(ok: true, data: enriched);
  }
}
