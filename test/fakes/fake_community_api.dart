import 'dart:async';

import 'package:outfitly/data/community/community_api.dart';

/// In-memory backend mirroring the rules enforced by supabase/schema.sql (RLS + triggers).
class FakeCommunityApi implements CommunityApi {
  FakeCommunityApi({this.requireEmailConfirm = false});

  final bool requireEmailConfirm;
  final _users = <String, String>{}; // email → password
  final _ids = <String, String>{}; // email → uid
  final profiles = <String, CommunityProfile>{};
  final posts = <CommunityPost>[];
  final likes = <(String post, String user)>{};
  final views = <(String post, String user)>{};
  final reports = <(String post, String user)>{};
  final blocks = <(String blocker, String blocked)>{};
  final _auth = StreamController<String?>.broadcast();
  String? _me;
  int _seq = 0;

  void loginAs(String uid) {
    _me = uid;
    _auth.add(uid);
  }

  /// Seeds another user with a public profile and a post.
  CommunityPost seedPost({required String uid, required String username, String title = 'Linen shirt', DateTime? at}) {
    profiles[uid] ??= CommunityProfile(id: uid, username: username, displayName: username.toUpperCase());
    final p = CommunityPost(
      id: 'post-${_seq++}',
      ownerId: uid,
      ownerUsername: username,
      ownerName: profiles[uid]!.displayName,
      kind: 'item',
      localRef: 'l$_seq',
      title: title,
      imageUrls: const [], // no network images in widget tests (cache manager needs platform plugins)
      imagePaths: ['$uid/x.jpg'],
      likeCount: 0,
      viewCount: 0,
      createdAt: at ?? DateTime.now().subtract(Duration(minutes: _seq)),
    );
    posts.add(p);
    return p;
  }

  @override
  bool get isConfigured => true;
  @override
  String? get currentUserId => _me;
  @override
  Stream<String?> get userChanges => _auth.stream;

  String _require() => _me ?? (throw CommunityException('Please sign in first.'));

  @override
  Future<SignUpResult> signUp(String email, String password) async {
    if (_users.containsKey(email)) throw CommunityException('User already registered');
    _users[email] = password;
    _ids[email] = 'user-${_ids.length + 1}';
    if (requireEmailConfirm) return SignUpResult.confirmEmail;
    loginAs(_ids[email]!);
    return SignUpResult.signedIn;
  }

  @override
  Future<void> signIn(String email, String password) async {
    if (_users[email] != password) throw CommunityException('Invalid login credentials');
    loginAs(_ids[email]!);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    _me = null;
    _auth.add(null);
  }

  @override
  Future<CommunityProfile?> myProfile() async => _me == null ? null : profiles[_me];
  @override
  Future<CommunityProfile?> profile(String userId) async => profiles[userId];

  @override
  Future<void> saveProfile({required String username, required String displayName, String? bio, required bool isPublic}) async {
    final me = _require();
    if (profiles.values.any((p) => p.username == username && p.id != me)) throw CommunityException('That already exists — try a different name.');
    profiles[me] = CommunityProfile(id: me, username: username, displayName: displayName, bio: bio, isPublic: isPublic);
  }

  int _likes(String id) => likes.where((l) => l.$1 == id).length;
  int _views(String id) => views.where((v) => v.$1 == id).length;
  bool _hidden(String id) => reports.where((r) => r.$1 == id).length >= 3;
  bool _visible(CommunityPost p) =>
      p.ownerId == _me ||
      (!_hidden(p.id) && (profiles[p.ownerId]?.isPublic ?? false) && !blocks.contains((_me ?? '', p.ownerId)) && !blocks.contains((p.ownerId, _me ?? '')));

  CommunityPost _fresh(CommunityPost p) => CommunityPost(
    id: p.id,
    ownerId: p.ownerId,
    ownerUsername: p.ownerUsername,
    ownerName: p.ownerName,
    kind: p.kind,
    localRef: p.localRef,
    title: p.title,
    caption: p.caption,
    category: p.category,
    colorName: p.colorName,
    imageUrls: p.imageUrls,
    imagePaths: p.imagePaths,
    likeCount: _likes(p.id),
    viewCount: _views(p.id),
    createdAt: p.createdAt,
    hidden: _hidden(p.id),
  );

  @override
  Future<List<CommunityPost>> feed({DateTime? before, int limit = 20}) async {
    final list = posts.where((p) => _visible(p) && !_hidden(p.id) && (before == null || p.createdAt.isBefore(before))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).map(_fresh).toList();
  }

  @override
  Future<List<CommunityPost>> postsBy(String userId) async =>
      posts.where((p) => p.ownerId == userId && _visible(p)).map(_fresh).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<Set<String>> likedPostIds(Iterable<String> postIds) async => {
    for (final l in likes)
      if (l.$2 == _me && postIds.contains(l.$1)) l.$1,
  };

  @override
  Future<CommunityPost> share({
    required String kind,
    required String localRef,
    required String title,
    String? caption,
    String? category,
    String? colorName,
    required List<UploadImage> images,
  }) async {
    final me = _require();
    if (posts.any((p) => p.ownerId == me && p.kind == kind && p.localRef == localRef)) throw CommunityException('That already exists — try a different name.');
    final prof = profiles[me]!;
    final p = CommunityPost(
      id: 'post-${_seq++}',
      ownerId: me,
      ownerUsername: prof.username,
      ownerName: prof.displayName,
      kind: kind,
      localRef: localRef,
      title: title,
      caption: caption,
      category: category,
      colorName: colorName,
      imageUrls: [for (var i = 0; i < images.length; i++) 'https://example.invalid/$i.jpg'],
      imagePaths: [for (var i = 0; i < images.length; i++) '$me/$i.jpg'],
      likeCount: 0,
      viewCount: 0,
      createdAt: DateTime.now(),
    );
    posts.add(p);
    return p;
  }

  @override
  Future<void> deletePost(CommunityPost post) async {
    if (post.ownerId != _require()) throw CommunityException('Not allowed');
    posts.removeWhere((p) => p.id == post.id);
  }

  @override
  Future<void> like(String postId) async => likes.add((postId, _require()));
  @override
  Future<void> unlike(String postId) async => likes.remove((postId, _require()));

  @override
  Future<void> recordView(String postId) async {
    final p = posts.firstWhere((p) => p.id == postId);
    if (p.ownerId != _me && _me != null) views.add((postId, _me!));
  }

  @override
  Future<CommunityStats> myStats() async {
    final mine = posts.where((p) => p.ownerId == _me).toList();
    final l = mine.fold<int>(0, (a, p) => a + _likes(p.id));
    final v = mine.fold<int>(0, (a, p) => a + _views(p.id));
    return CommunityStats(posts: mine.length, likes: l, views: v, likes7d: l, views7d: v);
  }

  @override
  Future<void> report(String postId, ReportReason reason, {String? details}) async => reports.add((postId, _require()));
  @override
  Future<void> block(String userId) async => blocks.add((_require(), userId));
  @override
  Future<void> unblock(String userId) async => blocks.remove((_require(), userId));
  @override
  Future<List<CommunityProfile>> blockedUsers() async => [
    for (final b in blocks)
      if (b.$1 == _me && profiles[b.$2] != null) profiles[b.$2]!,
  ];

  @override
  Future<void> deleteAccount() async {
    final me = _require();
    posts.removeWhere((p) => p.ownerId == me);
    likes.removeWhere((l) => l.$2 == me);
    profiles.remove(me);
    await signOut();
  }
}
