// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund_search_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fundSearchService)
final fundSearchServiceProvider = FundSearchServiceProvider._();

final class FundSearchServiceProvider
    extends
        $FunctionalProvider<
          FundSearchService,
          FundSearchService,
          FundSearchService
        >
    with $Provider<FundSearchService> {
  FundSearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fundSearchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fundSearchServiceHash();

  @$internal
  @override
  $ProviderElement<FundSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FundSearchService create(Ref ref) {
    return fundSearchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FundSearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FundSearchService>(value),
    );
  }
}

String _$fundSearchServiceHash() => r'2ff05e736d460d38a9ec5ac2b593e3a89743473c';
