// lib/utils/notification/NotificationService.dart 파일 생성

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awaken_quest/utils/manager/Import_Manager.dart';
import 'package:awaken_quest/app/controllers/Quest_Controller.dart';
import 'package:awaken_quest/app/controllers/Home_Controller.dart';
import 'package:awaken_quest/app/widgets/Day_Countdown_Timer.dart';

class NotificationService {
  // 싱글톤 패턴 구현
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // 알림 설정 여부 저장 키
  static const String _notificationEnabledKey = 'iconoding.awaken.notification_enabled';
  // 마지막 알림 전송 날짜 저장 키
  static const String _lastNotificationDateKey = 'iconoding.awaken.last_notification_date';

  // 초기화 메서드
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 타임존 초기화
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대 설정

    // 안드로이드 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // 앱 아이콘 사용

    // iOS 설정
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // iOS 10 미만에서 알림을 탭했을 때 처리 (현재는 거의 사용되지 않음)
      },
    );

    // 초기화 설정 적용
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 플러그인 초기화
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 탭 처리
        _handleNotificationTap(response.payload);
      },
    );

    _isInitialized = true;
  }

  // 알림 탭 처리
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      // 앱이 이미 실행 중일 때
      if (Get.context != null) {
        if (payload == 'quest_reminder') {
          // 퀘스트 페이지로 이동
          Get.offAllNamed('/home');
          Get.find<HomeController>().currentTab.value = 0; // 퀘스트 탭으로 이동
        }
      }
    }
  }

  // 알림 권한 요청
  Future<bool> requestPermission() async {
    if (!_isInitialized) await initialize();

    // Android 13+ (API 33+)에서는 명시적인 권한 요청이 필요
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidPlugin?.requestNotificationsPermission();

    // iOS도 권한 요청
    final bool? iosGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 권한 허용 상태를 저장
    final prefs = await SharedPreferences.getInstance();
    final isGranted = granted ?? iosGranted ?? false;
    await prefs.setBool(_notificationEnabledKey, isGranted);

    return isGranted;
  }

  // 알림 활성화 상태 확인
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  // 알림 활성화/비활성화 설정
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  // 남은 시간을 확인하고 알림 예약
  Future<void> scheduleReminderIfNeeded() async {
    if (!_isInitialized) await initialize();

    // 알림이 비활성화되어 있으면 처리하지 않음
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dayCountdownController = Get.isRegistered<DayCountdownTimerController>()
          ? Get.find<DayCountdownTimerController>()
          : null;

      // 컨트롤러가 없으면 처리하지 않음
      if (dayCountdownController == null) return;

      // 남은 시간 (초)
      final remainingSeconds = dayCountdownController.remainingSeconds.value;
      final fiveHoursInSeconds = 5 * 60 * 60; // 5시간을 초로 변환

      // 오늘 날짜
      final today = DateTime.now().toLocal();
      final todayStr = today.year.toString() +
          today.month.toString().padLeft(2, '0') +
          today.day.toString().padLeft(2, '0');

      // 오늘 이미 알림을 보냈는지 확인
      final lastNotificationDate = prefs.getString(_lastNotificationDateKey);
      final alreadySentToday = lastNotificationDate == todayStr;

      // 남은 시간이 5시간 이하이고, 오늘 알림을 아직 보내지 않았으면
      if (remainingSeconds <= fiveHoursInSeconds && !alreadySentToday) {
        // 퀘스트 컨트롤러 확인
        if (!Get.isRegistered<QuestController>()) return;

        final questController = Get.find<QuestController>();

        // 미션 데이터 확인
        final hasUncompletedMissions = _hasUncompletedMissions(questController);

        if (hasUncompletedMissions) {
          // 알림 예약 (즉시 보냄)
          await _scheduleReminder();

          // 오늘 알림 보냈음을 기록
          await prefs.setString(_lastNotificationDateKey, todayStr);
        }
      }
    } catch (e) {
      print('알림 예약 중 오류 발생: $e');
    }
  }

  // 완료되지 않은 미션이 있는지 확인
  bool _hasUncompletedMissions(QuestController questController) {
    // 메인 미션 확인
    final anyMainIncomplete = questController.todayMainMissions
        .any((mission) => mission.isClear == null);

    // 서브 미션 확인
    final anySubIncomplete = questController.todaySubMissions
        .any((mission) => mission.isClear == null);

    // 커스텀 미션 확인
    final anyCustomIncomplete = questController.todayCustomMissions
        .any((mission) => mission.isClear == null);

    // 하나라도 완료되지 않은 미션이 있으면 true
    return anyMainIncomplete || anySubIncomplete || anyCustomIncomplete;
  }

  // 알림 즉시 예약
  Future<void> _scheduleReminder() async {
    // 알림 채널 설정 (Android)
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mission_reminder_channel', // 채널 ID
      '미션 리마인더', // 채널 이름
      channelDescription: '완료되지 않은 미션을 알려주는 채널입니다.', // 채널 설명
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      // sound: RawResourceAndroidNotificationSound('notification_sound'), // 사용자 지정 소리 (선택)
      // largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'), // 큰 아이콘
      styleInformation: BigTextStyleInformation(''), // 긴 텍스트 지원
      color: Color(0xFF3A7FFF), // 알림 색상
    );

    // iOS 설정
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: 'notification_sound.aiff', // iOS용 사용자 지정 소리 (선택)
    );

    // 플랫폼 통합 설정
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 현재 시각을 기준으로 즉시 알림
    final now = tz.TZDateTime.now(tz.local);

    // 알림 표시
    await _notificationsPlugin.zonedSchedule(
      0, // 알림 ID
      '미션 완료 시간이 얼마 남지 않았습니다!', // 제목
      '오늘의 미션을 완료하지 않은 항목이 있습니다. 확인해보세요!', // 내용
      now.add(const Duration(seconds: 5)), // 5초 후 (즉시)
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 배터리 최적화 무시
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'quest_reminder', // 알림 탭 시 전달할 데이터
    );
  }

  // 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}