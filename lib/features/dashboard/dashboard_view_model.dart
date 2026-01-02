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

    // Setup periodic refresh every 1 minute
    final timer = Timer.periodic(const Duration(minutes: 1), (t) {
      print('DEBUG: Periodic dashboard refresh triggered (1 min)');
      _fetchCurrentPrices();
    });
    ref.onDispose(() => timer.cancel());

    // 1. Get Exchange Rate (Cached or quick fetch)
    final exchangeRate = await stockService.getExchangeRate();

    // 2. Get Assets from DB
    final assetsWithHoldings = await repo.getAllAssets();

    if (assetsWithHoldings.isEmpty) {
      return DashboardState(
        totalValue: 0,
        assets: [],
        exchangeRate: exchangeRate,
      );
    }

    // 3. Create initial state with prices from DB (averagePrice)
    final List<DashboardAsset> initialDashboardAssets = [];
    for (final item in assetsWithHoldings) {
      List<int>? divMonths;
      if (item.asset.dividendMonths != null &&
          item.asset.dividendMonths!.isNotEmpty) {
        divMonths = item.asset.dividendMonths!
            .split(',')
            .map((e) => int.parse(e.trim()))
            .toList();
      }

      initialDashboardAssets.add(
        DashboardAsset(
          asset: item.asset,
          holding: item.holding,
          currentPrice: item.holding.averagePrice, // Start with avg price
          dividendAmount: item.asset.dividendAmount,
          dividendMonths: divMonths,
        ),
      );
    }

    final initialState = DashboardState(
      totalValue: _calculateTotal(initialDashboardAssets, exchangeRate),
      assets: _applySort(initialDashboardAssets),
      exchangeRate: exchangeRate,
    );

    // 4. Kick off incremental price fetch
    _fetchCurrentPrices();

    return initialState;
  }

  double _calculateTotal(List<DashboardAsset> assets, double exchangeRate) {
    return assets.fold(0.0, (sum, item) {
      double itemValue = item.totalValue;
      if (item.asset.currency == 'USD') {
        itemValue *= exchangeRate;
      }
      return sum + itemValue;
    });
  }

  List<DashboardAsset> _applySort(List<DashboardAsset> assets) {
    final sorted = List<DashboardAsset>.from(assets);
    sorted.sort((a, b) {
      final ownerCompare = a.asset.owner.compareTo(b.asset.owner);
      if (ownerCompare != 0) return ownerCompare;
      return a.asset.type.index.compareTo(b.asset.type.index);
    });
    return sorted;
  }

  Future<void> refresh() async {
    // Avoid setting loading state to keep UI interactive
    await _fetchCurrentPrices();
  }

  Future<void> _fetchCurrentPrices() async {
    final stockService = ref.read(stockServiceProvider);
    final currentState = state.value;
    if (currentState == null) return;

    final symbols = currentState.assets
        .where(
          (e) =>
              e.asset.type != AssetType.deposit &&
              e.asset.type != AssetType.fund &&
              !e.asset.symbol.startsWith('MANUAL_'),
        )
        .map((e) => e.asset.symbol)
        .toSet()
        .toList();

    for (final symbol in symbols) {
      try {
        final prices = await stockService.getPrices([symbol]);
        if (prices.containsKey(symbol)) {
          final newPrice = prices[symbol]!;
          _updateSinglePrice(symbol, newPrice);
        }
      } catch (e) {
        print('Error fetching incremental price for $symbol: $e');
      }
    }
  }

  void _updateSinglePrice(String symbol, double price) {
    final currentState = state.value;
    if (currentState == null) return;

    final newAssets = currentState.assets.map((da) {
      if (da.asset.symbol == symbol) {
        return DashboardAsset(
          asset: da.asset,
          holding: da.holding,
          currentPrice: price,
          dividendAmount: da.dividendAmount,
          dividendMonths: da.dividendMonths,
        );
      }
      return da;
    }).toList();

    state = AsyncData(
      DashboardState(
        totalValue: _calculateTotal(newAssets, currentState.exchangeRate),
        assets: _applySort(newAssets),
        exchangeRate: currentState.exchangeRate,
      ),
    );
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
    // Final refresh to get all data updated
    ref.invalidateSelf();
  }
}
