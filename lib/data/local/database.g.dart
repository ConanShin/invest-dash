// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OwnersTable extends Owners with TableInfo<$OwnersTable, Owner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owners';
  @override
  VerificationContext validateIntegrity(
    Insertable<Owner> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Owner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Owner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $OwnersTable createAlias(String alias) {
    return $OwnersTable(attachedDatabase, alias);
  }
}

class Owner extends DataClass implements Insertable<Owner> {
  final int id;
  final String name;
  const Owner({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  OwnersCompanion toCompanion(bool nullToAbsent) {
    return OwnersCompanion(id: Value(id), name: Value(name));
  }

  factory Owner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Owner(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Owner copyWith({int? id, String? name}) =>
      Owner(id: id ?? this.id, name: name ?? this.name);
  Owner copyWithCompanion(OwnersCompanion data) {
    return Owner(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Owner(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Owner && other.id == this.id && other.name == this.name);
}

class OwnersCompanion extends UpdateCompanion<Owner> {
  final Value<int> id;
  final Value<String> name;
  const OwnersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  OwnersCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Owner> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  OwnersCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return OwnersCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AssetType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AssetType>($AssetsTable.$convertertype);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('신철민'),
  );
  static const VerificationMeta _dividendAmountMeta = const VerificationMeta(
    'dividendAmount',
  );
  @override
  late final GeneratedColumn<double> dividendAmount = GeneratedColumn<double>(
    'dividend_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dividendMonthsMeta = const VerificationMeta(
    'dividendMonths',
  );
  @override
  late final GeneratedColumn<String> dividendMonths = GeneratedColumn<String>(
    'dividend_months',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    name,
    type,
    currency,
    owner,
    dividendAmount,
    dividendMonths,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('dividend_amount')) {
      context.handle(
        _dividendAmountMeta,
        dividendAmount.isAcceptableOrUnknown(
          data['dividend_amount']!,
          _dividendAmountMeta,
        ),
      );
    }
    if (data.containsKey('dividend_months')) {
      context.handle(
        _dividendMonthsMeta,
        dividendMonths.isAcceptableOrUnknown(
          data['dividend_months']!,
          _dividendMonthsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AssetsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      dividendAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dividend_amount'],
      ),
      dividendMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dividend_months'],
      ),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AssetType, String, String> $convertertype =
      const EnumNameConverter<AssetType>(AssetType.values);
}

class Asset extends DataClass implements Insertable<Asset> {
  final int id;
  final String symbol;
  final String name;
  final AssetType type;
  final String currency;
  final String owner;
  final double? dividendAmount;
  final String? dividendMonths;
  const Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.currency,
    required this.owner,
    this.dividendAmount,
    this.dividendMonths,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($AssetsTable.$convertertype.toSql(type));
    }
    map['currency'] = Variable<String>(currency);
    map['owner'] = Variable<String>(owner);
    if (!nullToAbsent || dividendAmount != null) {
      map['dividend_amount'] = Variable<double>(dividendAmount);
    }
    if (!nullToAbsent || dividendMonths != null) {
      map['dividend_months'] = Variable<String>(dividendMonths);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      owner: Value(owner),
      dividendAmount: dividendAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(dividendAmount),
      dividendMonths: dividendMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(dividendMonths),
    );
  }

  factory Asset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<int>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      type: $AssetsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      currency: serializer.fromJson<String>(json['currency']),
      owner: serializer.fromJson<String>(json['owner']),
      dividendAmount: serializer.fromJson<double?>(json['dividendAmount']),
      dividendMonths: serializer.fromJson<String?>(json['dividendMonths']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $AssetsTable.$convertertype.toJson(type),
      ),
      'currency': serializer.toJson<String>(currency),
      'owner': serializer.toJson<String>(owner),
      'dividendAmount': serializer.toJson<double?>(dividendAmount),
      'dividendMonths': serializer.toJson<String?>(dividendMonths),
    };
  }

  Asset copyWith({
    int? id,
    String? symbol,
    String? name,
    AssetType? type,
    String? currency,
    String? owner,
    Value<double?> dividendAmount = const Value.absent(),
    Value<String?> dividendMonths = const Value.absent(),
  }) => Asset(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    owner: owner ?? this.owner,
    dividendAmount: dividendAmount.present
        ? dividendAmount.value
        : this.dividendAmount,
    dividendMonths: dividendMonths.present
        ? dividendMonths.value
        : this.dividendMonths,
  );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      owner: data.owner.present ? data.owner.value : this.owner,
      dividendAmount: data.dividendAmount.present
          ? data.dividendAmount.value
          : this.dividendAmount,
      dividendMonths: data.dividendMonths.present
          ? data.dividendMonths.value
          : this.dividendMonths,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('owner: $owner, ')
          ..write('dividendAmount: $dividendAmount, ')
          ..write('dividendMonths: $dividendMonths')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    name,
    type,
    currency,
    owner,
    dividendAmount,
    dividendMonths,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.owner == this.owner &&
          other.dividendAmount == this.dividendAmount &&
          other.dividendMonths == this.dividendMonths);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<int> id;
  final Value<String> symbol;
  final Value<String> name;
  final Value<AssetType> type;
  final Value<String> currency;
  final Value<String> owner;
  final Value<double?> dividendAmount;
  final Value<String?> dividendMonths;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.owner = const Value.absent(),
    this.dividendAmount = const Value.absent(),
    this.dividendMonths = const Value.absent(),
  });
  AssetsCompanion.insert({
    this.id = const Value.absent(),
    required String symbol,
    required String name,
    required AssetType type,
    required String currency,
    this.owner = const Value.absent(),
    this.dividendAmount = const Value.absent(),
    this.dividendMonths = const Value.absent(),
  }) : symbol = Value(symbol),
       name = Value(name),
       type = Value(type),
       currency = Value(currency);
  static Insertable<Asset> custom({
    Expression<int>? id,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<String>? owner,
    Expression<double>? dividendAmount,
    Expression<String>? dividendMonths,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (owner != null) 'owner': owner,
      if (dividendAmount != null) 'dividend_amount': dividendAmount,
      if (dividendMonths != null) 'dividend_months': dividendMonths,
    });
  }

  AssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? symbol,
    Value<String>? name,
    Value<AssetType>? type,
    Value<String>? currency,
    Value<String>? owner,
    Value<double?>? dividendAmount,
    Value<String?>? dividendMonths,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      owner: owner ?? this.owner,
      dividendAmount: dividendAmount ?? this.dividendAmount,
      dividendMonths: dividendMonths ?? this.dividendMonths,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AssetsTable.$convertertype.toSql(type.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (dividendAmount.present) {
      map['dividend_amount'] = Variable<double>(dividendAmount.value);
    }
    if (dividendMonths.present) {
      map['dividend_months'] = Variable<String>(dividendMonths.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('owner: $owner, ')
          ..write('dividendAmount: $dividendAmount, ')
          ..write('dividendMonths: $dividendMonths')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTable extends Holdings with TableInfo<$HoldingsTable, Holding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averagePriceMeta = const VerificationMeta(
    'averagePrice',
  );
  @override
  late final GeneratedColumn<double> averagePrice = GeneratedColumn<double>(
    'average_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, assetId, quantity, averagePrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Holding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('average_price')) {
      context.handle(
        _averagePriceMeta,
        averagePrice.isAcceptableOrUnknown(
          data['average_price']!,
          _averagePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averagePriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Holding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      averagePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_price'],
      )!,
    );
  }

  @override
  $HoldingsTable createAlias(String alias) {
    return $HoldingsTable(attachedDatabase, alias);
  }
}

class Holding extends DataClass implements Insertable<Holding> {
  final int id;
  final int assetId;
  final double quantity;
  final double averagePrice;
  const Holding({
    required this.id,
    required this.assetId,
    required this.quantity,
    required this.averagePrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    map['quantity'] = Variable<double>(quantity);
    map['average_price'] = Variable<double>(averagePrice);
    return map;
  }

  HoldingsCompanion toCompanion(bool nullToAbsent) {
    return HoldingsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      quantity: Value(quantity),
      averagePrice: Value(averagePrice),
    );
  }

  factory Holding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holding(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      averagePrice: serializer.fromJson<double>(json['averagePrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'quantity': serializer.toJson<double>(quantity),
      'averagePrice': serializer.toJson<double>(averagePrice),
    };
  }

  Holding copyWith({
    int? id,
    int? assetId,
    double? quantity,
    double? averagePrice,
  }) => Holding(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    quantity: quantity ?? this.quantity,
    averagePrice: averagePrice ?? this.averagePrice,
  );
  Holding copyWithCompanion(HoldingsCompanion data) {
    return Holding(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      averagePrice: data.averagePrice.present
          ? data.averagePrice.value
          : this.averagePrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holding(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('quantity: $quantity, ')
          ..write('averagePrice: $averagePrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, assetId, quantity, averagePrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holding &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.quantity == this.quantity &&
          other.averagePrice == this.averagePrice);
}

class HoldingsCompanion extends UpdateCompanion<Holding> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<double> quantity;
  final Value<double> averagePrice;
  const HoldingsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.averagePrice = const Value.absent(),
  });
  HoldingsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required double quantity,
    required double averagePrice,
  }) : assetId = Value(assetId),
       quantity = Value(quantity),
       averagePrice = Value(averagePrice);
  static Insertable<Holding> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<double>? quantity,
    Expression<double>? averagePrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (quantity != null) 'quantity': quantity,
      if (averagePrice != null) 'average_price': averagePrice,
    });
  }

  HoldingsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<double>? quantity,
    Value<double>? averagePrice,
  }) {
    return HoldingsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (averagePrice.present) {
      map['average_price'] = Variable<double>(averagePrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('quantity: $quantity, ')
          ..write('averagePrice: $averagePrice')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OwnersTable owners = $OwnersTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $HoldingsTable holdings = $HoldingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    owners,
    assets,
    holdings,
  ];
}

typedef $$OwnersTableCreateCompanionBuilder =
    OwnersCompanion Function({Value<int> id, required String name});
typedef $$OwnersTableUpdateCompanionBuilder =
    OwnersCompanion Function({Value<int> id, Value<String> name});

class $$OwnersTableFilterComposer
    extends Composer<_$AppDatabase, $OwnersTable> {
  $$OwnersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OwnersTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnersTable> {
  $$OwnersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnersTable> {
  $$OwnersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$OwnersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnersTable,
          Owner,
          $$OwnersTableFilterComposer,
          $$OwnersTableOrderingComposer,
          $$OwnersTableAnnotationComposer,
          $$OwnersTableCreateCompanionBuilder,
          $$OwnersTableUpdateCompanionBuilder,
          (Owner, BaseReferences<_$AppDatabase, $OwnersTable, Owner>),
          Owner,
          PrefetchHooks Function()
        > {
  $$OwnersTableTableManager(_$AppDatabase db, $OwnersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => OwnersCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  OwnersCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnersTable,
      Owner,
      $$OwnersTableFilterComposer,
      $$OwnersTableOrderingComposer,
      $$OwnersTableAnnotationComposer,
      $$OwnersTableCreateCompanionBuilder,
      $$OwnersTableUpdateCompanionBuilder,
      (Owner, BaseReferences<_$AppDatabase, $OwnersTable, Owner>),
      Owner,
      PrefetchHooks Function()
    >;
typedef $$AssetsTableCreateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      required String symbol,
      required String name,
      required AssetType type,
      required String currency,
      Value<String> owner,
      Value<double?> dividendAmount,
      Value<String?> dividendMonths,
    });
typedef $$AssetsTableUpdateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      Value<String> symbol,
      Value<String> name,
      Value<AssetType> type,
      Value<String> currency,
      Value<String> owner,
      Value<double?> dividendAmount,
      Value<String?> dividendMonths,
    });

final class $$AssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetsTable, Asset> {
  $$AssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HoldingsTable, List<Holding>> _holdingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.holdings,
    aliasName: $_aliasNameGenerator(db.assets.id, db.holdings.assetId),
  );

  $$HoldingsTableProcessedTableManager get holdingsRefs {
    final manager = $$HoldingsTableTableManager(
      $_db,
      $_db.holdings,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AssetType, AssetType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dividendAmount => $composableBuilder(
    column: $table.dividendAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dividendMonths => $composableBuilder(
    column: $table.dividendMonths,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> holdingsRefs(
    Expression<bool> Function($$HoldingsTableFilterComposer f) f,
  ) {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dividendAmount => $composableBuilder(
    column: $table.dividendAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dividendMonths => $composableBuilder(
    column: $table.dividendMonths,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssetType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<double> get dividendAmount => $composableBuilder(
    column: $table.dividendAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dividendMonths => $composableBuilder(
    column: $table.dividendMonths,
    builder: (column) => column,
  );

  Expression<T> holdingsRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          Asset,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (Asset, $$AssetsTableReferences),
          Asset,
          PrefetchHooks Function({bool holdingsRefs})
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AssetType> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<double?> dividendAmount = const Value.absent(),
                Value<String?> dividendMonths = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                symbol: symbol,
                name: name,
                type: type,
                currency: currency,
                owner: owner,
                dividendAmount: dividendAmount,
                dividendMonths: dividendMonths,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String symbol,
                required String name,
                required AssetType type,
                required String currency,
                Value<String> owner = const Value.absent(),
                Value<double?> dividendAmount = const Value.absent(),
                Value<String?> dividendMonths = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                symbol: symbol,
                name: name,
                type: type,
                currency: currency,
                owner: owner,
                dividendAmount: dividendAmount,
                dividendMonths: dividendMonths,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AssetsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({holdingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (holdingsRefs) db.holdings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (holdingsRefs)
                    await $_getPrefetchedData<Asset, $AssetsTable, Holding>(
                      currentTable: table,
                      referencedTable: $$AssetsTableReferences
                          ._holdingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AssetsTableReferences(db, table, p0).holdingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.assetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      Asset,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (Asset, $$AssetsTableReferences),
      Asset,
      PrefetchHooks Function({bool holdingsRefs})
    >;
typedef $$HoldingsTableCreateCompanionBuilder =
    HoldingsCompanion Function({
      Value<int> id,
      required int assetId,
      required double quantity,
      required double averagePrice,
    });
typedef $$HoldingsTableUpdateCompanionBuilder =
    HoldingsCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<double> quantity,
      Value<double> averagePrice,
    });

final class $$HoldingsTableReferences
    extends BaseReferences<_$AppDatabase, $HoldingsTable, Holding> {
  $$HoldingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssetsTable _assetIdTable(_$AppDatabase db) => db.assets.createAlias(
    $_aliasNameGenerator(db.holdings.assetId, db.assets.id),
  );

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averagePrice => $composableBuilder(
    column: $table.averagePrice,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averagePrice => $composableBuilder(
    column: $table.averagePrice,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get averagePrice => $composableBuilder(
    column: $table.averagePrice,
    builder: (column) => column,
  );

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingsTable,
          Holding,
          $$HoldingsTableFilterComposer,
          $$HoldingsTableOrderingComposer,
          $$HoldingsTableAnnotationComposer,
          $$HoldingsTableCreateCompanionBuilder,
          $$HoldingsTableUpdateCompanionBuilder,
          (Holding, $$HoldingsTableReferences),
          Holding,
          PrefetchHooks Function({bool assetId})
        > {
  $$HoldingsTableTableManager(_$AppDatabase db, $HoldingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> averagePrice = const Value.absent(),
              }) => HoldingsCompanion(
                id: id,
                assetId: assetId,
                quantity: quantity,
                averagePrice: averagePrice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required double quantity,
                required double averagePrice,
              }) => HoldingsCompanion.insert(
                id: id,
                assetId: assetId,
                quantity: quantity,
                averagePrice: averagePrice,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HoldingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable: $$HoldingsTableReferences
                                    ._assetIdTable(db),
                                referencedColumn: $$HoldingsTableReferences
                                    ._assetIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$HoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingsTable,
      Holding,
      $$HoldingsTableFilterComposer,
      $$HoldingsTableOrderingComposer,
      $$HoldingsTableAnnotationComposer,
      $$HoldingsTableCreateCompanionBuilder,
      $$HoldingsTableUpdateCompanionBuilder,
      (Holding, $$HoldingsTableReferences),
      Holding,
      PrefetchHooks Function({bool assetId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OwnersTableTableManager get owners =>
      $$OwnersTableTableManager(_db, _db.owners);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$HoldingsTableTableManager get holdings =>
      $$HoldingsTableTableManager(_db, _db.holdings);
}
