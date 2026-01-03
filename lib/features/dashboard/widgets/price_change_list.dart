import 'package:flutter/material.dart';
import '../dashboard_view_model.dart';

class PriceChangeList extends StatelessWidget {
  final List<DashboardAsset> gainers;
  final List<DashboardAsset> losers;

  const PriceChangeList({
    super.key,
    required this.gainers,
    required this.losers,
  });

  @override
  Widget build(BuildContext context) {
    if (gainers.isEmpty && losers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '가격 변동 추이',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '현재 급격한 가격 변동이 있는 종목이 없거나 데이터를 불러오는 중입니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (gainers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              '급등 종목 (전일 대비)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          ...gainers.map((asset) => _buildPriceRow(asset, true)),
        ],
        if (losers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              '급락 종목 (전일 대비)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          ...losers.map((asset) => _buildPriceRow(asset, false)),
        ],
      ],
    );
  }

  Widget _buildPriceRow(DashboardAsset asset, bool isGainer) {
    final color = isGainer ? Colors.red[400] : Colors.blue[400];
    final icon = isGainer ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color?.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.asset.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  asset.asset.symbol,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${asset.priceChangePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontSize: 16,
                ),
              ),
              Text(
                '${isGainer ? "+" : ""}${asset.priceChange.toInt()} ₩',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
