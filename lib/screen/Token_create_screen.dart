import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Api/Api_service.dart';
import '../api/SharedPreference.dart';
import 'home_screen.dart';

class TokenCreateScreen extends StatefulWidget {
  const TokenCreateScreen({super.key});

  @override
  State<TokenCreateScreen> createState() => _TokenCreateScreenState();
}

class _TokenCreateScreenState extends State<TokenCreateScreen> {
  final _chainController = TextEditingController(text: "dchain");
  final _ownerAddrController = TextEditingController();
  final _ownerPkeyController = TextEditingController();
  final _tokenNameController = TextEditingController();
  final _tokenSymbolController = TextEditingController();
  final _supplyController = TextEditingController();
  final apiService = ApiService();

  bool _isLoading = false;
  String _status = "";

  Future<void> _createToken() async {
    setState(() {
      _isLoading = true;
      _status = "";
    });

    //공백 제거
    final chain = _chainController.text.trim();
    final owner = _ownerAddrController.text.trim();
    final pkey = _ownerPkeyController.text.trim();
    final tokenName = _tokenNameController.text.trim();
    final tokenSymbol = _tokenSymbolController.text.trim();
    final supply = _supplyController.text.trim();

    final createResult = await apiService.fetchTokenCreate(
      chainName: chain,
      ownerAddr: owner,
      ownerPkey: pkey,
      tokenName: tokenName,
      tokenSymbol: tokenSymbol,
      supply: supply,
    );

    if (createResult == null || createResult['state'] != 'OK') {
      setState(() {
        _status = "❌ 생성 실패: ${createResult?['msg'] ?? '오류'}";
        _isLoading = false;
      });
      return;
    }

    final contractAddress = createResult['data']?['contract']?['data']?['address'] ?? "";

    final mintResult = await apiService.fetchTokenMint(
      chainName: chain,
      contractAddress: contractAddress,
      owner: owner,
      privateKey: pkey,
      receiverAddress: owner,
      amount: supply,
    );

    if (mintResult == null || mintResult['state'] != 'OK') {
      setState(() {
        _status = "❌ Mint 실패: ${mintResult?['msg'] ?? '오류'}";
        _isLoading = false;
      });
      return;
    }

    await FirebaseFirestore.instance.collection('token').add({
      'token_name': tokenName,
      'token_symbol': tokenSymbol,
      'contract_address': contractAddress,
      'supply': supply,
      'created_at': FieldValue.serverTimestamp(),
    });

    await PrefsHelper.saveTokenInfo(
      tokenId: tokenName,
      contractAddress: contractAddress,
      ownerAddr: owner,
      ownerPkey: pkey,
      chainName: chain,
    );

    setState(() {
      _status = "✅ 생성 및 발행 성공!";
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  //⬇️ 공통 TextField 디자인
  Widget _buildInput(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigoAccent),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xAB6DA0FE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.indigoAccent),
          ),
        ),
      ),
    );
  }

  //⬇️ 공통 버튼 위젯
  Widget _buildActionButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _createToken,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(160, 50),
        ),
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.add_circle_outline),
        label: Text(_isLoading ? '처리중...' : '토큰 생성 및 발행'),
      ),
    );
  }

  @override
  void dispose() {
    _chainController.dispose();
    _ownerAddrController.dispose();
    _ownerPkeyController.dispose();
    _tokenNameController.dispose();
    _tokenSymbolController.dispose();
    _supplyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('토큰 생성 및 발행'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 150, left: 600, right: 600),
        child: Column(
          children: [
            _buildInput(_chainController, '체인 이름', Icons.link),
            _buildInput(_ownerAddrController, '오너 주소', Icons.person),
            _buildInput(_ownerPkeyController, '오너 개인키', Icons.vpn_key, obscureText: true),
            _buildInput(_tokenNameController, '토큰 이름', Icons.emoji_symbols),
            _buildInput(_tokenSymbolController, '토큰 심볼', Icons.abc),
            _buildInput(_supplyController, '총 공급량', Icons.numbers, isNumber: true),
            const SizedBox(height: 30),
            _buildActionButton(),
            const SizedBox(height: 24),
            if (_status.isNotEmpty)
              Text(
                _status,
                style: TextStyle(
                  color: _status.contains('성공') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
