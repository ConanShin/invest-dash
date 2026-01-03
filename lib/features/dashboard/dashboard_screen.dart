import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_view_model.dart';
import 'widgets/compact_asset_list.dart';
import 'widgets/summary_card.dart';
import 'widgets/weather_widget.dart';
import 'widgets/price_change_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: assetsAsync.when(
          data: (dashboardState) {
            final totalValue = dashboardState.totalValue;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SummaryCard(totalValue: totalValue),
                  ),
                  const WeatherWidget(),
                  const SizedBox(height: 8),
                  CompactAssetList(
                    assets: dashboardState.assets,
                    exchangeRate: dashboardState.exchangeRate,
                  ),
                  PriceChangeList(
                    gainers: dashboardState.topGainers,
                    losers: dashboardState.topLosers,
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('오류가 발생했습니다: $err'),
                TextButton(
                  onPressed: () => ref.invalidate(dashboardViewModelProvider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
