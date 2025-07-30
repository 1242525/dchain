/*import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  // 토큰 관련 정보 저장
  static Future<void> saveTokenInfo({
    required String tokenId,
    required String contractAddress,
    required String ownerAddr,
    required String ownerPkey,
    required String chainName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenId', tokenId);
    await prefs.setString('contractAddress', contractAddress);
    await prefs.setString('ownerAddr', ownerAddr);
    await prefs.setString('ownerPkey', ownerPkey);
    await prefs.setString('chainName', chainName);
  }

  static Future<String?> getTokenId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenId');
  }

  static Future<String?> getContractAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('contractAddress');
  }

  static Future<String?> getOwnerAddr() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ownerAddr');
  }

  static Future<String?> getOwnerPkey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ownerPkey');
  }

  static Future<String?> getChainName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('chainName');
  }
}

 */
