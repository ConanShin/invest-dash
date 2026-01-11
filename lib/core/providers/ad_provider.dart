import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_providers.dart';

// Manual definition of the provider to avoid build_runner execution
final adRemovalStateProvider = AsyncNotifierProvider<AdRemovalNotifier, bool>(
  () {
    return AdRemovalNotifier();
  },
);

class AdRemovalNotifier extends AsyncNotifier<bool> {
  static const _purchasedKey = 'ad_removed_purchased';

  @override
  Future<bool> build() async {
    // 1. Check if purchased via SharedPreferences
    // We access sharedPreferencesProvider safely
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final isPurchased = prefs.getBool(_purchasedKey) ?? false;
      if (isPurchased) return true;
    } catch (_) {
      // If sharedPreferencesProvider is not ready yet
    }

    // 2. Check owners (Shin Cheol-min or Chae Ji-seon)
    try {
      final owners = await ref.watch(ownersProvider.future);
      for (final owner in owners) {
        // We assume owner has a 'name' property.
        // Accessing dynamically to match ownersProvider's return type.
        final name = (owner as dynamic).name;
        if (name == '신철민' || name == '채지선') {
          return true;
        }
      }
    } catch (e) {
      // Handle potential errors (e.g. database not ready)
    }

    return false;
  }

  Future<void> purchaseRemoveAds() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_purchasedKey, true);
    // Invalidate self to re-run build and update state
    ref.invalidateSelf();
  }
}
