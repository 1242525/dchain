import 'package:flutter/material.dart';
import '../api/Api_service.dart';
import 'package:flutter/services.dart';


class BalanceList extends StatefulWidget {


  @override
  State<BalanceList> createState() => _BalanceListState();
}

class _BalanceListState extends State<BalanceList> {

  final _contractAdressController = TextEditingController();


  List<List<dynamic>>? _balanceListData;
  bool _isLoading = false;
  String? _error;

  Future<void> _balanceList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final contract_address = _contractAdressController.text.trim();



    try{
      final api = ApiService();
      final result = await api.fetchBalanceList(
          contract_address: contract_address);

      if (result != null) {
        print('잔액 조회 결과: $result');
        setState(() {
          _balanceListData = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'error';
        });
      }
    }
    catch(e, stacktrace){
      print('예외 발생: $e');
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
            onPressed: _isLoading ? null : _balanceList,
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
            label: Text(_isLoading ? '처리중...' : '잔액 조회'),
          ),
        ),

      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('잔액 조회'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 150, left: 600, right: 600),
        child: Column(
          children: [
            _buildInput(
                _contractAdressController, '컨트랙트 주소', Icons.contact_page),
            const SizedBox(height: 30),
            _buildActionButton(),
            const SizedBox(height: 24),
            if (_balanceListData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _balanceListData!.map((entry) {
                  final address = entry[0];
                  final balance = entry[1];
                  return GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('주소가 복사되었습니다!')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('Address: $address / Balance: $balance'),
                    ),
                  );
                }).toList(),
              ),
          ], // <- 여기 외부 Column children 닫는 대괄호
        ),

      ),
    );
  }

}