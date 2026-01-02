// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_search_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stockSearchService)
final stockSearchServiceProvider = StockSearchServiceProvider._();

final class StockSearchServiceProvider
    extends
        $FunctionalProvider<
          StockSearchService,
          StockSearchService,
          StockSearchService
        >
    with $Provider<StockSearchService> {
  StockSearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockSearchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockSearchServiceHash();

  @$internal
  @override
  $ProviderElement<StockSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StockSearchService create(Ref ref) {
    return stockSearchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StockSearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StockSearchService>(value),
    );
  }
}

String _$stockSearchServiceHash() =>
    r'93eead0ce601ebc85e86c032c0f92bba90132897';
