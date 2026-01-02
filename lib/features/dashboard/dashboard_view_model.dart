import 'dart:async';
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
  final double? dividendAmount;
  final List<int>? dividendMonths;

  DashboardAsset({
    required this.asset,
    required this.holding,
    required this.currentPrice,
    this.dividendAmount,
    this.dividendMonths,
  }) : totalValue = asset.type == AssetType.deposit
           ? holding.averagePrice
           : holding.quantity * currentPrice;

  double get annualDividendValue => (dividendAmount ?? 0) * holding.quantity;
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

    // Setup periodic refresh every 10 minutes
    final timer = Timer.periodic(const Duration(minutes: 10), (t) {
      print('DEBUG: Periodic dashboard refresh triggered (10 min)');
      ref.invalidateSelf();
    });
    ref.onDispose(() => timer.cancel());

    // 1. Get Exchange Rate
    final exchangeRate = await stockService.getExchangeRate();

    // 2. Get Assets
    final assetsWithHoldings = await repo.getAllAssets();

    if (assetsWithHoldings.isEmpty) {
      return DashboardState(
        totalValue: 0,
        assets: [],
        exchangeRate: exchangeRate,
      );
    }

    // 3. Get Prices
    final symbols = assetsWithHoldings
        .where(
          (e) =>
              e.asset.type != AssetType.deposit &&
              e.asset.type != AssetType.fund &&
              !e.asset.symbol.startsWith('MANUAL_'),
        )
        .map((e) => e.asset.symbol)
        .toList();
    final prices = await stockService.getPrices(symbols);

    // 4. Map to DashboardAsset
    final List<DashboardAsset> dashboardAssets = [];
    for (final item in assetsWithHoldings) {
      final currentPrice =
          prices[item.asset.symbol] ?? item.holding.averagePrice;

      List<int>? divMonths;
      if (item.asset.dividendMonths != null &&
          item.asset.dividendMonths!.isNotEmpty) {
        divMonths = item.asset.dividendMonths!
            .split(',')
            .map((e) => int.parse(e.trim()))
            .toList();
      }

      dashboardAssets.add(
        DashboardAsset(
          asset: item.asset,
          holding: item.holding,
          currentPrice: currentPrice,
          dividendAmount: item.asset.dividendAmount,
          dividendMonths: divMonths,
        ),
      );
    }

    // 5. Calculate Total (in KRW)
    final totalValue = dashboardAssets.fold(0.0, (sum, item) {
      double itemValue = item.totalValue;
      if (item.asset.currency == 'USD') {
        itemValue *= exchangeRate;
      }
      return sum + itemValue;
    });

    // Sort: Owner -> Type
    dashboardAssets.sort((a, b) {
      final ownerCompare = a.asset.owner.compareTo(b.asset.owner);
      if (ownerCompare != 0) return ownerCompare;
      return a.asset.type.index.compareTo(b.asset.type.index);
    });

    return DashboardState(
      totalValue: totalValue,
      assets: dashboardAssets,
      exchangeRate: exchangeRate,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }

  // New method to fetch and update dividends for all assets
  Future<void> updateAllDividends() async {
    final stockService = ref.read(stockServiceProvider);
    final repo = ref.read(assetRepositoryProvider);
    final currentAssets = state.value?.assets ?? [];

    for (final da in currentAssets) {
      if (da.asset.type == AssetType.deposit || da.asset.type == AssetType.fund)
        continue;

      final divInfo = await stockService.getDividendInfo(da.asset.symbol);
      if (divInfo != null) {
        final monthsStr = divInfo.months?.join(',');
        // Update DB via Repository
        await repo.updateDividend(
          assetId: da.asset.id,
          amount: divInfo.annualAmount,
          months: monthsStr,
        );
      }
    }
    ref.invalidateSelf();
  }
}
