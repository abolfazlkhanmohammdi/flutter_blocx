import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/core/data/fake_repository.dart';
import 'package:example/src/core/data/response_wrapper.dart';

typedef Json = Map<String, dynamic>;

class UserJsonRepository extends FakeRepository implements BaseEntity {
  UserJsonRepository._();
  static final UserJsonRepository _instance = UserJsonRepository._();
  factory UserJsonRepository() => _instance;

  final List<Json> _users = <Json>[];
  final Set<String> _usernames = <String>{};

  @override
  String get identifier => 'user-repo';

  String _newUniqueUsername([String? seed]) {
    var candidate = seed ?? faker.internet.userName();
    var tries = 0;
    while (_usernames.contains(candidate) && tries < 6) {
      candidate = faker.internet.userName();
      tries++;
    }
    if (_usernames.contains(candidate)) {
      candidate = uuid.split('-').first;
    }
    _usernames.add(candidate);
    return candidate;
  }

  void _reserveUsername(String u) => _usernames.add(u);
  void _freeUsername(String u) => _usernames.remove(u);

  Json _newUserJson({
    int? idOverride,
    String? displayName,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    final uname = (username == null || _usernames.contains(username))
        ? _newUniqueUsername(username)
        : (() {
            _reserveUsername(username);
            return username;
          })();

    return {
      'id': idOverride ?? id,
      'displayName': displayName ?? name,
      'username': uname,
      'email': email ?? faker.internet.email(),
      'avatarUrl': avatarUrl ?? image,
      'isActive': isActive ?? faker.randomGenerator.boolean(),
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? createdAt ?? now).toIso8601String(),
    };
  }

  void _ensureAtLeast(int count) {
    while (_users.length < count) {
      _users.add(_newUserJson());
    }
  }

  Future<ResponseWrapper<int>> seed({int count = 20}) async {
    final ids = <int>[];
    for (var i = 0; i < count; i++) {
      final u = _newUserJson();
      _users.add(u);
      ids.add(u['id'] as int);
    }
    return ResponseWrapper(ok: true, data: ids);
  }

  Future<ResponseWrapper<Json>> clear() async {
    _users.clear();
    _usernames.clear();
    return const ResponseWrapper(ok: true, data: <Json>[]);
  }

  Future<ResponseWrapper<Json>> getPaginated({required int offset, int limit = 20}) async {
    await randomWaitFuture;
    _ensureAtLeast(offset + limit);

    final end = (offset + limit).clamp(0, _users.length);
    final start = offset.clamp(0, end);
    final slice = _users.sublist(start, end);

    return ResponseWrapper(ok: true, data: slice);
  }

  Future<ResponseWrapper<Json>> getAll() async {
    await randomWaitFuture;
    return ResponseWrapper(ok: true, data: _users);
  }

  Future<ResponseWrapper<Json>> getById(int userId) async {
    final i = _users.indexWhere((e) => e['id'] == userId);
    if (i == -1) return const ResponseWrapper(ok: false, data: <Json>[]);
    return ResponseWrapper(ok: true, data: <Json>[_users[i]]);
  }

  Future<ResponseWrapper<Json>> create({
    String? displayName,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isActive,
  }) async {
    await randomWaitFuture;
    final u = _newUserJson(
      displayName: displayName,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      isActive: isActive,
    );
    _users.add(u);
    return ResponseWrapper(ok: true, data: <Json>[u]);
  }

  Future<ResponseWrapper<Json>> update(
    int userId, {
    String? displayName,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isActive,
  }) async {
    await randomWaitFuture;
    final idx = _users.indexWhere((e) => e['id'] == userId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final current = Map<String, dynamic>.from(_users[idx]);

    String? newUsername = username;
    if (newUsername != null && newUsername != current['username']) {
      if (_usernames.contains(newUsername)) {
        newUsername = _newUniqueUsername(newUsername);
      } else {
        _freeUsername(current['username'] as String);
        _reserveUsername(newUsername);
      }
    }

    final updated = {
      ...current,
      if (displayName != null) 'displayName': displayName,
      if (newUsername != null) 'username': newUsername,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (isActive != null) 'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _users[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }

  Future<ResponseWrapper<Json>> delete(int userId) async {
    await randomWaitFuture;
    final idx = _users.indexWhere((e) => e['id'] == userId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final removed = _users.removeAt(idx);
    final uname = removed['username'] as String?;
    if (uname != null) _freeUsername(uname);

    return ResponseWrapper(ok: true, data: <Json>[removed]);
  }

  Future<ResponseWrapper<Json>> toggleActive(int userId) async {
    await randomWaitFuture;
    final idx = _users.indexWhere((e) => e['id'] == userId);
    if (idx == -1) return const ResponseWrapper(ok: false, data: <Json>[]);

    final current = Map<String, dynamic>.from(_users[idx]);
    final updated = {
      ...current,
      'isActive': !(current['isActive'] as bool? ?? true),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _users[idx] = updated;
    return ResponseWrapper(ok: true, data: <Json>[updated]);
  }

  Future<ResponseWrapper<Json>> searchUsers(String searchText, int offset, int loadCount) async {
    await randomWaitFuture;
    final lowerCaseSearchText = searchText.toLowerCase();
    final filtered = _users.where((u) {
      final displayName = (u['displayName'] as String?)?.toLowerCase();
      final email = (u['email'] as String?)?.toLowerCase();
      return (displayName?.contains(lowerCaseSearchText) ?? false) ||
          (email?.contains(lowerCaseSearchText) ?? false);
    }).toList();
    offset = offset.clamp(0, filtered.length);
    final end = (offset + loadCount).clamp(0, filtered.length);
    return ResponseWrapper(ok: true, data: filtered.sublist(offset, end).toList());
  }
}
