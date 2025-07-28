import 'package:flutter/material.dart';
import '../api/SharedPreference.dart';
import '../screen/Token_create_screen.dart';
import 'account_list_screen.dart';
import '../screen/account_management_screen.dart';
import '../screen/token_balance.dart';
import '../screen/account_create.dart';
import '../screen/token_burn_screen.dart';
import '../screen/privateKey_screen.dart';
import '../screen/publickey_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('홈'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHomeButton(
                context,
                text: '토큰 생성',
                icon: Icons.token,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TokenCreateScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '회원 가입',
                icon: Icons.person,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '토큰 1:1 전송',
                icon: Icons.send,
                onPressed: () async {
                  final tokenId = await PrefsHelper.getTokenId();
                  final contractAddress = await PrefsHelper.getContractAddress();
                  final chainName = await PrefsHelper.getChainName();

                  if (tokenId == null || contractAddress == null || chainName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 토큰을 생성해주세요')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountManagementScreen(
                        token: tokenId,
                        chainName: chainName,
                        contractAddress: contractAddress,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '계정 리스트',
                icon: Icons.list,
                onPressed: () async {
                  // 필요하다면 async 작업 수행
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '공개키+개인키 찾기',
                icon: Icons.key,
                onPressed: () async {
                  // 필요하다면 async 작업 수행
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublickeyScreen(),
                    ),
                  );
                },
              ),

              /*
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '계정 리스트 + 일괄 지급',
                icon: Icons.group,
                onPressed: () async {
                  final tokenId = await PrefsHelper.getTokenId();
                  final contract = await PrefsHelper.getContractAddress();
                  final chain = await PrefsHelper.getChainName();

                  if (tokenId == null || contract == null || chain == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 토큰을 생성해주세요')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountListScreen(
                        token: tokenId,
                        chainName: chain,
                        contractAddress: contract,
                      ),
                    ),
                  );
                },
              ),


              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '토큰 소각하기',
                icon: Icons.group,
                onPressed: () async {
                  final tokenId = await PrefsHelper.getTokenId();
                  final contract = await PrefsHelper.getContractAddress();
                  final chain = await PrefsHelper.getChainName();

                  if (tokenId == null || contract == null || chain == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 토큰을 생성해주세요')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountListScreen(
                        token: tokenId,
                        chainName: chain,
                        contractAddress: contract,
                      ),
                    ),
                  );
                },
              ),

               */

              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '계정 잔액 보기',
                icon: Icons.list_alt,
                onPressed: () async {
                  final tokenId = await PrefsHelper.getTokenId();
                  final contractAddress = await PrefsHelper.getContractAddress();
                  final chainName = await PrefsHelper.getChainName();

                  // 필요한 경우 sender 주소 등도 가져오기
                  final senderAddress = 'your_sender_address';       // 실제 값으로 대체
                  final senderPrivateKey = 'your_private_key';       // 실제 값으로 대체

                  if (tokenId == null || contractAddress == null || chainName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 토큰을 생성해주세요')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountStatusScreen(
                        tokenId: tokenId,
                        chainName: chainName,
                        contractAddress: contractAddress,
                        senderAddress: senderAddress,
                        senderPrivateKey: senderPrivateKey,
                        mode: AccountStatusMode.batch,

                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  버튼
  Widget _buildHomeButton(
      BuildContext context, {
        required String text,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: 260,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.indigoAccent),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.indigoAccent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.indigoAccent, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
