import 'package:flutter/material.dart';
import '../dashboard_view_model.dart';
import '../../../data/local/database.dart';

class CompactAssetList extends StatelessWidget {
  final List<DashboardAsset> assets;
  final double exchangeRate;

  const CompactAssetList({
    super.key,
    required this.assets,
    required this.exchangeRate,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('보유 자산이 없습니다.'));
    }

    // Sort by value and take top 5
    final displayAssets = assets.toList()
      ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
    final topAssets = displayAssets.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            '주요 보유 자산',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topAssets.length,
            itemBuilder: (context, index) {
              return CompactAssetCard(asset: topAssets[index]);
            },
          ),
        ),
      ],
    );
  }
}

class CompactAssetCard extends StatefulWidget {
  final DashboardAsset asset;
  final bool isFixedSize;

  const CompactAssetCard({
    super.key,
    required this.asset,
    this.isFixedSize = true,
  });

  @override
  State<CompactAssetCard> createState() => _CompactAssetCardState();
}

class _CompactAssetCardState extends State<CompactAssetCard> {
  Color _flashColor = Colors.transparent;

  @override
  void didUpdateWidget(CompactAssetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.asset.currentPrice != oldWidget.asset.currentPrice) {
      _triggerFlash(widget.asset.currentPrice > oldWidget.asset.currentPrice);
    }
  }

  void _triggerFlash(bool isUp) {
    setState(() {
      _flashColor = isUp
          ? Colors.green.withAlpha(50)
          : Colors.red.withAlpha(50);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _flashColor = Colors.transparent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.asset.asset.type == AssetType.deposit;
    final investment = isDeposit
        ? widget.asset.holding.averagePrice
        : widget.asset.holding.quantity * widget.asset.holding.averagePrice;
    final currentVal = isDeposit
        ? widget.asset.holding.averagePrice
        : widget.asset.holding.quantity * widget.asset.currentPrice;
    final profit = currentVal - investment;
    final profitPercent = investment == 0 ? 0.0 : (profit / investment) * 100;

    final Color statusColor;
    final String statusPrefix;

    if (profit > 0.001) {
      statusColor = Colors.red[700]!;
      statusPrefix = '▲';
    } else if (profit < -0.001) {
      statusColor = Colors.blue[700]!;
      statusPrefix = '▼';
    } else {
      statusColor = Colors.grey[600]!;
      statusPrefix = '';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: widget.isFixedSize ? 140 : null,
      margin: widget.isFixedSize
          ? const EdgeInsets.only(right: 12, bottom: 8, top: 4)
          : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _flashColor == Colors.transparent
            ? Theme.of(context).cardColor
            : _flashColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.asset.asset.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isDeposit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${statusPrefix.isNotEmpty ? statusPrefix : ""}${profitPercent.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            widget.asset.asset.symbol,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Total Value with rolling animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.asset.totalValue),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return Text(
                _formatPrice(value),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          // Unit Price with rolling animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.asset.currentPrice),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              final isUsd = widget.asset.asset.currency == 'USD';
              return Text(
                '${isUsd ? '\$' : '₩'}${value.toStringAsFixed(isUsd ? 2 : 0)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M ₩';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(1)}K ₩';
    return '${price.toInt()} ₩';
  }
}
