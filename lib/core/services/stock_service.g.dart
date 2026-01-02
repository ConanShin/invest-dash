// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stockService)
final stockServiceProvider = StockServiceProvider._();

final class StockServiceProvider
    extends $FunctionalProvider<StockService, StockService, StockService>
    with $Provider<StockService> {
  StockServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockServiceHash();

  @$internal
  @override
  $ProviderElement<StockService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StockService create(Ref ref) {
    return stockService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StockService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StockService>(value),
    );
  }
}

String _$stockServiceHash() => r'861e4bf0562132cd658e30987133cea2bcc9b22c';
