import 'package:awaken_quest/utils/dialog/Dialog_Frame.dart';

import '../manager/Import_Manager.dart';

class FirebaseExceptionHandler{

  static void firebaseAuthExceptionHandler(String code){
    String message = '알수 없는 오류가 발생하였습니다.';

    switch (code) {
      case 'invalid-email':
        message = '유효하지 않은 이메일 형식입니다.';
        break;
      case 'user-disabled':
        message = '이 계정은 비활성화되었습니다.';
        break;
      case 'user-not-found':
        message = '등록된 계정이 존재하지 않습니다.';
        break;
      case 'wrong-password':
        message = '비밀번호가 일치하지 않습니다.';
        break;
      case 'email-already-in-use':
        message = '이미 사용 중인 이메일입니다.';
        break;
      case 'operation-not-allowed':
        message = '이메일/비밀번호 로그인이 허용되지 않았습니다.';
        break;
      case 'weak-password':
        message = '비밀번호는 6자 이상이어야 합니다.';
        break;
      case 'missing-email':
        message = '이메일이 입력되지 않았습니다.';
        break;
      case 'too-many-requests':
        message = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
        break;
      case 'network-request-failed':
        message = '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
        break;
      default:
        message = '알 수 없는 오류가 발생하였습니다. (${code})';
        break;
    }

    DialogFrame.errorHandler(message);
  }

  static void firebaseGeneralExceptionHandler(dynamic error) {
    String message = '알 수 없는 오류가 발생하였습니다.';

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          message = '권한이 없습니다. 관리자에게 문의해주세요.';
          break;
        case 'unavailable':
          message = '서비스를 사용할 수 없습니다. 나중에 다시 시도해주세요.';
          break;
        case 'not-found':
          message = '요청한 데이터를 찾을 수 없습니다.';
          break;
        case 'deadline-exceeded':
          message = '서버 응답 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.';
          break;
        case 'resource-exhausted':
          message = '요청 제한을 초과했습니다. 잠시 후 다시 시도해주세요.';
          break;
        case 'unauthenticated':
          message = '인증이 필요합니다. 다시 로그인해주세요.';
          break;
        case 'cancelled':
          message = '요청이 취소되었습니다.';
          break;
        default:
          message = '알 수 없는 오류가 발생하였습니다. (${error.code})';
          break;
      }
    }

    DialogFrame.errorHandler(message);
  }

}