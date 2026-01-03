import 'package:flutter/material.dart';
import '../dashboard_view_model.dart';
import '../../portfolio/add_asset_screen.dart';
import 'live_asset_row.dart';

class AssetList extends StatelessWidget {
  final List<DashboardAsset> assets;
  final double exchangeRate;

  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AssetList({
    super.key,
    required this.assets,
    required this.exchangeRate,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('보유 자산이 없습니다. 자산을 추가해주세요!')); // Localized
    }

    final List<Widget> listItems = [];
    String? currentOwner;

    for (final item in assets) {
      if (item.asset.owner != currentOwner) {
        currentOwner = item.asset.owner;
        listItems.add(_buildOwnerHeader(currentOwner));
      }
      listItems.add(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAssetScreen(initialAsset: item),
              ),
            );
          },
          child: LiveAssetRow(assetItem: item, exchangeRate: exchangeRate),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        return listItems[index];
      },
    );
  }

  Widget _buildOwnerHeader(String owner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$owner의 포트폴리오',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
