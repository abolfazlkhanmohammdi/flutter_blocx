import 'package:example/src/core/data/fake_repository.dart';
import 'package:example/src/core/data/response_wrapper.dart';

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
    String? query,
    bool? isPinned,
    bool? isArchived,
    String sortBy = 'updatedAt',
    bool descending = true,
    bool generateOnDemand = true,
  }) async {
    await randomWaitFuture;

    Iterable<Json> results = _notes;

    if (generateOnDemand && tagId != null) {
      _ensureAtLeastForTag(tagId, offset + limit);
    }

    if (tagId != null) {
      results = results.where((n) => n['tagId'] == tagId);
    } else if (tagIds != null && tagIds.isNotEmpty) {
      final set = tagIds.toSet();
      results = results.where((n) => set.contains(n['tagId']));
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where(
        (n) =>
            (n['title'] as String).toLowerCase().contains(q) ||
            (n['content'] as String).toLowerCase().contains(q),
      );
    }

    if (isPinned != null) results = results.where((n) => n['isPinned'] == isPinned);
    if (isArchived != null) results = results.where((n) => n['isArchived'] == isArchived);

    int cmp(Json a, Json b) {
      if (sortBy == 'title') {
        return (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase());
      }
      final ad = DateTime.tryParse(a['updatedAt'] as String) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = DateTime.tryParse(b['updatedAt'] as String) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ad.compareTo(bd);
    }

    var sorted = results.toList()..sort(cmp);
    if (descending) sorted = sorted.reversed.toList();

    final end = (offset + limit).clamp(0, sorted.length);
    final start = offset.clamp(0, end);
    final slice = sorted.sublist(start, end);

    return ResponseWrapper(ok: true, data: slice);
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

  Future<ResponseWrapper<Json>> delete(int noteId) async {
    await randomWaitFuture;
    final idx = _notes.indexWhere((e) => e['id'] == noteId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);
    final removed = _notes.removeAt(idx);
    return ResponseWrapper(ok: true, data: <Json>[removed]);
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
}
