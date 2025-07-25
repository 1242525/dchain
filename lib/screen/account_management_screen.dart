import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screen/transfer_tokenSingle_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  final String token;
  final String chainName;
  final String contractAddress;

  const AccountManagementScreen({
    Key? key,
    required this.token,
    required this.chainName,
    required this.contractAddress,
  }) : super(key: key);

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _selectedAccount;

  final TextEditingController _senderAddressController = TextEditingController();
  final TextEditingController _senderPkeyController = TextEditingController();

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return '-';
    final date = ts.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _senderAddressController.dispose();
    _senderPkeyController.dispose();
    super.dispose();
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigoAccent),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 리스트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 발신자 정보 입력란
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildInput(_senderAddressController, '발신자 주소 입력', Icons.person),
                _buildInput(_senderPkeyController, '발신자 개인키 입력', Icons.vpn_key, obscureText: true),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('account').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('오류 발생: ${snapshot.error}');
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('저장된 계정이 없습니다.'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final nickname = data['nickname'] ?? '-';
                    final address = data['address'] ?? '-';
                    final privateKey = data['privatekey'] ?? '-';
                    final publicKey = data['publickey'] ?? '-';
                    final timestamp = data['timestamp'] as Timestamp?;

                    final isSelected = _selectedAccount != null && _selectedAccount!['address'] == address;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAccount = null;
                          } else {
                            _selectedAccount = {
                              'nickname': nickname,
                              'address': address,
                              'privatekey': privateKey,
                              'publickey': publicKey,
                            };
                          }
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: isSelected ? Colors.indigo.shade100 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? Colors.indigoAccent : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('닉네임: $nickname', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                              const SizedBox(height: 6),
                              Text('주소: $address', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('개인키: $privateKey'),
                              const SizedBox(height: 6),
                              Text('공개키: $publicKey'),
                              const SizedBox(height: 6),
                              Text('등록시간: ${formatTimestamp(timestamp)}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _selectedAccount == null
                  ? null
                  : () {
                if (_senderAddressController.text.trim().isEmpty ||
                    _senderPkeyController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('발신자 주소와 개인키를 입력하세요')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TokenTransferSingleScreen(
                      chainName: widget.chainName,
                      contractAddress: widget.contractAddress,
                      senderAddress: _senderAddressController.text.trim(),
                      senderPrivateKey: _senderPkeyController.text.trim(),
                      recipientAddress: _selectedAccount!['address'],
                      recipientNickname: _selectedAccount!['nickname'],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('1:1 토큰 전송 화면으로 이동'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(220, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
