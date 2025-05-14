// lib/utils/handlers/Login_Streak_Handler.dart

import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginStreakHandler {
  // SharedPreferences 키
  static const String _lastLoginDateKey = 'iconoding.awaken.last_login_date';
  static const String _currentStreakKey = 'iconoding.awaken.current_login_streak';
  static const String _maxStreakKey = 'iconoding.awaken.max_login_streak';
  static const String _streakUpdatedTodayKey = 'iconoding.awaken.streak_updated_today';

  // Firebase 유저 참조
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // 오늘 날짜 기준 로그인 스트릭 계산
  Future<int> calculateLoginStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 이전 로그인 날짜 확인
    final lastLoginDateStr = prefs.getString(_lastLoginDateKey);
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final alreadyUpdatedToday = prefs.getBool(_streakUpdatedTodayKey) ?? false;

    // 이미 오늘 업데이트했으면 현재 스트릭 반환
    if (alreadyUpdatedToday) {
      return currentStreak;
    }

    // 최초 로그인인 경우
    if (lastLoginDateStr == null) {
      await _updateStreak(prefs, today, 1);
      return 1;
    }

    // 이전 로그인 날짜 파싱
    final lastLoginDate = DateTime.parse(lastLoginDateStr);
    final lastDate = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);

    // 날짜 차이 계산
    final difference = today.difference(lastDate).inDays;

    int newStreak;

    if (difference == 1) {
      // 연속 로그인 - 하루 차이
      newStreak = currentStreak + 1;
    } else if (difference == 0) {
      // 같은 날 또 로그인 - 스트릭 유지
      newStreak = currentStreak;
    } else {
      // 하루 이상 놓침 - 스트릭 리셋
      newStreak = 1;
    }

    // 스트릭 업데이트
    await _updateStreak(prefs, today, newStreak);

    return newStreak;
  }

  // 스트릭 업데이트 및 저장
  Future<void> _updateStreak(SharedPreferences prefs, DateTime today, int newStreak) async {
    // 로컬 저장
    await prefs.setString(_lastLoginDateKey, today.toIso8601String());
    await prefs.setInt(_currentStreakKey, newStreak);
    await prefs.setBool(_streakUpdatedTodayKey, true);

    // 최대 스트릭 업데이트
    final maxStreak = prefs.getInt(_maxStreakKey) ?? 0;
    if (newStreak > maxStreak) {
      await prefs.setInt(_maxStreakKey, newStreak);
    }

    // Firebase 동기화 (사용자가 로그인한 경우에만)
    await _syncWithFirebase(newStreak, maxStreak >= newStreak ? maxStreak : newStreak);

    // 타이머로 자정에 _streakUpdatedTodayKey 리셋
    _scheduleResetFlag();
  }

  // 자정에 오늘 업데이트 여부 플래그 리셋
  void _scheduleResetFlag() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final remainingTime = tomorrow.difference(now);

    Timer(remainingTime, () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_streakUpdatedTodayKey, false);
    });
  }

  // Firebase와 동기화 (선택적)
  Future<void> _syncWithFirebase(int currentStreak, int maxStreak) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'login_streak': currentStreak,
        'max_login_streak': maxStreak,
        'last_login': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firebase 스트릭 동기화 오류: $e');
      // 오류 발생 시 무시하고 계속 진행 (다음 로그인 시 재시도)
    }
  }

  // 서버에서 스트릭 데이터 복구 (앱 재설치 등)
  Future<void> recoverStreakFromServer() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || !doc.data()!.containsKey('login_streak')) return;

      final data = doc.data()!;
      final serverStreak = data['login_streak'] as int? ?? 0;
      final serverMaxStreak = data['max_login_streak'] as int? ?? 0;
      final serverLastLogin = (data['last_login'] as Timestamp?)?.toDate();

      if (serverLastLogin == null) return;

      // 로컬 저장소에 복구
      final prefs = await SharedPreferences.getInstance();

      // 현재 날짜와 서버의 마지막 로그인 날짜 비교
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastLoginDay = DateTime(
          serverLastLogin.year,
          serverLastLogin.month,
          serverLastLogin.day
      );

      final difference = today.difference(lastLoginDay).inDays;

      if (difference <= 1) {
        // 어제 또는 오늘 로그인했다면 스트릭 유지
        await prefs.setString(_lastLoginDateKey, lastLoginDay.toIso8601String());
        await prefs.setInt(_currentStreakKey, serverStreak);
        await prefs.setInt(_maxStreakKey, serverMaxStreak);
        await prefs.setBool(_streakUpdatedTodayKey, difference == 0);
      } else {
        // 그외 경우는 스트릭 리셋 (오늘의 첫 로그인으로 취급)
        await prefs.setString(_lastLoginDateKey, today.toIso8601String());
        await prefs.setInt(_currentStreakKey, 1);
        await prefs.setInt(_maxStreakKey, serverMaxStreak);
        await prefs.setBool(_streakUpdatedTodayKey, true);

        // 변경된 스트릭 서버에 동기화
        await _syncWithFirebase(1, serverMaxStreak);
      }
    } catch (e) {
      print('서버 스트릭 복구 오류: $e');
    }
  }

  // 현재 연속 로그인 일수 조회
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  // 최대 연속 로그인 일수 조회
  Future<int> getMaxStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxStreakKey) ?? 0;
  }

  // 로그인 스트릭 관련 모든 정보 조회
  Future<Map<String, dynamic>> getStreakInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final maxStreak = prefs.getInt(_maxStreakKey) ?? 0;
    final lastLoginDateStr = prefs.getString(_lastLoginDateKey);
    final lastLoginDate = lastLoginDateStr != null
        ? DateTime.parse(lastLoginDateStr)
        : null;

    return {
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'lastLoginDate': lastLoginDate,
      'updatedToday': prefs.getBool(_streakUpdatedTodayKey) ?? false,
    };
  }
}