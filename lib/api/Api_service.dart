import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // .env에서 값 읽어오기 (null일 경우 대비 필수 환경변수로 설정)
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://www.daegu.go.kr/daeguchain/v2/mitum';
  static final String token = dotenv.env['API_TOKEN'] ?? 'ddfe8284753b0bdd2aff8249b09157b7';
  static final String chainName = dotenv.env['CHAIN_NAME'] ?? 'dchain';

  // 계정 생성 API
  Future<String?> fetchKeyPair({
    required String chainName,
  }) async {
    final url = Uri.parse('$baseUrl/com/acc_create'); // 실제 API 경로
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "chain": chainName,
      }),
    );

    if (response.statusCode == 200) {
      return response.body; // JSON 문자열 그대로 리턴
    } else {
      return null;
    }
  }

  // 토큰 전송
  Future<Map<String, dynamic>?> transferToken({
    required String chainName,
    required String contractAddress,
    required String sender,
    required String senderPkey,
    required String receiver,
    required String amount,
  }) async {
    final url = Uri.parse('$baseUrl/token/transfer');
    final body = jsonEncode({
      "token": token,
      "chain": chainName,
      "cont_addr": contractAddress,
      "sender": sender,
      "sender_pkey": senderPkey,
      "receiver": receiver,
      "amount": amount,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('[TOKEN TRANSFER] status: ${response.statusCode}');
    print('[TOKEN TRANSFER] body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['state'] == 'OK') return json;
      print('전송 실패: ${json['msg']}');
    } else {
      print('HTTP 에러: ${response.statusCode}');
    }

    return null;
  }

  // 토큰 생성
  Future<Map<String, dynamic>?> fetchTokenCreate({
    required String chainName,
    required String ownerAddr,
    required String ownerPkey,
    required String tokenName,
    required String tokenSymbol,
    required String supply,
  }) async {
    final url = Uri.parse('$baseUrl/token/create');
    final body = jsonEncode({
      "token": token,
      "chain": chainName,
      "owner_addr": ownerAddr,
      "owner_pkey": ownerPkey,
      "token_name": tokenName,
      "token_symbol": tokenSymbol,
      "decimals": 9,
      "supply": supply,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('📥 API 응답 상태코드: ${response.statusCode}');
    print('📥 API 응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'error': '요청 실패',
        'status': response.statusCode,
        'body': response.body,
      };
    }
  }

  // 토큰 발행하기
  Future<Map<String, dynamic>?> fetchTokenMint({
    required String chainName,
    required String contractAddress,
    required String owner,
    required String privateKey,
    required String receiverAddress,
    required String amount,
  }) async {
    final url = Uri.parse('$baseUrl/token/mint');
    final body = jsonEncode({
      "token": token,
      "chain": chainName,
      "cont_addr": contractAddress,
      "owner": owner,
      "owner_pkey": privateKey,
      "receiver": receiverAddress,
      "amount": amount,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('📤 Mint 요청 바디: $body');
    print('📥 상태코드: ${response.statusCode}');
    print('📥 본문: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'error': true,
        'status': response.statusCode,
        'body': response.body,
      };
    }
  }

  // 계좌 잔액 조회
  Future<String?> fetchTokenBalance({
    required String chainName,
    required String contractAddress,
    required String accountAddress,
  }) async {
    final url = Uri.parse('$baseUrl/token/balance');
    final body = jsonEncode({
      "token": token,
      "chain": chainName,
      "cont_addr": contractAddress,
      "addr": accountAddress,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('📥 응답 데이터: $json');

      final balance = json['data']?['balance'];
      if (balance != null) {
        return balance.toString();
      }
    }

    return null;
  }
}
