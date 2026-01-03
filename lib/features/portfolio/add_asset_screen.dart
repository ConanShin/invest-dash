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
  bool _movingForward = true;

  void _resetFields() {
    setState(() {
      _symbol = '';
      _name = '';
      _symbolController.clear();
      _nameController.clear();
      _quantity = 0;
      _averagePrice = 0;
      _currency = 'KRW';
    });
  }

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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: _movingForward
                      ? const Offset(1.0, 0.0)
                      : const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);

                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _currentStep == 0
                  ? _buildTypeSelection(key: const ValueKey('selection'))
                  : _buildInputForm(key: const ValueKey('form')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0 && widget.initialAsset == null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () {
                _resetFields();
                setState(() {
                  _movingForward = false;
                  _currentStep = 0;
                });
              },
            )
          else
            const SizedBox(width: 48),
          Text(
            widget.initialAsset == null ? '신규 자산 등록' : '자산 정보 수정',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 32),
          const Text(
            '관리할 자산의 종류를\n선택해주세요',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildTypeCard(
            title: '국내 주식',
            subtitle: 'KOSPI, KOSDAQ 종목',
            icon: Icons.show_chart,
            type: AssetType.domesticStock,
            colors: [Colors.blue, Colors.blueAccent],
          ),
          const SizedBox(height: 20),
          _buildTypeCard(
            title: '미국 주식',
            subtitle: 'NASDAQ, NYSE 실시간 시세',
            icon: Icons.public,
            type: AssetType.usStock,
            colors: [Colors.red, Colors.redAccent],
          ),
          const SizedBox(height: 20),
          _buildTypeCard(
            title: 'ETF',
            subtitle: '지수 추종 및 테마형 상장지수펀드',
            icon: Icons.pie_chart_outline,
            type: AssetType.etf,
            colors: [Colors.green, Colors.teal],
          ),
          const SizedBox(height: 20),
          _buildTypeCard(
            title: '현금 / 예금',
            subtitle: '은행 계좌 및 입출금 예치금',
            icon: Icons.account_balance_wallet,
            type: AssetType.deposit,
            colors: [Colors.orange, Colors.amber],
          ),
          const SizedBox(height: 20),
          _buildTypeCard(
            title: '기타 펀드',
            subtitle: '개인 투자 및 적립식 펀드',
            icon: Icons.layers_outlined,
            type: AssetType.fund,
            colors: [Colors.purple, Colors.deepPurple],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required AssetType type,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            setState(() {
              _type = type;
              _currency = (type == AssetType.usStock) ? 'USD' : 'KRW';
              _movingForward = true;
              _currentStep = 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm({Key? key}) {
    final state = ref.watch(addAssetViewModelProvider);
    final isDeposit = _type == AssetType.deposit;

    return Container(
      key: key,
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(32.0),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildSectionTitle('기본 정보'),
            const SizedBox(height: 20),
            if (!isDeposit) ...[
              TypeAheadField<StockSearchResult>(
                controller: _symbolController,
                builder: (context, controller, focusNode) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: _inputDecoration(
                      label: '종목 검색 (명칭 또는 코드)',
                      icon: Icons.search,
                      helper: _getTypeHelperText(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? '종목을 선택해주세요' : null,
                    onSaved: (value) => _symbol = value!,
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 2) return [];
                  final service = ref.read(stockSearchServiceProvider);
                  final results = await service.search(pattern);

                  return results.where((item) {
                    final code = item.exchangeCode.toUpperCase();
                    if (_type == AssetType.usStock) {
                      return ['NMS', 'NGM', 'NYQ', 'ASE', 'PNK'].contains(code);
                    }
                    if (_type == AssetType.domesticStock) {
                      return ['KSC', 'KOE'].contains(code) ||
                          item.exchange.contains('KOSDAQ') ||
                          item.exchange.contains('Seoul');
                    }
                    if (_type == AssetType.fund) {
                      return item.typeDisplay == 'Fund' ||
                          item.symbol.startsWith('MANUAL_KB_');
                    }
                    return true;
                  }).toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(
                      suggestion.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${suggestion.symbol} • ${suggestion.exchange}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
                onSelected: (suggestion) {
                  _symbolController.text = suggestion.symbol;
                  _nameController.text = suggestion.name;
                },
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _nameController,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: _inputDecoration(
                label: isDeposit ? '은행/상품명' : '자산 명칭',
                icon: Icons.edit_note,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '명칭을 입력해주세요' : null,
              onSaved: (value) {
                _name = value!;
                if (isDeposit) _symbol = _name;
              },
            ),
            const SizedBox(height: 48),
            _buildSectionTitle('계좌 / 소유 정보'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _owner,
                    decoration: _inputDecoration(
                      label: '소유자',
                      icon: Icons.person_outline,
                    ),
                    items: ['신철민', '채지선', '신비']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _owner = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: _inputDecoration(label: '통화'),
                    items: ['KRW', 'USD']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _currency = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildSectionTitle('투자 내역'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: isDeposit
                        ? (widget.initialAsset?.holding.quantity.toString() ==
                                  '1.0'
                              ? ''
                              : widget.initialAsset?.holding.quantity
                                    .toString())
                        : widget.initialAsset?.holding.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                    decoration: _inputDecoration(
                      label: isDeposit ? '이자율' : '보유 수량',
                      suffix: isDeposit ? '%' : '주',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        double.tryParse(value ?? '') == null ? '입력' : null,
                    onSaved: (value) => _quantity = double.parse(value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.initialAsset?.holding.averagePrice
                        .toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                    decoration: _inputDecoration(
                      label: isDeposit ? '예치 금액' : '평단가',
                      suffix: _currency == 'USD' ? '\$' : '₩',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        double.tryParse(value ?? '') == null ? '입력' : null,
                    onSaved: (value) => _averagePrice = double.parse(value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: widget.initialAsset == null
                    ? Theme.of(context).primaryColor
                    : Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      widget.initialAsset == null ? '저장하기' : '수정 완료',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
            ),
            if (widget.initialAsset != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _showDeleteConfirmation,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red[400],
                ),
                child: const Text(
                  '이 자산 삭제하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Colors.grey[400],
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    String? helper,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      suffixText: suffix,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      floatingLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
