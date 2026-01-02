import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repository/asset_repository.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/services/stock_service.dart';
import '../../../data/local/database.dart';

part 'dashboard_view_model.g.dart';

class DashboardAsset {
  final Asset asset;
  final Holding holding;
  final double currentPrice;
  final double totalValue;

  DashboardAsset({
    required this.asset,
    required this.holding,
    required this.currentPrice,
  }) : totalValue = asset.type == AssetType.deposit
            ? holding
                .averagePrice // For deposit, avgPrice is the Principal Amount
            : holding.quantity * currentPrice;
}

class DashboardState {
  final double totalValue;
  final List<DashboardAsset> assets;
  final double exchangeRate;

  DashboardState({
    required this.totalValue,
    required this.assets,
    required this.exchangeRate,
  });
}

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  Future<DashboardState> build() async {
    final repo = ref.watch(assetRepositoryProvider);
    final stockService = ref.watch(stockServiceProvider);

    // 1. Get Exchange Rate
    final exchangeRate = await stockService.getExchangeRate();

    // 2. Get Assets
    final assetsWithHoldings = await repo.getAllAssets();

    if (assetsWithHoldings.isEmpty) {
      return DashboardState(
          totalValue: 0, assets: [], exchangeRate: exchangeRate);
    }

    // 3. Get Prices
    final symbols = assetsWithHoldings
        .where((e) =>
            e.asset.type != AssetType.deposit &&
            e.asset.type != AssetType.fund &&
            !e.asset.symbol.startsWith('MANUAL_'))
        .map((e) => e.asset.symbol)
        .toList();
    final prices = await stockService.getPrices(symbols);

    // 4. Map to DashboardAsset
    final dashboardAssets = assetsWithHoldings.map((item) {
      final currentPrice =
          prices[item.asset.symbol] ?? item.holding.averagePrice;
      return DashboardAsset(
        asset: item.asset,
        holding: item.holding,
        currentPrice: currentPrice,
      );
    }).toList();

    // 5. Calculate Total (in KRW)
    final totalValue = dashboardAssets.fold(0.0, (sum, item) {
      double itemValue = item.totalValue;
      if (item.asset.currency == 'USD') {
        itemValue *= exchangeRate;
      }
      return sum + itemValue;
    });

    // Sort: Owner (Sincheolmin, Chaejiseon, Sinbi) -> Type
    dashboardAssets.sort((a, b) {
      final ownerCompare = a.asset.owner.compareTo(b.asset.owner);
      if (ownerCompare != 0) return ownerCompare;
      return a.asset.type.index.compareTo(b.asset.type.index);
    });

    return DashboardState(
        totalValue: totalValue,
        assets: dashboardAssets,
        exchangeRate: exchangeRate);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}
