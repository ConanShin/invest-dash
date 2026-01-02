import 'dart:async';
import 'package:drift/drift.dart';

import '../../data/local/database.dart';

class AssetRepository {
  final AppDatabase _db;

  AssetRepository(this._db);

  // Get all assets with holdings
  Future<List<AssetWithHolding>> getAllAssets() async {
    final query = _db.select(_db.assets).join([
      innerJoin(
        _db.holdings,
        _db.holdings.assetId.equalsExp(_db.assets.id),
      ),
    ]);

    final result = await query.get();

    return result.map((row) {
      return AssetWithHolding(
        asset: row.readTable(_db.assets),
        holding: row.readTable(_db.holdings),
      );
    }).toList();
  }

  // Add new asset and holding
  Future<void> addAsset({
    required String symbol,
    required String name,
    required AssetType type,
    required String currency,
    required double quantity,
    required double averagePrice,
    required String owner,
  }) async {
    await _db.transaction(() async {
      // Check if asset exists for this owner
      final asset = await (_db.select(_db.assets)
            ..where((t) => t.symbol.equals(symbol) & t.owner.equals(owner)))
          .getSingleOrNull();

      int assetId;
      if (asset == null) {
        assetId = await _db.into(_db.assets).insert(AssetsCompanion(
              symbol: Value(symbol),
              name: Value(name),
              type: Value(type),
              currency: Value(currency),
              owner: Value(owner),
            ));
      } else {
        assetId = asset.id;
      }

      await _db.into(_db.holdings).insert(HoldingsCompanion(
            assetId: Value(assetId),
            quantity: Value(quantity),
            averagePrice: Value(averagePrice),
          ));
    });
  }

  // Update asset and holding
  Future<void> updateAsset({
    required int assetId,
    required String symbol,
    required String name,
    required AssetType type,
    required String currency,
    required double quantity,
    required double averagePrice,
    required String owner,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.assets)..where((t) => t.id.equals(assetId))).write(
        AssetsCompanion(
          symbol: Value(symbol),
          name: Value(name),
          type: Value(type),
          currency: Value(currency),
          owner: Value(owner),
        ),
      );

      await (_db.update(_db.holdings)..where((t) => t.assetId.equals(assetId)))
          .write(
        HoldingsCompanion(
          quantity: Value(quantity),
          averagePrice: Value(averagePrice),
        ),
      );
    });
  }

  // Delete asset
  Future<void> deleteAsset(int assetId) async {
    await _db.transaction(() async {
      // Drift should handle cascade delete if configured, but let's be safe if it's not
      await (_db.delete(_db.holdings)..where((t) => t.assetId.equals(assetId)))
          .go();
      await (_db.delete(_db.assets)..where((t) => t.id.equals(assetId))).go();
    });
  }
}

class AssetWithHolding {
  final Asset asset;
  final Holding holding;

  AssetWithHolding({required this.asset, required this.holding});
}
