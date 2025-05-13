import 'dart:math' as math;
import '../../../utils/manager/Import_Manager.dart';
import '../../widgets/Sync_ProgressBar.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AppController appController;
  late UserController userController;

  // 애니메이션 컨트롤러
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  // 파티클 효과를 위한 변수
  final List<ParticleModel> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화
    appController = Get.find<AppController>();
    userController = Get.find<UserController>();

    // 애니메이션 컨트롤러 설정
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 펄스 애니메이션
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 회전 애니메이션
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // 파티클 생성
    _generateParticles();

    // 초기화 시작
    initStep();
  }

  // 파티클 생성 함수
  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(
        ParticleModel(
          position: Offset(
            _random.nextDouble() * Get.width,
            _random.nextDouble() * Get.height,
          ),
          speed: Offset(
            (_random.nextDouble() - 0.5) * 1.5,
            (_random.nextDouble() - 0.5) * 1.5,
          ),
          color: [
            Colors.blue.shade400,
            Colors.cyan.shade300,
            Colors.purple.shade300,
            Colors.amber.shade300,
          ][_random.nextInt(4)],
          size: 3 + _random.nextDouble() * 4,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initStep() async {
    if (appController.progress.value == 0) { // 첫진입이면 전체 초기화
      await appController.appControllerInit();
      await Future.delayed(
          const Duration(milliseconds: 300),
              () => userController.userControllerInit()
      );
    } else { // 앱이 이미 스트림중이면 유저만 패치
      userController.fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050915), // 더 어두운 배경색
      body: Stack(
        children: [
          // 배경 파티클 효과
          CustomPaint(
            painter: ParticlePainter(_particles, _animationController),
            size: Size(Get.width, Get.height),
          ),

          // 배경 그라데이션 효과
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.blue.shade900.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // 중앙 콘텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 애니메이션
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A7FFF), Color(0xFF9B4DFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3A7FFF).withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _rotateAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateAnimation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      // 앱 로고 또는 아이콘을 넣을 위치
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                // 동기화 상태 텍스트
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GlitchText(
                    text: '상태 동기화 중...',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      letterSpacing: 1.2,
                    ),
                    colorGlitch: true,
                  ),
                ),

                const SizedBox(height: 25),

                // 프로그레스 표시
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.black.withValues(alpha: 0.4),
                      border: Border.all(
                        color: const Color(0xFF3A7FFF).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3A7FFF).withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Obx(() {
                      final totalProgress = appController.progress.value + userController.progress.value;
                      return Column(
                        children: [
                          // 커스텀 프로그레스 바
                          EnhancedSyncProgressBar(
                            progress: totalProgress / 100,
                          ),

                          const SizedBox(height: 12),

                          // 진행 상태 텍스트
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$totalProgress%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3A7FFF),
                                ),
                              ),

                              // 로딩 애니메이션 효과
                              const SizedBox(width: 8),
                              LoadingDots(
                                color: const Color(0xFF3A7FFF),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 현재 로딩 중인 항목 표시
                          FadeIn(
                            child: Text(
                              totalProgress < 50 ? '데이터 초기화 중' : '플레이어 정보 로드 중',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // 하단 정보
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Text(
                  'AWAKEN QUEST',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





// 로딩 점 애니메이션
class LoadingDots extends StatefulWidget {
  final Color color;

  const LoadingDots({
    super.key,
    required this.color,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 6).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // 순차적으로 애니메이션 시작
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Transform.translate(
                offset: Offset(0, -_animations[index].value),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// 파티클 모델 클래스
class ParticleModel {
  Offset position;
  Offset speed;
  Color color;
  double size;

  ParticleModel({
    required this.position,
    required this.speed,
    required this.color,
    required this.size,
  });

  void update(Size screenSize) {
    position += speed;

    // 화면 경계에 도달하면 방향 전환
    if (position.dx < 0 || position.dx > screenSize.width) {
      speed = Offset(-speed.dx, speed.dy);
    }
    if (position.dy < 0 || position.dy > screenSize.height) {
      speed = Offset(speed.dx, -speed.dy);
    }
  }
}

// 파티클 효과를 그리는 CustomPainter
class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final Animation<double> animation;

  ParticlePainter(this.particles, this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // 파티클 업데이트 및 그리기
    for (var particle in particles) {
      particle.update(size);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);

      // 발광 효과
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
    }

    // 파티클 간 연결선 그리기
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].position - particles[j].position).distance;

        if (distance < 100) {
          final opacity = 1.0 - (distance / 100);
          final paint = Paint()
            ..color = Colors.white.withValues(alpha: opacity * 0.2)
            ..strokeWidth = 0.5;

          canvas.drawLine(
            particles[i].position,
            particles[j].position,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}