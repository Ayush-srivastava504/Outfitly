import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/ads/ad_service.dart';
import '../../core/providers.dart';
import '../../data/community/community_api.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/widgets.dart';
import 'community_providers.dart';

// ───────────────────────────── Tab entry ─────────────────────────────

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(communityApiProvider);
    if (!api.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Community')),
        body: const EmptyState(
          icon: Icons.public_off_outlined,
          title: 'Community isn\'t connected',
          message: 'This build doesn\'t include the online community. Everything else works offline.',
        ),
      );
    }
    final user = ref.watch(authUserProvider);
    return user.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(body: ErrorView(e)),
      data: (uid) {
        if (uid == null) return const AuthScreen();
        final profile = ref.watch(myProfileProvider);
        return profile.when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Community')),
            body: ErrorView(e, onRetry: () => ref.invalidate(myProfileProvider)),
          ),
          data: (p) => p == null ? const ProfileEditScreen(isSetup: true) : const FeedScreen(),
        );
      },
    );
  }
}

// ───────────────────────────── Auth ─────────────────────────────

const _guidelines =
    'Share only photos of clothes you own. No nudity, harassment, hate or spam. '
    'Posts reported by several people are hidden automatically, and you can report or block anyone.';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = true;
  bool _agreed = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_signUp && !_agreed) {
      setState(() => _message = 'Please accept the community guidelines.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final api = ref.read(communityApiProvider);
    try {
      if (_signUp) {
        final r = await api.signUp(_email.text, _password.text);
        if (r == SignUpResult.confirmEmail && mounted) {
          setState(() {
            _signUp = false;
            _message = 'Check your inbox and tap the confirmation link, then sign in here.';
          });
        }
      } else {
        await api.signIn(_email.text, _password.text);
      }
    } catch (e) {
      if (mounted) setState(() => _message = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      setState(() => _message = 'Enter your email above first.');
      return;
    }
    try {
      await ref.read(communityApiProvider).sendPasswordReset(_email.text);
      if (mounted) setState(() => _message = 'If that email has an account, a reset link is on its way.');
    } catch (e) {
      if (mounted) setState(() => _message = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Icon(Icons.people_alt_outlined, size: 48, color: t.colorScheme.primary),
                const SizedBox(height: 12),
                Text(_signUp ? 'Join the Outfitly community' : 'Welcome back', textAlign: TextAlign.center, style: t.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Share pieces and outfits you choose, discover other wardrobes and collect likes. Your private wardrobe stays on your phone.',
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                ),
                if (_signUp) ...[
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    title: const Text('I agree to the community guidelines'),
                    subtitle: const Text(_guidelines),
                  ),
                ],
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_message!, style: TextStyle(color: t.colorScheme.tertiary)),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Text(_signUp ? 'Create account' : 'Sign in'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _signUp = !_signUp;
                    _message = null;
                  }),
                  child: Text(_signUp ? 'I already have an account' : 'Create a new account'),
                ),
                if (!_signUp) TextButton(onPressed: _forgot, child: const Text('Forgot password?')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Profile setup / edit ─────────────────────────────

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.isSetup = false});
  final bool isSetup;
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _bio = TextEditingController();
  bool _public = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = ref.read(myProfileProvider).value;
    if (p != null) {
      _username.text = p.username;
      _name.text = p.displayName;
      _bio.text = p.bio ?? '';
      _public = p.isPublic;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(communityApiProvider).saveProfile(username: _username.text, displayName: _name.text, bio: _bio.text, isPublic: _public);
      ref.invalidate(myProfileProvider);
      if (!widget.isSetup && mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetup ? 'Create your profile' : 'Edit profile'),
        actions: [if (widget.isSetup) TextButton(onPressed: () => ref.read(communityApiProvider).signOut(), child: const Text('Sign out'))],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username', prefixText: '@', helperText: '3–24 characters: a–z, 0–9 and _'),
              autocorrect: false,
              validator: (v) => RegExp(r'^[a-z0-9_]{3,24}$').hasMatch((v ?? '').trim().toLowerCase()) ? null : 'Use 3–24 letters, numbers or _',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            TextFormField(
              controller: _bio,
              maxLength: 160,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Bio (optional)'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Public profile'),
              subtitle: const Text('When off, only you can see your shared posts.'),
              value: _public,
              onChanged: (v) => setState(() => _public = v),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: TextStyle(color: t.colorScheme.error)),
              ),
            FilledButton(onPressed: _busy ? null : _save, child: Text(widget.isSetup ? 'Continue' : 'Save')),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Feed ─────────────────────────────

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});
  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) ref.read(feedProvider.notifier).loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final ads = ref.watch(adServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(tooltip: 'My posts & stats', icon: const Icon(Icons.insights_outlined), onPressed: () => context.push('/community/me')),
          IconButton(tooltip: 'Community account', icon: const Icon(Icons.manage_accounts_outlined), onPressed: () => context.push('/community/account')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: Builder(
          builder: (context) {
            if (feed.posts.isEmpty && feed.loading) return const LoadingView();
            if (feed.posts.isEmpty && feed.error != null) {
              return ListView(
                children: [SizedBox(height: 420, child: ErrorView(feed.error!, onRetry: () => ref.read(feedProvider.notifier).refresh()))],
              );
            }
            if (feed.posts.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(
                    height: 420,
                    child: EmptyState(
                      icon: Icons.dynamic_feed_outlined,
                      title: 'No posts yet',
                      message: 'Be the first! Open an item or outfit and tap "Share to community".',
                    ),
                  ),
                ],
              );
            }
            // A banner after every 8 posts (non-intrusive, never inside a post).
            final rows = <Widget>[];
            for (var i = 0; i < feed.posts.length; i++) {
              final post = feed.posts[i];
              rows.add(PostCard(post: post, liked: feed.liked.contains(post.id)));
              if ((i + 1) % 8 == 0) rows.add(Center(child: ads.banner(AdPlacement.community)));
            }
            if (feed.loading) {
              rows.add(const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
            }
            if (feed.done && feed.posts.length > 3) {
              rows.add(
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('You\'re all caught up ✨', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                ),
              );
            }
            return ListView(controller: _scroll, padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: rows);
          },
        ),
      ),
    );
  }
}

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, required this.liked, this.showOwner = true});
  final CommunityPost post;
  final bool liked;
  final bool showOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final me = ref.watch(communityApiProvider).currentUserId;
    final mine = post.ownerId == me;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showOwner)
            ListTile(
              leading: CircleAvatar(child: Text(initial(post.ownerName))),
              title: Text(post.ownerName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('@${post.ownerUsername} · ${DateFormat.MMMd().format(post.createdAt.toLocal())}', maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => context.push('/community/user/${post.ownerId}'),
              trailing: _PostMenu(post: post, mine: mine),
            ),
          GestureDetector(
            onTap: () => context.push('/community/post', extra: post),
            child: AspectRatio(
              aspectRatio: post.imageUrls.length > 1 ? 1 : 4 / 5,
              child: PostImages(urls: post.imageUrls),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: liked ? 'Unlike' : 'Like',
                  icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.redAccent : null),
                  onPressed: mine
                      ? null
                      : () async {
                          try {
                            await ref.read(feedProvider.notifier).toggleLike(post);
                          } catch (e) {
                            if (context.mounted) showSnack(context, '$e');
                          }
                        },
                ),
                Text('${post.likeCount}', style: t.textTheme.labelLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    [?post.category, ?post.colorName, if (post.kind == 'outfit') 'Outfit'].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                  ),
                ),
                if (!showOwner) _PostMenu(post: post, mine: mine),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: t.textTheme.titleMedium),
                if (post.caption != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(post.caption!, style: t.textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostImages extends StatelessWidget {
  const PostImages({super.key, required this.urls, this.fit = BoxFit.cover});
  final List<String> urls;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget one(String u) => CachedNetworkImage(
      imageUrl: u,
      fit: fit,
      placeholder: (_, _) => Container(color: bg),
      errorWidget: (_, _, _) => Container(color: bg, child: const Icon(Icons.broken_image_outlined)),
    );
    if (urls.isEmpty) return Container(color: bg, child: const Icon(Icons.checkroom_outlined));
    if (urls.length == 1) return one(urls.first);
    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      padding: EdgeInsets.zero,
      children: [for (final u in urls.take(4)) one(u)],
    );
  }
}

