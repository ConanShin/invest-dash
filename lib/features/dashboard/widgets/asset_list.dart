import 'package:flutter/material.dart';
import '../dashboard_view_model.dart';
import '../../../data/local/database.dart';
import '../../portfolio/add_asset_screen.dart';

class AssetList extends StatelessWidget {
  final List<DashboardAsset> assets;
  final double exchangeRate;

  const AssetList(
      {super.key, required this.assets, required this.exchangeRate});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('보유 자산이 없습니다. 자산을 추가해주세요!')); // Localized
    }

    // Since assets are already sorted by Owner -> Type in ViewModel,
    // we just need to insert headers when owner changes.
    // However, ListView.builder is index based.
    // Let's build a flattened list of items (Header + Asset).
    final List<Widget> listItems = [];
    String? currentOwner;

    for (final item in assets) {
      if (item.asset.owner != currentOwner) {
        currentOwner = item.asset.owner;
        listItems.add(_buildOwnerHeader(currentOwner!));
      }
      listItems.add(_buildAssetItem(context, item));
    }

    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        return listItems[index];
      },
    );
  }

  Widget _buildOwnerHeader(String owner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100,
      child: Text(
        '$owner의 자산',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAssetItem(BuildContext context, DashboardAsset item) {
    final isDeposit = item.asset.type == AssetType.deposit;

    // Calculate P/L
    final investment = isDeposit
        ? item.holding.averagePrice
        : item.holding.quantity * item.holding.averagePrice;
    final currentVal = item.totalValue;
    final profit = currentVal - investment;
    final profitPercent = investment == 0 ? 0.0 : (profit / investment) * 100;
    final isProfit = profit >= 0;

    // Determine currency symbol
    final isUsd = item.asset.currency == 'USD';
    final symbol = isUsd ? '\$' : '₩';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddAssetScreen(initialAsset: item),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            _buildAssetIcon(item.asset.type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.asset.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        isDeposit
                            ? '이자율 ${item.holding.quantity}% | 예치금 $symbol${item.holding.averagePrice.toStringAsFixed(0)}'
                            : '${item.holding.quantity} @ $symbol${item.holding.averagePrice.toStringAsFixed(isUsd ? 2 : 0)} -> $symbol${item.currentPrice.toStringAsFixed(isUsd ? 2 : 0)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (isUsd && !isDeposit) ...[
                    // Show approximate KRW value for USD assets
                    Text(
                      '≈ ₩${(currentVal * exchangeRate).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    )
                  ]
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // If USD, show USD Total line 1, KRW Total line 2 (subtext)
                Text(
                  '$symbol${currentVal.toStringAsFixed(isUsd ? 2 : 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!isDeposit)
                  Text(
                    '${isProfit ? '+' : ''}${profitPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isProfit
                          ? Colors.red
                          : Colors.blue, // KR Stock color: Red is up
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetIcon(AssetType type) {
    IconData icon;
    Color color;

    switch (type) {
      case AssetType.domesticStock:
        icon = Icons.business;
        color = Colors.blue;
        break;
      case AssetType.usStock:
        icon = Icons.language;
        color = Colors.red;
        break;
      case AssetType.etf:
        icon = Icons.pie_chart;
        color = Colors.green;
        break;
      case AssetType.deposit:
        icon = Icons.account_balance;
        color = Colors.orange;
        break;
      case AssetType.fund:
        icon = Icons.trending_up;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
