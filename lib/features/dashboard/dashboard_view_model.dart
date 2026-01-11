import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/fund_search_service.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/services/stock_service.dart';
import '../../../data/local/database.dart';

part 'dashboard_view_model.g.dart';

class WeatherRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void trigger() => state++;
}

final weatherRefreshTriggerProvider =
    NotifierProvider<WeatherRefreshNotifier, int>(WeatherRefreshNotifier.new);

class DashboardAsset {
  final Asset asset;
  final Holding holding;
  final double currentPrice;
  final double previousClose;
  final double totalValue;
  final double? dividendAmount;
  final List<int>? dividendMonths;

  DashboardAsset({
    required this.asset,
    required this.holding,
    required this.currentPrice,
    required this.previousClose,
    this.dividendAmount,
    this.dividendMonths,
  }) : totalValue = asset.type == AssetType.deposit
           ? holding.averagePrice
           : holding.quantity * currentPrice;

  double get priceChange => currentPrice - previousClose;
  double get priceChangePercent =>
      previousClose > 0 ? (priceChange / previousClose) * 100 : 0;

  double get annualDividendValue => (dividendAmount ?? 0) * holding.quantity;
}

class DashboardState {
  final double totalValue;
  final List<DashboardAsset> assets;
  final double exchangeRate;
  final List<DashboardAsset> topGainers;
  final List<DashboardAsset> topLosers;

  DashboardState({
    required this.totalValue,
    required this.assets,
    required this.exchangeRate,
    this.topGainers = const [],
    this.topLosers = const [],
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
      _fetchCurrentPrices();
    });
    ref.onDispose(() => timer.cancel());

    final exchangeRate = await stockService.getExchangeRate();
    final assetsWithHoldings = await repo.getAllAssets();

    if (assetsWithHoldings.isEmpty) {
      return DashboardState(
        totalValue: 0,
        assets: [],
        exchangeRate: exchangeRate,
      );
    }

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

      final isPriceFetchable =
          item.asset.type != AssetType.deposit &&
          !item.asset.symbol.startsWith('MANUAL_');

      initialDashboardAssets.add(
        DashboardAsset(
          asset: item.asset,
          holding: item.holding,
          currentPrice: isPriceFetchable ? 0.0 : item.holding.averagePrice,
          previousClose: isPriceFetchable ? 0.0 : item.holding.averagePrice,
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

    // Fetch prices in next microtask so that 'state.value' is available
    Future.microtask(() => _fetchCurrentPrices());

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
    print('DEBUG: Manual Refresh Started');
    ref.read(weatherRefreshTriggerProvider.notifier).trigger();
    ref.invalidateSelf();
    await future;
    await _fetchCurrentPrices();
    print('DEBUG: Manual Refresh Completed');
  }

  Future<void> _fetchCurrentPrices() async {
    final stockService = ref.read(stockServiceProvider);
    final fundService = ref.read(fundSearchServiceProvider);
    final currentState = state.value;
    if (currentState == null) return;

    final fetchableAssets = currentState.assets.where(
      (e) =>
          e.asset.type != AssetType.deposit &&
          !e.asset.symbol.startsWith('MANUAL_') &&
          e.asset.symbol.isNotEmpty,
    );

    final stockSymbols = fetchableAssets
        .where((e) => e.asset.type != AssetType.fund)
        .map((e) => e.asset.symbol)
        .toSet()
        .toList();

    final fundSymbols = fetchableAssets
        .where((e) => e.asset.type == AssetType.fund)
        .map((e) => e.asset.symbol)
        .toSet()
        .toList();

    if (stockSymbols.isEmpty && fundSymbols.isEmpty) return;

    try {
      final results = await Future.wait([
        if (stockSymbols.isNotEmpty) stockService.getPrices(stockSymbols),
        if (fundSymbols.isNotEmpty)
          _getFundPrices(fundService, fundSymbols)
        else
          Future.value(<String, StockPriceData>{}),
      ]);

      final Map<String, StockPriceData> allPrices = {};
      for (final result in results) {
        allPrices.addAll(result);
      }

      _updateAllPrices(allPrices);
    } catch (e) {
      print('Error fetching batched prices: $e');
      _updateAllPrices({}); // Trigger fallback to average price on error
    }
  }

  Future<Map<String, StockPriceData>> _getFundPrices(
    FundSearchService fundService,
    List<String> symbols,
  ) async {
    final Map<String, StockPriceData> fundPrices = {};
    final results = await Future.wait(
      symbols.map((symbol) async {
        final price = await fundService.getLatestPrice(symbol);
        if (price != null) return MapEntry(symbol, price);
        return null;
      }),
    );

    for (var result in results) {
      if (result != null) fundPrices[result.key] = result.value;
    }
    return fundPrices;
  }

  void _updateAllPrices(Map<String, StockPriceData> allPrices) {
    final currentState = state.value;
    if (currentState == null) return;

    final Map<String, StockPriceData> normalizedPrices = allPrices.map(
      (key, value) => MapEntry(key.toUpperCase(), value),
    );

    final newAssets = currentState.assets.map((da) {
      final normalizedSymbol = da.asset.symbol.toUpperCase();
      if (normalizedPrices.containsKey(normalizedSymbol)) {
        final priceData = normalizedPrices[normalizedSymbol]!;
        print(
          'DEBUG: [Match Success] ${da.asset.symbol} -> Market Price: ${priceData.currentPrice}',
        );
        return DashboardAsset(
          asset: da.asset,
          holding: da.holding,
          currentPrice: priceData.currentPrice,
          previousClose: priceData.previousClose,
          dividendAmount: da.dividendAmount,
          dividendMonths: da.dividendMonths,
        );
      } else if (da.currentPrice == 0.0) {
        print(
          'DEBUG: [Match Fallback] ${da.asset.symbol} -> Using Avg Price: ${da.holding.averagePrice}',
        );
        return DashboardAsset(
          asset: da.asset,
          holding: da.holding,
          currentPrice: da.holding.averagePrice,
          previousClose: da.holding.averagePrice,
          dividendAmount: da.dividendAmount,
          dividendMonths: da.dividendMonths,
        );
      }
      return da;
    }).toList();

    final fetchableAssets = newAssets
        .where(
          (e) =>
              e.asset.type != AssetType.deposit &&
              !e.asset.symbol.startsWith('MANUAL_'),
        )
        .toList();

    final sortedByChange = List<DashboardAsset>.from(fetchableAssets)
      ..sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));

    final topGainers = sortedByChange
        .where((e) => e.priceChangePercent > 0)
        .take(3)
        .toList();
    final topLosers = sortedByChange.reversed
        .where((e) => e.priceChangePercent < 0)
        .take(3)
        .toList();

    state = AsyncData(
      DashboardState(
        totalValue: _calculateTotal(newAssets, currentState.exchangeRate),
        assets: _applySort(newAssets),
        exchangeRate: currentState.exchangeRate,
        topGainers: topGainers,
        topLosers: topLosers,
      ),
    );
  }

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
