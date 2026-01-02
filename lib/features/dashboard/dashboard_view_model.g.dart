// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardViewModel)
final dashboardViewModelProvider = DashboardViewModelProvider._();

final class DashboardViewModelProvider
    extends $AsyncNotifierProvider<DashboardViewModel, DashboardState> {
  DashboardViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardViewModelHash();

  @$internal
  @override
  DashboardViewModel create() => DashboardViewModel();
}

String _$dashboardViewModelHash() =>
    r'f32c10a6bbf1583da52c09315c48bfd6f9ef5ddf';

abstract class _$DashboardViewModel extends $AsyncNotifier<DashboardState> {
  FutureOr<DashboardState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DashboardState>, DashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DashboardState>, DashboardState>,
              AsyncValue<DashboardState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
