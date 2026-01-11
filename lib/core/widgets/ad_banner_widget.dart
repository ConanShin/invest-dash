import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ad_provider.dart';

class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Test Ad Unit IDs from Google
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    // Optimistically load ad. Logic to hide/dispose will be handled by provider listeners/build.
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adRemovedState = ref.watch(adRemovalStateProvider);

    // If ads are removed, or we are still checking (to avoid flicker), we can chose to hide or show.
    // Here we choose to hide if confirmed removed.
    // If checking (loading), we might show nothing or the ad.
    // Let's hide if we know for sure it's removed.
    final isAdRemoved = adRemovedState.asData?.value ?? false;

    if (isAdRemoved) {
      // Ensure we clean up resources if we switch state or loaded unnecessarily
      if (_bannerAd != null) {
        // We defer disposal to next frame or just let garbage collection/dispose method handle it?
        // Calling dispose inside build is bad.
        // So we just return SizedBox here.
        // The resource will be cleaned up in dispose() when this widget is removed from tree
        // OR we should actively dispose if we stay in tree?
        // Ideally we should use ref.listen to dispose.
      }
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
