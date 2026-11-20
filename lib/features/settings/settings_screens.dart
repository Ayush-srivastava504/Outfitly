import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/prefs/app_prefs.dart';
import '../../core/providers.dart';
import '../../data/backup/backup_service.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';

const _supportEmail = String.fromEnvironment('SUPPORT_EMAIL');
const _privacyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');

final packageInfoProvider = FutureProvider((ref) => PackageInfo.fromPlatform());

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final items = ref.watch(allItemsProvider).value?.length ?? 0;
    final outfits = ref.watch(outfitsProvider).value?.length ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Card(
            color: t.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.checkroom, color: t.colorScheme.onPrimary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My wardrobe', style: t.textTheme.titleLarge?.copyWith(color: t.colorScheme.onPrimary)),
                        Text(
                          '$items items · $outfits outfits',
                          style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onPrimary.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _tile(context, Icons.insights_outlined, 'Wardrobe insights', 'Usage, colours and combinations', '/profile/analytics'),
          _tile(context, Icons.calendar_month_outlined, 'Outfit calendar', 'Planned and worn outfits', '/calendar'),
          _tile(context, Icons.tune, 'Style preferences', 'Colours and styles for suggestions', '/profile/preferences'),
          _tile(context, Icons.settings_outlined, 'Settings', 'Theme, data and privacy', '/profile/settings'),
          _tile(context, Icons.backup_outlined, 'Backup & restore', 'Export or import your wardrobe', '/profile/backup'),
          _tile(context, Icons.workspace_premium_outlined, 'Premium', 'Coming soon', '/profile/premium'),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String sub, String route) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(sub), trailing: const Icon(Icons.chevron_right), onTap: () => context.push(route)),
  );
}

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final p = ref.watch(appPrefsProvider);
    final n = ref.read(appPrefsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Style preferences')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Styles you like', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in ClothingStyle.values)
                FilterChip(
                  label: Text(s.label),
                  selected: p.preferredStyles.contains(s),
                  onSelected: (v) => n.update((x) => x.copyWith(preferredStyles: v ? {...x.preferredStyles, s} : ({...x.preferredStyles}..remove(s)))),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Favourite colours', style: t.textTheme.titleMedium),
          const SizedBox(height: 10),
          ColorPickerChips(
            selected: null,
            multi: true,
            selectedSet: p.preferredColors,
            onSelected: (c) => n.update(
              (x) =>
                  x.copyWith(preferredColors: x.preferredColors.contains(c.name) ? ({...x.preferredColors}..remove(c.name)) : {...x.preferredColors, c.name}),
            ),
          ),
          const SizedBox(height: 24),
          Text('Categories shown first', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final c in ClothingCategory.values)
                FilterChip(
                  label: Text(c.label),
                  selected: p.preferredCategories.contains(c),
                  onSelected: (v) =>
                      n.update((x) => x.copyWith(preferredCategories: v ? {...x.preferredCategories, c} : ({...x.preferredCategories}..remove(c)))),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Measurement units', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<Units>(
            segments: const [
              ButtonSegment(value: Units.metric, label: Text('Metric')),
              ButtonSegment(value: Units.imperial, label: Text('Imperial')),
            ],
            selected: {p.units},
            onSelectionChanged: (s) => n.update((x) => x.copyWith(units: s.first)),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final prefs = ref.watch(appPrefsProvider);
    final info = ref.watch(packageInfoProvider).value;
    final ads = ref.watch(adServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _header(t, 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('System')),
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) => ref.read(appPrefsProvider.notifier).update((p) => p.copyWith(themeMode: s.first)),
            ),
          ),
          _header(t, 'Data'),
          ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('Backup & restore'), onTap: () => context.push('/profile/backup')),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: t.colorScheme.error),
            title: Text('Clear all data', style: TextStyle(color: t.colorScheme.error)),
            subtitle: const Text('Deletes every item, outfit and photo'),
            onTap: () async {
              final ok = await confirm(
                context,
                title: 'Delete everything?',
                message: 'This permanently removes your whole wardrobe from this device. Export a backup first if you might want it back.',
                confirmLabel: 'Delete everything',
              );
              if (!ok || !context.mounted) return;
              final again = await confirm(context, title: 'Are you sure?', message: 'This cannot be undone.', confirmLabel: 'Yes, delete');
              if (!again) return;
              await ref.read(backupServiceProvider).wipe();
              if (context.mounted) showSnack(context, 'All data cleared');
            },
          ),
          _header(t, 'Privacy'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            subtitle: const Text('Your photos never leave this device'),
            onTap: () => context.push('/profile/privacy'),
          ),
          FutureBuilder<bool>(
            future: ads.privacyOptionsRequired,
            builder: (_, s) => s.data == true
                ? ListTile(leading: const Icon(Icons.ads_click_outlined), title: const Text('Ad privacy choices'), onTap: ads.showPrivacyOptions)
                : const SizedBox.shrink(),
          ),
          _header(t, 'About'),
          if (_supportEmail.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Send feedback'),
              onTap: () => launchUrl(Uri(scheme: 'mailto', path: _supportEmail, queryParameters: {'subject': 'Outfitly feedback (v${info?.version ?? ''})'})),
            ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licences'),
            onTap: () => showLicensePage(context: context, applicationName: 'Outfitly', applicationVersion: info?.version),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(info == null ? '…' : '${info.version} (${info.buildNumber})'),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData t, String s) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(s.toUpperCase(), style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.primary, letterSpacing: 1)),
  );
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    const sections = [
      (
        'Your wardrobe stays on your phone',
        'Photos, items, outfits and your calendar are stored only in Outfitly\'s private storage on this device. You don\'t need an account to use the wardrobe.',
      ),
      (
        'Processing happens on-device',
        'Colour detection, duplicate detection, background removal for try-on and outfit suggestions run locally. No photo is uploaded for analysis.',
      ),
      (
        'Community (optional)',
        'Only if you join the community: we store your email and password (handled by our hosting provider, Supabase), your profile, and the photos, titles and captions you choose to share, plus likes, views, reports and blocks. Shared posts are visible to other members. Delete any post at any time, or delete your whole community account in Community → account; this removes your profile, posts, photos and likes from our servers.',
      ),
      (
        'Sharing and backups are your choice',
        'Apart from community posts you publish, data leaves the app only when you share an outfit image or export a backup file, and only to the destination you pick.',
      ),
      (
        'Advertising',
        'The free version shows ads from Google AdMob. Google may use a device advertising ID to serve and measure ads, subject to the consent choices you make. You can review those choices in Settings → Ad privacy choices (where required in your region).',
      ),
      ('Deleting data', 'Uninstalling the app, or Settings → Clear all data, permanently deletes everything stored by Outfitly on this device.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final (h, b) in sections) ...[
            Text(h, style: t.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(b, style: t.textTheme.bodyMedium),
            const SizedBox(height: 18),
          ],
          if (_privacyUrl.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse(_privacyUrl), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Full privacy policy'),
            ),
        ],
      ),
    );
  }
}

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});
  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _status;

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _status = 'Preparing backup…';
    });
    try {
      final bytes = await ref.read(backupServiceProvider).export();
      final name = 'outfitly-backup-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.zip';
      final uri = await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: 'application/zip', dialogTitle: 'Save Outfitly backup');
      setState(() => _status = uri == null ? 'Export cancelled.' : 'Backup saved (${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB).');
    } catch (e) {
      setState(() => _status = 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final files = await FilePicker.pickFiles(type: FileType.any, dialogTitle: 'Choose an Outfitly backup (.zip)');
    if (files.isEmpty || !mounted) return;
    final ok = await confirm(
      context,
      title: 'Restore this backup?',
      message: 'Your current wardrobe on this device will be replaced by the backup.',
      confirmLabel: 'Restore',
      destructive: false,
    );
    if (!ok) return;
    setState(() {
      _busy = true;
      _status = 'Restoring…';
    });
    try {
      final bytes = await files.first.readAsBytes();
      final r = await ref.read(backupServiceProvider).restore(bytes);
      setState(() => _status = 'Restored ${r.items} items, ${r.outfits} outfits and ${r.calendarEntries} calendar entries.');
    } on BackupException catch (e) {
      setState(() => _status = e.message);
    } catch (e) {
      setState(() => _status = 'Restore failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Outfitly keeps everything on this phone. A backup is a single .zip with your items, photos, outfits and calendar — save it to Drive, your computer or anywhere you like.',
            style: t.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: _busy ? null : _export, icon: const Icon(Icons.upload_file), label: const Text('Export backup')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _import,
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
            icon: const Icon(Icons.download),
            label: const Text('Restore from backup'),
          ),
          const SizedBox(height: 24),
          if (_busy) const LinearProgressIndicator(),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_status!, style: t.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
