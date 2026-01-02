import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/database.dart'; // For AssetType mapping if needed

part 'stock_search_service.g.dart';

class StockSearchResult {
  final String symbol;
  final String name;
  final String exchange;
  final String exchangeCode;
  final String typeDisplay;

  StockSearchResult({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.exchangeCode,
    required this.typeDisplay,
  });

  factory StockSearchResult.fromJson(Map<String, dynamic> json) {
    return StockSearchResult(
      symbol: json['symbol'] ?? '',
      name: json['shortname'] ?? json['longname'] ?? '',
      exchange: json['exchDisp'] ?? json['exchange'] ?? '',
      exchangeCode: json['exchange'] ?? '',
      typeDisplay: json['typeDisp'] ?? '',
    );
  }

  // Helper to guess AssetType
  AssetType get inferredType {
    final exch = exchange.toUpperCase();
    // Simple heuristic; can be improved
    if (exch == 'SEOUL' || exch == 'KOSDAQ') {
      // It's hard to distinguish ETF vs Stock just by exchange in simple cases without more data,
      // but usually typeDisplay helps.
      if (typeDisplay.toUpperCase().contains('ETF')) return AssetType.etf;
      return AssetType.domesticStock;
    }
    // Assume other major exchanges are US for now (NYSE, NASDAQ)
    if (typeDisplay.toUpperCase().contains('ETF')) return AssetType.etf;
    return AssetType.usStock;
  }
}

class StockSearchService {
  final Dio _dio;

  StockSearchService(this._dio);

  Future<List<StockSearchResult>> search(String query) async {
    if (query.isEmpty) return [];

    // Mock Search Results for KB Funds
    if (query.toUpperCase().contains('KB') ||
        query.toUpperCase().contains('FUND') ||
        query.toUpperCase().contains('펀드') ||
        query.toUpperCase().contains('K55223BT1450')) {
      return [
        StockSearchResult(
          symbol: 'MANUAL_KB_BOND',
          name: 'KB 스타막강 국공채 설정액',
          exchange: 'KB Asset Management',
          exchangeCode: 'KB_FUND',
          typeDisplay: 'Fund',
        ),
        StockSearchResult(
          symbol: 'MANUAL_KB_VALUE',
          name: 'KB 밸류 포커스 증권',
          exchange: 'KB Asset Management',
          exchangeCode: 'KB_FUND',
          typeDisplay: 'Fund',
        ),
        StockSearchResult(
          symbol: 'MANUAL_KB_CHINA',
          name: 'KB 통중국 고배당',
          exchange: 'KB Asset Management',
          exchangeCode: 'KB_FUND',
          typeDisplay: 'Fund',
        ),
        StockSearchResult(
          symbol: 'MANUAL_K55223BT1450',
          name: 'FunETF (K55223BT1450)',
          exchange: 'Korea Fund',
          exchangeCode: 'KOF',
          typeDisplay: 'Fund',
        ),
      ];
    }

    try {
      final url = 'https://query1.finance.yahoo.com/v1/finance/search';
      final params = {
        'q': query,
        'lang': 'en-US',
        'quotesCount': 20,
        'newsCount': 0,
      };

      print('DEBUG: Stock Search Request -> $url with params: $params');

      final response = await _dio.get(
        url,
        queryParameters: params,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      print('DEBUG: Stock Search Response Status -> ${response.statusCode}');

      final data = response.data;
      if (data != null && data['quotes'] != null) {
        final quotes = (data['quotes'] as List)
            .where(
              (item) =>
                  item['quoteType'] == 'EQUITY' || item['quoteType'] == 'ETF',
            )
            .toList();
        print('DEBUG: Stock Search Results Count -> ${quotes.length}');
        return quotes.map((item) => StockSearchResult.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        print('Search Error (Dio): ${e.type} - ${e.message}');
        print('Search Error Response: ${e.response?.data}');
      } else {
        print('Search Error: $e');
      }
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
StockSearchService stockSearchService(Ref ref) {
  return StockSearchService(Dio());
}
