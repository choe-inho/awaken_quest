
import 'package:awaken_quest/app/widgets/Hunter_Effect_Overlay.dart';

import '../../../utils/manager/Import_Manager.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: HunterEffectOverlay(count: 100, height: Get.height,)),
        Center(
          child: GlitchText(text: '불러오는 중..', style: TextStyle(fontSize: 16,), colorGlitch: true,)
        )
      ],
    );
  }
}
