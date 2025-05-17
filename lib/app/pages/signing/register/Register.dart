import 'package:awaken_quest/app/controllers/Register_Controller.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import '../../../../utils/animation/Simmer_Text.dart';
import '../../../../utils/manager/Import_Manager.dart';

class Register extends GetView<RegisterController> {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.loading.value,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 140,
            leading: FadeInLeft(
              duration: const Duration(milliseconds: 600),
              child: TextButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                label: Text(
                  '각성취소',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              // 에너지 파티클 효과
              Positioned.fill(
                child: EnergyParticlesEffect(),
              ),

              // 반투명 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        const Color(0xFF050915).withValues(alpha: 0.85),
                        const Color(0xFF050915).withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // 중앙 상태창
              Center(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          const Color(0xFF0A1530).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    constraints: const BoxConstraints(
                      maxHeight: 520,
                      minHeight: 320,
                    ),
                    alignment: Alignment.center,
                    child: Obx(
                          () => controller.loading.value
                          ? _buildLoadingState()
                          : _buildFormPages(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 로딩 상태 위젯
  Widget _buildLoadingState() {
    return FadeInUp(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerText(
            text: '각성자 데이터 구축 중...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 40),
          EnergyCoreLoader(
            size: 100,
            color: Colors.cyanAccent,
          ),
          const SizedBox(height: 50),
          Text(
            '차원 통신을 기다려 주세요',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 폼 페이지 위젯
  Widget _buildFormPages() {
    return Column(
      children: [
        // 페이지 뷰
        Expanded(
          child: PageView(
            onPageChanged: (page) => controller.currentPage.value = page,
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              FirstPage(),
              SecondPage(),
            ],
          ),
        ),

        // 페이지 인디케이터
        SizedBox(
          height: 36,
          child: Center(
            child: Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0, 1].map((index) {
                  final isActive = controller.currentPage.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.cyanAccent
                          : Colors.cyanAccent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isActive
                          ? [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // 네비게이션 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 이전 버튼
            Obx(
                  () => CyberIconButton(
                icon: CupertinoIcons.back,
                onPressed: () {
                  if (controller.currentPage.value == 1) {
                    controller.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    controller.currentPage.value--;
                  }
                },
                isEnabled: controller.currentPage.value == 1,
              ),
            ),

            // 완료 버튼
            Obx(
                  () => CyberActionButton(
                text: '상태창 로드',
                onPressed: () {
                  if (controller.nickName.value.trim().isNotEmpty &&
                      controller.currentTag.length >= 4 &&
                      controller.selectedGender.value.isNotEmpty) {
                    controller.createUser();
                  }
                },
                isEnabled: controller.nickName.value.trim().isNotEmpty &&
                    controller.currentTag.length >= 4 &&
                    controller.selectedGender.value.isNotEmpty,
              ),
            ),

            // 다음 버튼
            Obx(
                  () => CyberIconButton(
                icon: CupertinoIcons.forward,
                onPressed: () {
                  if (controller.currentPage.value == 0) {
                    controller.pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    controller.currentPage.value++;
                  }
                },
                isEnabled: controller.currentPage.value == 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 첫 번째 페이지 - 기본 정보 입력
class FirstPage extends GetWidget<RegisterController> {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerText(
              text: '각성자 프로파일을 입력하세요',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 30),
            CyberTextField(
              label: '각성 코드명(닉네임)',
              onChanged: (value) {
                controller.nickName.value = value;
              },
              initialValue: controller.nickName.value,
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            const SelectGender(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 성별 선택 위젯
class SelectGender extends GetWidget<RegisterController> {
  const SelectGender({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '성별',
              style: TextStyle(
                color: Colors.cyanAccent.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
                () => Row(
              children: ['남자', '여자'].map((gender) {
                final isSelected = controller.selectedGender.value == gender;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedGender.value = gender;
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.cyanAccent
                              : Colors.cyanAccent.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                            : null,
                        gradient: isSelected
                            ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.cyanAccent.withValues(alpha: 0.2),
                            Colors.blue.withValues(alpha: 0.1),
                          ],
                        )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          gender,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.cyanAccent
                                : Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 두 번째 페이지 - 키워드 선택
class SecondPage extends GetWidget<RegisterController> {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Column(
        children: [
          ShimmerText(
            text: '마음에 드는 키워드를\n4개 이상 선택하세요',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
                () => Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.currentTag.length >= 4
                      ? Colors.cyanAccent.withValues(alpha: 0.5)
                      : Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${controller.currentTag.length}/4 선택됨',
                style: TextStyle(
                  fontSize: 14,
                  color: controller.currentTag.length >= 4
                      ? Colors.cyanAccent.withValues(alpha: 0.8)
                      : Colors.red.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: controller.keywords.map((keyword) {
                        return Obx(
                              () => CyberKeywordChip(
                            label: keyword,
                            isSelected: controller.currentTag.contains(keyword),
                            onSelected: (selected) {
                              if (!controller.currentTag.contains(keyword)) {
                                controller.currentTag.add(keyword);
                              } else {
                                controller.currentTag.remove(keyword);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 사이버 스타일 텍스트 필드
class CyberTextField extends StatelessWidget {
  final String label;
  final void Function(String) onChanged;
  final String initialValue;
  final int maxLength;

  const CyberTextField({
    super.key,
    required this.label,
    required this.onChanged,
    required this.initialValue,
    this.maxLength = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.cyanAccent.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            maxLength: maxLength,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.3),
              counterText: '',
              hintText: label,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.cyanAccent,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 사이버 키워드 칩
class CyberKeywordChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const CyberKeywordChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.cyanAccent
                : Colors.cyanAccent.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Colors.cyanAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.cyanAccent
                : Colors.white.withValues(alpha: 0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// 사이버 아이콘 버튼
class CyberIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isEnabled;

  const CyberIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(
            color: isEnabled
                ? Colors.cyanAccent.withValues(alpha: 0.7)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ]
              : [],
        ),
        child: Icon(
          icon,
          size: 25,
          color: isEnabled
              ? Colors.cyanAccent
              : Colors.grey.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// 사이버 액션 버튼
class CyberActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const CyberActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? Colors.cyanAccent.withValues(alpha: 0.7)
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ]
              : [],
          gradient: isEnabled
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.cyanAccent.withValues(alpha: 0.1),
            ],
          )
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled
                ? Colors.cyanAccent
                : Colors.grey.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// 에너지 코어 로더
class EnergyCoreLoader extends StatefulWidget {
  final double size;
  final Color color;

  const EnergyCoreLoader({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  State<EnergyCoreLoader> createState() => _EnergyCoreLoaderState();
}

class _EnergyCoreLoaderState extends State<EnergyCoreLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 외부 원
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),

          // 중간 원
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_controller.value * 4 * math.pi,
                child: Container(
                  width: widget.size * 0.7,
                  height: widget.size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),

          // 내부 원
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.1),
                  border: Border.all(
                    color: widget.color,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SYNC',
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          // 회전하는 점들
          ...List.generate(8, (index) {
            final angle = index * (math.pi / 4);
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final currentAngle = angle + (_controller.value * 2 * math.pi);
                final x = math.cos(currentAngle) * (widget.size * 0.45);
                final y = math.sin(currentAngle) * (widget.size * 0.45);

                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// 에너지 파티클 효과
class EnergyParticlesEffect extends StatelessWidget {
  const EnergyParticlesEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: EnergyParticlesPainter(),
      size: Size.infinite,
    );
  }
}

class EnergyParticlesPainter extends CustomPainter {
  final List<Particle> particles = List.generate(
    30,
        (index) => Particle.random(),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(size);

      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );

      // 발광 효과
      final glowPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: particle.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        particle.position,
        particle.size * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
  });

  factory Particle.random() {
    final random = math.Random();

    return Particle(
      position: Offset(
        random.nextDouble() * 500,
        random.nextDouble() * 800,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 0.5,
        (random.nextDouble() - 0.5) * 0.5 - 0.5, // 주로 위로 올라가도록
      ),
      size: 1 + random.nextDouble() * 2,
      opacity: 0.1 + random.nextDouble() * 0.3,
    );
  }

  void update(Size screenSize) {
    position += velocity;

    // 화면 밖으로 나가면 아래로 다시 등장
    if (position.dy < -size) {
      position = Offset(
        math.Random().nextDouble() * screenSize.width,
        screenSize.height + size,
      );
      opacity = 0.1 + math.Random().nextDouble() * 0.3;
      size = 1 + math.Random().nextDouble() * 2;
    }

    // 좌우 경계 처리
    if (position.dx < -size || position.dx > screenSize.width + size) {
      position = Offset(
        position.dx < 0 ? screenSize.width + size : -size,
        position.dy,
      );
    }
  }
}
