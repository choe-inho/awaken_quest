class LevelInfo{
  //경험치 레벨 상한선
  static int maxExpPrev = 1000;
  static int baseExp = 100;
  static int factor = 50;


  static int maxExp(int level){
    return maxExpPrev + (baseExp + level * factor);
  }

  //감각 / 지능 - mp , 근력 / 체력 - hp , 민첩 - 둘다
  static int base_health = 8;
  static int base_strength = 5;
  static int base_agility = 3;
  static int base_mana = 8;
  static int base_stamina = 5;

  static int maxHp(int health,  int strength, int agility){
    final hp = (health * base_health) + (strength * base_strength) + (agility * base_agility);
    return hp;
  }

  static int maxMp(int mana, int stamina, int agility){
    final mp = (mana * base_mana) + (stamina * base_stamina) + (agility * base_agility);
    return mp;
  }
}