class MissionCleared{
  final int warrior; //전사 미션
  final int magic; //마법사 미션
  final int healer; //힐러 미션
  final int smith; //대장장이 미션
  final int explorer; //탐험가 미션

  MissionCleared({
      required this.warrior,
      required this.magic,
      required this.healer,
      required this.smith,
      required this.explorer
  });

  factory MissionCleared.fromJson(Map<String, dynamic> map){
    return MissionCleared(
        warrior: map['warrior'],
        magic: map['magic'],
        healer: map['healer'],
        smith: map['smith'],
        explorer: map['explorer']
    );
  }


  MissionCleared copyWith({int? warrior, int? magic, int? healer, int? smith, int? explorer}){
    return MissionCleared(
        warrior: warrior ?? this.warrior,
        magic: magic ?? this.magic,
        healer: healer ??  this.healer,
        smith: smith ??  this.smith,
        explorer: explorer ?? this.explorer
    );
  }

  toMap(){
    return {
      'warrior': warrior,
      'magic': magic,
      'healer': healer,
      'smith': smith,
      'explorer': explorer
    };
  }
}