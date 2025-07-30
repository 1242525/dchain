import 'package:flutter/material.dart';
import '../api/Api_service.dart';


class TokenRetrieve extends StatefulWidget {


  @override
  State<TokenRetrieve> createState() => _TokenRetrieveState();
}

class _TokenRetrieveState extends State<TokenRetrieve> {

  final _contractAdressController = TextEditingController();
  final _holderController = TextEditingController();
  final _recieverController = TextEditingController();
  final _amountController = TextEditingController();

  Map<String, dynamic>?_RetrieveTokenData;
  bool _isLoading = false;
  String? _error;

  Future<void> _transferToken() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final contract_address = _contractAdressController.text.trim();
    final holder = _holderController.text.trim();
    final receiver = _recieverController.text.trim();
    final amount = _amountController.text.trim();


    try{
      final api = ApiService();
      final result = await api.fetchTokenRetrieve(
          contract_address: contract_address,
          holder: holder, receiver: receiver,
          amount: amount);

      if (result != null) {
        print('토큰 회수 결과: $result');
        setState(() {
          _RetrieveTokenData = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'error';
        });
      }
    }
    catch(e, stacktrace){
      print('토큰 회수 중 예외 발생: $e');
      print('스택 트레이스: $stacktrace');
      setState(() {
        _error = '네트워크 오류가 발생했습니다.';
        _isLoading = false;
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

  Widget _buildActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _transferToken,
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
            label: Text(_isLoading ? '처리중...' : '토큰 회수'),
          ),
        ),

      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('토큰 회수'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 150, left: 600, right: 600),
        child: Column(
          children: [
            _buildInput(
                _contractAdressController, '컨트랙트 주소', Icons.contact_page),
            _buildInput(_holderController, '홀더 주소', Icons.person),
            _buildInput(_recieverController, '받는 사람', Icons.person),
            _buildInput(_amountController, '수량', Icons.monetization_on),
            const SizedBox(height: 30),
            _buildActionButton(),
            const SizedBox(height: 24),
            if (_RetrieveTokenData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${_RetrieveTokenData!['Date'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Sender: ${_RetrieveTokenData!['Target'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Receiver: ${_RetrieveTokenData!['Amount'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),

                ],
              ),
          ],
        ),
      ),
    );
  }
}