import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/providers/data_providers.dart';
import '../../features/dashboard/dashboard_view_model.dart';
import 'owner_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            const Text(
              '설정',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: const Text('소유자 관리'),
              subtitle: const Text('자산 소유자를 등록하거나 수정합니다.'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OwnerManagementScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 48),
            _buildSectionHeader('앱 설정'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette_outlined),
              title: const Text('화면 테마'),
              subtitle: const Text('앱의 화면 테마를 변경합니다.'),
              trailing: Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeModeControllerProvider);
                  return SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('라이트'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('다크'),
                      ),
                    ],
                    selected: {
                      themeMode == ThemeMode.system
                          ? ThemeMode.light
                          : themeMode,
                    },
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref
                          .read(themeModeControllerProvider.notifier)
                          .setThemeMode(newSelection.first);
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 48),
            _buildSectionHeader('데이터 관리'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.file_upload),
              title: const Text('데이터 내보내기 (Export)'),
              subtitle: const Text('현재 자산 데이터를 JSON 파일로 저장하거나 공유합니다.'),
              onTap: () => _exportData(context, ref),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.file_download),
              title: const Text('데이터 가져오기 (Import)'),
              subtitle: const Text('기존에 내보낸 JSON 파일에서 데이터를 복원합니다.'),
              onTap: () => _importData(context, ref),
            ),
            const Divider(height: 48),
            _buildSectionHeader('앱 정보'),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('버전'),
              trailing: Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(assetRepositoryProvider);
      final assets = await repo.getAllAssets();
      final owners = await repo.getAllOwners();

      // Simplified for export; we'll need to store both Assets and Holdings
      final data = {
        'owners': owners.map((o) => o.name).toList(),
        'assets': assets
            .map(
              (a) => {
                'asset': {
                  'symbol': a.asset.symbol,
                  'name': a.asset.name,
                  'type': a.asset.type.name,
                  'currency': a.asset.currency,
                  'owner': a.asset.owner,
                  'dividendAmount': a.asset.dividendAmount,
                  'dividendMonths': a.asset.dividendMonths,
                },
                'holding': {
                  'quantity': a.holding.quantity,
                  'averagePrice': a.holding.averagePrice,
                },
              },
            )
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/invest_dash_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Invest Dash 자산 백업');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('내보내기 실패: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        final repo = ref.read(assetRepositoryProvider);

        // Confirm before deleting existing data (optional but recommended)
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('데이터 가져오기'),
            content: const Text('현재 데이터가 모두 삭제되고 파일의 데이터로 대체됩니다. 계속하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('가져오기'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // Show loading indicator
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }

          await repo.replaceAllData(data);

          // Close loading indicator
          if (context.mounted) {
            Navigator.pop(context);
          }

          ref.invalidate(dashboardViewModelProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('데이터를 성공적으로 가져왔습니다.')));
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('가져오기 실패: $e')));
      }
    }
  }
}
