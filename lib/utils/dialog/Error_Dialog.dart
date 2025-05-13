import 'dart:ui';

import '../manager/Import_Manager.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, required this.error});
  final String error;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1), // 살짝 흰빛 투명
            border: Border.all(
              color:  Color(0xFFB71C1C).withValues(alpha: 0.5), // 푸른 오라 테두리
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '시스템이 응답하지 않습니다.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: ()=> Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1), // 살짝 흰빛 투명
                    border: Border.all(
                      color: Color(0xFFB71C1C).withValues(alpha: 0.5), // 푸른 오라 테두리
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text('확인', style: TextStyle(fontSize: 12,  color: Colors.white.withValues(alpha: 0.9),),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
