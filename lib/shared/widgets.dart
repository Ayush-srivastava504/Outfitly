import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../data/db/app_database.dart';
import '../domain/services/color_analyzer.dart';

Color hexColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

/// Thumbnail from local storage with a graceful placeholder.
class ItemImage extends ConsumerWidget {
  const ItemImage(this.item, {super.key, this.full = false, this.fit = BoxFit.cover, this.borderRadius});
  final ClothingItem item;
  final bool full;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(imageStoreProvider);
    final path = store.resolve(full ? item.imagePath : item.thumbPath);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    Widget img = Image.file(
      File(path),
      fit: fit,
      cacheWidth: full ? null : (300 * dpr).round().clamp(200, 900),
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Container(
        color: hexColor(item.colorHex).withValues(alpha: 0.25),
        alignment: Alignment.center,
        child: Icon(Icons.checkroom_outlined, color: hexColor(item.colorHex), size: 36),
      ),
      semanticLabel: item.name,
    );
    if (borderRadius != null) img = ClipRRect(borderRadius: borderRadius!, child: img);
    return img;
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    // Scrollable + centred: never overflows in landscape, small screens or large text.
    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxHeight.isFinite && c.maxHeight < 360;
        final content = Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: tight ? 12 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!tight) ...[
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: t.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, size: 40, color: t.colorScheme.primary),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Icon(icon, size: 32, color: t.colorScheme.primary),
                const SizedBox(height: 8),
              ],
              Text(title, style: t.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  message,
                  style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              if (action != null) ...[SizedBox(height: tight ? 12 : 20), action!],
            ],
          ),
        );
        if (!c.maxHeight.isFinite) return Center(child: content);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight, minWidth: c.maxWidth),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView(this.error, {super.key, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.error_outline,
    title: 'Something went wrong',
    message: '$error',
    action: onRetry == null ? null : OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
  );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

/// Renders AsyncValue with consistent loading/error states.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody(this.value, {super.key, required this.data});
  final AsyncValue<T> value;
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) => value.when(data: data, loading: () => const LoadingView(), error: (e, _) => ErrorView(e));
}

Future<bool> confirm(BuildContext context, {required String title, required String message, String confirmLabel = 'Delete', bool destructive = true}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error) : null,
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return r ?? false;
}

void showSnack(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: onAction == null ? 3 : 5),
        action: onAction == null ? null : SnackBarAction(label: actionLabel ?? 'Undo', onPressed: onAction),
      ),
    );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 12, 10),
    child: Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        ?trailing,
      ],
    ),
  );
}

class ColorDot extends StatelessWidget {
  const ColorDot(this.hex, {super.key, this.size = 14});
  final String hex;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: hexColor(hex),
      shape: BoxShape.circle,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
  );
}

/// Grid tile for a clothing item.
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, this.onTap, this.selected = false, this.heroPrefix = 'item'});
  final ClothingItem item;
  final VoidCallback? onTap;
  final bool selected;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? t.colorScheme.primary : t.colorScheme.outlineVariant.withValues(alpha: 0.5), width: selected ? 2.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: '$heroPrefix-${item.id}', child: ItemImage(item)),
                  if (item.isFavorite)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: _Badge(icon: Icons.favorite, color: Colors.redAccent),
                    ),
                  if (selected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(icon: Icons.check, color: t.colorScheme.primary),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  ColorDot(item.colorHex, size: 10),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.labelLarge),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
    child: Icon(icon, size: 14, color: color),
  );
}

/// Collage of an outfit's item thumbnails.
class OutfitCollage extends StatelessWidget {
  const OutfitCollage(this.items, {super.key});
  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    if (items.isEmpty) {
      return Container(
        color: bg,
        child: const Center(child: Icon(Icons.hide_image_outlined)),
      );
    }
    final shown = items.take(4).toList();
    return Container(
      color: bg,
      padding: const EdgeInsets.all(4),
      child: GridView.count(
        crossAxisCount: shown.length == 1 ? 1 : 2,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: EdgeInsets.zero,
        children: [for (final i in shown) ItemImage(i, borderRadius: BorderRadius.circular(10))],
      ),
    );
  }
}

/// Wraps multi-select chips for an enum bitmask.
class MaskChips<T> extends StatelessWidget {
  const MaskChips({super.key, required this.values, required this.label, required this.bit, required this.mask, required this.onChanged});
  final List<T> values;
  final String Function(T) label;
  final int Function(T) bit;
  final int mask;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (final v in values) FilterChip(label: Text(label(v)), selected: mask & bit(v) != 0, onSelected: (s) => onChanged(s ? mask | bit(v) : mask & ~bit(v))),
    ],
  );
}

class ColorPickerChips extends StatelessWidget {
  const ColorPickerChips({super.key, required this.selected, required this.onSelected, this.multi = false, this.selectedSet = const {}});
  final String? selected;
  final Set<String> selectedSet;
  final bool multi;
  final ValueChanged<NamedColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in kNamedColors)
          Semantics(
            button: true,
            selected: multi ? selectedSet.contains(c.name) : selected == c.name,
            label: c.name,
            child: Tooltip(
              message: c.name,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onSelected(c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, c.r, c.g, c.b),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (multi ? selectedSet.contains(c.name) : selected == c.name) ? t.colorScheme.primary : t.colorScheme.outlineVariant,
                      width: (multi ? selectedSet.contains(c.name) : selected == c.name) ? 3 : 1,
                    ),
                  ),
                  child: (multi ? selectedSet.contains(c.name) : selected == c.name)
                      ? Icon(Icons.check, size: 18, color: c.r + c.g + c.b > 450 ? Colors.black : Colors.white)
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
