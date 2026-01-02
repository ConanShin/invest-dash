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
        title: const Text('투자 대시보드'), // Localized
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to Add Asset Screen
              Navigator.pushNamed(context, '/add_asset');
            },
          ),
        ],
      ),
      body: assetsAsync.when(
        data: (dashboardState) {
          final totalValue = dashboardState.totalValue;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SummaryCard(totalValue: totalValue),
                const SizedBox(height: 16),
                const Text(
                  '포트폴리오', // Localized
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                    child: AssetList(
                        assets: dashboardState.assets,
                        exchangeRate: dashboardState.exchangeRate)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
