import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard_view_model.dart';
import '../../../data/local/database.dart';
import '../../../core/services/stock_service.dart';

class LiveAssetRow extends ConsumerStatefulWidget {
  final DashboardAsset assetItem;
  final double exchangeRate;

  const LiveAssetRow({
    super.key,
    required this.assetItem,
    required this.exchangeRate,
  });

  @override
  ConsumerState<LiveAssetRow> createState() => _LiveAssetRowState();
}

class _LiveAssetRowState extends ConsumerState<LiveAssetRow> {
  late double _currentPrice;
  Timer? _timer;
  Color _flashColor = Colors.transparent;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.assetItem.currentPrice;

    // Don't auto-refresh Deposit or Funds (manual/static)
    if (widget.assetItem.asset.type != AssetType.deposit &&
        widget.assetItem.asset.type != AssetType.fund) {
      _scheduleRandomInitialRefresh();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleRandomInitialRefresh() {
    // Random delay between 0 and 5 minutes (300 seconds) for the first refresh
    final initialDelaySeconds = _random.nextInt(300);
    _timer = Timer(Duration(seconds: initialDelaySeconds), () {
      _refreshPrice();
      // Then start the 5-minute interval
      _timer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _refreshPrice(),
      );
    });
  }

  Future<void> _refreshPrice() async {
    final stockService = ref.read(stockServiceProvider);
    try {
      final prices = await stockService.getPrices([
        widget.assetItem.asset.symbol,
      ]);
      if (prices.containsKey(widget.assetItem.asset.symbol)) {
        final newPrice = prices[widget.assetItem.asset.symbol]!;
        if (newPrice != _currentPrice) {
          if (mounted) {
            setState(() {
              final isUp = newPrice > _currentPrice;
              _currentPrice = newPrice;
              _flashColor = isUp
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3);
            });

            // Reset flash color after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _flashColor = Colors.transparent;
                });
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Live refresh error for ${widget.assetItem.asset.symbol}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.assetItem.asset.type == AssetType.deposit;

    // Recalculate P/L based on potentially updated _currentPrice
    final investment = isDeposit
        ? widget.assetItem.holding.averagePrice
        : widget.assetItem.holding.quantity *
              widget.assetItem.holding.averagePrice;

    final currentVal = isDeposit
        ? widget.assetItem.holding.averagePrice
        : widget.assetItem.holding.quantity * _currentPrice;

    final profit = currentVal - investment;
    final profitPercent = investment == 0 ? 0.0 : (profit / investment) * 100;
    final isProfit = profit >= 0;

    // Determine currency symbol
    final isUsd = widget.assetItem.asset.currency == 'USD';
    final symbol = isUsd ? '\$' : '₩';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _flashColor == Colors.transparent
            ? Theme.of(context).cardColor
            : _flashColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildAssetIcon(widget.assetItem.asset.type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assetItem.asset.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDeposit
                        ? '이자율 ${widget.assetItem.holding.quantity}% | 예치금 $symbol${widget.assetItem.holding.averagePrice.toStringAsFixed(0)}'
                        : '${widget.assetItem.holding.quantity.toStringAsFixed(widget.assetItem.holding.quantity == widget.assetItem.holding.quantity.toInt() ? 0 : 2)}주 • 현재가격 $symbol${_currentPrice.toStringAsFixed(isUsd ? 2 : 0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$symbol${currentVal.toStringAsFixed(isUsd ? 2 : 0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!isDeposit) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (isProfit ? Colors.red : Colors.blue).withAlpha(
                        30,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isProfit ? '▲' : '▼'} ${profitPercent.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isProfit ? Colors.red[700] : Colors.blue[700],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
