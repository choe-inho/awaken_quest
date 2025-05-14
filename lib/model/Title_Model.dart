// lib/model/Title_Model.dart
import 'package:hive/hive.dart';

import '../utils/manager/Import_Manager.dart';

part 'Title_Model.g.dart';

@HiveType(typeId: 1)
class TitleModel {
  // 칭호 고유 ID
  @HiveField(0)
  final String id;

  // 칭호 이름
  @HiveField(1)
  final String name;

  // 칭호 설명
  @HiveField(2)
  final String description;

  // 칭호 등급 (0: 일반, 1: 희귀, 2: 영웅, 3: 전설)
  @HiveField(3)
  final int rarity;

  // 획득 조건 유형 (예: mission_complete, level_up, streak 등)
  @HiveField(4)
  final String conditionType;

  // 조건 값 (예: 10번의 미션, 레벨 5 등)
  @HiveField(5)
  final int conditionValue;

  // 칭호 색상 (16진수 문자열)
  @HiveField(6)
  final String colorHex;

  // 특수 효과 (true/false)
  @HiveField(7)
  final bool hasEffect;

  // 획득 날짜 (nullable)
  @HiveField(8)
  final DateTime? acquiredAt;

  // 칭호 이미지/아이콘 경로
  @HiveField(9)
  final String iconPath;

  const TitleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.conditionType,
    required this.conditionValue,
    required this.colorHex,
    this.hasEffect = false,
    this.acquiredAt,
    required this.iconPath,
  });

  // 색상 헥스 코드를 Color로 변환하는 유틸 함수
  Color get color {
    final hexCode = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // 등급에 따른 배경 색상
  Color get rarityColor {
    switch (rarity) {
      case 0: // 일반
        return Colors.green.withValues(alpha: 0.7);
      case 1: // 희귀
        return Colors.blue.withValues(alpha: 0.7);
      case 2: // 영웅
        return Colors.purple.withValues(alpha: 0.7);
      case 3: // 전설
        return Colors.orange.withValues(alpha: 0.7);
      default:
        return Colors.grey.withValues(alpha: 0.7);
    }
  }

  // 등급에 따른 표시 이름
  String get rarityName {
    switch (rarity) {
      case 0: return "일반";
      case 1: return "희귀";
      case 2: return "영웅";
      case 3: return "전설";
      default: return "미확인";
    }
  }

  // 획득 여부
  bool get isAcquired => acquiredAt != null;

  // 사본 생성 (획득 시간 설정용)
  TitleModel copyWith({DateTime? acquiredAt}) {
    return TitleModel(
      id: id,
      name: name,
      description: description,
      rarity: rarity,
      conditionType: conditionType,
      conditionValue: conditionValue,
      colorHex: colorHex,
      hasEffect: hasEffect,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      iconPath: iconPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'acquiredAt': acquiredAt?.toIso8601String(),
    };
  }

  factory TitleModel.fromJson(Map<String, dynamic> json, TitleModel baseTitle) {
    final acquiredAtString = json['acquiredAt'] as String?;
    final acquiredAt = acquiredAtString != null
        ? DateTime.parse(acquiredAtString)
        : null;

    return baseTitle.copyWith(acquiredAt: acquiredAt);
  }
}