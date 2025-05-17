import '../utils/manager/Import_Manager.dart';

class QuestModel{
  final int id;
  final String quest;
  final DateTime? isClear;
  final String unit;
  final int amount;
  final int exp;
  final int hp;
  final int mp;

  QuestModel({
    required this.id,
    required this.quest,
    required this.isClear,
    required this.unit,
    required this.amount,
    required this.exp,
    required this.hp,
    required this.mp
  });

  factory QuestModel.fromJson(Map<String, dynamic> map) {
    final userController = Get.find<UserController>();
    final isMain = map['type'];
    final id = map['id'];

    final Mission? mission = isMain == 'm'
        ? JobInfo.mainMissions[userController.user.value!.job]
        ?.where((e) => e.id == id)
        .firstOrNull
        : isMain == 's'
        ? JobInfo.subMissions[userController.user.value!.job]
        ?.where((e) => e.id == id)
        .firstOrNull
        : userController.customTodoList
        .where((e) => e.id == id)
        .firstOrNull;

    // ✅ Timestamp -> DateTime 변환 (nullable-safe)
    final isClearRaw = map['isClear'];
    DateTime? isClearTime;

    if (isClearRaw is Timestamp) {
      isClearTime = isClearRaw.toDate();
    } else if (isClearRaw is DateTime) {
      isClearTime = isClearRaw;
    } else if(isClearRaw is String){
      isClearTime = DateTime.parse(isClearRaw);
    }else{
      isClearTime = null;
    }

    return QuestModel(
      id: id,
      quest: mission?.title ?? "이름 없는 임무",
      isClear: isClearTime,
      unit: mission?.unit ?? "??",
      amount: mission?.baseAmount ?? 99 + ((mission?.baseAmount ?? 99) * (userController.user.value!.level * 0.1).toInt()),
      exp: mission?.baseExp ?? 0 + (mission?.baseAmount ?? 1 * (userController.user.value!.level * 0.1).toInt()),
      hp: (mission?.hp ?? 3) * (userController.user.value!.level),
      mp: (mission?.mp ?? 3) * (userController.user.value!.level),
    );
  }

}