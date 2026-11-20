import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../data/storage/image_store.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';

const _subcategories = <ClothingCategory, List<String>>{
  ClothingCategory.tops: ['T-shirt', 'Shirt', 'Blouse', 'Sweater', 'Hoodie', 'Tank top', 'Polo'],
  ClothingCategory.bottoms: ['Jeans', 'Trousers', 'Shorts', 'Skirt', 'Chinos', 'Joggers', 'Leggings'],
  ClothingCategory.dresses: ['Casual dress', 'Maxi dress', 'Midi dress', 'Evening dress', 'Jumpsuit'],
  ClothingCategory.outerwear: ['Jacket', 'Coat', 'Blazer', 'Cardigan', 'Raincoat', 'Puffer'],
  ClothingCategory.shoes: ['Sneakers', 'Boots', 'Loafers', 'Sandals', 'Heels', 'Formal shoes'],
  ClothingCategory.accessories: ['Watch', 'Belt', 'Scarf', 'Hat', 'Jewellery', 'Sunglasses', 'Tie'],
  ClothingCategory.bags: ['Backpack', 'Tote', 'Handbag', 'Crossbody', 'Clutch'],
};

/// Add (from one or more picked photos) or edit an item.
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.sourcePaths = const [], this.editId});
  final List<String> sourcePaths;
  final String? editId;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _notes = TextEditingController();

  int _queueIndex = 0;
  StoredImage? _image; // newly imported, not yet saved
  ClothingItem? _existing;
  bool _busy = true;
  bool _saving = false;
  String? _error;
  List<ClothingItem> _similar = [];
  bool _nameTouched = false;

  ClothingCategory _category = ClothingCategory.tops;
  String? _subcategory;
  String _colorHex = '#202022';
  String _colorName = 'Black';
  int _seasons = 0;
  int _occasions = 0;
  ClothingStyle? _style;
  bool _favorite = false;
  DateTime? _purchase;

  bool get _isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    _store = ref.read(imageStoreProvider); // `ref` must not be used inside dispose().
    _load();
  }

  late final ImageStore _store;

  Future<void> _load() async {
    if (_isEdit) {
      final it = await ref.read(wardrobeRepoProvider).getItem(widget.editId!);
      if (!mounted) return;
      if (it == null) {
        setState(() {
          _busy = false;
          _error = 'This item no longer exists.';
        });
        return;
      }
      _existing = it;
      _name.text = it.name;
      _brand.text = it.brand ?? '';
      _notes.text = it.notes ?? '';
      _nameTouched = true;
      setState(() {
        _category = it.categoryEnum;
        _subcategory = it.subcategory;
        _colorHex = it.colorHex;
        _colorName = it.colorName;
        _seasons = it.seasons;
        _occasions = it.occasions;
        _style = it.styleEnum;
        _favorite = it.isFavorite;
        _purchase = it.purchaseDate;
        _busy = false;
      });
    } else {
      await _importCurrent();
    }
  }

  Future<void> _importCurrent() async {
    setState(() {
      _busy = true;
      _error = null;
      _similar = [];
    });
    try {
      final stored = await ref.read(imageStoreProvider).importImage(widget.sourcePaths[_queueIndex]);
      final similar = await ref.read(wardrobeRepoProvider).findSimilar(stored.phash);
      if (!mounted) return;
      setState(() {
        _image = stored;
        _similar = similar;
        _colorHex = stored.colorHex;
        _colorName = stored.colorName;
        if (!_nameTouched) _name.text = _suggestName();
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Couldn\'t read this photo ($e).';
      });
    }
  }

  String _suggestName() => '$_colorName ${(_subcategory ?? _category.label).toLowerCase()}'.replaceAll(RegExp(r's$'), '');

  Future<void> _changePhoto() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f == null) return;
    setState(() => _busy = true);
    try {
      final stored = await ref.read(imageStoreProvider).importImage(f.path);
      if (_image != null) await ref.read(imageStoreProvider).deleteFiles([_image!.imagePath, _image!.thumbPath]);
      setState(() {
        _image = stored;
        _colorHex = stored.colorHex;
        _colorName = stored.colorName;
        _busy = false;
      });
    } catch (e) {
      setState(() => _busy = false);
      if (mounted) showSnack(context, 'Couldn\'t read that photo.');
    }
  }

  ItemDraft _draft() => ItemDraft(
    name: _name.text,
    category: _category,
    subcategory: _subcategory,
    colorHex: _colorHex,
    colorName: _colorName,
    brand: _brand.text,
    seasons: _seasons,
    occasions: _occasions,
    style: _style,
    isFavorite: _favorite,
    purchaseDate: _purchase,
    notes: _notes.text,
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(wardrobeRepoProvider);
    try {
      if (_isEdit) {
        await repo.updateItem(widget.editId!, _draft(), newImage: _image);
        _image = null;
        if (mounted) context.pop();
        return;
      }
      await repo.addItem(_draft(), _image!);
      _image = null;
      if (!mounted) return;
      if (_queueIndex < widget.sourcePaths.length - 1) {
        showSnack(context, 'Saved "${_name.text.trim()}"');
        setState(() {
          _queueIndex++;
          _nameTouched = false;
          _saving = false;
          _subcategory = null;
          _brand.clear();
          _notes.clear();
          _favorite = false;
          _purchase = null;
        });
        await _importCurrent();
      } else {
        showSnack(context, widget.sourcePaths.length > 1 ? 'Saved ${widget.sourcePaths.length} items' : 'Saved to your wardrobe');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showSnack(context, 'Couldn\'t save: $e');
      }
    }
  }

  Future<void> _skip() async {
    await _discardImage();
    if (_queueIndex < widget.sourcePaths.length - 1) {
      setState(() => _queueIndex++);
      await _importCurrent();
    } else if (mounted) {
      context.pop();
    }
  }

  Future<void> _discardImage() async {
    if (_image != null) {
      await ref.read(imageStoreProvider).deleteFiles([_image!.imagePath, _image!.thumbPath]);
      _image = null;
    }
  }

  @override
  void dispose() {
    // Never leave orphaned files if the user backs out mid-way.
    final img = _image;
    if (img != null) _store.deleteFiles([img.imagePath, img.thumbPath]);
    _name.dispose();
    _brand.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = widget.sourcePaths.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'Edit item'
              : total > 1
              ? 'New item ${_queueIndex + 1} of $total'
              : 'New item',
        ),
        actions: [if (!_isEdit && total > 1) TextButton(onPressed: _busy || _saving ? null : _skip, child: const Text('Skip'))],
      ),
      body: _error != null
          ? ErrorView(_error!, onRetry: _isEdit ? null : _importCurrent)
          : _busy
          ? const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Processing photo…')]),
            )
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  _preview(t),
                  if (_similar.isNotEmpty) _duplicateWarning(t),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 80,
                    onChanged: (_) => _nameTouched = true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Give this item a name' : null,
                  ),
                  const SizedBox(height: 8),
                  Text('Category', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in ClothingCategory.values)
                        ChoiceChip(
                          label: Text(c.label),
                          selected: _category == c,
                          onSelected: (_) => setState(() {
                            _category = c;
                            _subcategory = null;
                            if (!_nameTouched) _name.text = _suggestName();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Type', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final s in _subcategories[_category]!)
                        ChoiceChip(
                          label: Text(s),
                          selected: _subcategory == s,
                          onSelected: (sel) => setState(() {
                            _subcategory = sel ? s : null;
                            if (!_nameTouched) _name.text = _suggestName();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Colour', style: t.textTheme.titleSmall),
                      const SizedBox(width: 8),
                      ColorDot(_colorHex),
                      const SizedBox(width: 6),
                      Text(_colorName, style: t.textTheme.bodyMedium),
                      if (_image != null && !_isEdit) ...[
                        const SizedBox(width: 6),
                        Text('· auto-detected', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  ColorPickerChips(
                    selected: _colorName,
                    onSelected: (c) => setState(() {
                      _colorName = c.name;
                      _colorHex = c.hex;
                      if (!_nameTouched) _name.text = _suggestName();
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text('Seasons', style: t.textTheme.titleSmall),
                  Text('Leave empty for all-season', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  MaskChips<Season>(
                    values: Season.values,
                    label: (s) => s.label,
                    bit: (s) => s.bit,
                    mask: _seasons,
                    onChanged: (m) => setState(() => _seasons = m),
                  ),
                  const SizedBox(height: 16),
                  Text('Occasions', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  MaskChips<Occasion>(
                    values: Occasion.values,
                    label: (o) => o.label,
                    bit: (o) => o.bit,
                    mask: _occasions,
                    onChanged: (m) => setState(() => _occasions = m),
                  ),
                  const SizedBox(height: 16),
                  Text('Style', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final s in ClothingStyle.values)
                        ChoiceChip(label: Text(s.label), selected: _style == s, onSelected: (sel) => setState(() => _style = sel ? s : null)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _brand,
                    decoration: const InputDecoration(labelText: 'Brand (optional)'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(_purchase == null ? 'Purchase date (optional)' : 'Bought ${DateFormat.yMMMd().format(_purchase!)}'),
                    trailing: _purchase == null
                        ? null
                        : IconButton(tooltip: 'Clear date', icon: const Icon(Icons.close), onPressed: () => setState(() => _purchase = null)),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1990),
                        lastDate: DateTime.now(),
                        initialDate: _purchase ?? DateTime.now(),
                      );
                      if (d != null) setState(() => _purchase = d);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.favorite_border),
                    title: const Text('Favourite'),
                    value: _favorite,
                    onChanged: (v) => setState(() => _favorite = v),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notes,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _busy || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Text(_isEdit ? 'Save changes' : (_queueIndex < total - 1 ? 'Save & next' : 'Save item')),
                ),
              ),
            ),
    );
  }

  Widget _preview(ThemeData t) {
    final store = ref.read(imageStoreProvider);
    Widget img;
    if (_image != null) {
      img = Image.file(File(store.resolve(_image!.imagePath)), fit: BoxFit.cover, cacheWidth: 900);
    } else if (_existing != null) {
      img = ItemImage(_existing!, full: true);
    } else {
      img = const SizedBox();
    }
    return Center(
      child: ConstrainedBox(
        // Keep the preview from filling the whole screen in landscape.
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(20), child: img),
              if (_isEdit)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FilledButton.tonalIcon(onPressed: _changePhoto, icon: const Icon(Icons.photo_outlined), label: const Text('Change photo')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _duplicateWarning(ThemeData t) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: t.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(14)),
    child: Row(
      children: [
        SizedBox(width: 44, height: 44, child: ItemImage(_similar.first, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Looks similar to "${_similar.first.name}" already in your wardrobe. You can still save it.',
            style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onTertiaryContainer),
          ),
        ),
      ],
    ),
  );
}
