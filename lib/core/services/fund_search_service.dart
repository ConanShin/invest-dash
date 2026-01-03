import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'stock_search_service.dart';
import 'stock_service.dart';

part 'fund_search_service.g.dart';

class FundSearchService {
  final Dio _dio;

  FundSearchService(this._dio);

  Future<List<StockSearchResult>> search(String query) async {
    if (query.isEmpty) return [];

    try {
      // Pattern: https://www.funddoctor.co.kr/afs/search/fundsearch1.jsp?search_flag=Y&page=1&fund_nm={검색어}
      final url = 'https://www.funddoctor.co.kr/afs/search/fundsearch1.jsp';
      final params = {'search_flag': 'Y', 'page': '1', 'fund_nm': query};

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

      if (response.statusCode == 200) {
        final document = parse(response.data);
        // Selector: a[href*="fund_cd="]
        final links = document.querySelectorAll('a[href*="fund_cd="]');

        final List<StockSearchResult> results = [];
        final Set<String> seenCodes = {};

        for (var link in links) {
          final name = link.text.trim();
          final href = link.attributes['href'] ?? '';

          if (name.isEmpty || !href.contains('fund_cd=')) continue;

          // Extract fund_cd from href
          final uri = Uri.tryParse(
            href.replaceFirst('..', 'https://www.funddoctor.co.kr'),
          );
          final fundCode = uri?.queryParameters['fund_cd'];

          if (fundCode != null && !seenCodes.contains(fundCode)) {
            seenCodes.add(fundCode);
            results.add(
              StockSearchResult(
                symbol: fundCode,
                name: name,
                exchange: 'FundDoctor',
                exchangeCode: 'KOF',
                typeDisplay: 'Fund',
              ),
            );
          }
        }

        return results;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<StockPriceData?> getLatestPrice(String fundCode) async {
    if (fundCode.isEmpty) return null;

    try {
      // Pattern: https://www.funddoctor.co.kr/afn/fund/fprofile.jsp?fund_cd={fund_cd}
      final url = 'https://www.funddoctor.co.kr/afn/fund/fprofile.jsp';
      final params = {'fund_cd': fundCode};

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

      if (response.statusCode == 200) {
        final document = parse(response.data);

        // Standard Price (기준가)
        final priceElement = document.querySelector('.fund_price');
        // Price Change (전일대비)
        final changeElement = document.querySelector(
          '.fund_gaprate span:first-child',
        );

        if (priceElement != null && changeElement != null) {
          final priceStr = priceElement.text.replaceAll(',', '').trim();
          final changeStr = changeElement.text.replaceAll(',', '').trim();

          final currentPrice = double.tryParse(priceStr);
          final priceChange = double.tryParse(changeStr);

          if (currentPrice != null && priceChange != null) {
            // previousClose = currentPrice - priceChange
            final previousClose = currentPrice - priceChange;
            return StockPriceData(
              currentPrice: currentPrice,
              previousClose: previousClose,
            );
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
FundSearchService fundSearchService(Ref ref) {
  return FundSearchService(Dio());
}
