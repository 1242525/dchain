import 'package:flutter/material.dart';
import '../screen/Token_create_screen.dart';
import 'account_list_screen.dart';
import '../screen/account_create.dart';
import '../screen/publickey_screen.dart';
import '../screen/transfer_tokenAll_screen.dart';
import '../screen/balance_list.dart';
import '../screen/token_retrieve.dart';
import '../screen/owner_privatekey.dart';

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
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '토큰 전송하기',
                icon: Icons.money,
                onPressed: () async {
                  // 필요하다면 async 작업 수행
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TokenTransferScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '잔액 조회하기',
                icon: Icons.list,
                onPressed: () async {
                  // 필요하다면 async 작업 수행
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BalanceList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '토큰 회수하기',
                icon: Icons.reset_tv,
                onPressed: () async {
                  // 필요하다면 async 작업 수행
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TokenRetrieve(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                text: '오너 개인키',
                icon: Icons.key,
                onPressed: () async {
                  // 필요하다면 async 작업 수행
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OwnerPrivatekey(),
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
