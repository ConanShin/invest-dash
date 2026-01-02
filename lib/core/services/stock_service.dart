import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock_service.g.dart';

abstract class StockService {
  Future<Map<String, double>> getPrices(List<String> symbols);
  Future<double> getExchangeRate();
}

@Riverpod(keepAlive: true)
StockService stockService(Ref ref) {
  return YahooStockService(Dio());
}

class YahooStockService implements StockService {
  final Dio _dio;

  YahooStockService(this._dio);

  @override
  Future<Map<String, double>> getPrices(List<String> symbols) async {
    final Map<String, double> prices = {};

    // Yahoo Chart API v8 supports multiple symbols but it's often safer to do individual or batched carefully.
    // However, v8/chart/SYMBOL is for single. v7/finance/quote?symbols=A,B is for multiple but unauthorized.
    // We will use v8/finance/chart/{symbol} for each symbol for now (simpler).
    // For production, we should parallelize.

    for (final symbol in symbols) {
      if (symbol.isEmpty) continue;
      try {
        final url = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol';
        final params = {
          'interval': '1d',
          'range': '1d',
        };

        print('DEBUG: Fetch Price Request -> $url');

        final response = await _dio.get(url,
            queryParameters: params,
            options: Options(
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': '*/*'
              },
              validateStatus: (status) =>
                  status! < 500, // Handle 404/429 gracefully
            ));

        print(
            'DEBUG: Fetch Price Response Status ($symbol) -> ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = response.data;
          final meta = data['chart']['result'][0]['meta'];
          final price = meta['regularMarketPrice'] as num?;
          print('DEBUG: Fetched Price ($symbol) -> $price');
          if (price != null) {
            prices[symbol] = price.toDouble();
          }
        } else {
          print('Failed to fetch $symbol: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching $symbol: $e');
      }
    }
    return prices;
  }

  @override
  Future<double> getExchangeRate() async {
    try {
      final url = 'https://query1.finance.yahoo.com/v8/finance/chart/KRW=X';
      final params = {
        'interval': '1d',
        'range': '1d',
      };

      print('DEBUG: Fetch Exchange Rate Request -> $url');

      final response = await _dio.get(url,
          queryParameters: params,
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept': '*/*'
            },
            validateStatus: (status) => status! < 500,
          ));

      print(
          'DEBUG: Fetch Exchange Rate Response Status -> ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final meta = data['chart']['result'][0]['meta'];
        // regularMarketPrice for currencies usually works
        final price = meta['regularMarketPrice'] as num?;
        print('DEBUG: Fetched Exchange Rate -> $price');
        if (price != null) {
          return price.toDouble();
        }
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
    }
    return 1300.0; // Fallback default if fetch fails
  }
}
