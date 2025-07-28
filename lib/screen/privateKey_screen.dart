/*import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/Api_service.dart';

class PrivatekeyScreen extends StatefulWidget {
  const PrivatekeyScreen({Key? key}) : super(key: key);

  @override
  State<PrivatekeyScreen> createState() => _PrivatekeyScreenState();
}

class _PrivatekeyScreenState extends State<PrivatekeyScreen> {
  final _ownerAddrController = TextEditingController();
  bool _isLoading = false;
  String? _privateKey;

  Future<void> _fetchPrivateKey() async {
    setState(() {
      _isLoading = true;
      _privateKey = null;
    });

    final owner = _ownerAddrController.text.trim();

    final result = await ApiService().fetchPrivatekey(ownerAddr: owner);

    setState(() {
      _isLoading = false;

      // 전체 결과 출력
      print('🔍 API 응답 전체: $result');

      if (result == null) {
        print('❌ 서버 응답이 null 입니다.');
      } else {
        _privateKey = result['private_key'] ?? '(키 없음)';


        // 디버깅용 상세 출력
        print('✅ 성공!');
        print('📌 private_key: $_privateKey');
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프라이빗 키 조회')),
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
              onPressed: _isLoading ? null : _fetchPrivateKey,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('프라이빗 키 조회'),
            ),
            const SizedBox(height: 20),
            if (_privateKey != null)
              SelectableText(
                "프라이빗 키: $_privateKey",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

 */
