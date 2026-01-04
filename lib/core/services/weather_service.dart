import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather_service.g.dart';

class WeatherData {
  final double temperature;
  final double tempMax;
  final double tempMin;
  final double precipitation;
  final int pm10;
  final String condition;

  WeatherData({
    required this.temperature,
    required this.tempMax,
    required this.tempMin,
    required this.precipitation,
    required this.pm10,
    required this.condition,
  });
}

@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) {
  return WeatherService(Dio());
}

class WeatherService {
  final Dio _dio;

  WeatherService(this._dio);

  Future<WeatherData?> getWeatherData({
    required double lat,
    required double lon,
  }) async {
    try {
      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,precipitation,weather_code&daily=temperature_2m_max,temperature_2m_min&timezone=Asia%2FSeoul';

      final response = await _dio.get(weatherUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final current = data['current'];
        final daily = data['daily'];

        // Mocking fine dust data
        final pm10 = 35;

        return WeatherData(
          temperature: current['temperature_2m'].toDouble(),
          tempMax: daily['temperature_2m_max'][0].toDouble(),
          tempMin: daily['temperature_2m_min'][0].toDouble(),
          precipitation: current['precipitation'].toDouble(),
          pm10: pm10,
          condition: _getConditionFromCode(current['weather_code']),
        );
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }

  String _getConditionFromCode(int code) {
    if (code == 0) return '맑음';
    if (code <= 3) return '구름조금';
    if (code <= 48) return '안개';
    if (code <= 67) return '비';
    if (code <= 77) return '눈';
    if (code <= 82) return '소나기';
    if (code <= 99) return '천둥번개';
    return '불명';
  }
}
