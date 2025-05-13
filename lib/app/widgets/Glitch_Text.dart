// 글리치 텍스트 위젯
import 'dart:math' as math;
import '../../utils/manager/Import_Manager.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool colorGlitch;

  const GlitchText({
    super.key,
    required this.text,
    required this.style,
    this.colorGlitch = false,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayText = '';
  double _glitchAmount = 0;
  Color _currentColor = Colors.cyanAccent;
  final List<Color> _glitchColors = [
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.blueAccent,
  ];

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )
      ..addListener(_glitchEffect)
      ..repeat();

    // 시작 시 글자를 하나씩 보여주는 효과
    _typeWriter();
  }

  void _typeWriter() async {
    _displayText = '';
    for (int i = 0; i < widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _displayText = widget.text.substring(0, i + 1);
        });
      }
    }
  }

  void _glitchEffect() {
    if (!mounted) return;

    // 랜덤으로 글리치 효과 적용
    final random = math.Random();
    if (random.nextDouble() < 0.05) {
      setState(() {
        _glitchAmount = random.nextDouble() * 5;
        if (widget.colorGlitch && random.nextDouble() < 0.3) {
          _currentColor = _glitchColors[random.nextInt(_glitchColors.length)];
        }
      });

      // 글리치 효과 리셋
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _glitchAmount = 0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 글리치 효과 레이어 1
        if (_glitchAmount > 0)
          Positioned(
            left: -2 * _glitchAmount,
            child: Text(
              _displayText,
              style: widget.style.copyWith(
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
          ),

        // 글리치 효과 레이어 2
        if (_glitchAmount > 0)
          Positioned(
            left: 2 * _glitchAmount,
            child: Text(
              _displayText,
              style: widget.style.copyWith(
                color: Colors.blue.withValues(alpha: 0.7),
              ),
            ),
          ),

        // 메인 텍스트
        Text(
          _displayText,
          style: widget.style.copyWith(
            color: widget.colorGlitch ? _currentColor : widget.style.color,
          ),
        ),
      ],
    );
  }
}