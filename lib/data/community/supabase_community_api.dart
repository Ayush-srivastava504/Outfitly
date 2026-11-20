import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'community_api.dart';

/// Supabase implementation. Schema + RLS: supabase/schema.sql.
class SupabaseCommunityApi implements CommunityApi {
  SupabaseCommunityApi(this.client);

  final SupabaseClient client;
  static const bucket = 'wardrobe';
  static const _uuid = Uuid();
  static const _postSelect = '*, profiles!inner(username, display_name)';

  static Future<SupabaseCommunityApi> initialize() async {
    await Supabase.initialize(url: CommunityConfig.url, publishableKey: CommunityConfig.anonKey);
    return SupabaseCommunityApi(Supabase.instance.client);
  }

  @override
  bool get isConfigured => true;

  @override
  String? get currentUserId => client.auth.currentUser?.id;

  @override
  Stream<String?> get userChanges => client.auth.onAuthStateChange.map((s) => s.session?.user.id);

  String _requireUser() => currentUserId ?? (throw CommunityException('Please sign in first.'));

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthException catch (e) {
      throw CommunityException(e.message);
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw CommunityException('That already exists — try a different name.');
      throw CommunityException(e.message);
    } on StorageException catch (e) {
      throw CommunityException('Upload failed: ${e.message}');
    }
  }

  @override
  Future<SignUpResult> signUp(String email, String password) => _guard(() async {
    final r = await client.auth.signUp(email: email.trim(), password: password);
    return r.session == null ? SignUpResult.confirmEmail : SignUpResult.signedIn;
  });

  @override
  Future<void> signIn(String email, String password) => _guard(() => client.auth.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<void> sendPasswordReset(String email) => _guard(() => client.auth.resetPasswordForEmail(email.trim()));

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  Future<CommunityProfile?> myProfile() async {
    final id = currentUserId;
    return id == null ? null : profile(id);
  }

  @override
  Future<CommunityProfile?> profile(String userId) => _guard(() async {
    final row = await client.from('profiles').select().eq('id', userId).maybeSingle();
    return row == null ? null : CommunityProfile.fromJson(row);
  });

  @override
  Future<void> saveProfile({required String username, required String displayName, String? bio, required bool isPublic}) => _guard(() async {
    await client.from('profiles').upsert({
      'id': _requireUser(),
      'username': username.trim().toLowerCase(),
      'display_name': displayName.trim(),
      'bio': (bio == null || bio.trim().isEmpty) ? null : bio.trim(),
      'is_public': isPublic,
    });
  });

  CommunityPost _post(Map<String, dynamic> j) {
    final owner = j['profiles'] as Map<String, dynamic>;
    final paths = (j['image_paths'] as List).cast<String>();
    return CommunityPost(
      id: j['id'] as String,
      ownerId: j['owner'] as String,
      ownerUsername: owner['username'] as String,
      ownerName: owner['display_name'] as String,
      kind: j['kind'] as String,
      localRef: j['local_ref'] as String,
      title: j['title'] as String,
      caption: j['caption'] as String?,
      category: j['category'] as String?,
      colorName: j['color_name'] as String?,
      imagePaths: paths,
      imageUrls: [for (final p in paths) client.storage.from(bucket).getPublicUrl(p)],
      likeCount: j['like_count'] as int,
      viewCount: j['view_count'] as int,
      createdAt: DateTime.parse(j['created_at'] as String),
      hidden: (j['hidden'] as bool?) ?? false,
    );
  }

  @override
  Future<List<CommunityPost>> feed({DateTime? before, int limit = 20}) => _guard(() async {
    var q = client.from('posts').select(_postSelect).eq('hidden', false);
    if (before != null) q = q.lt('created_at', before.toUtc().toIso8601String());
    final rows = await q.order('created_at', ascending: false).limit(limit);
    return rows.map(_post).toList();
  });

  @override
  Future<List<CommunityPost>> postsBy(String userId) => _guard(() async {
    final rows = await client.from('posts').select(_postSelect).eq('owner', userId).order('created_at', ascending: false).limit(200);
    return rows.map(_post).toList();
  });

  @override
  Future<Set<String>> likedPostIds(Iterable<String> postIds) => _guard(() async {
    final ids = postIds.toList();
    final me = currentUserId;
    if (ids.isEmpty || me == null) return <String>{};
    final rows = await client.from('likes').select('post_id').eq('user_id', me).inFilter('post_id', ids);
    return {for (final r in rows) r['post_id'] as String};
  });

  @override
  Future<CommunityPost> share({
    required String kind,
    required String localRef,
    required String title,
    String? caption,
    String? category,
    String? colorName,
    required List<UploadImage> images,
  }) => _guard(() async {
    final me = _requireUser();
    if (images.isEmpty) throw CommunityException('Nothing to upload.');
    final paths = <String>[];
    try {
      for (final img in images.take(4)) {
        final path = '$me/${_uuid.v4()}.jpg';
        await client.storage.from(bucket).uploadBinary(path, img.bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false));
        paths.add(path);
      }
      final row = await client
          .from('posts')
          .insert({
            'owner': me,
            'kind': kind,
            'local_ref': localRef,
            'title': title.trim(),
            'caption': (caption == null || caption.trim().isEmpty) ? null : caption.trim(),
            'category': category,
            'color_name': colorName,
            'image_paths': paths,
          })
          .select(_postSelect)
          .single();
      return _post(row);
    } catch (_) {
      // Don't leave orphaned uploads behind if the insert fails (e.g. already shared).
      if (paths.isNotEmpty) await client.storage.from(bucket).remove(paths);
      rethrow;
    }
  });

  @override
  Future<void> deletePost(CommunityPost post) => _guard(() async {
    await client.from('posts').delete().eq('id', post.id);
    if (post.imagePaths.isNotEmpty) await client.storage.from(bucket).remove(post.imagePaths);
  });

  @override
  Future<void> like(String postId) => _guard(() => client.from('likes').upsert({'post_id': postId, 'user_id': _requireUser()}, ignoreDuplicates: true));

  @override
  Future<void> unlike(String postId) => _guard(() => client.from('likes').delete().eq('post_id', postId).eq('user_id', _requireUser()));

  @override
  Future<void> recordView(String postId) async {
    try {
      await client.rpc('record_view', params: {'p_post': postId});
    } catch (_) {
      // Analytics must never break browsing.
    }
  }

  @override
  Future<CommunityStats> myStats() => _guard(() async {
    final rows = await client.rpc('my_stats') as List;
    if (rows.isEmpty) return const CommunityStats();
    final r = rows.first as Map<String, dynamic>;
    return CommunityStats(
      posts: r['posts'] as int,
      likes: r['likes'] as int,
      views: r['views'] as int,
      likes7d: r['likes_7d'] as int,
      views7d: r['views_7d'] as int,
    );
  });

  @override
  Future<void> report(String postId, ReportReason reason, {String? details}) => _guard(
    () => client
        .from('reports')
        .upsert(
          {'post_id': postId, 'reporter': _requireUser(), 'reason': reason.name, 'details': details},
          onConflict: 'post_id,reporter',
          ignoreDuplicates: true,
        ),
  );

  @override
  Future<void> block(String userId) => _guard(() => client.from('blocks').upsert({'blocker': _requireUser(), 'blocked': userId}, ignoreDuplicates: true));

  @override
  Future<void> unblock(String userId) => _guard(() => client.from('blocks').delete().eq('blocker', _requireUser()).eq('blocked', userId));

  @override
  Future<List<CommunityProfile>> blockedUsers() => _guard(() async {
    final rows = await client.from('blocks').select('profiles!blocks_blocked_fkey(*)').eq('blocker', _requireUser());
    return [for (final r in rows) CommunityProfile.fromJson(r['profiles'] as Map<String, dynamic>)];
  });

  @override
  Future<void> deleteAccount() => _guard(() async {
    final me = _requireUser();
    // 1) Photos (Storage API — SQL can't delete storage objects).
    while (true) {
      final files = await client.storage.from(bucket).list(path: me);
      if (files.isEmpty) break;
      await client.storage.from(bucket).remove([for (final f in files) '$me/${f.name}']);
      if (files.length < 100) break;
    }
    // 2) Rows + auth user (cascade).
    await client.rpc('delete_my_account');
    await client.auth.signOut();
  });
}
