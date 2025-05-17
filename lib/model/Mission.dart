import 'dart:math';

import 'package:awaken_quest/utils/handler/Hive_Handler.dart';
import 'package:hive/hive.dart';

part 'Mission.g.dart';

@HiveType(typeId: 0)
class Mission {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final int baseAmount;

  @HiveField(4)
  final int baseExp; //캐시에 저장되는 미션은 경험치 소량지급

  @HiveField(5)
  final int hp;

  @HiveField(6)
  final int mp;

  const Mission({
    required this.id,
    required this.title,
    required this.unit,
    required this.baseAmount,
    required this.baseExp,
    required this.hp,
    required this.mp
  });


  factory Mission.toMission({required String title, required int baseAmount, required String unit}){ //커스텀일경우
    final getLastId = HiveHandler.allQuest.lastOrNull?.id ?? 0;
    final rand = Random();
    return Mission(id: 10000 + getLastId, title: title, unit: unit, baseAmount: baseAmount, baseExp:rand.nextInt(9) + 1, hp: rand.nextInt(15)+5, mp: rand.nextInt(15)+5);
  }

}
