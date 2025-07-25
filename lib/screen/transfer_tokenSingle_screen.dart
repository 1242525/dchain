import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Api/Api_service.dart';
import '../screen/token_balance.dart';

class TokenTransferSingleScreen extends StatefulWidget {
  final String chainName;
  final String contractAddress;

  // 발신자 정보 (AccountManagementScreen에서 전달됨)
  final String senderAddress;
  final String senderPrivateKey;

  // 수신자 정보 (선택된 계정)
  final String recipientAddress;
  final String recipientNickname;

  const TokenTransferSingleScreen({
    Key? key,
    required this.chainName,
    required this.contractAddress,
    required this.senderAddress,
    required this.senderPrivateKey,
    required this.recipientAddress,
    required this.recipientNickname,
  }) : super(key: key);

  @override
  State<TokenTransferSingleScreen> createState() => _TokenTransferSingleScreenState();
}

class _TokenTransferSingleScreenState extends State<TokenTransferSingleScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;

  Future<void> _transferToken() async {
    final amount = _amountController.text.trim();
    final token = dotenv.env['API_TOKEN'] ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('토큰 ID가 설정되어 있지 않습니다.')),
      );
      return;
    }

    if (amount.isEmpty || int.tryParse(amount) == null || int.parse(amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 전송 수량을 입력하세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await apiService.transferToken(
        chainName: widget.chainName,
        contractAddress: widget.contractAddress,
        sender: widget.senderAddress,
        senderPkey: widget.senderPrivateKey,
        receiver: widget.recipientAddress,
        amount: amount,
      );

      if (result != null && result['state'] == 'OK') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.recipientNickname} 에게 $amount 토큰 전송 성공')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AccountStatusScreen(
              tokenId: token,
              chainName: widget.chainName,
              contractAddress: widget.contractAddress,
              senderAddress: widget.senderAddress,
              senderPrivateKey: widget.senderPrivateKey,
              mode: AccountStatusMode.single,
              updatedReceiver: widget.recipientAddress,
              updatedAmount: amount,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰 전송 실패: ${result?['msg'] ?? '알 수 없는 오류'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전송 중 오류 발생: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1:1 토큰 전송'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 600, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('수신자 닉네임: ${widget.recipientNickname}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('수신자 주소: ${widget.recipientAddress}',
                style: const TextStyle(fontSize: 16)),
            const Divider(height: 30, thickness: 1),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '전송할 토큰 수량',
                prefixIcon: Icon(Icons.numbers, color: Colors.indigoAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Colors.indigoAccent),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _transferToken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text('토큰 전송'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
