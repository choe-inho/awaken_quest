// 실시간 카운트다운 타이머 위젯
import 'package:awaken_quest/app/controllers/Quest_Controller.dart';

import '../../utils/animation/Simmer_Text.dart';
import '../../utils/manager/Import_Manager.dart';

class DayCountdownTimerController extends GetxController{
  // 남은 시간 (초)을 저장할 변수
  RxInt remainingSeconds = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    _calculateRemainingTime();
    // 1초마다 업데이트하는 타이머
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
    super.onInit();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  // 남은 시간 계산
  void _calculateRemainingTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);

    remainingSeconds.value = difference.inSeconds;

    //만약 사용중에 날짜가 바뀐다면
    if(remainingSeconds.value == 0){
      Get.find<QuestController>().getTodayQuest();
    }
  }
}

class DayCountdownTimer extends GetWidget<DayCountdownTimerController> {
  const DayCountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 시계 아이콘
        Center(
          child: Icon(
            BootstrapIcons.clock,
            size: 14,
            color: Get.theme.colorScheme.primary,
          ),
        ),

        const SizedBox(width: 8),

        // 카운트다운 텍스트
        Obx(
            (){
              // 시간, 분, 초로 변환
              final hours = controller.remainingSeconds ~/ 3600;
              final minutes = (controller.remainingSeconds % 3600) ~/ 60;
              final seconds = controller.remainingSeconds % 60;
              final ment = hours > 16 ? '째깍째깍' : hours > 10 ? "시간 가는 중..." : hours > 5 ? "시간이 없습니다!" : "곧 종료됩니다";
              return ShimmerText(
                text: '$ment ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.primary,
                ),
              );
           }
        ),
      ],
    );
  }
}
