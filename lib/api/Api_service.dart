import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = 'http://220.149.235.79:5000';


  // 계정 생성 API
  Future<String?> fetchKeyPair() async {
    final url = Uri.parse('$baseUrl/acc/create'); // 실제 API 경로
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
      }),
    );

    if (response.statusCode == 200) {
      return response.body; // JSON 문자열 그대로 리턴
    } else {
      return null;
    }
  }

  //계정 리스트 api
  Future<String?> fetchAccountList() async {
    final url = Uri.parse('$baseUrl/acc/get_list'); // 실제 API 경로
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
      }),
    );

    if (response.statusCode == 200) {
      return response.body; // JSON 문자열 그대로 리턴
    } else {
      return null;
    }
  }

  //개인키 반환
  Future<Map<String, dynamic>?> fetchPrivatekey({
    required String ownerAddr,
  }) async {
    final url = Uri.parse(
        '$baseUrl/acc/get_private_key'); // 실제 API 경로
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "address": ownerAddr,
      }),
    );


    final json = jsonDecode(response.body);
    return json;


  }

  // 공개키 반환
  Future<Map<String, dynamic>?> fetchPublickey({
    required String ownerAddr,
}
      ) async {
    final url = Uri.parse('$baseUrl/acc/get_public_key');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "address": ownerAddr,
      }),
    );
    final json = jsonDecode(response.body);
    return json;
    }


  // 토큰 전송
  Future<Map<String, dynamic>?> fetchTransferToken({
    required String contract_address,
    required String sender,
    required String sender_private_key,
    required String receiver,
    required String amount,
  }) async {
    final url = Uri.parse('$baseUrl/token/transfer');
    final body = jsonEncode({
      "contract_address": contract_address,
      "sender": sender,
      "sender_private_key": sender_private_key,
      "receiver": receiver,
      "amount": amount,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print('응답 body: ${response.body}');
    final json = jsonDecode(response.body);
    print('디코딩 결과 타입: ${json.runtimeType}');
    print('디코딩 결과 내용: $json');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('토큰 전송 성공!');
      return json;
    } else {
      print('HTTP 오류: 상태 코드 ${response.statusCode}');
      print('응답 내용: ${response.body}');
      throw Exception('HTTP 오류: 상태 코드 ${response.statusCode}');
    }
  }

  //계좌 리스트
  Future<List<List<dynamic>>?> fetchBalanceList({
    required String contract_address,
  }) async {
    final url = Uri.parse('http://220.149.235.79:5000/token/balance_list');
    final body = jsonEncode({
      "contract_address": contract_address,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('응답 body: ${response.body}');
    final json = jsonDecode(response.body);
    print('디코딩 결과 타입: ${json.runtimeType}');
    print('디코딩 결과 내용: $json');


    if (response.statusCode == 200) {
      if (json is List) {
        // 내부가 List<dynamic>인 리스트인지 확인 후 변환
        if (json.isNotEmpty && json[0] is List) {
          // JSON 배열을 List<List<dynamic>>로 변환
          return List<List<dynamic>>.from(
              json.map((item) => List<dynamic>.from(item)));
        } else {
          // 혹시 2차원 배열이 아닌 경우라도 List<List<dynamic>> 형태로 맞춤
          return [List<dynamic>.from(json)];
        }
      }
    }

    return null;
  }

  // 토큰 생성
  Future<Map<String, dynamic>?> fetchTokenCreate({
    required String tokenName,
    required String tokenSymbol,
    required String supply,
  }) async {
    final url = Uri.parse('$baseUrl/token/create');
    final body = jsonEncode({
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
    final json = jsonDecode(response.body);
    return json;

  }

  //토큰 회수

  Future<Map<String, dynamic>?> fetchTokenRetrieve({
    required String contract_address,
    required String holder,
    required String receiver,
    required String amount,
  }) async {
    final url = Uri.parse('$baseUrl/token/retrieve');
    final body = jsonEncode({
      "contract_address":contract_address,
      "holder":holder,
      "receiver":receiver,
      "amount":amount,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    final json = jsonDecode(response.body);
    return json;

  }


  //관리자 pkey
  Future<String?> fetchAdminPkey() async {
    final url = Uri.parse('$baseUrl/acc/get_owner_info'); // 실제 API 경로
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
      }),
    );

    if (response.statusCode == 200) {
      return response.body; // JSON 문자열 그대로 리턴
    } else {
      return null;
    }
  }

  // 계좌 잔액 조회
  Future<String?> fetchTokenBalance({

    required String accountAddress,
  }) async {
    final url = Uri.parse('$baseUrl/token/balance');
    final body = jsonEncode({

      "addr": accountAddress,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json;

    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchTokenBurn({
    required String holderAddr,
    required String holderPkey,
    required String amount,
  }) async {
    final url = Uri.parse('$baseUrl/token/burn');
    final body = jsonEncode({
      "holder": holderAddr,
      "holder_pkey": holderPkey,
      "amount": amount,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );


    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  }

}
