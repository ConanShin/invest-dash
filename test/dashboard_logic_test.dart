import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:invest_dash/features/dashboard/dashboard_view_model.dart';
import 'package:invest_dash/data/repository/asset_repository.dart';
import 'package:invest_dash/core/services/stock_service.dart';
import 'package:invest_dash/core/providers/data_providers.dart';
import 'package:invest_dash/data/local/database.dart';

// Manual mock to be safer against generation quirks during this phase
class ManualMockAssetRepository extends Mock implements AssetRepository {
  @override
  Future<List<AssetWithHolding>> getAllAssets() => super.noSuchMethod(
        Invocation.method(#getAllAssets, []),
        returnValue: Future.value(<AssetWithHolding>[]),
      );
}

class ManualMockStockService extends Mock implements StockService {
  @override
  Future<Map<String, double>> getPrices(List<String>? symbols) =>
      super.noSuchMethod(
        Invocation.method(#getPrices, [symbols]),
        returnValue: Future.value(<String, double>{}),
      );

  @override
  Future<double> getExchangeRate() => super.noSuchMethod(
        Invocation.method(#getExchangeRate, []),
        returnValue: Future.value(1300.0),
      );
}

void main() {
  test(
      'DashboardViewModel calculates total value correctly with currency conversion',
      () async {
    final mockRepo = ManualMockAssetRepository();
    final mockStockService = ManualMockStockService();

    final container = ProviderContainer(
      overrides: [
        assetRepositoryProvider.overrideWithValue(mockRepo),
        stockServiceProvider.overrideWithValue(mockStockService),
      ],
    );
    addTearDown(container.dispose);

    final testAssets = [
      AssetWithHolding(
        asset: Asset(
            id: 1,
            symbol: 'AAPL',
            name: 'Apple',
            type: AssetType.usStock,
            currency: 'USD',
            owner: '신철민'),
        holding: Holding(id: 1, assetId: 1, quantity: 10, averagePrice: 150),
      ),
    ];

    when(mockRepo.getAllAssets()).thenAnswer((_) async => testAssets);
    when(mockStockService.getPrices(any))
        .thenAnswer((_) async => {'AAPL': 200.0});
    when(mockStockService.getExchangeRate()).thenAnswer((_) async => 1300.0);

    // Act
    final state = await container.read(dashboardViewModelProvider.future);

    // Assert
    // Total Value should be (10 qty * 200 price) * 1300 rate = 2,600,000
    expect(state.totalValue, 2600000.0);
    expect(state.assets.first.currentPrice, 200.0);
    expect(state.exchangeRate, 1300.0);
    expect(state.exchangeRate, 1300.0);
  });

  test(
      'DashboardViewModel calculates Deposit correctly (TotalValue = Principal)',
      () async {
    final mockRepo = ManualMockAssetRepository();
    final mockStockService = ManualMockStockService();

    final container = ProviderContainer(
      overrides: [
        assetRepositoryProvider.overrideWithValue(mockRepo),
        stockServiceProvider.overrideWithValue(mockStockService),
      ],
    );
    addTearDown(container.dispose);

    final testAssets = [
      AssetWithHolding(
        asset: Asset(
            id: 2,
            symbol: 'KB',
            name: 'KB Deposit',
            type: AssetType.deposit,
            currency: 'KRW',
            owner: '신철민'),
        holding: Holding(
            id: 2,
            assetId: 2,
            quantity: 3.5,
            averagePrice: 10000), // 3.5% rate, 10000 principal
      ),
    ];

    when(mockRepo.getAllAssets()).thenAnswer((_) async => testAssets);
    when(mockStockService.getPrices(any))
        .thenAnswer((_) async => {}); // No prices for deposit
    when(mockStockService.getExchangeRate()).thenAnswer((_) async => 1300.0);

    // Act
    final state = await container.read(dashboardViewModelProvider.future);

    // Assert
    // Total Value should be 10000 (Principal only)
    expect(state.totalValue, 10000.0);
    expect(state.assets.first.totalValue, 10000.0);
  });

  test(
      'DashboardViewModel calculates Fund correctly (TotalValue = Quantity * AvgPrice, No API fetch)',
      () async {
    final mockRepo = ManualMockAssetRepository();
    final mockStockService = ManualMockStockService();

    final container = ProviderContainer(
      overrides: [
        assetRepositoryProvider.overrideWithValue(mockRepo),
        stockServiceProvider.overrideWithValue(mockStockService),
      ],
    );
    addTearDown(container.dispose);

    final testAssets = [
      AssetWithHolding(
        asset: Asset(
            id: 3,
            symbol: 'MANUAL_KB_BOND',
            name: 'KB Bond Fund',
            type: AssetType.fund,
            currency: 'KRW',
            owner: '신철민'),
        holding: Holding(
            id: 3,
            assetId: 3,
            quantity: 1000,
            averagePrice: 1.5), // 1000 units * 1.5 price = 1500 value
      ),
    ];

    when(mockRepo.getAllAssets()).thenAnswer((_) async => testAssets);
    when(mockStockService.getPrices(any))
        .thenAnswer((_) async => {}); // No prices for fund
    when(mockStockService.getExchangeRate()).thenAnswer((_) async => 1300.0);

    // Act
    final state = await container.read(dashboardViewModelProvider.future);

    // Assert
    expect(state.totalValue, 1500.0);
    expect(state.assets.first.currentPrice, 1.5); // Fallback to avgPrice
  });
}
