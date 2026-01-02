import 'package:flutter/material.dart';
import '../dashboard_view_model.dart';
import '../../portfolio/add_asset_screen.dart';
import 'live_asset_row.dart';

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
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        return listItems[index];
      },
    );
  }

  Widget _buildOwnerHeader(String owner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.withAlpha(25), // Safe alternative for withOpacity
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
}
