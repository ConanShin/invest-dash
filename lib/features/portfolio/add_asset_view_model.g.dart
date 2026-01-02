// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_asset_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddAssetViewModel)
final addAssetViewModelProvider = AddAssetViewModelProvider._();

final class AddAssetViewModelProvider
    extends $AsyncNotifierProvider<AddAssetViewModel, void> {
  AddAssetViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAssetViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAssetViewModelHash();

  @$internal
  @override
  AddAssetViewModel create() => AddAssetViewModel();
}

String _$addAssetViewModelHash() => r'd97b54ed942f2be0692917bfa95441e40961045e';

abstract class _$AddAssetViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
