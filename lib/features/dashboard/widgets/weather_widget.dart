import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../dashboard_view_model.dart';

class WeatherWidget extends ConsumerStatefulWidget {
  const WeatherWidget({super.key});

  @override
  ConsumerState<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends ConsumerState<WeatherWidget> {
  WeatherData? _weatherData;
  String _locationName = '위치 확인 중...';
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _fetchWeather();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeather({bool isManualRefresh = false}) async {
    try {
      if (!_isLoading && mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _error = '위치 서비스가 비활성화되어 있습니다.';
            _isLoading = false;
            _isRefreshing = false;
          });
        }
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _error = '위치 권한이 거부되었습니다.';
              _isLoading = false;
              _isRefreshing = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _error = '위치 권한이 영구적으로 거부되었습니다. 설정에서 허용해주세요.';
            _isLoading = false;
            _isRefreshing = false;
          });
        }
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Get weather
      final weatherService = ref.read(weatherServiceProvider);
      final weatherData = await weatherService.getWeatherData(
        lat: position.latitude,
        lon: position.longitude,
      );

      // Get address
      String locationName = '알 수 없는 지역';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          // Priority: SubLocality -> Locality -> AdministrativeArea
          locationName =
              p.subLocality ?? p.locality ?? p.administrativeArea ?? '대한민국';
        }
      } catch (e) {
        print('Error geocoding: $e');
      }

      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _locationName = locationName;
          _isLoading = false;
          _isRefreshing = false;
          _error = null;
        });

        if (isManualRefresh &&
            weatherData != null &&
            _shouldShowPrecipitationAlert(weatherData.dailyWeatherCode)) {
          _showPrecipitationDialog(weatherData.dailyWeatherCode);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '날씨 정보를 가져오는 중 오류가 발생했습니다.';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _showPrecipitationDialog(int code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('날씨 알림'),
        content: Text(_getPrecipitationMessage(code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(weatherRefreshTriggerProvider, (previous, next) {
      _fetchWeather(isManualRefresh: true);
    });

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 120,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _fetchWeather(isManualRefresh: true),
              icon: const Icon(Icons.refresh, size: 16, color: Colors.blue),
              label: const Text('다시 시도', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    }

    final data = _weatherData;
    if (data == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF161B22)
            : Colors.blue[50]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _isRefreshing ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 날씨',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.blueAccent[100]
                                : Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _locationName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        if (_shouldShowPrecipitationAlert(
                          data.dailyWeatherCode,
                        )) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getPrecipitationMessage(data.dailyWeatherCode),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          _getIconForCondition(data.condition),
                          color: Colors.blue,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${data.temperature.toInt()}°',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeatherItem(
                      context,
                      label: '최고/최저',
                      value:
                          '${data.tempMax.toInt()}° / ${data.tempMin.toInt()}°',
                      icon: Icons.thermostat,
                    ),
                    _buildWeatherItem(
                      context,
                      label: '강수량',
                      value: '${data.precipitation.toStringAsFixed(1)}mm',
                      icon: Icons.water_drop,
                    ),
                    _buildWeatherItem(
                      context,
                      label: '미세먼지',
                      value: _getDustLevel(data.pm10),
                      icon: Icons.air,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isRefreshing)
            const Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.blue[200]
              : Colors.blue[300],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  IconData _getIconForCondition(String condition) {
    if (condition.contains('맑음')) return Icons.wb_sunny;
    if (condition.contains('구름')) return Icons.cloud;
    if (condition.contains('비') || condition.contains('소나기'))
      return Icons.umbrella;
    if (condition.contains('눈')) return Icons.ac_unit;
    return Icons.cloud_queue;
  }

  String _getDustLevel(int pm10) {
    if (pm10 <= 30) return '좋음';
    if (pm10 <= 80) return '보통';
    if (pm10 <= 150) return '나쁨';
    return '매우나쁨';
  }

  bool _shouldShowPrecipitationAlert(int code) {
    // 0~48: Clear, Cloudy, Fog (No precipitation)
    // >= 51: Drizzle, Rain, Snow, Showers, Thunderstorm
    return code >= 51;
  }

  String _getPrecipitationMessage(int code) {
    // Snow codes: 71, 73, 75, 77, 85, 86
    final snowCodes = [71, 73, 75, 77, 85, 86];
    if (snowCodes.contains(code)) {
      return '오늘 눈 소식이 있어요 ❄️';
    }
    // Thunderstorm codes: 95, 96, 99
    final stormCodes = [95, 96, 99];
    if (stormCodes.contains(code)) {
      return '천둥번개를 동반한 비 예보 ⛈️';
    }

    return '오늘 비 소식이 있어요 ☔️';
  }
}
