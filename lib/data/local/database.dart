import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

enum AssetType {
  domesticStock, // KR Stock
  usStock, // US Stock
  etf, // ETF
  deposit, // Bank Deposit
  fund, // Private Fund
}

class Owners extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()(); // Owner name must be unique
}

class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get symbol => text()(); // e.g., AAPL, 005930
  TextColumn get name => text()();
  TextColumn get type => textEnum<AssetType>()(); // Stored as string
  TextColumn get currency => text()(); // KRW, USD
  TextColumn get owner =>
      text().withDefault(const Constant('신철민'))(); // Owner name
  RealColumn get dividendAmount => real().nullable()(); // Annual div per share
  TextColumn get dividendMonths => text().nullable()(); // e.g. "1,4,7,10"
}

class Holdings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId => integer().references(Assets, #id)();
  RealColumn get quantity => real()();
  RealColumn get averagePrice => real()();
}

@DriftDatabase(tables: [Owners, Assets, Holdings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(assets, assets.owner);
        }
        if (from < 3) {
          await _migrateToVersion3(m);
        }
        if (from < 4) {
          await m.addColumn(assets, assets.dividendAmount);
          await m.addColumn(assets, assets.dividendMonths);
        }
        if (from < 5) {
          await m.createTable(owners);
          // Pre-populate owners from existing assets
          await customStatement('''
            INSERT OR IGNORE INTO owners (name)
            SELECT DISTINCT owner FROM assets;
          ''');
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _migrateToVersion3(Migrator m) async {
    await customStatement('PRAGMA foreign_keys = OFF');

    try {
      // Clean up potentially leftover tables from failed previous runs
      await customStatement('DROP TABLE IF EXISTS assets_old');
      await customStatement('DROP TABLE IF EXISTS holdings_old');

      await customStatement('ALTER TABLE assets RENAME TO assets_old');
      await customStatement('ALTER TABLE holdings RENAME TO holdings_old');

      // Create new tables with current definition (which has no UNIQUE on symbol)
      await m.createTable(assets);
      await m.createTable(holdings);

      // Copy data with INSERT OR REPLACE to avoid ID conflicts
      await customStatement(
        "INSERT OR REPLACE INTO assets (id, symbol, name, type, currency, owner) "
        "SELECT id, symbol, name, type, currency, COALESCE(owner, '신철민') FROM assets_old",
      );

      await customStatement(
        "INSERT OR REPLACE INTO holdings (id, asset_id, quantity, average_price) "
        "SELECT id, asset_id, quantity, average_price FROM holdings_old",
      );

      // Fix Auto-Increment Sequence
      await customStatement(
        "UPDATE sqlite_sequence SET seq = (SELECT MAX(id) FROM assets) WHERE name = 'assets'",
      );
      await customStatement(
        "UPDATE sqlite_sequence SET seq = (SELECT MAX(id) FROM holdings) WHERE name = 'holdings'",
      );

      await customStatement('DROP TABLE assets_old');
      await customStatement('DROP TABLE holdings_old');
    } catch (e) {
      print('Migration Error: $e');
      rethrow;
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
