import 'dart:async';
import 'package:drift/drift.dart';

import '../../data/local/database.dart';

class AssetRepository {
  final AppDatabase _db;

  AssetRepository(this._db);

  // Get all assets with holdings
  Future<List<AssetWithHolding>> getAllAssets() async {
    final query = _db.select(_db.assets).join([
      innerJoin(_db.holdings, _db.holdings.assetId.equalsExp(_db.assets.id)),
    ]);

    final result = await query.get();

    return result.map((row) {
      return AssetWithHolding(
        asset: row.readTable(_db.assets),
        holding: row.readTable(_db.holdings),
      );
    }).toList();
  }

  // Get all owners
  Future<List<Owner>> getAllOwners() async {
    return _db.select(_db.owners).get();
  }

  // Add new owner
  Future<int> addOwner(String name) async {
    return _db.into(_db.owners).insert(OwnersCompanion(name: Value(name)));
  }

  // Update owner name
  Future<void> updateOwner(int id, String newName) async {
    await _db.transaction(() async {
      final oldOwner = await (_db.select(
        _db.owners,
      )..where((t) => t.id.equals(id))).getSingle();

      // Update assets first to maintain "consistency" (even if not strictly FK-tied yet)
      await (_db.update(_db.assets)
            ..where((t) => t.owner.equals(oldOwner.name)))
          .write(AssetsCompanion(owner: Value(newName)));

      // Update owner table
      await (_db.update(_db.owners)..where((t) => t.id.equals(id))).write(
        OwnersCompanion(name: Value(newName)),
      );
    });
  }

  // Delete owner
  Future<void> deleteOwner(int id) async {
    await _db.transaction(() async {
      final owner = await (_db.select(
        _db.owners,
      )..where((t) => t.id.equals(id))).getSingle();

      // Delete assets first
      final assetsToDelete = await (_db.select(
        _db.assets,
      )..where((t) => t.owner.equals(owner.name))).get();
      for (var asset in assetsToDelete) {
        await deleteAsset(asset.id);
      }

      // Delete owner
      await (_db.delete(_db.owners)..where((t) => t.id.equals(id))).go();
    });
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
      final asset =
          await (_db.select(_db.assets)
                ..where((t) => t.symbol.equals(symbol) & t.owner.equals(owner)))
              .getSingleOrNull();

      int assetId;
      if (asset == null) {
        assetId = await _db
            .into(_db.assets)
            .insert(
              AssetsCompanion(
                symbol: Value(symbol),
                name: Value(name),
                type: Value(type),
                currency: Value(currency),
                owner: Value(owner),
              ),
            );
      } else {
        assetId = asset.id;
      }

      await _db
          .into(_db.holdings)
          .insert(
            HoldingsCompanion(
              assetId: Value(assetId),
              quantity: Value(quantity),
              averagePrice: Value(averagePrice),
            ),
          );
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

      await (_db.update(
        _db.holdings,
      )..where((t) => t.assetId.equals(assetId))).write(
        HoldingsCompanion(
          quantity: Value(quantity),
          averagePrice: Value(averagePrice),
        ),
      );
    });
  }

  // Update dividend information
  Future<void> updateDividend({
    required int assetId,
    required double? amount,
    required String? months,
  }) async {
    await (_db.update(_db.assets)..where((t) => t.id.equals(assetId))).write(
      AssetsCompanion(
        dividendAmount: Value(amount),
        dividendMonths: Value(months),
      ),
    );
  }

  // Delete asset
  Future<void> deleteAsset(int assetId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.holdings,
      )..where((t) => t.assetId.equals(assetId))).go();
      await (_db.delete(_db.assets)..where((t) => t.id.equals(assetId))).go();
    });
  }

  // Replace all data with imported data
  Future<void> replaceAllData(Map<String, dynamic> data) async {
    await _db.transaction(() async {
      // 1. Clear existing data
      await _db.delete(_db.holdings).go();
      await _db.delete(_db.assets).go();
      await _db.delete(_db.owners).go();

      // 2. Insert owners
      final List<dynamic> ownerList = data['owners'] ?? [];
      for (var ownerName in ownerList) {
        await _db
            .into(_db.owners)
            .insert(OwnersCompanion(name: Value(ownerName as String)));
      }

      // 3. Insert assets and holdings
      final List<dynamic> assetList = data['assets'] ?? [];
      for (var item in assetList) {
        final assetJson = item['asset'];
        final holdingJson = item['holding'];

        final typeName = assetJson['type'] as String;
        final type = AssetType.values.firstWhere(
          (e) => e.name == typeName,
          orElse: () => AssetType.domesticStock,
        );

        final assetId = await _db
            .into(_db.assets)
            .insert(
              AssetsCompanion(
                symbol: Value(assetJson['symbol']),
                name: Value(assetJson['name']),
                type: Value(type),
                currency: Value(assetJson['currency']),
                owner: Value(assetJson['owner']),
                dividendAmount: Value(assetJson['dividendAmount']?.toDouble()),
                dividendMonths: Value(assetJson['dividendMonths']),
              ),
            );

        await _db
            .into(_db.holdings)
            .insert(
              HoldingsCompanion(
                assetId: Value(assetId),
                quantity: Value((holdingJson['quantity'] as num).toDouble()),
                averagePrice: Value(
                  (holdingJson['averagePrice'] as num).toDouble(),
                ),
              ),
            );
      }
    });
  }
}

class AssetWithHolding {
  final Asset asset;
  final Holding holding;

  AssetWithHolding({required this.asset, required this.holding});
}
