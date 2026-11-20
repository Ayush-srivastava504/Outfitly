import 'dart:typed_data';

/// Compile-time config. URL is public; the anon/publishable key is public too (RLS protects data).
/// Build with: --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=...
abstract final class CommunityConfig {
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://hvebjndsvsoabnnhufnt.supabase.co');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get enabled => url.isNotEmpty && anonKey.isNotEmpty;
}

class CommunityProfile {
  const CommunityProfile({required this.id, required this.username, required this.displayName, this.bio, this.isPublic = true});
  final String id;
  final String username;
  final String displayName;
  final String? bio;
  final bool isPublic;

  factory CommunityProfile.fromJson(Map<String, dynamic> j) => CommunityProfile(
    id: j['id'] as String,
    username: j['username'] as String,
    displayName: j['display_name'] as String,
    bio: j['bio'] as String?,
    isPublic: (j['is_public'] as bool?) ?? true,
  );
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerName,
    required this.kind,
    required this.localRef,
    required this.title,
    this.caption,
    this.category,
    this.colorName,
    required this.imageUrls,
    required this.imagePaths,
    required this.likeCount,
    required this.viewCount,
    required this.createdAt,
    this.hidden = false,
  });

  final String id, ownerId, ownerUsername, ownerName, kind, localRef, title;
  final String? caption, category, colorName;
  final List<String> imageUrls; // public URLs for display
  final List<String> imagePaths; // storage paths, for deletion
  final int likeCount, viewCount;
  final DateTime createdAt;
  final bool hidden;

  CommunityPost copyWith({int? likeCount}) => CommunityPost(
    id: id,
    ownerId: ownerId,
    ownerUsername: ownerUsername,
    ownerName: ownerName,
    kind: kind,
    localRef: localRef,
    title: title,
    caption: caption,
    category: category,
    colorName: colorName,
    imageUrls: imageUrls,
    imagePaths: imagePaths,
    likeCount: likeCount ?? this.likeCount,
    viewCount: viewCount,
    createdAt: createdAt,
    hidden: hidden,
  );
}

class CommunityStats {
  const CommunityStats({this.posts = 0, this.likes = 0, this.views = 0, this.likes7d = 0, this.views7d = 0});
  final int posts, likes, views, likes7d, views7d;
}

enum ReportReason {
  spam('Spam'),
  nudity('Nudity or sexual content'),
  harassment('Harassment or bullying'),
  hate('Hate speech'),
  other('Something else');

  const ReportReason(this.label);
  final String label;
}

/// Image to upload: JPEG bytes.
class UploadImage {
  const UploadImage(this.bytes);
  final Uint8List bytes;
}

class CommunityException implements Exception {
  CommunityException(this.message);
  final String message;
  @override
  String toString() => message;
}

enum SignUpResult { signedIn, confirmEmail }

/// Everything the app needs from the backend. Implemented by Supabase in production and by a fake in tests.
abstract class CommunityApi {
  bool get isConfigured;
  String? get currentUserId;
  Stream<String?> get userChanges;

  Future<SignUpResult> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();

  Future<CommunityProfile?> myProfile();
  Future<CommunityProfile?> profile(String userId);
  Future<void> saveProfile({required String username, required String displayName, String? bio, required bool isPublic});

  /// Newest first. [before] = createdAt of the last post already loaded (keyset pagination).
  Future<List<CommunityPost>> feed({DateTime? before, int limit = 20});
  Future<List<CommunityPost>> postsBy(String userId);
  Future<Set<String>> likedPostIds(Iterable<String> postIds);

  Future<CommunityPost> share({
    required String kind,
    required String localRef,
    required String title,
    String? caption,
    String? category,
    String? colorName,
    required List<UploadImage> images,
  });
  Future<void> deletePost(CommunityPost post);

  Future<void> like(String postId);
  Future<void> unlike(String postId);
  Future<void> recordView(String postId);
  Future<CommunityStats> myStats();

  Future<void> report(String postId, ReportReason reason, {String? details});
  Future<void> block(String userId);
  Future<void> unblock(String userId);
  Future<List<CommunityProfile>> blockedUsers();

  /// Deletes uploaded photos, all rows (cascade) and the auth user. Required by Google Play.
  Future<void> deleteAccount();
}

/// Used when SUPABASE_ANON_KEY isn't provided: every call explains that the feature isn't connected.
class DisabledCommunityApi implements CommunityApi {
  const DisabledCommunityApi();
  Never _no() => throw CommunityException('Community isn\'t connected in this build.');
  @override
  bool get isConfigured => false;
  @override
  String? get currentUserId => null;
  @override
  Stream<String?> get userChanges => Stream.value(null);
  @override
  Future<SignUpResult> signUp(String email, String password) async => _no();
  @override
  Future<void> signIn(String email, String password) async => _no();
  @override
  Future<void> sendPasswordReset(String email) async => _no();
  @override
  Future<void> signOut() async {}
  @override
  Future<CommunityProfile?> myProfile() async => null;
  @override
  Future<CommunityProfile?> profile(String userId) async => null;
  @override
  Future<void> saveProfile({required String username, required String displayName, String? bio, required bool isPublic}) async => _no();
  @override
  Future<List<CommunityPost>> feed({DateTime? before, int limit = 20}) async => const [];
  @override
  Future<List<CommunityPost>> postsBy(String userId) async => const [];
  @override
  Future<Set<String>> likedPostIds(Iterable<String> postIds) async => const {};
  @override
  Future<CommunityPost> share({
    required String kind,
    required String localRef,
    required String title,
    String? caption,
    String? category,
    String? colorName,
    required List<UploadImage> images,
  }) async => _no();
  @override
  Future<void> deletePost(CommunityPost post) async => _no();
  @override
  Future<void> like(String postId) async => _no();
  @override
  Future<void> unlike(String postId) async => _no();
  @override
  Future<void> recordView(String postId) async {}
  @override
  Future<CommunityStats> myStats() async => const CommunityStats();
  @override
  Future<void> report(String postId, ReportReason reason, {String? details}) async => _no();
  @override
  Future<void> block(String userId) async => _no();
  @override
  Future<void> unblock(String userId) async => _no();
  @override
  Future<List<CommunityProfile>> blockedUsers() async => const [];
  @override
  Future<void> deleteAccount() async => _no();
}
