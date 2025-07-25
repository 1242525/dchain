import 'dart:math';

class NicknameGenerator {
  static final List<String> _adjectives = [
    "귀여운", "용감한", "빠른", "푸른", "빛나는",
    "작은", "행복한", "깜찍한", "조용한", "우아한",
    "반짝이는", "날쌘", "활기찬", "달콤한", "재밌는",
    "든든한", "사나운", "순한", "포근한", "든든한"
  ];

  static final List<String> _nouns = [
    "토끼", "호랑이", "펭귄", "드래곤", "고래",
    "여우", "사슴", "늑대", "독수리", "거북이",
    "사자", "고양이", "강아지", "판다", "코알라",
    "햄스터", "돌고래", "까치", "부엉이", "참새"
  ];

  static final Random _random = Random();

  /// 중복 없는 닉네임 n개 생성
  static List<String> generateNicknames(int count) {
    final List<String> allCombos = [];

    for (var adj in _adjectives) {
      for (var noun in _nouns) {
        allCombos.add("$adj $noun");
      }
    }

    allCombos.shuffle(_random);

    if (count > allCombos.length) {
      count = allCombos.length;
    }

    return allCombos.sublist(0, count);
  }

}
