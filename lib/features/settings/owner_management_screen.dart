import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/data_providers.dart';
import '../../data/local/database.dart';
import '../dashboard/dashboard_view_model.dart';

class OwnerManagementScreen extends ConsumerWidget {
  const OwnerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownersAsync = ref.watch(ownersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('소유자 관리')),
      body: ownersAsync.when(
        data: (owners) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: owners.length,
          itemBuilder: (context, index) {
            final owner = owners[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(
                  owner.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditDialog(context, ref, owner),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, ref, owner),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('오류 발생: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('소유자 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '이름'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final repo = ref.read(assetRepositoryProvider);
                final owners = await repo.getAllOwners();
                if (owners.any((o) => o.name == name)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미 존재하는 이름입니다.')),
                    );
                  }
                  return;
                }
                await repo.addOwner(name);
                ref.invalidate(ownersProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Owner owner) {
    final controller = TextEditingController(text: owner.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('소유자 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '새 이름'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != owner.name) {
                final repo = ref.read(assetRepositoryProvider);
                final owners = await repo.getAllOwners();
                if (owners.any((o) => o.name == newName)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미 존재하는 이름입니다.')),
                    );
                  }
                  return;
                }
                await repo.updateOwner(owner.id, newName);
                ref.invalidate(ownersProvider);
                ref.invalidate(dashboardViewModelProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Owner owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('소유자 삭제'),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: owner.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '님과 관련된 '),
              const TextSpan(
                text: '모든 자산 데이터가 함께 삭제',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '됩니다. 정말 삭제하시겠습니까?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(assetRepositoryProvider).deleteOwner(owner.id);
              ref.invalidate(ownersProvider);
              ref.invalidate(dashboardViewModelProvider);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
