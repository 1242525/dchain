import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api/Api_service.dart';
import '../screen/transfer_tokenAll_screen.dart';
import '../screen/nickname.dart';

class AccountListScreen extends StatefulWidget {
  final String token;
  final String chainName;
  final String contractAddress;

  const AccountListScreen({
    Key? key,
    required this.token,
    required this.chainName,
    required this.contractAddress,
  }) : super(key: key);

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  final firestore = FirebaseFirestore.instance;
  final apiService = ApiService();

  final TextEditingController _senderAddressController = TextEditingController();
  final TextEditingController _senderPkeyController = TextEditingController();

  bool isLoading = false;

  // 계정 100개 재생성 함수 (토큰과 체인 이름을 .env에서 읽도록 수정)
  Future<void> regenerate100Accounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 기존 계정 모두 삭제
      final snapshot = await firestore.collection('account').get();
      final batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 중복 닉네임, 주소 체크용 집합
      final usedNicknames = <String>{};
      final usedAddresses = <String>{};

      // 충분히 많은 닉네임 생성 후 중복 없이 100개 추출
      final allNicknames = NicknameGenerator.generateNicknames(200);
      final nicknames = <String>[];
      for (final n in allNicknames) {
        if (!usedNicknames.contains(n)) {
          nicknames.add(n);
          usedNicknames.add(n);
          if (nicknames.length == 100) break;
        }
      }

      // 환경변수에서 토큰과 체인명 읽기
      final token = dotenv.env['API_TOKEN'] ?? '';
      final chain = dotenv.env['CHAIN_NAME'] ?? '';

      if (token.isEmpty || chain.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API_TOKEN 또는 CHAIN_NAME 환경변수가 설정되지 않았습니다.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      int createdCount = 0;
      while (createdCount < 100) {
        // ApiService 쪽 fetchKeyPair 메서드가 token 파라미터 받도록 가정
        final responseBody = await apiService.fetchKeyPair(
          chainName: chain,
        );

        if (responseBody != null) {
          final jsonData = jsonDecode(responseBody);
          final keyPair = jsonData['data']['key_pair'];
          final address = keyPair['address'];

          if (usedAddresses.contains(address)) {
            print("[중복 주소 발견] $address - 재생성 시도");
            continue; // 중복이면 재시도
          }

          await firestore.collection('account').add({
            'nickname': nicknames[createdCount],
            'privatekey': keyPair['privatekey'],
            'publickey': keyPair['publickey'],
            'address': address,
            'timestamp': FieldValue.serverTimestamp(),
          });

          usedAddresses.add(address);
          print("[$createdCount] 저장 성공: $address (닉네임: ${nicknames[createdCount]})");
          createdCount++;
        } else {
          print("[API 응답 없음] 재시도");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정 100개 재생성 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정 재생성 중 오류 발생: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addNicknamesToExistingAccounts() async {
    final snapshot = await firestore.collection('account').get();

    // 닉네임 없는 문서만 필터링
    final docsWithoutNickname = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['nickname'] == null || data['nickname'].toString().isEmpty;
    }).toList();

    final nicknames = NicknameGenerator.generateNicknames(docsWithoutNickname.length);

    for (int i = 0; i < docsWithoutNickname.length; i++) {
      try {
        await docsWithoutNickname[i].reference.update({
          'nickname': nicknames[i],
        });
        print("[$i] 닉네임 업데이트 성공: ${nicknames[i]}");
      } catch (e) {
        print("[$i] 닉네임 업데이트 실패: $e");
      }
    }

    print("기존 닉네임 없는 계정 ${docsWithoutNickname.length}개에 닉네임 추가 완료");
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 600, right: 600),
        child: Column(
          children: [
            _buildInput(_senderAddressController, '발신자 주소 입력', Icons.person),
            _buildInput(_senderPkeyController, '발신자 개인키 입력', Icons.vpn_key, obscureText: true),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
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
                    builder: (_) => TokenTransferScreen(
                      chainName: widget.chainName,
                      contractAddress: widget.contractAddress,
                      senderAddress: _senderAddressController.text.trim(),
                      senderPrivateKey: _senderPkeyController.text.trim(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text("토큰 전송 화면으로 이동"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(220, 50),
              ),
            ),

            const SizedBox(height: 24),

            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('account')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('오류 발생: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text('저장된 계정이 없습니다.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final nickname = data['nickname'] ?? '-';
                    final address = data['address'] ?? '-';
                    final privateKey = data['privatekey'] ?? '-';
                    final publicKey = data['publickey'] ?? '-';
                    final timestamp = data['timestamp'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF6DA0FE)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '닉네임: $nickname',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '주소: $address',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '개인키: $privateKey',
                              style: const TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '공개키: $publicKey',
                              style: const TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '등록시간: ${formatTimestamp(timestamp)}',
                              style: const TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : regenerate100Accounts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 50),
                  ),
                  child: isLoading
                      ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text('계정 100개 재생성 중...'),
                    ],
                  )
                      : const Text('계정 100개 재생성'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
