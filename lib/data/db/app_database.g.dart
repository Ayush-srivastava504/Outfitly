// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClothingItemsTable extends ClothingItems with TableInfo<$ClothingItemsTable, ClothingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClothingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>('category', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoryMeta = const VerificationMeta('subcategory');
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>('color_hex', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorNameMeta = const VerificationMeta('colorName');
  @override
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
    'color_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>('brand', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seasonsMeta = const VerificationMeta('seasons');
  @override
  late final GeneratedColumn<int> seasons = GeneratedColumn<int>(
    'seasons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _occasionsMeta = const VerificationMeta('occasions');
  @override
  late final GeneratedColumn<int> occasions = GeneratedColumn<int>(
    'occasions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>('style', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>('notes', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta = const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta('thumbPath');
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phashMeta = const VerificationMeta('phash');
  @override
  late final GeneratedColumn<String> phash = GeneratedColumn<String>('phash', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cutoutPathMeta = const VerificationMeta('cutoutPath');
  @override
  late final GeneratedColumn<String> cutoutPath = GeneratedColumn<String>(
    'cutout_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wearCountMeta = const VerificationMeta('wearCount');
  @override
  late final GeneratedColumn<int> wearCount = GeneratedColumn<int>(
    'wear_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastWornMeta = const VerificationMeta('lastWorn');
  @override
  late final GeneratedColumn<DateTime> lastWorn = GeneratedColumn<DateTime>(
    'last_worn',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    subcategory,
    colorHex,
    colorName,
    brand,
    seasons,
    occasions,
    style,
    isFavorite,
    purchaseDate,
    notes,
    imagePath,
    thumbPath,
    phash,
    cutoutPath,
    wearCount,
    lastWorn,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clothing_items';
  @override
  VerificationContext validateIntegrity(Insertable<ClothingItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(_subcategoryMeta, subcategory.isAcceptableOrUnknown(data['subcategory']!, _subcategoryMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta, colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('color_name')) {
      context.handle(_colorNameMeta, colorName.isAcceptableOrUnknown(data['color_name']!, _colorNameMeta));
    } else if (isInserting) {
      context.missing(_colorNameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(_brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('seasons')) {
      context.handle(_seasonsMeta, seasons.isAcceptableOrUnknown(data['seasons']!, _seasonsMeta));
    }
    if (data.containsKey('occasions')) {
      context.handle(_occasionsMeta, occasions.isAcceptableOrUnknown(data['occasions']!, _occasionsMeta));
    }
    if (data.containsKey('style')) {
      context.handle(_styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(_isFavoriteMeta, isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(_purchaseDateMeta, purchaseDate.isAcceptableOrUnknown(data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta, imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('thumb_path')) {
      context.handle(_thumbPathMeta, thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta));
    } else if (isInserting) {
      context.missing(_thumbPathMeta);
    }
    if (data.containsKey('phash')) {
      context.handle(_phashMeta, phash.isAcceptableOrUnknown(data['phash']!, _phashMeta));
    }
    if (data.containsKey('cutout_path')) {
      context.handle(_cutoutPathMeta, cutoutPath.isAcceptableOrUnknown(data['cutout_path']!, _cutoutPathMeta));
    }
    if (data.containsKey('wear_count')) {
      context.handle(_wearCountMeta, wearCount.isAcceptableOrUnknown(data['wear_count']!, _wearCountMeta));
    }
    if (data.containsKey('last_worn')) {
      context.handle(_lastWornMeta, lastWorn.isAcceptableOrUnknown(data['last_worn']!, _lastWornMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClothingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClothingItem(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subcategory: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}subcategory']),
      colorHex: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      colorName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}color_name'])!,
      brand: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}brand']),
      seasons: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seasons'])!,
      occasions: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}occasions'])!,
      style: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}style']),
      isFavorite: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      purchaseDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}purchase_date']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      imagePath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      thumbPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}thumb_path'])!,
      phash: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}phash']),
      cutoutPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cutout_path']),
      wearCount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}wear_count'])!,
      lastWorn: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}last_worn']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ClothingItemsTable createAlias(String alias) {
    return $ClothingItemsTable(attachedDatabase, alias);
  }
}

class ClothingItem extends DataClass implements Insertable<ClothingItem> {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String colorHex;
  final String colorName;
  final String? brand;
  final int seasons;
  final int occasions;
  final String? style;
  final bool isFavorite;
  final DateTime? purchaseDate;
  final String? notes;

  /// Paths are relative to the app documents directory so backups are portable.
  final String imagePath;
  final String thumbPath;
  final String? phash;

  /// Background-removed PNG used by the try-on avatar (schema v2). Relative path.
  final String? cutoutPath;
  final int wearCount;
  final DateTime? lastWorn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.colorHex,
    required this.colorName,
    this.brand,
    required this.seasons,
    required this.occasions,
    this.style,
    required this.isFavorite,
    this.purchaseDate,
    this.notes,
    required this.imagePath,
    required this.thumbPath,
    this.phash,
    this.cutoutPath,
    required this.wearCount,
    this.lastWorn,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    map['color_hex'] = Variable<String>(colorHex);
    map['color_name'] = Variable<String>(colorName);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['seasons'] = Variable<int>(seasons);
    map['occasions'] = Variable<int>(occasions);
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(style);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['image_path'] = Variable<String>(imagePath);
    map['thumb_path'] = Variable<String>(thumbPath);
    if (!nullToAbsent || phash != null) {
      map['phash'] = Variable<String>(phash);
    }
    if (!nullToAbsent || cutoutPath != null) {
      map['cutout_path'] = Variable<String>(cutoutPath);
    }
    map['wear_count'] = Variable<int>(wearCount);
    if (!nullToAbsent || lastWorn != null) {
      map['last_worn'] = Variable<DateTime>(lastWorn);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ClothingItemsCompanion toCompanion(bool nullToAbsent) {
    return ClothingItemsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent ? const Value.absent() : Value(subcategory),
      colorHex: Value(colorHex),
      colorName: Value(colorName),
      brand: brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      seasons: Value(seasons),
      occasions: Value(occasions),
      style: style == null && nullToAbsent ? const Value.absent() : Value(style),
      isFavorite: Value(isFavorite),
      purchaseDate: purchaseDate == null && nullToAbsent ? const Value.absent() : Value(purchaseDate),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      imagePath: Value(imagePath),
      thumbPath: Value(thumbPath),
      phash: phash == null && nullToAbsent ? const Value.absent() : Value(phash),
      cutoutPath: cutoutPath == null && nullToAbsent ? const Value.absent() : Value(cutoutPath),
      wearCount: Value(wearCount),
      lastWorn: lastWorn == null && nullToAbsent ? const Value.absent() : Value(lastWorn),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClothingItem(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      colorName: serializer.fromJson<String>(json['colorName']),
      brand: serializer.fromJson<String?>(json['brand']),
      seasons: serializer.fromJson<int>(json['seasons']),
      occasions: serializer.fromJson<int>(json['occasions']),
      style: serializer.fromJson<String?>(json['style']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      thumbPath: serializer.fromJson<String>(json['thumbPath']),
      phash: serializer.fromJson<String?>(json['phash']),
      cutoutPath: serializer.fromJson<String?>(json['cutoutPath']),
      wearCount: serializer.fromJson<int>(json['wearCount']),
      lastWorn: serializer.fromJson<DateTime?>(json['lastWorn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'colorHex': serializer.toJson<String>(colorHex),
      'colorName': serializer.toJson<String>(colorName),
      'brand': serializer.toJson<String?>(brand),
      'seasons': serializer.toJson<int>(seasons),
      'occasions': serializer.toJson<int>(occasions),
      'style': serializer.toJson<String?>(style),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'notes': serializer.toJson<String?>(notes),
      'imagePath': serializer.toJson<String>(imagePath),
      'thumbPath': serializer.toJson<String>(thumbPath),
      'phash': serializer.toJson<String?>(phash),
      'cutoutPath': serializer.toJson<String?>(cutoutPath),
      'wearCount': serializer.toJson<int>(wearCount),
      'lastWorn': serializer.toJson<DateTime?>(lastWorn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    Value<String?> subcategory = const Value.absent(),
    String? colorHex,
    String? colorName,
    Value<String?> brand = const Value.absent(),
    int? seasons,
    int? occasions,
    Value<String?> style = const Value.absent(),
    bool? isFavorite,
    Value<DateTime?> purchaseDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? imagePath,
    String? thumbPath,
    Value<String?> phash = const Value.absent(),
    Value<String?> cutoutPath = const Value.absent(),
    int? wearCount,
    Value<DateTime?> lastWorn = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ClothingItem(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    colorHex: colorHex ?? this.colorHex,
    colorName: colorName ?? this.colorName,
    brand: brand.present ? brand.value : this.brand,
    seasons: seasons ?? this.seasons,
    occasions: occasions ?? this.occasions,
    style: style.present ? style.value : this.style,
    isFavorite: isFavorite ?? this.isFavorite,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    notes: notes.present ? notes.value : this.notes,
    imagePath: imagePath ?? this.imagePath,
    thumbPath: thumbPath ?? this.thumbPath,
    phash: phash.present ? phash.value : this.phash,
    cutoutPath: cutoutPath.present ? cutoutPath.value : this.cutoutPath,
    wearCount: wearCount ?? this.wearCount,
    lastWorn: lastWorn.present ? lastWorn.value : this.lastWorn,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ClothingItem copyWithCompanion(ClothingItemsCompanion data) {
    return ClothingItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present ? data.subcategory.value : this.subcategory,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      colorName: data.colorName.present ? data.colorName.value : this.colorName,
      brand: data.brand.present ? data.brand.value : this.brand,
      seasons: data.seasons.present ? data.seasons.value : this.seasons,
      occasions: data.occasions.present ? data.occasions.value : this.occasions,
      style: data.style.present ? data.style.value : this.style,
      isFavorite: data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      purchaseDate: data.purchaseDate.present ? data.purchaseDate.value : this.purchaseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      phash: data.phash.present ? data.phash.value : this.phash,
      cutoutPath: data.cutoutPath.present ? data.cutoutPath.value : this.cutoutPath,
      wearCount: data.wearCount.present ? data.wearCount.value : this.wearCount,
      lastWorn: data.lastWorn.present ? data.lastWorn.value : this.lastWorn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('colorHex: $colorHex, ')
          ..write('colorName: $colorName, ')
          ..write('brand: $brand, ')
          ..write('seasons: $seasons, ')
          ..write('occasions: $occasions, ')
          ..write('style: $style, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('phash: $phash, ')
          ..write('cutoutPath: $cutoutPath, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWorn: $lastWorn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    category,
    subcategory,
    colorHex,
    colorName,
    brand,
    seasons,
    occasions,
    style,
    isFavorite,
    purchaseDate,
    notes,
    imagePath,
    thumbPath,
    phash,
    cutoutPath,
    wearCount,
    lastWorn,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClothingItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.colorHex == this.colorHex &&
          other.colorName == this.colorName &&
          other.brand == this.brand &&
          other.seasons == this.seasons &&
          other.occasions == this.occasions &&
          other.style == this.style &&
          other.isFavorite == this.isFavorite &&
          other.purchaseDate == this.purchaseDate &&
          other.notes == this.notes &&
          other.imagePath == this.imagePath &&
          other.thumbPath == this.thumbPath &&
          other.phash == this.phash &&
          other.cutoutPath == this.cutoutPath &&
          other.wearCount == this.wearCount &&
          other.lastWorn == this.lastWorn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ClothingItemsCompanion extends UpdateCompanion<ClothingItem> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<String> colorHex;
  final Value<String> colorName;
  final Value<String?> brand;
  final Value<int> seasons;
  final Value<int> occasions;
  final Value<String?> style;
  final Value<bool> isFavorite;
  final Value<DateTime?> purchaseDate;
  final Value<String?> notes;
  final Value<String> imagePath;
  final Value<String> thumbPath;
  final Value<String?> phash;
  final Value<String?> cutoutPath;
  final Value<int> wearCount;
  final Value<DateTime?> lastWorn;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ClothingItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.colorName = const Value.absent(),
    this.brand = const Value.absent(),
    this.seasons = const Value.absent(),
    this.occasions = const Value.absent(),
    this.style = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.phash = const Value.absent(),
    this.cutoutPath = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWorn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClothingItemsCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.subcategory = const Value.absent(),
    required String colorHex,
    required String colorName,
    this.brand = const Value.absent(),
    this.seasons = const Value.absent(),
    this.occasions = const Value.absent(),
    this.style = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    required String imagePath,
    required String thumbPath,
    this.phash = const Value.absent(),
    this.cutoutPath = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWorn = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       colorHex = Value(colorHex),
       colorName = Value(colorName),
       imagePath = Value(imagePath),
       thumbPath = Value(thumbPath),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ClothingItem> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? colorHex,
    Expression<String>? colorName,
    Expression<String>? brand,
    Expression<int>? seasons,
    Expression<int>? occasions,
    Expression<String>? style,
    Expression<bool>? isFavorite,
    Expression<DateTime>? purchaseDate,
    Expression<String>? notes,
    Expression<String>? imagePath,
    Expression<String>? thumbPath,
    Expression<String>? phash,
    Expression<String>? cutoutPath,
    Expression<int>? wearCount,
    Expression<DateTime>? lastWorn,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (colorHex != null) 'color_hex': colorHex,
      if (colorName != null) 'color_name': colorName,
      if (brand != null) 'brand': brand,
      if (seasons != null) 'seasons': seasons,
      if (occasions != null) 'occasions': occasions,
      if (style != null) 'style': style,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (notes != null) 'notes': notes,
      if (imagePath != null) 'image_path': imagePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (phash != null) 'phash': phash,
      if (cutoutPath != null) 'cutout_path': cutoutPath,
      if (wearCount != null) 'wear_count': wearCount,
      if (lastWorn != null) 'last_worn': lastWorn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClothingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<String>? colorHex,
    Value<String>? colorName,
    Value<String?>? brand,
    Value<int>? seasons,
    Value<int>? occasions,
    Value<String?>? style,
    Value<bool>? isFavorite,
    Value<DateTime?>? purchaseDate,
    Value<String?>? notes,
    Value<String>? imagePath,
    Value<String>? thumbPath,
    Value<String?>? phash,
    Value<String?>? cutoutPath,
    Value<int>? wearCount,
    Value<DateTime?>? lastWorn,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ClothingItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      colorHex: colorHex ?? this.colorHex,
      colorName: colorName ?? this.colorName,
      brand: brand ?? this.brand,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      style: style ?? this.style,
      isFavorite: isFavorite ?? this.isFavorite,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      phash: phash ?? this.phash,
      cutoutPath: cutoutPath ?? this.cutoutPath,
      wearCount: wearCount ?? this.wearCount,
      lastWorn: lastWorn ?? this.lastWorn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (colorName.present) {
      map['color_name'] = Variable<String>(colorName.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (seasons.present) {
      map['seasons'] = Variable<int>(seasons.value);
    }
    if (occasions.present) {
      map['occasions'] = Variable<int>(occasions.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (phash.present) {
      map['phash'] = Variable<String>(phash.value);
    }
    if (cutoutPath.present) {
      map['cutout_path'] = Variable<String>(cutoutPath.value);
    }
    if (wearCount.present) {
      map['wear_count'] = Variable<int>(wearCount.value);
    }
    if (lastWorn.present) {
      map['last_worn'] = Variable<DateTime>(lastWorn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('colorHex: $colorHex, ')
          ..write('colorName: $colorName, ')
          ..write('brand: $brand, ')
          ..write('seasons: $seasons, ')
          ..write('occasions: $occasions, ')
          ..write('style: $style, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('phash: $phash, ')
          ..write('cutoutPath: $cutoutPath, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWorn: $lastWorn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitsTable extends Outfits with TableInfo<$OutfitsTable, Outfit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occasionsMeta = const VerificationMeta('occasions');
  @override
  late final GeneratedColumn<int> occasions = GeneratedColumn<int>(
    'occasions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seasonsMeta = const VerificationMeta('seasons');
  @override
  late final GeneratedColumn<int> seasons = GeneratedColumn<int>(
    'seasons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>('style', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, description, occasions, seasons, style, isFavorite, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfits';
  @override
  VerificationContext validateIntegrity(Insertable<Outfit> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('occasions')) {
      context.handle(_occasionsMeta, occasions.isAcceptableOrUnknown(data['occasions']!, _occasionsMeta));
    }
    if (data.containsKey('seasons')) {
      context.handle(_seasonsMeta, seasons.isAcceptableOrUnknown(data['seasons']!, _seasonsMeta));
    }
    if (data.containsKey('style')) {
      context.handle(_styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(_isFavoriteMeta, isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Outfit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Outfit(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description']),
      occasions: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}occasions'])!,
      seasons: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seasons'])!,
      style: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}style']),
      isFavorite: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $OutfitsTable createAlias(String alias) {
    return $OutfitsTable(attachedDatabase, alias);
  }
}

class Outfit extends DataClass implements Insertable<Outfit> {
  final String id;
  final String name;
  final String? description;
  final int occasions;
  final int seasons;
  final String? style;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Outfit({
    required this.id,
    required this.name,
    this.description,
    required this.occasions,
    required this.seasons,
    this.style,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['occasions'] = Variable<int>(occasions);
    map['seasons'] = Variable<int>(seasons);
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(style);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  OutfitsCompanion toCompanion(bool nullToAbsent) {
    return OutfitsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      occasions: Value(occasions),
      seasons: Value(seasons),
      style: style == null && nullToAbsent ? const Value.absent() : Value(style),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory Outfit.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Outfit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      occasions: serializer.fromJson<int>(json['occasions']),
      seasons: serializer.fromJson<int>(json['seasons']),
      style: serializer.fromJson<String?>(json['style']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'occasions': serializer.toJson<int>(occasions),
      'seasons': serializer.toJson<int>(seasons),
      'style': serializer.toJson<String?>(style),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Outfit copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? occasions,
    int? seasons,
    Value<String?> style = const Value.absent(),
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Outfit(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    occasions: occasions ?? this.occasions,
    seasons: seasons ?? this.seasons,
    style: style.present ? style.value : this.style,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Outfit copyWithCompanion(OutfitsCompanion data) {
    return Outfit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present ? data.description.value : this.description,
      occasions: data.occasions.present ? data.occasions.value : this.occasions,
      seasons: data.seasons.present ? data.seasons.value : this.seasons,
      style: data.style.present ? data.style.value : this.style,
      isFavorite: data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Outfit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('occasions: $occasions, ')
          ..write('seasons: $seasons, ')
          ..write('style: $style, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, occasions, seasons, style, isFavorite, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Outfit &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.occasions == this.occasions &&
          other.seasons == this.seasons &&
          other.style == this.style &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class OutfitsCompanion extends UpdateCompanion<Outfit> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> occasions;
  final Value<int> seasons;
  final Value<String?> style;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const OutfitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.occasions = const Value.absent(),
    this.seasons = const Value.absent(),
    this.style = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.occasions = const Value.absent(),
    this.seasons = const Value.absent(),
    this.style = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Outfit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? occasions,
    Expression<int>? seasons,
    Expression<String>? style,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (occasions != null) 'occasions': occasions,
      if (seasons != null) 'seasons': seasons,
      if (style != null) 'style': style,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? occasions,
    Value<int>? seasons,
    Value<String?>? style,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return OutfitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      occasions: occasions ?? this.occasions,
      seasons: seasons ?? this.seasons,
      style: style ?? this.style,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occasions.present) {
      map['occasions'] = Variable<int>(occasions.value);
    }
    if (seasons.present) {
      map['seasons'] = Variable<int>(seasons.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('occasions: $occasions, ')
          ..write('seasons: $seasons, ')
          ..write('style: $style, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitItemsTable extends OutfitItems with TableInfo<$OutfitItemsTable, OutfitItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outfitIdMeta = const VerificationMeta('outfitId');
  @override
  late final GeneratedColumn<String> outfitId = GeneratedColumn<String>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES outfits (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES clothing_items (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [outfitId, itemId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_items';
  @override
  VerificationContext validateIntegrity(Insertable<OutfitItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outfit_id')) {
      context.handle(_outfitIdMeta, outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta));
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outfitId, itemId};
  @override
  OutfitItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitItem(
      outfitId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}outfit_id'])!,
      itemId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $OutfitItemsTable createAlias(String alias) {
    return $OutfitItemsTable(attachedDatabase, alias);
  }
}

class OutfitItem extends DataClass implements Insertable<OutfitItem> {
  final String outfitId;
  final String itemId;
  final int position;
  const OutfitItem({required this.outfitId, required this.itemId, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outfit_id'] = Variable<String>(outfitId);
    map['item_id'] = Variable<String>(itemId);
    map['position'] = Variable<int>(position);
    return map;
  }

  OutfitItemsCompanion toCompanion(bool nullToAbsent) {
    return OutfitItemsCompanion(outfitId: Value(outfitId), itemId: Value(itemId), position: Value(position));
  }

  factory OutfitItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitItem(
      outfitId: serializer.fromJson<String>(json['outfitId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outfitId': serializer.toJson<String>(outfitId),
      'itemId': serializer.toJson<String>(itemId),
      'position': serializer.toJson<int>(position),
    };
  }

  OutfitItem copyWith({String? outfitId, String? itemId, int? position}) =>
      OutfitItem(outfitId: outfitId ?? this.outfitId, itemId: itemId ?? this.itemId, position: position ?? this.position);
  OutfitItem copyWithCompanion(OutfitItemsCompanion data) {
    return OutfitItem(
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItem(')
          ..write('outfitId: $outfitId, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(outfitId, itemId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is OutfitItem && other.outfitId == this.outfitId && other.itemId == this.itemId && other.position == this.position);
}

class OutfitItemsCompanion extends UpdateCompanion<OutfitItem> {
  final Value<String> outfitId;
  final Value<String> itemId;
  final Value<int> position;
  final Value<int> rowid;
  const OutfitItemsCompanion({
    this.outfitId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitItemsCompanion.insert({required String outfitId, required String itemId, this.position = const Value.absent(), this.rowid = const Value.absent()})
    : outfitId = Value(outfitId),
      itemId = Value(itemId);
  static Insertable<OutfitItem> custom({Expression<String>? outfitId, Expression<String>? itemId, Expression<int>? position, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (outfitId != null) 'outfit_id': outfitId,
      if (itemId != null) 'item_id': itemId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitItemsCompanion copyWith({Value<String>? outfitId, Value<String>? itemId, Value<int>? position, Value<int>? rowid}) {
    return OutfitItemsCompanion(
      outfitId: outfitId ?? this.outfitId,
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outfitId.present) {
      map['outfit_id'] = Variable<String>(outfitId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItemsCompanion(')
          ..write('outfitId: $outfitId, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEntriesTable extends CalendarEntries with TableInfo<$CalendarEntriesTable, CalendarEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _outfitIdMeta = const VerificationMeta('outfitId');
  @override
  late final GeneratedColumn<String> outfitId = GeneratedColumn<String>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES outfits (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _wornMeta = const VerificationMeta('worn');
  @override
  late final GeneratedColumn<bool> worn = GeneratedColumn<bool>(
    'worn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("worn" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, outfitId, worn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_entries';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('outfit_id')) {
      context.handle(_outfitIdMeta, outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta));
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('worn')) {
      context.handle(_wornMeta, worn.isAcceptableOrUnknown(data['worn']!, _wornMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, outfitId},
  ];
  @override
  CalendarEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      outfitId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}outfit_id'])!,
      worn: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}worn'])!,
    );
  }

  @override
  $CalendarEntriesTable createAlias(String alias) {
    return $CalendarEntriesTable(attachedDatabase, alias);
  }
}

class CalendarEntry extends DataClass implements Insertable<CalendarEntry> {
  final String id;

  /// Local date at midnight.
  final DateTime date;
  final String outfitId;
  final bool worn;
  const CalendarEntry({required this.id, required this.date, required this.outfitId, required this.worn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['outfit_id'] = Variable<String>(outfitId);
    map['worn'] = Variable<bool>(worn);
    return map;
  }

  CalendarEntriesCompanion toCompanion(bool nullToAbsent) {
    return CalendarEntriesCompanion(id: Value(id), date: Value(date), outfitId: Value(outfitId), worn: Value(worn));
  }

  factory CalendarEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      outfitId: serializer.fromJson<String>(json['outfitId']),
      worn: serializer.fromJson<bool>(json['worn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'outfitId': serializer.toJson<String>(outfitId),
      'worn': serializer.toJson<bool>(worn),
    };
  }

  CalendarEntry copyWith({String? id, DateTime? date, String? outfitId, bool? worn}) =>
      CalendarEntry(id: id ?? this.id, date: date ?? this.date, outfitId: outfitId ?? this.outfitId, worn: worn ?? this.worn);
  CalendarEntry copyWithCompanion(CalendarEntriesCompanion data) {
    return CalendarEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      worn: data.worn.present ? data.worn.value : this.worn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('outfitId: $outfitId, ')
          ..write('worn: $worn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, outfitId, worn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEntry && other.id == this.id && other.date == this.date && other.outfitId == this.outfitId && other.worn == this.worn);
}

class CalendarEntriesCompanion extends UpdateCompanion<CalendarEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> outfitId;
  final Value<bool> worn;
  final Value<int> rowid;
  const CalendarEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.outfitId = const Value.absent(),
    this.worn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEntriesCompanion.insert({
    required String id,
    required DateTime date,
    required String outfitId,
    this.worn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       outfitId = Value(outfitId);
  static Insertable<CalendarEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? outfitId,
    Expression<bool>? worn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (outfitId != null) 'outfit_id': outfitId,
      if (worn != null) 'worn': worn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEntriesCompanion copyWith({Value<String>? id, Value<DateTime>? date, Value<String>? outfitId, Value<bool>? worn, Value<int>? rowid}) {
    return CalendarEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      outfitId: outfitId ?? this.outfitId,
      worn: worn ?? this.worn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (outfitId.present) {
      map['outfit_id'] = Variable<String>(outfitId.value);
    }
    if (worn.present) {
      map['worn'] = Variable<bool>(worn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('outfitId: $outfitId, ')
          ..write('worn: $worn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WearLogsTable extends WearLogs with TableInfo<$WearLogsTable, WearLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WearLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES clothing_items (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _outfitIdMeta = const VerificationMeta('outfitId');
  @override
  late final GeneratedColumn<String> outfitId = GeneratedColumn<String>('outfit_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _calendarEntryIdMeta = const VerificationMeta('calendarEntryId');
  @override
  late final GeneratedColumn<String> calendarEntryId = GeneratedColumn<String>(
    'calendar_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, itemId, outfitId, calendarEntryId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wear_logs';
  @override
  VerificationContext validateIntegrity(Insertable<WearLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('outfit_id')) {
      context.handle(_outfitIdMeta, outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta));
    }
    if (data.containsKey('calendar_entry_id')) {
      context.handle(_calendarEntryIdMeta, calendarEntryId.isAcceptableOrUnknown(data['calendar_entry_id']!, _calendarEntryIdMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WearLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WearLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      outfitId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}outfit_id']),
      calendarEntryId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}calendar_entry_id']),
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $WearLogsTable createAlias(String alias) {
    return $WearLogsTable(attachedDatabase, alias);
  }
}

class WearLog extends DataClass implements Insertable<WearLog> {
  final int id;
  final String itemId;
  final String? outfitId;
  final String? calendarEntryId;
  final DateTime date;
  const WearLog({required this.id, required this.itemId, this.outfitId, this.calendarEntryId, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || outfitId != null) {
      map['outfit_id'] = Variable<String>(outfitId);
    }
    if (!nullToAbsent || calendarEntryId != null) {
      map['calendar_entry_id'] = Variable<String>(calendarEntryId);
    }
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  WearLogsCompanion toCompanion(bool nullToAbsent) {
    return WearLogsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      outfitId: outfitId == null && nullToAbsent ? const Value.absent() : Value(outfitId),
      calendarEntryId: calendarEntryId == null && nullToAbsent ? const Value.absent() : Value(calendarEntryId),
      date: Value(date),
    );
  }

  factory WearLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WearLog(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      outfitId: serializer.fromJson<String?>(json['outfitId']),
      calendarEntryId: serializer.fromJson<String?>(json['calendarEntryId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<String>(itemId),
      'outfitId': serializer.toJson<String?>(outfitId),
      'calendarEntryId': serializer.toJson<String?>(calendarEntryId),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  WearLog copyWith({
    int? id,
    String? itemId,
    Value<String?> outfitId = const Value.absent(),
    Value<String?> calendarEntryId = const Value.absent(),
    DateTime? date,
  }) => WearLog(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    outfitId: outfitId.present ? outfitId.value : this.outfitId,
    calendarEntryId: calendarEntryId.present ? calendarEntryId.value : this.calendarEntryId,
    date: date ?? this.date,
  );
  WearLog copyWithCompanion(WearLogsCompanion data) {
    return WearLog(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      calendarEntryId: data.calendarEntryId.present ? data.calendarEntryId.value : this.calendarEntryId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WearLog(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('outfitId: $outfitId, ')
          ..write('calendarEntryId: $calendarEntryId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, outfitId, calendarEntryId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WearLog &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.outfitId == this.outfitId &&
          other.calendarEntryId == this.calendarEntryId &&
          other.date == this.date);
}

class WearLogsCompanion extends UpdateCompanion<WearLog> {
  final Value<int> id;
  final Value<String> itemId;
  final Value<String?> outfitId;
  final Value<String?> calendarEntryId;
  final Value<DateTime> date;
  const WearLogsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.outfitId = const Value.absent(),
    this.calendarEntryId = const Value.absent(),
    this.date = const Value.absent(),
  });
  WearLogsCompanion.insert({
    this.id = const Value.absent(),
    required String itemId,
    this.outfitId = const Value.absent(),
    this.calendarEntryId = const Value.absent(),
    required DateTime date,
  }) : itemId = Value(itemId),
       date = Value(date);
  static Insertable<WearLog> custom({
    Expression<int>? id,
    Expression<String>? itemId,
    Expression<String>? outfitId,
    Expression<String>? calendarEntryId,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (outfitId != null) 'outfit_id': outfitId,
      if (calendarEntryId != null) 'calendar_entry_id': calendarEntryId,
      if (date != null) 'date': date,
    });
  }

  WearLogsCompanion copyWith({Value<int>? id, Value<String>? itemId, Value<String?>? outfitId, Value<String?>? calendarEntryId, Value<DateTime>? date}) {
    return WearLogsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      outfitId: outfitId ?? this.outfitId,
      calendarEntryId: calendarEntryId ?? this.calendarEntryId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (outfitId.present) {
      map['outfit_id'] = Variable<String>(outfitId.value);
    }
    if (calendarEntryId.present) {
      map['calendar_entry_id'] = Variable<String>(calendarEntryId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WearLogsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('outfitId: $outfitId, ')
          ..write('calendarEntryId: $calendarEntryId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $RecentViewsTable extends RecentViews with TableInfo<$RecentViewsTable, RecentView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentViewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES clothing_items (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _viewedAtMeta = const VerificationMeta('viewedAt');
  @override
  late final GeneratedColumn<DateTime> viewedAt = GeneratedColumn<DateTime>(
    'viewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, viewedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_views';
  @override
  VerificationContext validateIntegrity(Insertable<RecentView> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('viewed_at')) {
      context.handle(_viewedAtMeta, viewedAt.isAcceptableOrUnknown(data['viewed_at']!, _viewedAtMeta));
    } else if (isInserting) {
      context.missing(_viewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  RecentView map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentView(
      itemId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      viewedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}viewed_at'])!,
    );
  }

  @override
  $RecentViewsTable createAlias(String alias) {
    return $RecentViewsTable(attachedDatabase, alias);
  }
}

class RecentView extends DataClass implements Insertable<RecentView> {
  final String itemId;
  final DateTime viewedAt;
  const RecentView({required this.itemId, required this.viewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['viewed_at'] = Variable<DateTime>(viewedAt);
    return map;
  }

  RecentViewsCompanion toCompanion(bool nullToAbsent) {
    return RecentViewsCompanion(itemId: Value(itemId), viewedAt: Value(viewedAt));
  }

  factory RecentView.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentView(itemId: serializer.fromJson<String>(json['itemId']), viewedAt: serializer.fromJson<DateTime>(json['viewedAt']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'itemId': serializer.toJson<String>(itemId), 'viewedAt': serializer.toJson<DateTime>(viewedAt)};
  }

  RecentView copyWith({String? itemId, DateTime? viewedAt}) => RecentView(itemId: itemId ?? this.itemId, viewedAt: viewedAt ?? this.viewedAt);
  RecentView copyWithCompanion(RecentViewsCompanion data) {
    return RecentView(itemId: data.itemId.present ? data.itemId.value : this.itemId, viewedAt: data.viewedAt.present ? data.viewedAt.value : this.viewedAt);
  }

  @override
  String toString() {
    return (StringBuffer('RecentView(')
          ..write('itemId: $itemId, ')
          ..write('viewedAt: $viewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, viewedAt);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is RecentView && other.itemId == this.itemId && other.viewedAt == this.viewedAt);
}

class RecentViewsCompanion extends UpdateCompanion<RecentView> {
  final Value<String> itemId;
  final Value<DateTime> viewedAt;
  final Value<int> rowid;
  const RecentViewsCompanion({this.itemId = const Value.absent(), this.viewedAt = const Value.absent(), this.rowid = const Value.absent()});
  RecentViewsCompanion.insert({required String itemId, required DateTime viewedAt, this.rowid = const Value.absent()})
    : itemId = Value(itemId),
      viewedAt = Value(viewedAt);
  static Insertable<RecentView> custom({Expression<String>? itemId, Expression<DateTime>? viewedAt, Expression<int>? rowid}) {
    return RawValuesInsertable({if (itemId != null) 'item_id': itemId, if (viewedAt != null) 'viewed_at': viewedAt, if (rowid != null) 'rowid': rowid});
  }

  RecentViewsCompanion copyWith({Value<String>? itemId, Value<DateTime>? viewedAt, Value<int>? rowid}) {
    return RecentViewsCompanion(itemId: itemId ?? this.itemId, viewedAt: viewedAt ?? this.viewedAt, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (viewedAt.present) {
      map['viewed_at'] = Variable<DateTime>(viewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentViewsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('viewedAt: $viewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClothingItemsTable clothingItems = $ClothingItemsTable(this);
  late final $OutfitsTable outfits = $OutfitsTable(this);
  late final $OutfitItemsTable outfitItems = $OutfitItemsTable(this);
  late final $CalendarEntriesTable calendarEntries = $CalendarEntriesTable(this);
  late final $WearLogsTable wearLogs = $WearLogsTable(this);
  late final $RecentViewsTable recentViews = $RecentViewsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [clothingItems, outfits, outfitItems, calendarEntries, wearLogs, recentViews];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('outfits', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('clothing_items', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('outfits', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('calendar_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('clothing_items', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('wear_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('clothing_items', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('recent_views', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ClothingItemsTableCreateCompanionBuilder = ClothingItemsCompanion Function({
  required String id,
  required String name,
  required String category,
  Value<String?> subcategory,
  required String colorHex,
  required String colorName,
  Value<String?> brand,
  Value<int> seasons,
  Value<int> occasions,
  Value<String?> style,
  Value<bool> isFavorite,
  Value<DateTime?> purchaseDate,
  Value<String?> notes,
  required String imagePath,
  required String thumbPath,
  Value<String?> phash,
  Value<String?> cutoutPath,
  Value<int> wearCount,
  Value<DateTime?> lastWorn,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$ClothingItemsTableUpdateCompanionBuilder = ClothingItemsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String?> subcategory,
  Value<String> colorHex,
  Value<String> colorName,
  Value<String?> brand,
  Value<int> seasons,
  Value<int> occasions,
  Value<String?> style,
  Value<bool> isFavorite,
  Value<DateTime?> purchaseDate,
  Value<String?> notes,
  Value<String> imagePath,
  Value<String> thumbPath,
  Value<String?> phash,
  Value<String?> cutoutPath,
  Value<int> wearCount,
  Value<DateTime?> lastWorn,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$ClothingItemsTableReferences extends BaseReferences<_$AppDatabase, $ClothingItemsTable, ClothingItem> {
  $$ClothingItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>> _outfitItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.outfitItems, aliasName: 'clothing_items__id__outfit_items__item_id');

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager($_db, $_db.outfitItems).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WearLogsTable, List<WearLog>> _wearLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.wearLogs, aliasName: 'clothing_items__id__wear_logs__item_id');

  $$WearLogsTableProcessedTableManager get wearLogsRefs {
    final manager = $$WearLogsTableTableManager($_db, $_db.wearLogs).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wearLogsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecentViewsTable, List<RecentView>> _recentViewsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recentViews, aliasName: 'clothing_items__id__recent_views__item_id');

  $$RecentViewsTableProcessedTableManager get recentViewsRefs {
    final manager = $$RecentViewsTableTableManager($_db, $_db.recentViews).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recentViewsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClothingItemsTableFilterComposer extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategory => $composableBuilder(column: $table.subcategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorName => $composableBuilder(column: $table.colorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasons => $composableBuilder(column: $table.seasons, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occasions => $composableBuilder(column: $table.occasions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get style => $composableBuilder(column: $table.style, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbPath => $composableBuilder(column: $table.thumbPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phash => $composableBuilder(column: $table.phash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cutoutPath => $composableBuilder(column: $table.cutoutPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wearCount => $composableBuilder(column: $table.wearCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastWorn => $composableBuilder(column: $table.lastWorn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> outfitItemsRefs(Expression<bool> Function($$OutfitItemsTableFilterComposer f) f) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitItemsTableFilterComposer(
        $db: $db,
        $table: $db.outfitItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> wearLogsRefs(Expression<bool> Function($$WearLogsTableFilterComposer f) f) {
    final $$WearLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wearLogs,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WearLogsTableFilterComposer(
        $db: $db,
        $table: $db.wearLogs,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> recentViewsRefs(Expression<bool> Function($$RecentViewsTableFilterComposer f) f) {
    final $$RecentViewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recentViews,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$RecentViewsTableFilterComposer(
        $db: $db,
        $table: $db.recentViews,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$ClothingItemsTableOrderingComposer extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategory => $composableBuilder(column: $table.subcategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorName => $composableBuilder(column: $table.colorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasons => $composableBuilder(column: $table.seasons, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occasions => $composableBuilder(column: $table.occasions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get style => $composableBuilder(column: $table.style, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(column: $table.purchaseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbPath => $composableBuilder(column: $table.thumbPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phash => $composableBuilder(column: $table.phash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cutoutPath => $composableBuilder(column: $table.cutoutPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wearCount => $composableBuilder(column: $table.wearCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastWorn => $composableBuilder(column: $table.lastWorn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ClothingItemsTableAnnotationComposer extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(column: $table.subcategory, builder: (column) => column);

  GeneratedColumn<String> get colorHex => $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get colorName => $composableBuilder(column: $table.colorName, builder: (column) => column);

  GeneratedColumn<String> get brand => $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<int> get seasons => $composableBuilder(column: $table.seasons, builder: (column) => column);

  GeneratedColumn<int> get occasions => $composableBuilder(column: $table.occasions, builder: (column) => column);

  GeneratedColumn<String> get style => $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get imagePath => $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get thumbPath => $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get phash => $composableBuilder(column: $table.phash, builder: (column) => column);

  GeneratedColumn<String> get cutoutPath => $composableBuilder(column: $table.cutoutPath, builder: (column) => column);

  GeneratedColumn<int> get wearCount => $composableBuilder(column: $table.wearCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWorn => $composableBuilder(column: $table.lastWorn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> outfitItemsRefs<T extends Object>(Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitItemsTableAnnotationComposer(
        $db: $db,
        $table: $db.outfitItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> wearLogsRefs<T extends Object>(Expression<T> Function($$WearLogsTableAnnotationComposer a) f) {
    final $$WearLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wearLogs,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$WearLogsTableAnnotationComposer(
        $db: $db,
        $table: $db.wearLogs,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> recentViewsRefs<T extends Object>(Expression<T> Function($$RecentViewsTableAnnotationComposer a) f) {
    final $$RecentViewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recentViews,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$RecentViewsTableAnnotationComposer(
        $db: $db,
        $table: $db.recentViews,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$ClothingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClothingItemsTable,
          ClothingItem,
          $$ClothingItemsTableFilterComposer,
          $$ClothingItemsTableOrderingComposer,
          $$ClothingItemsTableAnnotationComposer,
          $$ClothingItemsTableCreateCompanionBuilder,
          $$ClothingItemsTableUpdateCompanionBuilder,
          (ClothingItem, $$ClothingItemsTableReferences),
          ClothingItem,
          PrefetchHooks Function({bool outfitItemsRefs, bool wearLogsRefs, bool recentViewsRefs})
        > {
  $$ClothingItemsTableTableManager(_$AppDatabase db, $ClothingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ClothingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ClothingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ClothingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> colorName = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<int> seasons = const Value.absent(),
                Value<int> occasions = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> thumbPath = const Value.absent(),
                Value<String?> phash = const Value.absent(),
                Value<String?> cutoutPath = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<DateTime?> lastWorn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClothingItemsCompanion(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                colorHex: colorHex,
                colorName: colorName,
                brand: brand,
                seasons: seasons,
                occasions: occasions,
                style: style,
                isFavorite: isFavorite,
                purchaseDate: purchaseDate,
                notes: notes,
                imagePath: imagePath,
                thumbPath: thumbPath,
                phash: phash,
                cutoutPath: cutoutPath,
                wearCount: wearCount,
                lastWorn: lastWorn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                Value<String?> subcategory = const Value.absent(),
                required String colorHex,
                required String colorName,
                Value<String?> brand = const Value.absent(),
                Value<int> seasons = const Value.absent(),
                Value<int> occasions = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String imagePath,
                required String thumbPath,
                Value<String?> phash = const Value.absent(),
                Value<String?> cutoutPath = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<DateTime?> lastWorn = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClothingItemsCompanion.insert(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                colorHex: colorHex,
                colorName: colorName,
                brand: brand,
                seasons: seasons,
                occasions: occasions,
                style: style,
                isFavorite: isFavorite,
                purchaseDate: purchaseDate,
                notes: notes,
                imagePath: imagePath,
                thumbPath: thumbPath,
                phash: phash,
                cutoutPath: cutoutPath,
                wearCount: wearCount,
                lastWorn: lastWorn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$ClothingItemsTable, ClothingItem>(table), $$ClothingItemsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({outfitItemsRefs = false, wearLogsRefs = false, recentViewsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (outfitItemsRefs) db.outfitItems, if (wearLogsRefs) db.wearLogs, if (recentViewsRefs) db.recentViews],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (outfitItemsRefs)
                    await $_getPrefetchedDataByColumns<ClothingItem, $ClothingItemsTable, OutfitItem, $OutfitItemsTable>(
                      currentTable: table,
                      referencedTable: $$ClothingItemsTableReferences._outfitItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ClothingItemsTableReferences(db, table, p0).outfitItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'item_id',
                      typedResults: items,
                    ),
                  if (wearLogsRefs)
                    await $_getPrefetchedDataByColumns<ClothingItem, $ClothingItemsTable, WearLog, $WearLogsTable>(
                      currentTable: table,
                      referencedTable: $$ClothingItemsTableReferences._wearLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ClothingItemsTableReferences(db, table, p0).wearLogsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'item_id',
                      typedResults: items,
                    ),
                  if (recentViewsRefs)
                    await $_getPrefetchedDataByColumns<ClothingItem, $ClothingItemsTable, RecentView, $RecentViewsTable>(
                      currentTable: table,
                      referencedTable: $$ClothingItemsTableReferences._recentViewsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ClothingItemsTableReferences(db, table, p0).recentViewsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'item_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClothingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClothingItemsTable,
      ClothingItem,
      $$ClothingItemsTableFilterComposer,
      $$ClothingItemsTableOrderingComposer,
      $$ClothingItemsTableAnnotationComposer,
      $$ClothingItemsTableCreateCompanionBuilder,
      $$ClothingItemsTableUpdateCompanionBuilder,
      (ClothingItem, $$ClothingItemsTableReferences),
      ClothingItem,
      PrefetchHooks Function({bool outfitItemsRefs, bool wearLogsRefs, bool recentViewsRefs})
    >;
typedef $$OutfitsTableCreateCompanionBuilder = OutfitsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<int> occasions,
  Value<int> seasons,
  Value<String?> style,
  Value<bool> isFavorite,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$OutfitsTableUpdateCompanionBuilder = OutfitsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<int> occasions,
  Value<int> seasons,
  Value<String?> style,
  Value<bool> isFavorite,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$OutfitsTableReferences extends BaseReferences<_$AppDatabase, $OutfitsTable, Outfit> {
  $$OutfitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>> _outfitItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.outfitItems, aliasName: 'outfits__id__outfit_items__outfit_id');

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager($_db, $_db.outfitItems).filter((f) => f.outfitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CalendarEntriesTable, List<CalendarEntry>> _calendarEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.calendarEntries, aliasName: 'outfits__id__calendar_entries__outfit_id');

  $$CalendarEntriesTableProcessedTableManager get calendarEntriesRefs {
    final manager = $$CalendarEntriesTableTableManager($_db, $_db.calendarEntries).filter((f) => f.outfitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarEntriesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OutfitsTableFilterComposer extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occasions => $composableBuilder(column: $table.occasions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasons => $composableBuilder(column: $table.seasons, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get style => $composableBuilder(column: $table.style, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> outfitItemsRefs(Expression<bool> Function($$OutfitItemsTableFilterComposer f) f) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitItemsTableFilterComposer(
        $db: $db,
        $table: $db.outfitItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> calendarEntriesRefs(Expression<bool> Function($$CalendarEntriesTableFilterComposer f) f) {
    final $$CalendarEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEntries,
      getReferencedColumn: (t) => t.outfitId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$CalendarEntriesTableFilterComposer(
        $db: $db,
        $table: $db.calendarEntries,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$OutfitsTableOrderingComposer extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occasions => $composableBuilder(column: $table.occasions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasons => $composableBuilder(column: $table.seasons, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get style => $composableBuilder(column: $table.style, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$OutfitsTableAnnotationComposer extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get occasions => $composableBuilder(column: $table.occasions, builder: (column) => column);

  GeneratedColumn<int> get seasons => $composableBuilder(column: $table.seasons, builder: (column) => column);

  GeneratedColumn<String> get style => $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> outfitItemsRefs<T extends Object>(Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitItemsTableAnnotationComposer(
        $db: $db,
        $table: $db.outfitItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> calendarEntriesRefs<T extends Object>(Expression<T> Function($$CalendarEntriesTableAnnotationComposer a) f) {
    final $$CalendarEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEntries,
      getReferencedColumn: (t) => t.outfitId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$CalendarEntriesTableAnnotationComposer(
        $db: $db,
        $table: $db.calendarEntries,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$OutfitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitsTable,
          Outfit,
          $$OutfitsTableFilterComposer,
          $$OutfitsTableOrderingComposer,
          $$OutfitsTableAnnotationComposer,
          $$OutfitsTableCreateCompanionBuilder,
          $$OutfitsTableUpdateCompanionBuilder,
          (Outfit, $$OutfitsTableReferences),
          Outfit,
          PrefetchHooks Function({bool outfitItemsRefs, bool calendarEntriesRefs})
        > {
  $$OutfitsTableTableManager(_$AppDatabase db, $OutfitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutfitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutfitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OutfitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> occasions = const Value.absent(),
                Value<int> seasons = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitsCompanion(
                id: id,
                name: name,
                description: description,
                occasions: occasions,
                seasons: seasons,
                style: style,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> occasions = const Value.absent(),
                Value<int> seasons = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitsCompanion.insert(
                id: id,
                name: name,
                description: description,
                occasions: occasions,
                seasons: seasons,
                style: style,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$OutfitsTable, Outfit>(table), $$OutfitsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({outfitItemsRefs = false, calendarEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (outfitItemsRefs) db.outfitItems, if (calendarEntriesRefs) db.calendarEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (outfitItemsRefs)
                    await $_getPrefetchedDataByColumns<Outfit, $OutfitsTable, OutfitItem, $OutfitItemsTable>(
                      currentTable: table,
                      referencedTable: $$OutfitsTableReferences._outfitItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$OutfitsTableReferences(db, table, p0).outfitItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'outfit_id',
                      typedResults: items,
                    ),
                  if (calendarEntriesRefs)
                    await $_getPrefetchedDataByColumns<Outfit, $OutfitsTable, CalendarEntry, $CalendarEntriesTable>(
                      currentTable: table,
                      referencedTable: $$OutfitsTableReferences._calendarEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$OutfitsTableReferences(db, table, p0).calendarEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'outfit_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OutfitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitsTable,
      Outfit,
      $$OutfitsTableFilterComposer,
      $$OutfitsTableOrderingComposer,
      $$OutfitsTableAnnotationComposer,
      $$OutfitsTableCreateCompanionBuilder,
      $$OutfitsTableUpdateCompanionBuilder,
      (Outfit, $$OutfitsTableReferences),
      Outfit,
      PrefetchHooks Function({bool outfitItemsRefs, bool calendarEntriesRefs})
    >;
typedef $$OutfitItemsTableCreateCompanionBuilder = OutfitItemsCompanion Function({
  required String outfitId,
  required String itemId,
  Value<int> position,
  Value<int> rowid,
});
typedef $$OutfitItemsTableUpdateCompanionBuilder = OutfitItemsCompanion Function({
  Value<String> outfitId,
  Value<String> itemId,
  Value<int> position,
  Value<int> rowid,
});

final class $$OutfitItemsTableReferences extends BaseReferences<_$AppDatabase, $OutfitItemsTable, OutfitItem> {
  $$OutfitItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitsTable _outfitIdTable(_$AppDatabase db) => db.outfits.createAlias('outfit_items__outfit_id__outfits__id');

  $$OutfitsTableProcessedTableManager get outfitId {
    final $_column = $_itemColumn<String>('outfit_id')!;

    final manager = $$OutfitsTableTableManager($_db, $_db.outfits).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outfitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ClothingItemsTable _itemIdTable(_$AppDatabase db) => db.clothingItems.createAlias('outfit_items__item_id__clothing_items__id');

  $$ClothingItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ClothingItemsTableTableManager($_db, $_db.clothingItems).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OutfitItemsTableFilterComposer extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  $$OutfitsTableFilterComposer get outfitId {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitsTableFilterComposer(
        $db: $db,
        $table: $db.outfits,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ClothingItemsTableFilterComposer get itemId {
    final $$ClothingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableFilterComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$OutfitItemsTableOrderingComposer extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  $$OutfitsTableOrderingComposer get outfitId {
    final $$OutfitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitsTableOrderingComposer(
        $db: $db,
        $table: $db.outfits,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ClothingItemsTableOrderingComposer get itemId {
    final $$ClothingItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableOrderingComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$OutfitItemsTableAnnotationComposer extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  $$OutfitsTableAnnotationComposer get outfitId {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitsTableAnnotationComposer(
        $db: $db,
        $table: $db.outfits,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  $$ClothingItemsTableAnnotationComposer get itemId {
    final $$ClothingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableAnnotationComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$OutfitItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitItemsTable,
          OutfitItem,
          $$OutfitItemsTableFilterComposer,
          $$OutfitItemsTableOrderingComposer,
          $$OutfitItemsTableAnnotationComposer,
          $$OutfitItemsTableCreateCompanionBuilder,
          $$OutfitItemsTableUpdateCompanionBuilder,
          (OutfitItem, $$OutfitItemsTableReferences),
          OutfitItem,
          PrefetchHooks Function({bool outfitId, bool itemId})
        > {
  $$OutfitItemsTableTableManager(_$AppDatabase db, $OutfitItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutfitItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutfitItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OutfitItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> outfitId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => OutfitItemsCompanion(outfitId: outfitId, itemId: itemId, position: position, rowid: rowid),
          createCompanionCallback: ({
            required String outfitId,
            required String itemId,
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => OutfitItemsCompanion.insert(outfitId: outfitId, itemId: itemId, position: position, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$OutfitItemsTable, OutfitItem>(table), $$OutfitItemsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({outfitId = false, itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (outfitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.outfitId,
                        referencedTable: $$OutfitItemsTableReferences._outfitIdTable(db),
                        referencedColumn: $$OutfitItemsTableReferences._outfitIdTable(db).id,
                      ) as T;
                    }
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$OutfitItemsTableReferences._itemIdTable(db),
                        referencedColumn: $$OutfitItemsTableReferences._itemIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OutfitItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitItemsTable,
      OutfitItem,
      $$OutfitItemsTableFilterComposer,
      $$OutfitItemsTableOrderingComposer,
      $$OutfitItemsTableAnnotationComposer,
      $$OutfitItemsTableCreateCompanionBuilder,
      $$OutfitItemsTableUpdateCompanionBuilder,
      (OutfitItem, $$OutfitItemsTableReferences),
      OutfitItem,
      PrefetchHooks Function({bool outfitId, bool itemId})
    >;
typedef $$CalendarEntriesTableCreateCompanionBuilder = CalendarEntriesCompanion Function({
  required String id,
  required DateTime date,
  required String outfitId,
  Value<bool> worn,
  Value<int> rowid,
});
typedef $$CalendarEntriesTableUpdateCompanionBuilder = CalendarEntriesCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String> outfitId,
  Value<bool> worn,
  Value<int> rowid,
});

final class $$CalendarEntriesTableReferences extends BaseReferences<_$AppDatabase, $CalendarEntriesTable, CalendarEntry> {
  $$CalendarEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitsTable _outfitIdTable(_$AppDatabase db) => db.outfits.createAlias('calendar_entries__outfit_id__outfits__id');

  $$OutfitsTableProcessedTableManager get outfitId {
    final $_column = $_itemColumn<String>('outfit_id')!;

    final manager = $$OutfitsTableTableManager($_db, $_db.outfits).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outfitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CalendarEntriesTableFilterComposer extends Composer<_$AppDatabase, $CalendarEntriesTable> {
  $$CalendarEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get worn => $composableBuilder(column: $table.worn, builder: (column) => ColumnFilters(column));

  $$OutfitsTableFilterComposer get outfitId {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitsTableFilterComposer(
        $db: $db,
        $table: $db.outfits,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$CalendarEntriesTableOrderingComposer extends Composer<_$AppDatabase, $CalendarEntriesTable> {
  $$CalendarEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get worn => $composableBuilder(column: $table.worn, builder: (column) => ColumnOrderings(column));

  $$OutfitsTableOrderingComposer get outfitId {
    final $$OutfitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitsTableOrderingComposer(
        $db: $db,
        $table: $db.outfits,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$CalendarEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $CalendarEntriesTable> {
  $$CalendarEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get worn => $composableBuilder(column: $table.worn, builder: (column) => column);

  $$OutfitsTableAnnotationComposer get outfitId {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$OutfitsTableAnnotationComposer(
        $db: $db,
        $table: $db.outfits,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$CalendarEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarEntriesTable,
          CalendarEntry,
          $$CalendarEntriesTableFilterComposer,
          $$CalendarEntriesTableOrderingComposer,
          $$CalendarEntriesTableAnnotationComposer,
          $$CalendarEntriesTableCreateCompanionBuilder,
          $$CalendarEntriesTableUpdateCompanionBuilder,
          (CalendarEntry, $$CalendarEntriesTableReferences),
          CalendarEntry,
          PrefetchHooks Function({bool outfitId})
        > {
  $$CalendarEntriesTableTableManager(_$AppDatabase db, $CalendarEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CalendarEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CalendarEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CalendarEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> outfitId = const Value.absent(),
            Value<bool> worn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CalendarEntriesCompanion(id: id, date: date, outfitId: outfitId, worn: worn, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required String outfitId,
            Value<bool> worn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CalendarEntriesCompanion.insert(id: id, date: date, outfitId: outfitId, worn: worn, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$CalendarEntriesTable, CalendarEntry>(table), $$CalendarEntriesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({outfitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (outfitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.outfitId,
                        referencedTable: $$CalendarEntriesTableReferences._outfitIdTable(db),
                        referencedColumn: $$CalendarEntriesTableReferences._outfitIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CalendarEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarEntriesTable,
      CalendarEntry,
      $$CalendarEntriesTableFilterComposer,
      $$CalendarEntriesTableOrderingComposer,
      $$CalendarEntriesTableAnnotationComposer,
      $$CalendarEntriesTableCreateCompanionBuilder,
      $$CalendarEntriesTableUpdateCompanionBuilder,
      (CalendarEntry, $$CalendarEntriesTableReferences),
      CalendarEntry,
      PrefetchHooks Function({bool outfitId})
    >;
typedef $$WearLogsTableCreateCompanionBuilder = WearLogsCompanion Function({
  Value<int> id,
  required String itemId,
  Value<String?> outfitId,
  Value<String?> calendarEntryId,
  required DateTime date,
});
typedef $$WearLogsTableUpdateCompanionBuilder = WearLogsCompanion Function({
  Value<int> id,
  Value<String> itemId,
  Value<String?> outfitId,
  Value<String?> calendarEntryId,
  Value<DateTime> date,
});

final class $$WearLogsTableReferences extends BaseReferences<_$AppDatabase, $WearLogsTable, WearLog> {
  $$WearLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClothingItemsTable _itemIdTable(_$AppDatabase db) => db.clothingItems.createAlias('wear_logs__item_id__clothing_items__id');

  $$ClothingItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ClothingItemsTableTableManager($_db, $_db.clothingItems).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WearLogsTableFilterComposer extends Composer<_$AppDatabase, $WearLogsTable> {
  $$WearLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outfitId => $composableBuilder(column: $table.outfitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get calendarEntryId => $composableBuilder(column: $table.calendarEntryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  $$ClothingItemsTableFilterComposer get itemId {
    final $$ClothingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableFilterComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WearLogsTableOrderingComposer extends Composer<_$AppDatabase, $WearLogsTable> {
  $$WearLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outfitId => $composableBuilder(column: $table.outfitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get calendarEntryId => $composableBuilder(column: $table.calendarEntryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  $$ClothingItemsTableOrderingComposer get itemId {
    final $$ClothingItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableOrderingComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WearLogsTableAnnotationComposer extends Composer<_$AppDatabase, $WearLogsTable> {
  $$WearLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get outfitId => $composableBuilder(column: $table.outfitId, builder: (column) => column);

  GeneratedColumn<String> get calendarEntryId => $composableBuilder(column: $table.calendarEntryId, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  $$ClothingItemsTableAnnotationComposer get itemId {
    final $$ClothingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableAnnotationComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$WearLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WearLogsTable,
          WearLog,
          $$WearLogsTableFilterComposer,
          $$WearLogsTableOrderingComposer,
          $$WearLogsTableAnnotationComposer,
          $$WearLogsTableCreateCompanionBuilder,
          $$WearLogsTableUpdateCompanionBuilder,
          (WearLog, $$WearLogsTableReferences),
          WearLog,
          PrefetchHooks Function({bool itemId})
        > {
  $$WearLogsTableTableManager(_$AppDatabase db, $WearLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WearLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WearLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WearLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> outfitId = const Value.absent(),
            Value<String?> calendarEntryId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) => WearLogsCompanion(id: id, itemId: itemId, outfitId: outfitId, calendarEntryId: calendarEntryId, date: date),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String itemId,
            Value<String?> outfitId = const Value.absent(),
            Value<String?> calendarEntryId = const Value.absent(),
            required DateTime date,
          }) => WearLogsCompanion.insert(id: id, itemId: itemId, outfitId: outfitId, calendarEntryId: calendarEntryId, date: date),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$WearLogsTable, WearLog>(table), $$WearLogsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$WearLogsTableReferences._itemIdTable(db),
                        referencedColumn: $$WearLogsTableReferences._itemIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WearLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WearLogsTable,
      WearLog,
      $$WearLogsTableFilterComposer,
      $$WearLogsTableOrderingComposer,
      $$WearLogsTableAnnotationComposer,
      $$WearLogsTableCreateCompanionBuilder,
      $$WearLogsTableUpdateCompanionBuilder,
      (WearLog, $$WearLogsTableReferences),
      WearLog,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$RecentViewsTableCreateCompanionBuilder = RecentViewsCompanion Function({required String itemId, required DateTime viewedAt, Value<int> rowid});
typedef $$RecentViewsTableUpdateCompanionBuilder = RecentViewsCompanion Function({Value<String> itemId, Value<DateTime> viewedAt, Value<int> rowid});

final class $$RecentViewsTableReferences extends BaseReferences<_$AppDatabase, $RecentViewsTable, RecentView> {
  $$RecentViewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClothingItemsTable _itemIdTable(_$AppDatabase db) => db.clothingItems.createAlias('recent_views__item_id__clothing_items__id');

  $$ClothingItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ClothingItemsTableTableManager($_db, $_db.clothingItems).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecentViewsTableFilterComposer extends Composer<_$AppDatabase, $RecentViewsTable> {
  $$RecentViewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get viewedAt => $composableBuilder(column: $table.viewedAt, builder: (column) => ColumnFilters(column));

  $$ClothingItemsTableFilterComposer get itemId {
    final $$ClothingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableFilterComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$RecentViewsTableOrderingComposer extends Composer<_$AppDatabase, $RecentViewsTable> {
  $$RecentViewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get viewedAt => $composableBuilder(column: $table.viewedAt, builder: (column) => ColumnOrderings(column));

  $$ClothingItemsTableOrderingComposer get itemId {
    final $$ClothingItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableOrderingComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$RecentViewsTableAnnotationComposer extends Composer<_$AppDatabase, $RecentViewsTable> {
  $$RecentViewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get viewedAt => $composableBuilder(column: $table.viewedAt, builder: (column) => column);

  $$ClothingItemsTableAnnotationComposer get itemId {
    final $$ClothingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ClothingItemsTableAnnotationComposer(
        $db: $db,
        $table: $db.clothingItems,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$RecentViewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentViewsTable,
          RecentView,
          $$RecentViewsTableFilterComposer,
          $$RecentViewsTableOrderingComposer,
          $$RecentViewsTableAnnotationComposer,
          $$RecentViewsTableCreateCompanionBuilder,
          $$RecentViewsTableUpdateCompanionBuilder,
          (RecentView, $$RecentViewsTableReferences),
          RecentView,
          PrefetchHooks Function({bool itemId})
        > {
  $$RecentViewsTableTableManager(_$AppDatabase db, $RecentViewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RecentViewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RecentViewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RecentViewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<DateTime> viewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => RecentViewsCompanion(itemId: itemId, viewedAt: viewedAt, rowid: rowid),
          createCompanionCallback: ({required String itemId, required DateTime viewedAt, Value<int> rowid = const Value.absent()}) =>
              RecentViewsCompanion.insert(itemId: itemId, viewedAt: viewedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$RecentViewsTable, RecentView>(table), $$RecentViewsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$RecentViewsTableReferences._itemIdTable(db),
                        referencedColumn: $$RecentViewsTableReferences._itemIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecentViewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentViewsTable,
      RecentView,
      $$RecentViewsTableFilterComposer,
      $$RecentViewsTableOrderingComposer,
      $$RecentViewsTableAnnotationComposer,
      $$RecentViewsTableCreateCompanionBuilder,
      $$RecentViewsTableUpdateCompanionBuilder,
      (RecentView, $$RecentViewsTableReferences),
      RecentView,
      PrefetchHooks Function({bool itemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClothingItemsTableTableManager get clothingItems => $$ClothingItemsTableTableManager(_db, _db.clothingItems);
  $$OutfitsTableTableManager get outfits => $$OutfitsTableTableManager(_db, _db.outfits);
  $$OutfitItemsTableTableManager get outfitItems => $$OutfitItemsTableTableManager(_db, _db.outfitItems);
  $$CalendarEntriesTableTableManager get calendarEntries => $$CalendarEntriesTableTableManager(_db, _db.calendarEntries);
  $$WearLogsTableTableManager get wearLogs => $$WearLogsTableTableManager(_db, _db.wearLogs);
  $$RecentViewsTableTableManager get recentViews => $$RecentViewsTableTableManager(_db, _db.recentViews);
}
