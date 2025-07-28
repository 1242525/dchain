import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/Api_service.dart';
import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TokenBurnScreen extends StatefulWidget{
  final String token;
  final String chainName;
  final String contractAddress;

  const TokenBurnScreen({
    Key? key,
    required this.token,
    required this.chainName,
    required this.contractAddress,
  }) : super(key: key);


  State<TokenBurnScreen> createState()=>_TokenBurnScreenState();
}

class _TokenBurnScreenState extends State<TokenBurnScreen> {
  final _holderAddrController = TextEditingController();
  final _holderPkeyController = TextEditingController();
  final _amountController = TextEditingController();
  final apiService = ApiService();

  bool _isLoading = false;
  String _status=" ";

  Future<void> _burnToken() async {
    setState((){
    _isLoading=true;
    _status="";
  });

    final chainName = widget.chainName;
    final contractAddress = widget.contractAddress;
    final holder = _holderAddrController.text.trim();
    final pkey = _holderPkeyController.text.trim();
    final amount = _amountController.text.trim();

    final createResult = await apiService.fetchTokenBurn(
      chainName: chainName,
      contractAddress: contractAddress,
      holderAddr: holder,
      holderPkey: pkey,
      amount: amount,
    );
    if (createResult == null || createResult['state'] != 'OK') {
      setState(() {
        _status = "❌ 생성 실패: ${createResult?['msg'] ?? '오류'}";
        _isLoading = false;
      });
      return;
    }
    final balance = await apiService.fetchTokenBalance(
      chainName: chainName,
      contractAddress: contractAddress,
      accountAddress: holder,
    );

    setState(() {
      _status = "✅ 토큰 소각 성공! 소각량: $amount\n남은 잔액: ${balance ?? '조회 실패'}";
      _isLoading = false;
    });
  }
void dispose() {
  _holderAddrController.dispose();
  _holderPkeyController.dispose();
  _amountController.dispose();
  super.dispose();
}
Widget _buildInput(TextEditingController controller, String label, {bool obscureText = false, bool isNumber = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

Widget _buildActionButton() {
  return ElevatedButton(
    onPressed: _isLoading ? null : _burnToken,
    child: _isLoading
        ? const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    )
        : const Text("토큰 소각 실행"),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("토큰 소각 화면")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildInput(_holderAddrController, "홀더 주소"),
            _buildInput(_holderPkeyController, "홀더 개인키", obscureText: true),
            _buildInput(_amountController, "소각할 토큰 수량", isNumber: true),
            const SizedBox(height: 20),
            _buildActionButton(),
            const SizedBox(height: 20),
            if (_status.isNotEmpty)
              Text(
                _status,
                style: TextStyle(
                  color: _status.startsWith("✅") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
}