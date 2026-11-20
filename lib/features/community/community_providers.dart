import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/community/community_api.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';

/// Overridden in main() with the Supabase implementation when configured.
final communityApiProvider = Provider<CommunityApi>((ref) => const DisabledCommunityApi());

final authUserProvider = StreamProvider<String?>((ref) async* {
  final api = ref.watch(communityApiProvider);
  yield api.currentUserId;
  yield* api.userChanges;
});

final myProfileProvider = FutureProvider<CommunityProfile?>((ref) async {
  final uid = await ref.watch(authUserProvider.future);
  if (uid == null) return null;
  return ref.watch(communityApiProvider).myProfile();
});

final myStatsProvider = FutureProvider.autoDispose<CommunityStats>((ref) => ref.watch(communityApiProvider).myStats());
final userPostsProvider = FutureProvider.autoDispose.family<List<CommunityPost>, String>((ref, id) => ref.watch(communityApiProvider).postsBy(id));
final userProfileProvider = FutureProvider.autoDispose.family<CommunityProfile?, String>((ref, id) => ref.watch(communityApiProvider).profile(id));

class FeedState {
  const FeedState({this.posts = const [], this.liked = const {}, this.loading = false, this.done = false, this.error});
  final List<CommunityPost> posts;
  final Set<String> liked;
  final bool loading, done;
  final String? error;

  FeedState copyWith({List<CommunityPost>? posts, Set<String>? liked, bool? loading, bool? done, String? Function()? error}) => FeedState(
    posts: posts ?? this.posts,
    liked: liked ?? this.liked,
    loading: loading ?? this.loading,
    done: done ?? this.done,
    error: error != null ? error() : this.error,
  );
}

/// Paged, keyset-based feed with optimistic likes.
class FeedNotifier extends Notifier<FeedState> {
  static const pageSize = 20;

  @override
  FeedState build() {
    ref.watch(authUserProvider);
    Future.microtask(refresh);
    return const FeedState(loading: true);
  }

  CommunityApi get _api => ref.read(communityApiProvider);

  Future<void> refresh() async {
    state = const FeedState(loading: true);
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (state.loading || state.done) return;
    state = state.copyWith(loading: true);
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    try {
      final before = reset || state.posts.isEmpty ? null : state.posts.last.createdAt;
      final page = await _api.feed(before: before, limit: pageSize);
      final liked = await _api.likedPostIds(page.map((p) => p.id));
      state = state.copyWith(
        posts: reset ? page : [...state.posts, ...page],
        liked: reset ? liked : {...state.liked, ...liked},
        loading: false,
        done: page.length < pageSize,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: () => '$e');
    }
  }

  Future<void> toggleLike(CommunityPost post) async {
    final wasLiked = state.liked.contains(post.id);
    _applyLike(post.id, !wasLiked);
    try {
      wasLiked ? await _api.unlike(post.id) : await _api.like(post.id);
    } catch (e) {
      _applyLike(post.id, wasLiked); // roll back
      rethrow;
    }
  }

  void _applyLike(String id, bool liked) {
    state = state.copyWith(
      liked: liked ? {...state.liked, id} : ({...state.liked}..remove(id)),
      posts: [
        for (final p in state.posts)
          if (p.id == id) p.copyWith(likeCount: (p.likeCount + (liked ? 1 : -1)).clamp(0, 1 << 30)) else p,
      ],
    );
  }

  void removeWhere(bool Function(CommunityPost) test) => state = state.copyWith(posts: state.posts.where((p) => !test(p)).toList());
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);

/// Prepares a photo for upload: ≤1080px JPEG (keeps uploads small and within the 2 MB bucket limit).
Future<UploadImage?> uploadImageFor(String absolutePath) async {
  final bytes = await FlutterImageCompress.compressWithFile(absolutePath, minWidth: 1080, minHeight: 1080, quality: 80);
  return bytes == null ? null : UploadImage(bytes);
}

/// Share one wardrobe item publicly.
Future<CommunityPost> shareItem(WidgetRef ref, ClothingItem item, {String? caption}) async {
  final img = await uploadImageFor(ref.read(imageStoreProvider).resolve(item.imagePath));
  if (img == null) throw CommunityException('Couldn\'t read this photo.');
  return ref
      .read(communityApiProvider)
      .share(kind: 'item', localRef: item.id, title: item.name, caption: caption, category: item.categoryEnum.label, colorName: item.colorName, images: [img]);
}

/// Share an outfit (up to 4 photos).
Future<CommunityPost> shareOutfit(WidgetRef ref, OutfitWithItems o, {String? caption}) async {
  final store = ref.read(imageStoreProvider);
  final images = <UploadImage>[];
  for (final i in o.items.take(4)) {
    final img = await uploadImageFor(store.resolve(i.imagePath));
    if (img != null) images.add(img);
  }
  if (images.isEmpty) throw CommunityException('This outfit has no photos to share.');
  return ref
      .read(communityApiProvider)
      .share(kind: 'outfit', localRef: o.outfit.id, title: o.outfit.name, caption: caption ?? o.outfit.description, images: images);
}
