import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/core/data/fake_repository.dart';
import 'package:example/src/core/data/response_wrapper.dart';

typedef Json = Map<String, dynamic>;

class NoteTagJsonRepository extends FakeRepository implements BaseEntity {
  NoteTagJsonRepository._();
  static final NoteTagJsonRepository _instance = NoteTagJsonRepository._();
  factory NoteTagJsonRepository() => _instance;

  @override
  String get identifier => 'note-tag-repo';

  final List<Json> _tags = <Json>[];
  final Set<String> _names = <String>{};

  String _newUniqueName([String? seed]) {
    String clean(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    var candidate = clean(seed ?? faker.lorem.word());
    if (candidate.isEmpty) candidate = 'tag';
    var tries = 0;
    while (_names.contains(candidate) && tries < 6) {
      candidate = clean(faker.lorem.word());
      if (candidate.isEmpty) candidate = 'tag';
      tries++;
    }
    if (_names.contains(candidate)) candidate = uuid.split('-').first;
    _names.add(candidate);
    return candidate;
  }

  void _reserveName(String n) => _names.add(n);
  void _freeName(String n) => _names.remove(n);

  int _randColorArgb() {
    final rgb = faker.randomGenerator.integer(0xFFFFFF, min: 0);
    return 0xFF000000 | rgb;
  }

  Json _newTagJson({
    required int userId,
    int? idOverride,
    String? nameOverride,
    int? colorArgb,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    final uniqueName = faker.conference.name();

    return {
      'id': idOverride ?? id,
      'userId': userId,
      'name': uniqueName,
      'colorArgb': colorArgb ?? _randColorArgb(),
      'isArchived': isArchived ?? faker.randomGenerator.boolean(),
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? createdAt ?? now).toIso8601String(),
    };
  }

  void _ensureAtLeastForUser(int userId, int count) {
    while (_tags.where((t) => t['userId'] == userId).length < count) {
      _tags.add(_newTagJson(userId: userId));
    }
  }

  Future<ResponseWrapper<int>> seedForUsers(List<int> userIds, {int perUser = 5}) async {
    final ids = <int>[];
    for (final uid in userIds) {
      for (int i = 0; i < perUser; i++) {
        final t = _newTagJson(userId: uid);
        _tags.add(t);
        ids.add(t['id'] as int);
      }
    }
    return ResponseWrapper(ok: true, data: ids);
  }

  Future<ResponseWrapper<Json>> clear() async {
    _tags.clear();
    _names.clear();
    return const ResponseWrapper(ok: true, data: <Json>[]);
  }

  Future<ResponseWrapper<Json>> getPaginated({
    required int offset,
    int limit = 20,
    int? userId,
    String? query,
    bool? isArchived,
    String sortBy = 'updatedAt',
    bool descending = true,
  }) async {
    await randomWaitFuture;

    Iterable<Json> results = _tags;

    if (userId != null) {
      _ensureAtLeastForUser(userId, offset + limit);
      results = results.where((t) => t['userId'] == userId);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((t) => (t['name'] as String).toLowerCase().contains(q));
    }
    if (isArchived != null) {
      results = results.where((t) => t['isArchived'] == isArchived);
    }

    int cmp(Json a, Json b) {
      if (sortBy == 'name') {
        return (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase());
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
    return ResponseWrapper(ok: true, data: _tags);
  }

  Future<ResponseWrapper<Json>> getById(int tagId) async {
    await randomWaitFuture;
    final idx = _tags.indexWhere((e) => e['id'] == tagId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);
    return ResponseWrapper(ok: true, data: <Json>[_tags[idx]]);
  }

  Future<ResponseWrapper<Json>> create({
    required int userId,
    String? name,
    int? colorArgb,
    bool? isArchived,
  }) async {
    await randomWaitFuture;
    final t = _newTagJson(userId: userId, nameOverride: name, colorArgb: colorArgb, isArchived: isArchived);
    _tags.add(t);
    return ResponseWrapper(ok: true, data: <Json>[t]);
  }

  Future<ResponseWrapper<Json>> update(int tagId, {String? name, int? colorArgb, bool? isArchived}) async {
    await randomWaitFuture;
    final idx = _tags.indexWhere((e) => e['id'] == tagId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final current = Map<String, dynamic>.from(_tags[idx]);

    String? newName = name;
    if (newName != null && newName != current['name']) {
      if (_names.contains(newName)) {
        newName = _newUniqueName(newName);
      } else {
        _freeName(current['name'] as String);
        _reserveName(newName);
      }
    }

    final updated = {
      ...current,
      if (newName != null) 'name': newName,
      if (colorArgb != null) 'colorArgb': colorArgb,
      if (isArchived != null) 'isArchived': isArchived,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _tags[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }

  Future<ResponseWrapper<Json>> delete(int tagId) async {
    await randomWaitFuture;
    final idx = _tags.indexWhere((e) => e['id'] == tagId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final removed = _tags.removeAt(idx);
    final n = removed['name'] as String?;
    if (n != null) _freeName(n);

    return ResponseWrapper(ok: true, data: <Json>[removed]);
  }

  Future<ResponseWrapper<Json>> toggleArchived(int tagId) async {
    await randomWaitFuture;
    final idx = _tags.indexWhere((e) => e['id'] == tagId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final current = Map<String, dynamic>.from(_tags[idx]);
    final updated = {
      ...current,
      'isArchived': !(current['isArchived'] as bool? ?? false),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tags[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }
}