class _PostMenu extends ConsumerWidget {
  const _PostMenu({required this.post, required this.mine});
  final CommunityPost post;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<String>(
    tooltip: 'Post options',
    onSelected: (a) async {
      final api = ref.read(communityApiProvider);
      try {
        switch (a) {
          case 'delete':
            final sure = await confirm(context, title: 'Delete this post?', message: 'It will be removed from the community. Your item stays in your wardrobe.');
            if (!sure) return;
            await api.deletePost(post);
            ref.read(feedProvider.notifier).removeWhere((p) => p.id == post.id);
            ref.invalidate(userPostsProvider(post.ownerId));
            if (context.mounted) showSnack(context, 'Post deleted');
          case 'report':
            if (!context.mounted) return;
            final reason = await showModalBottomSheet<ReportReason>(
              context: context,
              showDragHandle: true,
              builder: (c) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(title: Text('Why are you reporting this post?')),
                    for (final r in ReportReason.values) ListTile(title: Text(r.label), onTap: () => Navigator.pop(c, r)),
                  ],
                ),
              ),
            );
            if (reason == null) return;
            await api.report(post.id, reason);
            ref.read(feedProvider.notifier).removeWhere((p) => p.id == post.id);
            if (context.mounted) showSnack(context, 'Thanks — we\'ve hidden this post for you and recorded your report.');
          case 'block':
            if (!await confirm(
              context,
              title: 'Block @${post.ownerUsername}?',
              message: 'You won\'t see each other\'s posts. You can unblock in Community account.',
              confirmLabel: 'Block',
            )) {
              return;
            }
            await api.block(post.ownerId);
            ref.read(feedProvider.notifier).removeWhere((p) => p.ownerId == post.ownerId);
            if (context.mounted) showSnack(context, 'Blocked @${post.ownerUsername}');
        }
      } catch (e) {
        if (context.mounted) showSnack(context, '$e');
      }
    },
    itemBuilder: (_) => mine
        ? const [PopupMenuItem(value: 'delete', child: Text('Delete post'))]
        : const [PopupMenuItem(value: 'report', child: Text('Report post')), PopupMenuItem(value: 'block', child: Text('Block user'))],
  );
}

