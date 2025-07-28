import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/Api_service.dart';

class PublickeyScreen extends StatefulWidget {
  const PublickeyScreen({Key? key}) : super(key: key);

  @override
  State<PublickeyScreen> createState() => _PublickeyScreenState();
}

class _PublickeyScreenState extends State<PublickeyScreen> {
  final _ownerAddrController = TextEditingController();
  bool _isLoading = false;
  String? _publicKey;
  String? _privateKey;

  Future<void> _fetchPublickeyKey() async {
    setState(() {
      _isLoading = true;
      _publicKey = null;
      _privateKey=null;
    });

    final owner = _ownerAddrController.text.trim();

    final publicKeyresult = await ApiService().fetchPublickey(ownerAddr: owner);
    final privateKeyresult = await ApiService().fetchPrivatekey(ownerAddr: owner);

    setState(() {
      _isLoading = false;

      // 전체 결과 출력
      print('🔍 API 응답 전체: $publicKeyresult');
      print('🔍 API 응답 전체: $privateKeyresult');

      if (publicKeyresult == null) {
        print('❌ 서버 응답이 null 입니다.');
      } else {
        _publicKey = publicKeyresult?['public_key'] ?? '(공개키 없음)';
        _privateKey = privateKeyresult?['private_key'] ?? '(개인키 없음)';

        // 디버깅용 상세 출력
        print('✅ 성공!');
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공개키+개인키 조회')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ownerAddrController,
              decoration: const InputDecoration(
                labelText: '주소 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchPublickeyKey,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('키 조회'),
            ),
            const SizedBox(height: 20),
            if (_publicKey != null)
              SelectableText(
                "공개키: $_publicKey",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (_privateKey != null)
              SelectableText(
                "개인키: $_privateKey",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
