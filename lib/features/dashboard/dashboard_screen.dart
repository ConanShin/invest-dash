import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_view_model.dart';
import 'widgets/asset_list.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invest Dash',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
              onPressed: () => Navigator.pushNamed(context, '/add_asset'),
            ),
          ),
        ],
      ),
      body: assetsAsync.when(
        data: (dashboardState) {
          final totalValue = dashboardState.totalValue;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SummaryCard(totalValue: totalValue),
              ),
              Expanded(
                child: AssetList(
                  assets: dashboardState.assets,
                  exchangeRate: dashboardState.exchangeRate,
                ),
              ),
            ],
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
    );
  }
}
