import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import 'add_asset_view_model.dart';
import '../dashboard/dashboard_view_model.dart'
    show dashboardViewModelProvider, DashboardAsset;
import '../../core/services/stock_search_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddAssetScreen extends ConsumerStatefulWidget {
  final DashboardAsset? initialAsset;

  const AddAssetScreen({super.key, this.initialAsset});

  @override
  ConsumerState<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends ConsumerState<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();

  String _symbol = '';
  String _name = '';
  AssetType _type = AssetType.domesticStock;
  String _currency = 'KRW';
  String _owner = '신철민';
  double _quantity = 0;
  double _averagePrice = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAsset != null) {
      final asset = widget.initialAsset!.asset;
      final holding = widget.initialAsset!.holding;
      _symbol = asset.symbol;
      _name = asset.name;
      _type = asset.type;
      _currency = asset.currency;
      _owner = asset.owner;
      _quantity = holding.quantity;
      _averagePrice = holding.averagePrice;

      _symbolController.text = _symbol;
      _nameController.text = _name;
      _currentStep = 1; // Go straight to input form
    }
  }

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialAsset == null ? '자산 추가' : '자산 수정'),
        leading: _currentStep > 0 && widget.initialAsset == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep = 0),
              )
            : null,
        actions: widget.initialAsset != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _showDeleteConfirmation,
                )
              ]
            : null,
      ),
      body: _currentStep == 0 ? _buildTypeSelection() : _buildInputForm(),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            '어떤 자산을 추가하시겠습니까?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildTypeCard(
            title: '국내 주식',
            subtitle: 'KOSPI, KOSDAQ',
            icon: Icons.business,
            type: AssetType.domesticStock,
            color: Colors.blue.shade100,
          ),
          const SizedBox(height: 16),
          _buildTypeCard(
            title: '미국 주식',
            subtitle: 'NASDAQ, NYSE, AMEX',
            icon: Icons.language,
            type: AssetType.usStock,
            color: Colors.red.shade100,
          ),
          const SizedBox(height: 16),
          _buildTypeCard(
            title: 'ETF',
            subtitle: 'Exchange Traded Value',
            icon: Icons.pie_chart,
            type: AssetType.etf,
            color: Colors.green.shade100,
          ),
          const SizedBox(height: 16),
          _buildTypeCard(
            title: '예금',
            subtitle: 'Bank Deposit',
            icon: Icons.account_balance,
            type: AssetType.deposit,
            color: Colors.orange.shade100,
          ),
          const SizedBox(height: 16),
          _buildTypeCard(
            title: '펀드',
            subtitle: 'Private Fund (KB)',
            icon: Icons.trending_up,
            type: AssetType.fund,
            color: Colors.purple.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required AssetType type,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _type = type;
            _currency = (type == AssetType.usStock) ? 'USD' : 'KRW';
            _currentStep = 1;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    final state = ref.watch(addAssetViewModelProvider);
    final isDeposit = _type == AssetType.deposit;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            if (!isDeposit) ...[
              TypeAheadField<StockSearchResult>(
                controller: _symbolController,
                builder: (context, controller, focusNode) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: '종목 검색 (명칭 또는 코드)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      helperText: _getTypeHelperText(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '종목을 선택해주세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _symbol = value!,
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 2) return [];
                  final service = ref.read(stockSearchServiceProvider);
                  final results = await service.search(pattern);

                  return results.where((item) {
                    if (_type == AssetType.usStock) {
                      final code = item.exchangeCode.toUpperCase();
                      return code == 'NMS' ||
                          code == 'NGM' ||
                          code == 'NYQ' ||
                          code == 'ASE' ||
                          code == 'PNK';
                    }
                    if (_type == AssetType.domesticStock) {
                      final code = item.exchangeCode.toUpperCase();
                      return code == 'KSC' ||
                          code == 'KOE' ||
                          item.exchange.contains('KOSDAQ') ||
                          item.exchange.contains('Seoul');
                    }
                    if (_type == AssetType.fund) {
                      // Only allow funds
                      return item.typeDisplay == 'Fund' ||
                          item.symbol.startsWith('MANUAL_KB_');
                    }
                    return true;
                  }).toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text('${suggestion.name} (${suggestion.symbol})'),
                    subtitle: Text(
                        '${suggestion.exchange} - ${suggestion.typeDisplay}'),
                  );
                },
                onSelected: (suggestion) {
                  _symbolController.text = suggestion.symbol;
                  _nameController.text = suggestion.name;
                },
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: _owner,
              decoration: const InputDecoration(
                labelText: '소유자',
                border: OutlineInputBorder(),
              ),
              items: ['신철민', '채지선', '신비']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _owner = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: isDeposit ? '은행/상품명 (예: 신한은행 적금)' : '종목명',
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '명칭을 입력해주세요' : null,
              onSaved: (value) {
                _name = value!;
                if (isDeposit) {
                  // For deposit, simple symbol if not provided
                  _symbol = _name;
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: const InputDecoration(
                labelText: '통화',
                border: OutlineInputBorder(),
              ),
              items: ['KRW', 'USD']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _currency = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: isDeposit
                        ? (widget.initialAsset?.holding.quantity.toString() ==
                                '1.0'
                            ? '' // Default empty for UX
                            : widget.initialAsset?.holding.quantity.toString())
                        : widget.initialAsset?.holding.quantity.toString(),
                    decoration: InputDecoration(
                      labelText: isDeposit ? '이자율 (%)' : '보유 수량',
                      border: const OutlineInputBorder(),
                      suffixText: isDeposit ? '%' : null,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        double.tryParse(value ?? '') == null ? '숫자 입력' : null,
                    onSaved: (value) => _quantity = double.parse(value!),
                    // For deposit default to 1 if user wants simple "Amount" input?
                    // But here we keep Quantity * Price model.
                    // User can set Quantity 1, Price = Total Amount.
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        widget.initialAsset?.holding.averagePrice.toString(),
                    decoration: InputDecoration(
                      labelText: isDeposit ? '예치 금액' : '평단가',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        double.tryParse(value ?? '') == null ? '숫자 입력' : null,
                    onSaved: (value) => _averagePrice = double.parse(value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: widget.initialAsset == null
                    ? Theme.of(context).primaryColor
                    : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.initialAsset == null ? '자산 추가하기' : '자산 수정하기',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeHelperText() {
    switch (_type) {
      case AssetType.domesticStock:
        return '국내 종목 (삼성전자, NAVER 등) 검색';
      case AssetType.usStock:
        return '미국 종목 (AAPL, TSLA 등) 검색';
      case AssetType.etf:
        return 'ETF 검색';
      case AssetType.deposit:
        return '예금';
      case AssetType.fund:
        return '펀드 검색 (예: KB)';
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final notifier = ref.read(addAssetViewModelProvider.notifier);
        if (widget.initialAsset == null) {
          await notifier.addAsset(
            symbol: _symbol,
            name: _name,
            type: _type,
            currency: _currency,
            quantity: _quantity,
            averagePrice: _averagePrice,
            owner: _owner, // Added owner
          );
        } else {
          await notifier.updateAsset(
            assetId: widget.initialAsset!.asset.id,
            symbol: _symbol,
            name: _name,
            type: _type,
            currency: _currency,
            quantity: _quantity,
            averagePrice: _averagePrice,
            owner: _owner, // Added owner
          );
        }

        if (mounted) {
          // Invalidating the dashboard provider to refresh list
          ref.invalidate(dashboardViewModelProvider);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자산 삭제'),
        content: const Text('정말로 이 자산을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(addAssetViewModelProvider.notifier)
                  .deleteAsset(widget.initialAsset!.asset.id);
              if (mounted) {
                ref.invalidate(dashboardViewModelProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
