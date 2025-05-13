import 'package:google_sign_in/google_sign_in.dart';

import '../../../../utils/manager/Import_Manager.dart';


// 향상된 구글 로그인 버튼
// Google 로그인 버튼 - 공식 브랜딩 가이드라인 준수
class GoogleSignInButton extends StatefulWidget {
  final String text;
  final ButtonMode mode;
  final ButtonTheme theme;
  final ButtonShape shape;
  final double width;
  final double height;

  const GoogleSignInButton({
    super.key,
    this.text = '구글로 로그인',
    this.mode = ButtonMode.standard,
    this.theme = ButtonTheme.light,
    this.shape = ButtonShape.rectangular,
    this.width = double.infinity,
    this.height = 48,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

// 버튼 모드 (표준 / 아이콘만)
enum ButtonMode { standard, iconOnly }

// 버튼 테마 (라이트 / 다크 / 뉴트럴)
enum ButtonTheme { light, dark, neutral }

// 버튼 모양 (사각형 / 알약형)
enum ButtonShape { rectangular, pill }

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: (){
          googleLogin();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.mode == ButtonMode.iconOnly ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: widget.shape == ButtonShape.rectangular
                ? BorderRadius.circular(4)
                : BorderRadius.circular(24),
            border: widget.theme != ButtonTheme.neutral
                ? Border.all(
              color: _getBorderColor(),
              width: 1,
            )
                : null,
            boxShadow: _isPressed
                ? []
                : _isHovered
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: widget.mode == ButtonMode.standard
              ? _buildStandardButton()
              : _buildIconOnlyButton(),
        ),
      ),
    );
  }

  Widget _buildStandardButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google 로고 - 이것은 변경하면 안됨
          Image.asset(
            'assets/image/app/google_g_logo.png',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 12), // 정확한 패딩 유지
          // Roboto Medium 폰트 사용 필요
          Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500, // Medium
              fontSize: 14,
              height: 20 / 14, // Line height 20
              letterSpacing: 0.25,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOnlyButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          'assets/image/icon/google_g_logo.png',
          width: 18,
          height: 18,
        ),
      ),
    );
  }

  // 테마에 따른 배경색 지정
  Color _getBackgroundColor() {
    if (_isPressed) {
      // 눌렸을 때 배경색
      switch (widget.theme) {
        case ButtonTheme.light:
          return const Color(0xFFE6E6E6);
        case ButtonTheme.dark:
          return const Color(0xFF232324);
        case ButtonTheme.neutral:
          return const Color(0xFFDFDFDF);
      }
    }

    // 기본 배경색
    switch (widget.theme) {
      case ButtonTheme.light:
        return Colors.white;
      case ButtonTheme.dark:
        return const Color(0xFF131314);
      case ButtonTheme.neutral:
        return const Color(0xFFF2F2F2);
    }
  }

  // 테마에 따른 테두리색 지정
  Color _getBorderColor() {
    switch (widget.theme) {
      case ButtonTheme.light:
        return const Color(0xFF747775);
      case ButtonTheme.dark:
        return const Color(0xFF8E918F);
      case ButtonTheme.neutral:
        return Colors.transparent;
    }
  }

  // 테마에 따른 텍스트색 지정
  Color _getTextColor() {
    switch (widget.theme) {
      case ButtonTheme.light:
      case ButtonTheme.neutral:
        return const Color(0xFF1F1F1F);
      case ButtonTheme.dark:
        return const Color(0xFFE3E3E3);
    }
  }
}



//구글
Future<void> googleLogin() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile'
        ]
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase 로그인
    await FirebaseAuth.instance.signInWithCredential(credential);
  }on FirebaseAuthException catch (e) {
    FirebaseExceptionHandler.firebaseAuthExceptionHandler(e.code);
  }
}