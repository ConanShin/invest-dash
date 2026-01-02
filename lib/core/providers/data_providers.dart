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
  final db = ref.watch(appDatabaseProvider);
  return AssetRepository(db);
}
