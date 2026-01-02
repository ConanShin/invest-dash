import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../../data/repository/asset_repository.dart';
import '../../../data/local/database.dart'; // for AssetType
import '../../../core/providers/data_providers.dart';

part 'add_asset_view_model.g.dart';

@riverpod
class AddAssetViewModel extends _$AddAssetViewModel {
  @override
  FutureOr<void> build() {
    // nothing to initialize
  }

  Future<void> addAsset({
    required String symbol,
    required String name,
    required AssetType type,
    required String currency,
    required double quantity,
    required double averagePrice,
    required String owner,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(assetRepositoryProvider);
      await repo.addAsset(
        symbol: symbol,
        name: name,
        type: type,
        currency: currency,
        quantity: quantity,
        averagePrice: averagePrice,
        owner: owner,
      );
    });
  }

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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(assetRepositoryProvider);
      await repo.updateAsset(
        assetId: assetId,
        symbol: symbol,
        name: name,
        type: type,
        currency: currency,
        quantity: quantity,
        averagePrice: averagePrice,
        owner: owner,
      );
    });
  }

  Future<void> deleteAsset(int assetId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(assetRepositoryProvider);
      await repo.deleteAsset(assetId);
    });
  }
}
