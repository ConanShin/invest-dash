import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock_service.g.dart';

class StockDividendInfo {
  final double? annualAmount;
  final List<int>? months; // 1-indexed months

  StockDividendInfo({this.annualAmount, this.months});
}

class StockPriceData {
  final double currentPrice;
  final double previousClose;
  double get change => currentPrice - previousClose;
  double get changePercent => (change / previousClose) * 100;

  StockPriceData({required this.currentPrice, required this.previousClose});
}

abstract class StockService {
  Future<Map<String, StockPriceData>> getPrices(List<String> symbols);
  Future<double> getExchangeRate();
  Future<StockDividendInfo?> getDividendInfo(String symbol);
}

@Riverpod(keepAlive: true)
StockService stockService(Ref ref) {
  return YahooStockService(Dio());
}

class YahooStockService implements StockService {
  final Dio _dio;

  YahooStockService(this._dio);

  @override
  Future<Map<String, StockPriceData>> getPrices(List<String> symbols) async {
    if (symbols.isEmpty) return {};
    final Map<String, StockPriceData> prices = {};

    try {
      final results = await Future.wait(
        symbols.map((symbol) async {
          if (symbol.isEmpty) return null;
          try {
            // Using query2 which is often more stable for chart requests
            final url =
                'https://query2.finance.yahoo.com/v8/finance/chart/$symbol';
            final params = {'interval': '1d', 'range': '1d'};

            print('DEBUG: [Price Request] $symbol -> $url');

            final response = await _dio.get(
              url,
              queryParameters: params,
              options: Options(
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                  'Accept': '*/*',
                },
                validateStatus: (status) => status! < 500,
              ),
            );

            if (response.statusCode == 200) {
              final data = response.data;
              final meta = data['chart']?['result']?[0]?['meta'];
              if (meta != null) {
                final currentPrice = meta['regularMarketPrice'] as num?;
                final previousClose =
                    (meta['chartPreviousClose'] ?? meta['previousClose'])
                        as num?;

                if (currentPrice != null && previousClose != null) {
                  print(
                    'DEBUG: [Price Response] $symbol -> Current: $currentPrice, PrevClose: $previousClose',
                  );
                  return MapEntry(
                    symbol,
                    StockPriceData(
                      currentPrice: currentPrice.toDouble(),
                      previousClose: previousClose.toDouble(),
                    ),
                  );
                }
              }
            } else {
              print(
                'DEBUG: [Price Error] $symbol -> Status: ${response.statusCode}',
              );
            }
          } catch (e) {
            print('Error fetching $symbol: $e');
          }
          return null;
        }),
      );

      for (var result in results) {
        if (result != null) {
          prices[result.key] = result.value;
        }
      }
    } catch (e) {
      print('Error in parallel fetching: $e');
    }
    return prices;
  }

  @override
  Future<double> getExchangeRate() async {
    try {
      final url = 'https://query2.finance.yahoo.com/v8/finance/chart/KRW=X';
      final params = {'interval': '1d', 'range': '1d'};

      print('DEBUG: Fetch Exchange Rate Request -> $url');

      final response = await _dio.get(
        url,
        queryParameters: params,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print(
        'DEBUG: Fetch Exchange Rate Response Status -> ${response.statusCode}',
      );

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

  @override
  Future<StockDividendInfo?> getDividendInfo(String symbol) async {
    if (symbol.isEmpty || symbol.startsWith('MANUAL_')) return null;

    try {
      // Use chart API with events=div to get the last year of dividends
      final url = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol';
      final params = {'interval': '1d', 'range': '1y', 'events': 'div'};

      print('DEBUG: Fetch Dividend Request -> $url');

      final response = await _dio.get(
        url,
        queryParameters: params,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final chart = data['chart']['result']?[0];
        if (chart == null) return null;

        final dividends = chart['events']?['dividends'];
        if (dividends == null) return null;

        double totalAmount = 0;
        final Set<int> months = {};

        dividends.forEach((key, val) {
          final amount = val['amount'] as num?;
          final timestamp = val['date'] as int?;
          if (amount != null && timestamp != null) {
            totalAmount += amount.toDouble();
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            months.add(date.month);
          }
        });

        if (totalAmount > 0) {
          final sortedMonths = months.toList()..sort();
          print(
            'DEBUG: Fetched Dividend for $symbol -> Annual: $totalAmount, Months: $sortedMonths',
          );
          return StockDividendInfo(
            annualAmount: totalAmount,
            months: sortedMonths,
          );
        }
      }
    } catch (e) {
      print('Error fetching dividend info for $symbol: $e');
    }
    return null;
  }
}
