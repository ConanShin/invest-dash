import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/weather_service.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<WeatherData?>(
      future: ref.read(weatherServiceProvider).getWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF161B22)
                : Colors.blue[50]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.blue[100]!,
              width: 1,
            ),
          ),
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blueAccent[100]
                              : Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '서울, 대한민국',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
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
        );
      },
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
}
