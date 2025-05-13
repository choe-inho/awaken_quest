import 'package:awaken_quest/utils/items/Job_Info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String gender;
  final String job;
  final List<String> goal;

  final int hp;
  final int mp;
  final int health; //체력
  final int strength; //근력
  final int agility; //지력
  final int mana; //집중력
  final int stamina; //모험력
  final int blackMana; //이상행위가 발생했을때 (너무 빠른 미션클리어, 미션 클리어가 잘 안이뤄졌을때)

  final int exp;           // 현재 경험치
  final int level;         // 현재 레벨
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.nickname,
    required this.gender,
    required this.job,
    required this.hp,
    required this.mp,
    required this.strength,
    required this.agility,
    required this.goal,
    required this.health,
    required this.mana,
    required this.stamina,
    required this.blackMana,
    required this.exp,
    required this.level,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nickname: map['nickname'] ?? '',
      gender: map['gender'] ?? '',
      job: map['job'] ?? '',
      hp: map['hp'] ?? 0,
      mp: map['mp'] ?? 0,
      strength: map['strength'] ?? 0,
      agility: map['agility'] ?? 0,
      health: map['health'] ?? 0,
      mana: map['mana'] ?? 0,
      stamina: map['stamina'] ?? 0,
      blackMana: map['blackMana'] ?? 0,
      goal: List<String>.from(map['goal'] ?? []),
      exp: map['exp'] ?? 0,
      level: map['level'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.firstCreate({required String nickname, required String gender,  required List<String> goal,  required String job}){
    final stat = JobInfo.jotToStat(job);

    return UserModel(
        uid: '',
        nickname: nickname,
        gender: gender,
        job: job,
        goal: goal,
        hp: 100,
        mp: 100,
        strength: stat['strength']!,
        agility: stat['agility']!,
        health: stat['health']!,
        mana: stat['mana']!,
        stamina: stat['stamina']!,
        blackMana: 0,
        exp: 0,
        level: 1,
        createdAt: DateTime.now());
  }


  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'gender': gender,
      'goal' : goal,
      'job': job,
      'hp': hp,
      'mp': mp,
      'strength': strength,
      'agility': agility,
      'health': health,
      'stamina' : stamina,
      'mana': mana,
      'blackMana' : blackMana,
      'exp': exp,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
