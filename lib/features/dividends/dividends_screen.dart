import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../dashboard/dashboard_view_model.dart';

class DividendsScreen extends ConsumerWidget {
  const DividendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardViewModelProvider);
    final currencyFormatter = NumberFormat.currency(
      symbol: '₩',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('월별 예상 배당금'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(dashboardViewModelProvider.notifier)
                .updateAllDividends(),
            tooltip: '배당 정보 업데이트',
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (state) {
          final monthlyDividends = _calculateMonthlyDividends(
            state.assets,
            state.exchangeRate,
          );
          final annualTotal = monthlyDividends.values.fold(
            0.0,
            (sum, val) => sum + val,
          );

          if (annualTotal == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('배당 정보가 없거나 자산이 없습니다.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(dashboardViewModelProvider.notifier)
                        .updateAllDividends(),
                    child: const Text('배당 정보 불러오기'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(annualTotal, currencyFormatter),
                const SizedBox(height: 24),
                const Text(
                  '월별 배당금 추정치',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildMonthlyList(monthlyDividends, currencyFormatter),
                const SizedBox(height: 24),
                _buildAssetDividendList(
                  state.assets,
                  state.exchangeRate,
                  currencyFormatter,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(double annualTotal, NumberFormat formatter) {
    return Card(
      elevation: 0,
      color: Colors.indigo.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '연간 예상 총 배당금',
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(annualTotal),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '월 평균: ${formatter.format(annualTotal / 12)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyList(Map<int, double> data, NumberFormat formatter) {
    return Column(
      children: List.generate(12, (index) {
        final month = index + 1;
        final amount = data[month] ?? 0;
        final isCurrentMonth = DateTime.now().month == month;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isCurrentMonth ? Colors.indigo.withAlpha(10) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentMonth ? Colors.indigo : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Text(
                '${month}월',
                style: TextStyle(
                  fontWeight: isCurrentMonth
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: amount == 0
                      ? 0
                      : amount / data.values.fold(1.0, (m, v) => m > v ? m : v),
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCurrentMonth
                        ? Colors.indigo
                        : Colors.indigo.withAlpha(100),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatter.format(amount),
                style: TextStyle(
                  fontWeight: isCurrentMonth
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: amount > 0 ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAssetDividendList(
    List<DashboardAsset> assets,
    double exchangeRate,
    NumberFormat formatter,
  ) {
    final dividendAssets = assets
        .where((a) => (a.dividendAmount ?? 0) > 0)
        .toList();
    if (dividendAssets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '자산별 배당 수익 (연간)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...dividendAssets.map((a) {
          double annualValue = a.annualDividendValue;
          if (a.asset.currency == 'USD') annualValue *= exchangeRate;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.monetization_on, color: Colors.amber),
            title: Text(a.asset.name),
            subtitle: Text('${a.dividendMonths?.join(', ') ?? '정보 없음'}월 지급'),
            trailing: Text(
              formatter.format(annualValue),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }),
      ],
    );
  }

  Map<int, double> _calculateMonthlyDividends(
    List<DashboardAsset> assets,
    double exchangeRate,
  ) {
    final Map<int, double> result = {};
    for (int i = 1; i <= 12; i++) result[i] = 0;

    for (var a in assets) {
      if (a.dividendAmount == null || a.dividendAmount! <= 0) continue;
      if (a.dividendMonths == null || a.dividendMonths!.isEmpty) continue;

      double perPayment = a.annualDividendValue / a.dividendMonths!.length;
      if (a.asset.currency == 'USD') perPayment *= exchangeRate;

      for (var month in a.dividendMonths!) {
        result[month] = (result[month] ?? 0) + perPayment;
      }
    }
    return result;
  }
}
