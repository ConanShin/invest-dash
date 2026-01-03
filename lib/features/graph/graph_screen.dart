import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/local/database.dart';
import '../dashboard/widgets/asset_list.dart';
import '../portfolio/add_asset_screen.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          data: (state) {
            if (state.assets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 80,
                      color: Theme.of(context).primaryColor.withAlpha(50),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '등록된 자산이 없습니다',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          builder: (context) => const AddAssetScreen(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('첫 자산 등록하기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = _calculateTypeRatio(state.assets, state.exchangeRate);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '나의 자산',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(32),
                                  ),
                                ),
                                builder: (context) => const AddAssetScreen(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Pie Chart on the left
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 150,
                              child: PieChart(
                                PieChartData(
                                  sections: data.entries.map((e) {
                                    return PieChartSectionData(
                                      value: e.value,
                                      title: e.value > 15
                                          ? '${e.value.toStringAsFixed(0)}%'
                                          : '',
                                      radius: 40,
                                      titleStyle: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      color: _getColorForType(e.key),
                                    );
                                  }).toList(),
                                  centerSpaceRadius: 25,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Vertical Legend on the right
                          Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...data.entries.map((e) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getColorForType(e.key),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _getTypeName(e.key),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${e.value.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  AssetList(
                    assets: state.assets,
                    exchangeRate: state.exchangeRate,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
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
