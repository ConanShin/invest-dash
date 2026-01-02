import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/local/database.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('자산 비중')),
      body: dashboardAsync.when(
        data: (state) {
          if (state.assets.isEmpty) {
            return const Center(child: Text('표시할 데이터가 없습니다.'));
          }

          final data = _calculateTypeRatio(state.assets, state.exchangeRate);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.map((e) {
                        return PieChartSectionData(
                          value: e.value,
                          title:
                              '${_getTypeName(e.key)}\n${e.value.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          color: _getColorForType(e.key),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    children: data.entries.map((e) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForType(e.key),
                        ),
                        title: Text(_getTypeName(e.key)),
                        trailing: Text('${e.value.toStringAsFixed(1)}%'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Map<AssetType, double> _calculateTypeRatio(
    List<DashboardAsset> assets,
    double exchangeRate,
  ) {
    final Map<AssetType, double> totals = {};
    double grandTotal = 0;

    for (var a in assets) {
      double value = a.totalValue;
      if (a.asset.currency == 'USD') {
        value *= exchangeRate;
      }
      totals[a.asset.type] = (totals[a.asset.type] ?? 0) + value;
      grandTotal += value;
    }

    if (grandTotal == 0) return {};

    return totals.map(
      (key, value) => MapEntry(key, (value / grandTotal) * 100),
    );
  }

  Color _getColorForType(AssetType type) {
    switch (type) {
      case AssetType.domesticStock:
        return Colors.blue;
      case AssetType.usStock:
        return Colors.red;
      case AssetType.etf:
        return Colors.green;
      case AssetType.deposit:
        return Colors.orange;
      case AssetType.fund:
        return Colors.purple;
    }
  }

  String _getTypeName(AssetType type) {
    switch (type) {
      case AssetType.domesticStock:
        return '국내주식';
      case AssetType.usStock:
        return '미국주식';
      case AssetType.etf:
        return 'ETF';
      case AssetType.deposit:
        return '예금';
      case AssetType.fund:
        return '펀드';
    }
  }
}
