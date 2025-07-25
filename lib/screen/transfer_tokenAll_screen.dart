import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Api/Api_service.dart';
import '../screen/token_balance.dart';

class TokenTransferScreen extends StatefulWidget {
  final String chainName;
  final String contractAddress;
  final String senderAddress;
  final String senderPrivateKey;

  const TokenTransferScreen({
    Key? key,
    required this.chainName,
    required this.contractAddress,
    required this.senderAddress,
    required this.senderPrivateKey,
  }) : super(key: key);

  @override
  State<TokenTransferScreen> createState() => _TokenTransferScreenState();
}

class _TokenTransferScreenState extends State<TokenTransferScreen> {
  final ApiService apiService = ApiService();

  bool _isLoading = false;
  String _statusMessage = "";

  // 사용자의 토큰 입력 대신 .env 토큰 사용 권장
  // 초기값은 .env에 설정된 토큰, 없으면 빈 문자열
  final TextEditingController _tokenController = TextEditingController(text: '');
  final TextEditingController _amountController =
  TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    // .env 토큰 자동 세팅 (필요시)
    final envToken = dotenv.env['API_TOKEN'] ?? '';
    if (envToken.isNotEmpty) {
      _tokenController.text = envToken;
    }
  }

  // 3회 재시도 로직
  Future<Map<String, dynamic>?> tryTransferWithRetry({
    required String token,
    required String receiverAddr,
    required String amount,
  }) async {
    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      final result = await apiService.transferToken(
        chainName: widget.chainName,
        contractAddress: widget.contractAddress,
        sender: widget.senderAddress,
        senderPkey: widget.senderPrivateKey,
        receiver: receiverAddr,
        amount: amount,
      );

      if (result != null && result['state'] == 'OK') {
        return result;
      }

      attempt++;
      await Future.delayed(const Duration(seconds: 3));
    }

    return null;
  }

  // 동시 최대 concurrency개씩 처리하는 병렬 전송 구현
  Future<void> _autoTransferTokens(String token, String amount) async {
    final accountsSnapshot = await FirebaseFirestore.instance
        .collection('account')
        .limit(100)
        .get();

    final docs = accountsSnapshot.docs;
    const concurrency = 1; // 동시 전송 제한
    int running = 0;
    int index = 0;

    final completers = <Future>[];

    Future<void> runNext() async {
      if (index >= docs.length) return;

      final doc = docs[index];
      index++;
      running++;

      final data = doc.data();
      final receiverAddr = data['address'];
      if (receiverAddr == null || receiverAddr.isEmpty) {
        running--;
        runNext();
        return;
      }

      final result = await tryTransferWithRetry(
        token: token,
        receiverAddr: receiverAddr,
        amount: amount,
      );

      await FirebaseFirestore.instance.collection('transfer').add({
        'sender': widget.senderAddress,
        'receiver': receiverAddr,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'status': result != null && result['state'] == 'OK' ? 'success' : 'fail',
        'response': result ?? {},
      });

      running--;
      runNext();
    }

    // concurrency 만큼 초기 실행
    for (int i = 0; i < concurrency && i < docs.length; i++) {
      runNext();
    }

    // 모든 작업 완료 대기
    while (running > 0) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _startTransferAndGoToStatusScreen() {
    // .env API_TOKEN을 기본값으로 쓰고, 입력값은 덮어쓰기 가능
    final token = _tokenController.text.trim();
    final amount = _amountController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('토큰 ID를 입력하세요')),
      );
      return;
    }
    if (amount.isEmpty || int.tryParse(amount) == null || int.parse(amount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 토큰 수량을 입력하세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "전송 시작, 상태 화면으로 이동합니다...";
    });

    // 전송 백그라운드 실행
    _autoTransferTokens(token, amount).whenComplete(() {
      setState(() {
        _isLoading = false;
        _statusMessage = "전송 작업 완료";
      });
    });

    // 전송 상태 화면으로 이동 (전송 시작하자마자)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AccountStatusScreen(
          tokenId: token,
          chainName: widget.chainName,
          contractAddress: widget.contractAddress,
          senderAddress: widget.senderAddress,
          senderPrivateKey: widget.senderPrivateKey,
          mode: AccountStatusMode.batch,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자동 토큰 전송'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: '토큰 ID 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: const Icon(Icons.vpn_key, color: Colors.indigoAccent),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '전송할 토큰 수량 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: const Icon(Icons.numbers, color: Colors.indigoAccent),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _startTransferAndGoToStatusScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('자동 토큰 전송 시작'),
            ),
            const SizedBox(height: 30),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains('완료') ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