/// Full-size post view; records a view for the owner's analytics.
class PostViewerScreen extends ConsumerStatefulWidget {
  const PostViewerScreen({super.key, required this.post});
  final CommunityPost post;
  @override
  ConsumerState<PostViewerScreen> createState() => _PostViewerScreenState();
}

class _PostViewerScreenState extends ConsumerState<PostViewerScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(communityApiProvider).recordView(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return Scaffold(
      appBar: AppBar(title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: PageView(
        children: [
          for (final u in p.imageUrls)
            InteractiveViewer(
              child: Center(
                child: PostImages(urls: [u], fit: BoxFit.contain),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Someone's public wardrobe ─────────────────────────────

class UserWardrobeScreen extends ConsumerWidget {
  const UserWardrobeScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final profile = ref.watch(userProfileProvider(userId));
    final posts = ref.watch(userPostsProvider(userId));
    final liked = ref.watch(feedProvider).liked;
    return Scaffold(
      appBar: AppBar(title: Text(profile.value == null ? 'Wardrobe' : '@${profile.value!.username}')),
      body: AsyncBody(
        posts,
        data: (List<CommunityPost> list) => ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            if (profile.value != null)
              ListTile(
                leading: CircleAvatar(radius: 26, child: Text(initial(profile.value!.displayName))),
                title: Text(profile.value!.displayName, style: t.textTheme.titleLarge),
                subtitle: Text(
                  [
                    if (profile.value!.bio != null) profile.value!.bio!,
                    '${list.length} shared · ${list.fold<int>(0, (a, p) => a + p.likeCount)} likes',
                  ].join('\n'),
                ),
              ),
            const SizedBox(height: 8),
            if (list.isEmpty)
              const SizedBox(
                height: 300,
                child: EmptyState(icon: Icons.checkroom_outlined, title: 'Nothing shared yet', message: 'Check back later.'),
              ),
            for (final p in list) PostCard(post: p, liked: liked.contains(p.id), showOwner: false),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── My posts & analytics ─────────────────────────────

class MyCommunityScreen extends ConsumerWidget {
  const MyCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final me = ref.watch(communityApiProvider).currentUserId;
    final stats = ref.watch(myStatsProvider);
    final posts = me == null ? const AsyncValue<List<CommunityPost>>.data([]) : ref.watch(userPostsProvider(me));
    return Scaffold(
      appBar: AppBar(title: const Text('My posts & stats')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myStatsProvider);
          if (me != null) ref.invalidate(userPostsProvider(me));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            stats.when(
              loading: () => const SizedBox(height: 110, child: LoadingView()),
              error: (e, _) => Text('$e'),
              data: (s) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Stat('${s.posts}', 'Posts'),
                  _Stat('${s.likes}', 'Likes'),
                  _Stat('${s.views}', 'Views'),
                  _Stat('+${s.likes7d}', 'Likes (7 days)'),
                  _Stat('+${s.views7d}', 'Views (7 days)'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Your shared posts', style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            posts.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
              error: (e, _) => Text('$e'),
              data: (list) => list.isEmpty
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Share an item or outfit from its detail page to see stats here.'))
                  : Column(
                      children: [
                        for (final p in list)
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: SizedBox(
                                width: 52,
                                height: 52,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: PostImages(urls: p.imageUrls.take(1).toList()),
                                ),
                              ),
                              title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('♥ ${p.likeCount}   👁 ${p.viewCount}${p.hidden ? '   · hidden after reports' : ''}'),
                              trailing: _PostMenu(post: p, mine: true),
                              onTap: () => context.push('/community/post', extra: p),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: t.textTheme.headlineSmall?.copyWith(color: t.colorScheme.primary)),
          Text(label, style: t.textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ───────────────────────────── Account ─────────────────────────────

final blockedUsersProvider = FutureProvider.autoDispose((ref) => ref.watch(communityApiProvider).blockedUsers());

class CommunityAccountScreen extends ConsumerWidget {
  const CommunityAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final profile = ref.watch(myProfileProvider).value;
    final blocked = ref.watch(blockedUsersProvider);
    final api = ref.read(communityApiProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Community account')),
      body: ListView(
        children: [
          if (profile != null)
            ListTile(
              leading: CircleAvatar(child: Text(initial(profile.displayName))),
              title: Text(profile.displayName),
              subtitle: Text('@${profile.username} · ${profile.isPublic ? 'Public' : 'Private'}'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => context.push('/community/profile'),
            ),
          const Divider(),
          ListTile(title: Text('Blocked users', style: t.textTheme.titleSmall)),
          ...blocked.when(
            loading: () => [const LinearProgressIndicator()],
            error: (e, _) => [ListTile(title: Text('$e'))],
            data: (list) => list.isEmpty
                ? [const ListTile(dense: true, title: Text('Nobody blocked'))]
                : [
                    for (final b in list)
                      ListTile(
                        title: Text('@${b.username}'),
                        trailing: TextButton(
                          onPressed: () async {
                            await api.unblock(b.id);
                            ref.invalidate(blockedUsersProvider);
                            ref.read(feedProvider.notifier).refresh();
                          },
                          child: const Text('Unblock'),
                        ),
                      ),
                  ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await api.signOut();
              if (context.mounted) context.pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: t.colorScheme.error),
            title: Text('Delete community account', style: TextStyle(color: t.colorScheme.error)),
            subtitle: const Text('Removes your profile, posts, photos and likes from our servers. Your private wardrobe on this phone is not affected.'),
            onTap: () async {
              if (!await confirm(
                context,
                title: 'Delete your community account?',
                message: 'All your shared posts, photos and likes will be permanently deleted.',
                confirmLabel: 'Delete account',
              )) {
                return;
              }
              if (!context.mounted || !await confirm(context, title: 'Are you sure?', message: 'This cannot be undone.', confirmLabel: 'Yes, delete')) return;
              try {
                await api.deleteAccount();
                if (context.mounted) {
                  context.pop();
                  showSnack(context, 'Your community account was deleted.');
                }
              } catch (e) {
                if (context.mounted) showSnack(context, '$e');
              }
            },
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Share entry points ─────────────────────────────

/// Shows the "share publicly" sheet for an item or outfit. Handles not-configured / signed-out states.
Future<void> showShareToCommunity(BuildContext context, WidgetRef ref, {ClothingItem? item, OutfitWithItems? outfit}) async {
  final api = ref.read(communityApiProvider);
  if (!api.isConfigured) {
    showSnack(context, 'Community isn\'t available in this build.');
    return;
  }
  if (api.currentUserId == null || await ref.read(myProfileProvider.future) == null) {
    if (!context.mounted) return;
    showSnack(context, 'Join the community first.', actionLabel: 'Open', onAction: () => context.go('/community'));
    return;
  }
  if (!context.mounted) return;
  final caption = TextEditingController();
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text('Share to community', style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'The photo${outfit != null ? 's' : ''} and name will be visible to everyone in the Outfitly community. You can delete the post at any time.',
              style: Theme.of(c).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caption,
              maxLength: 300,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Caption (optional)'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: () => Navigator.pop(c, true), icon: const Icon(Icons.public), label: const Text('Share publicly')),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  showSnack(context, 'Uploading…');
  try {
    if (item != null) {
      await shareItem(ref, item, caption: caption.text);
    } else if (outfit != null) {
      await shareOutfit(ref, outfit, caption: caption.text);
    }
    ref.read(feedProvider.notifier).refresh();
    if (context.mounted) showSnack(context, 'Shared! 🎉', actionLabel: 'View', onAction: () => context.go('/community'));
  } catch (e) {
    if (context.mounted) showSnack(context, '$e'.contains('already exists') ? 'You\'ve already shared this.' : '$e');
  }
}

/// First letter for avatar circles; safe for empty names.
String initial(String name) => name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
