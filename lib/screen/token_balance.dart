import '../screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/Api_service.dart';

enum AccountStatusMode {
  batch,
  single,
}

class AccountStatusScreen extends StatefulWidget {
  final String tokenId;
  final String chainName;
  final String contractAddress;
  final String senderAddress;
  final String senderPrivateKey;

  final AccountStatusMode mode;
  final String? updatedReceiver;
  final String? updatedAmount;

  const AccountStatusScreen({
    Key? key,
    required this.tokenId,
    required this.chainName,
    required this.contractAddress,
    required this.senderAddress,
    required this.senderPrivateKey,
    required this.mode,
    this.updatedReceiver,
    this.updatedAmount,
  }) : super(key: key);

  @override
  State<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, String> _balances = {};
  Map<String, String> _statuses = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();  // 화면 시작 시 데이터 불러오기
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;  // 로딩 시작 표시
    });

    await updateFromBatchTransfer();

    if (widget.mode == AccountStatusMode.single && widget.updatedReceiver != null) {
      final balance = await ApiService().fetchTokenBalance(
        chainName: widget.chainName,
        contractAddress: widget.contractAddress,
        accountAddress: widget.updatedReceiver!,
      );
      if (balance != null && mounted) {
        updateFromSingleTransfer(widget.updatedReceiver!, balance);
      }
    }

    setState(() {
      _isLoading = false;  // 로딩 종료 표시
    });
  }

  // Firestore에서 일괄 전송 기록 불러와 balances & statuses 업데이트
  Future<void> updateFromBatchTransfer() async {
    try {
      final snapshot = await firestore.collection('transfer').get();
      final balances = <String, String>{};
      final statuses = <String, String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final receiver = (data['receiver'] ?? '').toString().toLowerCase();
        final amount = (data['amount'] ?? '').toString();
        final status = (data['status'] ?? '성공').toString();

        if (receiver.isNotEmpty) {
          balances[receiver] = amount;
          statuses[receiver] = status;
        }
      }

      if (mounted) {
        setState(() {
          _balances = balances;
          _statuses = statuses;
        });
      }
    } catch (e) {
      debugPrint('Firestore 데이터 불러오기 오류: $e');
    }
  }


  // 단일 전송 후 특정 수신자 잔액 및 상태 덮어쓰기
  void updateFromSingleTransfer(String receiver, String balance) {
    if (!mounted) return;
    final addr = receiver.toLowerCase();
    debugPrint('💡 단일 전송 잔액 덮어쓰기: $addr / $balance');
    setState(() {
      _balances[addr] = balance;
      _statuses[addr] = 'success';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('전체 계정 잔액 및 상태'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
        actions: [
          _isLoading
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.indigoAccent,
                strokeWidth: 2,
              ),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: '홈으로 이동',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('account').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류 발생: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('등록된 계정이 없습니다.'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('닉네임')),
                          DataColumn(label: Text('주소')),
                          DataColumn(label: Text('잔액')),
                          DataColumn(label: Text('상태')),
                        ],
                        rows: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nickname = data['nickname'] ?? '-';
                          final address = (data['address'] ?? '-').toString().toLowerCase();
                          final balance = _balances[address] ?? '조회중...';
                          final status = _statuses[address] ?? '대기중';

                          return DataRow(cells: [
                            DataCell(Text(nickname)),
                            DataCell(Text(address)),
                            DataCell(Text(balance)),
                            DataCell(Text(status)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
