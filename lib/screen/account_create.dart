import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/Api_service.dart';
import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _chainController = TextEditingController(text: 'dchain');

  Map<String, dynamic>? _keyPairData;
  bool _isLoading = false;
  String? _error;

  final primaryColor = const Color(0xFF08174A);
  final labelTextColor = const Color(0xFF08174A);

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _keyPairData = null;
      _error = null;
    });

    final api = ApiService();
    final result = await api.fetchKeyPair(
      chainName: _chainController.text.trim(),
    );


    setState(() {
      _isLoading = false;
      if (result != null) {
        try {
          final Map<String, dynamic> jsonMap = json.decode(result);
          if (jsonMap['state'] == 'OK' && jsonMap['data']?['key_pair'] != null) {
            _keyPairData = Map<String, dynamic>.from(jsonMap['data']['key_pair']);

            // 여기서 JSON 파일 다운로드 실행
            final jsonString = json.encode(_keyPairData);
            final bytes = utf8.encode(jsonString);
            final blob = html.Blob([bytes], 'application/json');
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..setAttribute('download',
                  'identity_${DateTime.now().toIso8601String()}.json')
              ..click();
            html.Url.revokeObjectUrl(url);

          } else {
            _error = '키 페어 데이터를 찾을 수 없습니다.';
          }
        } catch (e) {
          _error = 'JSON 파싱 오류: $e';
        }
      } else {
        _error = '서버 응답이 없습니다.';
      }
    });

  }

  Widget _buildCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: labelTextColor)),
            const SizedBox(height: 8),
            SelectableText(value, style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _chainController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: primaryColor),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: '토큰',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? '토큰을 입력하세요.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _chainController,
                    decoration: InputDecoration(
                      labelText: '체인명',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? '체인명을 입력하세요.' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
