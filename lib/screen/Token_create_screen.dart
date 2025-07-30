import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/Api_service.dart';
import 'dart:convert';


class TokenCreateScreen extends StatefulWidget {
  const TokenCreateScreen({super.key});

  @override
  State<TokenCreateScreen> createState() => _TokenCreateScreenState();
}

class _TokenCreateScreenState extends State<TokenCreateScreen> {


  final _tokenNameController = TextEditingController();
  final _tokenSymbolController = TextEditingController();
  final _supplyController = TextEditingController();


  Map<String, dynamic>? _CreateTokenData;
  bool _isLoading = false;
  String? _error;


  Future<void> _createToken() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _CreateTokenData = null;
    });

    final tokenName = _tokenNameController.text.trim();
    final tokenSymbol = _tokenSymbolController.text.trim();
    final supply = _supplyController.text.trim();

    final api = ApiService();
    final result = await api.fetchTokenCreate(
        tokenName: tokenName,
        tokenSymbol: tokenSymbol,
        supply: supply);

    if (result != null) {
      setState(() {
        _CreateTokenData = result;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'error';
      });
    }
  }



    //⬇️ 공통 TextField 디자인
    Widget _buildInput(TextEditingController controller, String label,
        IconData icon,
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
            contentPadding: const EdgeInsets.symmetric(
                vertical: 18, horizontal: 16),
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
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
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
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.add_circle_outline),
              label: Text(_isLoading ? '처리중...' : '토큰 생성 및 발행'),
            ),
          ),

        ],
      );
    }




    @override
    void dispose() {
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
              _buildInput(_tokenNameController, '토큰 이름', Icons.emoji_symbols),
              _buildInput(_tokenSymbolController, '토큰 심볼', Icons.abc),
              _buildInput(
                  _supplyController, '총 공급량', Icons.numbers, isNumber: true),
              const SizedBox(height: 30),
              _buildActionButton(),
              const SizedBox(height: 24),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_CreateTokenData != null)
                GestureDetector(
                    onTap: (){
                      final contractAddress=_CreateTokenData!['contract address']??'-';
                      Clipboard.setData(ClipboardData(text:contractAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('컨트랙트 주소가 복사되었습니다!')),
                      );

                    },

                child: Text(
                  '컨트랙트 주소: ${_CreateTokenData!['contract address'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),



                )
            ],
          ),
        ),
      );
    }
  }

