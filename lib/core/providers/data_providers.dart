import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/database.dart';
import '../../data/repository/asset_repository.dart';

part 'data_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@riverpod
AssetRepository assetRepository(Ref ref) {
  return AssetRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Future<List<dynamic>> owners(Ref ref) async {
  // Using dynamic to avoid build_runner type resolution issues with generated drift classes
  return ref.watch(assetRepositoryProvider).getAllOwners();
}
