import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/Api_service.dart';
import 'package:flutter/services.dart'; //클립보드

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({Key? key}) : super(key: key);

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<dynamic> accountList = []; // API로 받은 계정 리스트
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAccounts(); // 화면 들어오자마자 API 호출
  }

  Future<void> fetchAccounts() async {
    try {
      final result = await ApiService().fetchAccountList();
      if (result == null) throw Exception("API 응답이 없습니다.");

      final Map<String, dynamic> jsonMap = jsonDecode(result);
      final List<String> accounts = jsonMap.values.map((e) => e.toString()).toList();

      setState(() {
        accountList = accounts;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
        title: const Text('계정 리스트'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('에러: $error'))
          : ListView.builder(
        itemCount: accountList.length,
        itemBuilder: (context, index) {
          final address = accountList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),

            child: InkWell(  // 클립보드 가능하게 하는 코드
              onTap: () {
                Clipboard.setData(ClipboardData(text: address)); //클립보드에 복사
                ScaffoldMessenger.of(context).showSnackBar( //복사 완료 안내 스낵바
                  SnackBar(content: Text('주소가 클립보드에 복사되었습니다!')),
                );
              },

              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }


}
