import 'package:awaken_quest/app/widgets/Title_Display.dart';
import 'package:awaken_quest/model/User_Model.dart';
import 'package:awaken_quest/utils/dialog/Basic_Dialog.dart';
import 'package:awaken_quest/utils/items/Level_Info.dart';
import '../../../utils/manager/Import_Manager.dart';
import 'dart:math' as math;
import '../../widgets/Hunter_Status_Frame.dart';

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> with SingleTickerProviderStateMixin {
  final controller = Get.find<HomeController>();
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    // 직업에 따른 색상 설정
    final jobColor = JobInfo.jobToColor(Get.find<UserController>().user.value!.job);

    return SafeArea(
      child: SizedBox(
        height: Get.height,
        child: Stack(
          children: [
            // 어두운 오버레이
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(180),
              ),
            ),

            // 배경 효과 (헌터 이펙트) - 랜덤한 기하학적 요소들
            Positioned.fill(
              child: _buildHunterEffects(jobColor),
            ),

            // 상태창
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              bottom: 20,
              child: ZoomIn(
                duration: const Duration(milliseconds: 600),
                child: FittedBox(child: _buildHunterStatusCard(jobColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 헌터 스타일 배경 효과
  Widget _buildHunterEffects(Color baseColor) {
    return Stack(
      children: List.generate(30, (index) {
        final isEvenIndex = index % 2 == 0;
        final effectType = _random.nextInt(4);
        final size = 10.0 + _random.nextDouble() * 30;
        final left = _random.nextDouble() * Get.width;
        final top = _random.nextDouble() * Get.height;
        final opacity = 0.1 + _random.nextDouble() * 0.3;

        final color = isEvenIndex
            ? baseColor.withAlpha((opacity * 255).toInt())
            : Colors.white.withAlpha((opacity * 100).toInt());

        switch (effectType) {
          case 0: // 사각형
            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 1),
                ),
              ),
            );

          case 1: // X 표시
            return Positioned(
              left: left,
              top: top,
              child:SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: CrossPainter(color: color),
                ),
              ),
            );

          case 2: // 원
            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1),
                ),
              ),
            );

          case 3: // 짧은 선
          default:
            return Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: _random.nextDouble() * math.pi,
                child: Container(
                  width: size,
                  height: 1,
                  color: color,
                ),
              ),
            );
        }
      }),
    );
  }

  // 헌터 스타일 상태창 카드
  Widget _buildHunterStatusCard(Color jobColor) {
    return GetBuilder<UserController>(
      builder: (userController) {
        final user  = userController.user.value!;
        return HunterStatusFrame(
          width: Get.width - 40,
          height: Get.height - 120,
          primaryColor: jobColor,
          secondaryColor: _getSecondaryColor(jobColor),
          borderWidth: 2.5,
          cornerSize: 15,
          polygonSides: 6, // 육각형 형태
          title: "${user.nickname}의 상태창",
          showStatusLines: true,
          glowIntensity: 1.5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              child: Column(
                children: [
                  //칭호
                  InkWell(
                      onTap: ()=> Get.toNamed('/title'),
                      child: TitleDisplay()),

                  const SizedBox(height: 20),

                  // 상단 정보 섹션
                  _buildInfoSection(user, userController),

                  const SizedBox(height: 20),

                  // HP/MP 바 섹션
                  _buildHpMpSection(user),

                  const SizedBox(height: 16),

                  // 스탯 섹션
                  _buildStatsSection(jobColor, userController),

                  const SizedBox(height: 16),

                  //정보수정 버튼
                  HunterButton(text: '정보수정', onTap: (){

                  })
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // 직업 색상에 맞는 보조 색상 생성
  Color _getSecondaryColor(Color primary) {
    // HSL 색상으로 변환하고 색조를 약간 변경하여 보조 색상 생성
    final hslColor = HSLColor.fromColor(primary);
    return hslColor.withHue((hslColor.hue + 30) % 360).toColor();
  }

  // 상단 정보 섹션
  Widget _buildInfoSection(UserModel user, UserController userController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withAlpha(60),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 유저 기본 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: BootstrapIcons.person_badge,
                label: "레벨",
                value: user.level.toString(),
              ),
              _buildInfoItem(
                icon: BootstrapIcons.briefcase,
                label: "직업",
                value: user.job,
              ),
              _buildInfoItem(
                icon: BootstrapIcons.emoji_astonished,
                label: "피로도",
                value: "${DateTime.now().difference(userController.firstLogin ?? DateTime.now()).inMinutes}%",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 정보 아이템 위젯
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withAlpha(220),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withAlpha(240),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // HP/MP 바 섹션
  Widget _buildHpMpSection(UserModel user) {
    final maxHp = LevelInfo.maxHp(user.health, user.strength, user.agility);
    final maxMp = LevelInfo.maxMp(user.mana, user.stamina, user.agility);
    final maxExp = LevelInfo.maxExp(user.level);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withAlpha(60),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // HP 바
          _buildStatusBar(
            label: "HP",
            current: user.hp,
            max: maxHp,
            primaryColor: const Color(0xFFFF3333),
            secondaryColor: const Color(0xFFFF6666),
            iconData: BootstrapIcons.heart_fill,
          ),

          const SizedBox(height: 16),

          // MP 바
          _buildStatusBar(
            label: "MP",
            current: user.mp,
            max: maxMp,
            primaryColor: const Color(0xFF3366FF),
            secondaryColor: const Color(0xFF66A3FF),
            iconData: BootstrapIcons.droplet_fill,
          ),

          const SizedBox(height: 16),


          // 경험치 바
          _buildStatusBar(
            label: "EXP",
            current: user.exp,
            max: maxExp,
            primaryColor: const Color(0xFF9B4DFF),  // 보라색 계열
            secondaryColor: const Color(0xFF00CFFF), // 하늘색 그라데이션
            iconData: BootstrapIcons.lightning_charge_fill,  // 번개 아이콘으로 파워업 느낌
          ),

        ],
      ),
    );
  }

  // 스탯 게이지 바
  Widget _buildStatusBar({
    required String label,
    required int current,
    required int max,
    required Color primaryColor,
    required Color secondaryColor,
    required IconData iconData,
  }) {
    final progress = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨과 값
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  iconData,
                  color: primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              "$current / $max",
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 프로그레스 바
        Stack(
          children: [
            // 배경
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.white.withAlpha(40),
                  width: 1,
                ),
              ),
            ),

            // 진행 바
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(150),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),

            // 격자 패턴
            SizedBox(
              height: 10,
              width: double.infinity,
              child: CustomPaint(
                painter: GridPatternPainter(
                  color: Colors.white.withAlpha(100),
                  divisions: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 스탯 섹션
  Widget _buildStatsSection(Color jobColor, UserController userController){
    final user = userController.user.value!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withAlpha(60),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: jobColor.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: jobColor.withAlpha(160),
                  width: 1,
                ),
              ),
              child: Text(
                "기본 스탯",
                style: TextStyle(
                  color: Colors.white.withAlpha(240),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          //잔여 스탯
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('배분 가능 스탯: ${user.extraStat}'),
            ],
          ),

          const SizedBox(height: 8),
          // 스탯 표시
          _buildStatRow("근력", user.strength, jobColor, user.extraStat, (){
            //미리 업데이트해서 막고
            userController.updateUser(strength: user.strength + 1 , extraStat:  user.extraStat -1, hp: user.hp + (LevelInfo.base_strength));
            //파이어베이스 업데이트
            final Map<String, dynamic> map = {
              'strength' : user.strength + 1,
              'extraStat' : user.extraStat -1 ,
              'hp' : user.hp + (LevelInfo.base_strength)
            };
            userController.updateStat(map);
          }),
          _buildStatRow("체력", user.health, jobColor, user.extraStat, (){
            userController.updateUser(health: user.strength + 1 , extraStat:  user.extraStat -1, hp: user.hp + (LevelInfo.base_health));
            //파이어베이스 업데이트
            final Map<String, dynamic> map = {
              'health' : user.strength + 1,
              'extraStat' : user.extraStat -1 ,
              'hp' : user.hp + (LevelInfo.base_health)
            };
            userController.updateStat(map);
          }),
          _buildStatRow("민첩", user.agility, jobColor, user.extraStat, (){
            userController.updateUser(agility: user.agility + 1 , extraStat:  user.extraStat -1, hp: user.hp + (LevelInfo.base_agility), mp: user.mp + (LevelInfo.base_agility));
            //파이어베이스 업데이트
            final Map<String, dynamic> map = {
              'agility' : user.agility + 1,
              'extraStat' : user.extraStat - 1 ,
              'hp' : user.hp + (LevelInfo.base_agility),
              'mp' : user.mp + (LevelInfo.base_agility)
            };
            userController.updateStat(map);
          }),
          _buildStatRow("지능", user.mana, jobColor, user.extraStat, (){
            userController.updateUser(mana: user.mana + 1 , extraStat:  user.extraStat -1, mp: user.mp + (LevelInfo.base_mana));
            //파이어베이스 업데이트
            final Map<String, dynamic> map = {
              'mana' : user.mana + 1,
              'extraStat' : user.extraStat - 1 ,
              'mp' : user.mp + (LevelInfo.base_mana)
            };
            userController.updateStat(map);
          }),
          _buildStatRow("집중", user.stamina, jobColor, user.extraStat, (){
            userController.updateUser(stamina: user.stamina + 1 , extraStat:  user.extraStat -1, mp: user.mp + (LevelInfo.base_stamina));
            //파이어베이스 업데이트
            final Map<String, dynamic> map = {
              'stamina' : user.mana + 1,
              'extraStat' : user.extraStat - 1 ,
              'mp' : user.mp + (LevelInfo.base_stamina)
            };
            userController.updateStat(map);
          }),
        ],
      ),
    );
  }

  // 스탯 행 위젯
  Widget _buildStatRow(String label, int value, Color jobColor, int visibleUp, VoidCallback callBack) {
    // 스탯 값에 따른 별 개수 (최대 5개)
    final starCount = (value / 20).floor().clamp(0, 5);

    return InkWell(
      onTap: callBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // 스탯 라벨
            SizedBox(
              width: 50,
              child: Text(
                "$label:",
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 스탯 값
            Container(
              width: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: jobColor.withAlpha(150),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: Colors.white.withAlpha(240),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 스탯 별 표시
            Expanded(
              child: Row(
                children: [
                  ...List.generate(starCount, (index) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      BootstrapIcons.star_fill,
                      color: jobColor.withAlpha(200),
                      size: 12,
                    ),
                  )),
                  ...List.generate(5 - starCount, (index) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      BootstrapIcons.star,
                      color: Colors.white.withAlpha(100),
                      size: 12,
                    ),
                  )),
                ],
              ),
            ),

            // 증가 표시
            if(visibleUp > 0)
            Pulse(
              child: InkWell(
                onTap: callBack,
                child: Icon(
                  BootstrapIcons.arrow_up_circle_fill,
                  color: jobColor.withAlpha(200),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// X 표시 패인터
class CrossPainter extends CustomPainter {
  final Color color;

  CrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CrossPainter oldDelegate) => oldDelegate.color != color;
}

// 격자 패턴 페인터
class GridPatternPainter extends CustomPainter {
  final Color color;
  final int divisions;

  GridPatternPainter({
    required this.color,
    required this.divisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final divisionWidth = size.width / divisions;

    for (int i = 1; i < divisions; i++) {
      final x = divisionWidth * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.divisions != divisions;
}