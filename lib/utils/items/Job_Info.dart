import '../manager/Import_Manager.dart';

class JobInfo{
  static Map<String, Map<String, double>> jobKeywordWeights = {
    '전사': {
      '다이어트': 1.0,
      '체지방 감소': 0.8,
      '체력 증가': 1.0,
      '근력 증가': 0.9,
      '운동 루틴': 0.8,
      '식단 조절': 0.7,
    },
    '마법사': {
      '공부': 1.0,
      '집중력 향상': 0.9,
      '외국어': 0.8,
      '자격증': 0.7,
    },
    '힐러': {
      '마음 안정': 1.0,
      '규칙적인 생활': 1.0,
      '명상': 0.8,
      '스트레스 해소': 0.9,
      '수면 습관': 0.8,
    },
    '대장장이': {
      '생산성': 1.0,
      '이직': 0.9,
      '자격증': 0.8,
      '업무 효율화': 0.8,
      '계획 세우기': 0.7,
    },
    '탐험가': {
      '여행': 1.0,
      '색다른 경험': 1.0,
      '취미 탐색': 0.8,
      '도전': 0.9,
      '새로운 장소': 0.7,
    }
  };

  String getRecommendedJob(List<String> selectedKeywords) {
    Map<String, double> jobScores = {};

    for (var job in jobKeywordWeights.keys) {
      double score = 0.0;
      final keywordMap = jobKeywordWeights[job]!;

      for (var keyword in selectedKeywords) {
        if (keywordMap.containsKey(keyword)) {
          score += keywordMap[keyword]!;
        }
      }

      jobScores[job] = score;
    }

    // 가장 높은 점수를 가진 직업 찾기
    final sortedJobs = jobScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedJobs.first.key;
  }

  static Map<String, int> jotToStat(String job){
    final Map<String, Map<String, int>> jobBaseStats = {
      '전사': {
        'strength': 8,
        'agility': 1,
        'stamina': 2,
        'mana': 3,
        'health': 6,
      },
      '마법사': {
        'strength': 1,
        'agility': 2,
        'stamina': 4,
        'mana': 9,
        'health': 4,
      },
      '힐러': {
        'strength': 2,
        'agility': 3,
        'stamina': 5,
        'mana': 6,
        'health': 4,
      },
      '대장장이': {
        'strength': 6,
        'agility': 4,
        'stamina': 4,
        'mana': 2,
        'health': 4,
      },
      '탐험가': {
        'strength': 4,
        'agility': 2,
        'stamina': 8,
        'mana': 1,
        'health': 5,
      },
    };

    return jobBaseStats[job]!;
  }

  static Map<String, Map<String, String>> awakenText = {
  "전사": {
    "firstText": "강인한 의지로 몸과 마음을 단련하는 자.\n오늘의 선택이 내일의 전장을 결정합니다",
    "secondText": "하루 한 끼를 절제하고, 10분이라도 땀 흘리세요.\n작은 루틴이 당신을 진짜 전사로 만들어갑니다."
  },
  "마법사": {
      "firstText": "지식은 당신의 마법입니다.\n끊임없는 탐구심이 세상을 바꾸죠.",
      "secondText": "하루 30분이라도 집중해보세요.\n책 한 장, 단어 하나가 마법진을 완성합니다."
    },
    "힐러": {
      "firstText": "당신의 평온이 세상의 균형을 지켜줍니다.\n치유는 곧 새로운 시작입니다.",
      "secondText": "잠들기 전 5분, 숨을 고르고 오늘을 돌아보세요.\n하루를 치유하는 습관이 됩니다."
    },
    "대장장이": {
      "firstText": "매일의 성실함이 당신의 무기를 만들어냅니다.\n지속은 가장 강력한 도구입니다.",
      "secondText": "작은 계획이라도 세워보세요.\n정리된 하루는 더 큰 성장을 부릅니다."
    },
    "탐험가": {
      "firstText": "세상은 아직도 미지로 가득합니다.\n도전하는 당신이 진짜 탐험가입니다.",
      "secondText": "오늘은 익숙한 길을 벗어나보세요.\n작은 변화가 당신을 새로운 세계로 이끕니다."
    }
  };


  static Color jobToColor(String job) {
    switch (job) {
      case '전사':
        return Colors.redAccent;
      case '마법사':
        return Colors.blueAccent;
      case '대장장이':
        return Colors.amber;
      case '탐험가':
        return Colors.purpleAccent;
      case '힐러':
        return Colors.greenAccent;
      default:
        return Colors.grey; // 예외 케이스
    }
  }

  static List<int> plusHp = [
    -1, 3, 13, 20, 33, 43,
    108, 111, 114, 122, 126,
    203, 206, 219, 227, 229,
    304, 316, 322, 328, 329,
    407, 409, 415, 424, 429,
    503, 510, 522, 524, 529
  ];

  static List<int> plusMp = [
    -1, 2,  10, 21, 31, 42,
    102, 107, 113, 125, 127,
    204, 210, 213, 225, 228,
    301, 311, 313, 324, 326,
    401, 408, 414, 417, 428,
    502, 507, 512, 514, 527,
  ];

  static const Map<String, List<Mission>> mainMissions = {
    '전사': [
      Mission(id: -1, title: '광고보기', unit: '초', baseAmount: 30, baseExp: 100, hp: 5, mp: 5),
      Mission(id: 0, title: '팔굽혀펴기', unit: '회', baseAmount: 50, baseExp: 80, hp: 5, mp: 1),
      Mission(id: 1, title: '유산소 운동', unit: '분', baseAmount: 30, baseExp: 85, hp: 5, mp: 1),
      Mission(id: 2, title: '스쿼트', unit: '회', baseAmount: 50, baseExp: 90, hp: 5, mp: 1),
      Mission(id: 3, title: '체중기록', unit: '회', baseAmount: 1, baseExp: 70, hp: 3, mp: 3),
    ],
    '마법사': [
      Mission(id: -1, title: '광고보기', unit: '초', baseAmount: 30, baseExp: 100, hp: 5, mp: 5),
      Mission(id: 10, title: '공부 루틴 지키기', unit: '회', baseAmount: 1, baseExp: 90, hp: 1, mp: 5),
      Mission(id: 11, title: '외국어 단어 암기', unit: '개', baseAmount: 30, baseExp: 80, hp: 1, mp: 5),
      Mission(id: 12, title: '공부 집중 타이머', unit: '분', baseAmount: 90, baseExp: 85, hp: 1, mp: 5),
      Mission(id: 13, title: '책읽기', unit: '분', baseAmount: 30, baseExp: 70, hp: 3, mp: 3),
    ],
    '힐러': [
      Mission(id: -1, title: '광고보기', unit: '초', baseAmount: 30, baseExp: 100, hp: 5, mp: 5),
      Mission(id: 20, title: '명상하기', unit: '분', baseAmount: 5, baseExp: 50, hp: 1, mp: 5),
      Mission(id: 22, title: '스트레칭', unit: '분', baseAmount: 15, baseExp: 50, hp: 3, mp: 3),
      Mission(id: 21, title: '일기 쓰기', unit: '회', baseAmount: 1, baseExp: 40, hp: 2, mp: 4),
      Mission(id: 23, title: '숙면 준비 루틴', unit: '회', baseAmount: 1, baseExp: 600, hp: 4, mp: 2),
    ],
    '대장장이': [
      Mission(id: -1, title: '광고보기', unit: '초', baseAmount: 30, baseExp: 100, hp: 5, mp: 5),
      Mission(id: 30, title: '생각 메모하기', unit: '회', baseAmount: 3, baseExp: 80, hp: 3, mp: 3),
      Mission(id: 31, title: '자격증 공부', unit: '분', baseAmount: 60, baseExp: 85, hp: 4, mp: 2),
      Mission(id: 32, title: '포트폴리오 만들기', unit: '회', baseAmount: 1, baseExp: 90, hp: 2, mp: 4),
      Mission(id: 33, title: '하루 시작 할 일 체크하기', unit: '회', baseAmount: 1, baseExp: 70, hp: 1, mp: 5),
    ],
    '탐험가': [
      Mission(id: -1, title: '광고보기', unit: '초', baseAmount: 30, baseExp: 100, hp: 5, mp: 5),
      Mission(id: 40, title: '산책하기', unit: '분', baseAmount: 30, baseExp: 80, hp: 4, mp: 2),
      Mission(id: 41, title: '새로운 장소 가보기', unit: '회', baseAmount: 1, baseExp: 90, hp: 4, mp: 2),
      Mission(id: 42, title: '사진 찍기', unit: '장', baseAmount: 3, baseExp: 75, hp: 2, mp: 4),
      Mission(id: 43, title: '맛집 탐방', unit: '회', baseAmount: 1, baseExp: 75, hp: 2, mp: 4),
    ],
  };

  static const Map<String, List<Mission>> subMissions = {
    '전사': [
      Mission(id: 100, title: '플랭크', unit: '초', baseAmount: 60, baseExp: 30, hp: 4, mp: 1),
      Mission(id: 101, title: '버피테스트', unit: '회', baseAmount: 20, baseExp: 40, hp: 5, mp: 0),
      Mission(id: 102, title: '줄넘기', unit: '회', baseAmount: 200, baseExp: 45, hp: 3, mp: 2),
      Mission(id: 103, title: '계단 오르기', unit: '층', baseAmount: 10, baseExp: 35, hp: 3, mp: 2),
      Mission(id: 104, title: '런지', unit: '회', baseAmount: 30, baseExp: 40, hp: 4, mp: 1),
      Mission(id: 105, title: '사이클', unit: '분', baseAmount: 20, baseExp: 40, hp: 5, mp: 0),
      Mission(id: 106, title: '턱걸이', unit: '회', baseAmount: 10, baseExp: 50, hp: 3, mp: 2),
      Mission(id: 107, title: '스텝박스', unit: '분', baseAmount: 15, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 108, title: '물 마시기', unit: '리터', baseAmount: 2, baseExp: 20, hp: 5, mp: 0),
      Mission(id: 109, title: '저녁 단백질 섭취', unit: '회', baseAmount: 1, baseExp: 25, hp: 3, mp: 2),
      Mission(id: 110, title: '체중 측정', unit: '회', baseAmount: 1, baseExp: 10, hp: 2, mp: 3),
      Mission(id: 111, title: '식단 기록', unit: '회', baseAmount: 1, baseExp: 10, hp: 2, mp: 3),
      Mission(id: 112, title: '헬스장 출석', unit: '회', baseAmount: 1, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 113, title: '홈트 영상 따라하기', unit: '회', baseAmount: 1, baseExp: 30, hp: 3, mp: 2),
      Mission(id: 114, title: '체성분 기록', unit: '회', baseAmount: 1, baseExp: 35, hp: 3, mp: 2),
      Mission(id: 115, title: '체중 변화 비교', unit: '회', baseAmount: 1, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 116, title: '복근 운동', unit: '회', baseAmount: 30, baseExp: 45, hp: 4, mp: 1),
      Mission(id: 117, title: '팔 운동', unit: '회', baseAmount: 30, baseExp: 45, hp: 4, mp: 1),
      Mission(id: 118, title: '하체 운동', unit: '회', baseAmount: 30, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 119, title: '가슴 운동', unit: '회', baseAmount: 30, baseExp: 45, hp: 4, mp: 1),
      Mission(id: 120, title: '등 운동', unit: '회', baseAmount: 30, baseExp: 45, hp: 4, mp: 1),
      Mission(id: 121, title: '어깨 운동', unit: '회', baseAmount: 30, baseExp: 45, hp: 4, mp: 1),
      Mission(id: 122, title: '체지방률 체크', unit: '회', baseAmount: 1, baseExp: 40, hp: 2, mp: 3),
      Mission(id: 123, title: '스트레칭 루틴', unit: '분', baseAmount: 10, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 124, title: '전신 순환운동', unit: '분', baseAmount: 15, baseExp: 50, hp: 5, mp: 0),
      Mission(id: 125, title: '운동 전 워밍업', unit: '분', baseAmount: 5, baseExp: 10, hp: 3, mp: 2),
      Mission(id: 126, title: '운동 후 쿨다운', unit: '분', baseAmount: 5, baseExp: 10, hp: 2, mp: 3),
      Mission(id: 127, title: '몸 상태 체크', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 128, title: '아침 스트레칭', unit: '분', baseAmount: 10, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 129, title: '야간 유산소', unit: '분', baseAmount: 20, baseExp: 45, hp: 4, mp: 1),
    ],
    '힐러': [
      Mission(id: 200, title: '감사한 일 적기', unit: '회', baseAmount: 1, baseExp: 30, hp: 3, mp: 2),
      Mission(id: 201, title: '아로마 테라피 즐기기', unit: '회', baseAmount: 1, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 202, title: '마음챙김 호흡', unit: '분', baseAmount: 5, baseExp: 35, hp: 2, mp: 3),
      Mission(id: 203, title: '휴식 음악 듣기', unit: '분', baseAmount: 10, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 204, title: '아침 햇빛 쐬기', unit: '분', baseAmount: 10, baseExp: 10 , hp: 4, mp: 1),
      Mission(id: 205, title: '마음에 드는 글귀 쓰기', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 206, title: '심호흡', unit: '회', baseAmount: 10, baseExp: 25, hp: 0, mp: 5),
      Mission(id: 207, title: '마음 안정 명상', unit: '분', baseAmount: 10, baseExp: 30, hp: 5, mp: 0),
      Mission(id: 208, title: '편안한 공간 정리', unit: '회', baseAmount: 1, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 209, title: '좋아하는 차 마시기', unit: '잔', baseAmount: 1, baseExp: 30, hp: 3, mp: 2),
      Mission(id: 210, title: '자기전 핸드폰 끄기', unit: '회', baseAmount: 1, baseExp: 40, hp: 2, mp: 3),
      Mission(id: 211, title: '휴식 알림 설정', unit: '회', baseAmount: 1, baseExp: 10, hp: 3, mp: 2),
      Mission(id: 212, title: '이완 스트레칭', unit: '분', baseAmount: 10, baseExp: 30, hp: 4, mp: 1),
      Mission(id: 213, title: '아로마 오일 마사지', unit: '회', baseAmount: 1, baseExp: 35, hp: 1, mp: 4),
      Mission(id: 214, title: '긍정 확언 읽기', unit: '회', baseAmount: 1, baseExp: 15, hp: 2, mp: 3),
      Mission(id: 215, title: '디지털 디톡스 시간', unit: '분', baseAmount: 30, baseExp: 40, hp: 2, mp: 3),
      Mission(id: 216, title: '좋은 일 회상하기', unit: '회', baseAmount: 1, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 217, title: '핫팩 찜질', unit: '회', baseAmount: 1, baseExp: 20, hp: 4, mp: 1),
      Mission(id: 218, title: '손 편지 쓰기', unit: '회', baseAmount: 1, baseExp: 45, hp: 1, mp: 4),
      Mission(id: 219, title: '눈 감고 음악 감상', unit: '분', baseAmount: 15, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 220, title: '자기돌봄 루틴 점검', unit: '회', baseAmount: 1, baseExp: 40, hp: 2, mp: 3),
      Mission(id: 221, title: '밤 산책', unit: '분', baseAmount: 20, baseExp: 35, hp: 3, mp: 2),
      Mission(id: 222, title: '감정일기 쓰기', unit: '회', baseAmount: 1, baseExp: 45, hp: 3, mp: 2),
      Mission(id: 223, title: '수면 환경 정비', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 224, title: '숙면 위한 독서', unit: '분', baseAmount: 15, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 225, title: '조용한 공간 찾기', unit: '회', baseAmount: 1, baseExp: 10, hp: 4, mp: 1),
      Mission(id: 226, title: '릴렉스 요가', unit: '분', baseAmount: 20, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 227, title: '자기위로 글쓰기', unit: '회', baseAmount: 1, baseExp: 35, hp: 3, mp: 2),
      Mission(id: 228, title: '오늘 하루 평가하기', unit: '회', baseAmount: 1, baseExp: 35, hp: 2, mp: 3),
      Mission(id: 229, title: '마음 안정 명상 유튜브 보기', unit: '회', baseAmount: 1, baseExp: 30, hp: 2, mp: 3),
    ],
    "마법사" : [
      Mission(id: 300, title: '강의 시청', unit: '분', baseAmount: 30, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 301, title: '퀴즈 풀기', unit: '문제', baseAmount: 10, baseExp: 20, hp: 1, mp: 4),
      Mission(id: 302, title: '암기 복습', unit: '분', baseAmount: 15, baseExp: 35, hp: 2, mp: 3),
      Mission(id: 303, title: '프로그래밍 문제 풀기', unit: '문제', baseAmount: 3, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 304, title: '노션 정리', unit: '분', baseAmount: 20, baseExp: 10, hp: 0, mp: 5),
      Mission(id: 305, title: '유튜브 교육 영상 시청', unit: '분', baseAmount: 15, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 306, title: '작문 연습', unit: '문장', baseAmount: 5, baseExp: 35, hp: 2, mp: 3),
      Mission(id: 307, title: '토익 문제 풀기', unit: '문제', baseAmount: 20, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 308, title: '수학 문제 풀기', unit: '문제', baseAmount: 10, baseExp: 40, hp: 1, mp: 4),
      Mission(id: 309, title: '논문 읽기', unit: '분', baseAmount: 20, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 310, title: '독서노트 작성', unit: '분', baseAmount: 15, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 311, title: '새로운 어휘 정리', unit: '단어', baseAmount: 10, baseExp: 10, hp: 1, mp: 4),
      Mission(id: 312, title: '인터뷰 영어 연습', unit: '문장', baseAmount: 10, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 313, title: '스터디 참여', unit: '문장', baseAmount: 60, baseExp: 35, hp: 1, mp: 4),
      Mission(id: 314, title: '문장 암기', unit: '문장', baseAmount: 5, baseExp: 15, hp: 2, mp: 3),
      Mission(id: 315, title: '요약 정리', unit: '분', baseAmount: 10, baseExp: 40, hp: 1, mp: 4),
      Mission(id: 316, title: '지식 영상 시청', unit: '분', baseAmount: 20, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 317, title: '회화 연습', unit: '분', baseAmount: 20, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 318, title: '발음 연습', unit: '단어', baseAmount: 10, baseExp: 45, hp: 3, mp: 2),
      Mission(id: 319, title: '오답노트 작성', unit: '문제', baseAmount: 5, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 320, title: '새로운 개념 정리', unit: '개념', baseAmount: 3, baseExp: 40, hp: 1, mp: 4),
      Mission(id: 321, title: '자기주도 학습', unit: '분', baseAmount: 20, baseExp: 45, hp: 0, mp: 5),
      Mission(id: 322, title: 'AI 사용해보기', unit: '회', baseAmount: 5, baseExp: 45, hp: 0, mp: 5),
      Mission(id: 323, title: '학습 플래너 작성', unit: '분', baseAmount: 15, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 324, title: '타이머 공부', unit: '회', baseAmount: 3, baseExp: 35, hp: 1, mp: 4),
      Mission(id: 325, title: '정리된 강의 복습', unit: '분', baseAmount: 20, baseExp: 10, hp: 2, mp: 3),
      Mission(id: 326, title: '문제 풀이 영상 시청', unit: '분', baseAmount: 15, baseExp: 40, hp: 3, mp: 2),
      Mission(id: 327, title: '플래시카드 학습', unit: '장', baseAmount: 20, baseExp: 45, hp: 3, mp: 2),
      Mission(id: 328, title: '읽은 내용 요약', unit: '분', baseAmount: 10, baseExp: 35, hp: 1, mp: 4),
      Mission(id: 329, title: '지식 공유', unit: '회', baseAmount: 1, baseExp: 30, hp: 2, mp: 3),
    ],
    "대장장이" : [
      Mission(id: 400, title: '이직 준비 자료 정리', unit: '분', baseAmount: 30, baseExp: 25, hp: 3, mp: 2),
      Mission(id: 401, title: '이력서 업데이트', unit: '회', baseAmount: 1, baseExp: 30, hp: 3, mp: 2),
      Mission(id: 402, title: '자소서 정리', unit: '분', baseAmount: 15, baseExp: 20, hp: 4, mp: 1),
      Mission(id: 403, title: '구직 사이트 탐색', unit: '분', baseAmount: 10, baseExp: 20, hp: 4, mp: 1),
      Mission(id: 404, title: '스터디 참여', unit: '분', baseAmount: 60, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 405, title: '시간 차트 작성', unit: '회', baseAmount: 1, baseExp: 20, hp: 1, mp: 4),
      Mission(id: 406, title: '오늘의 회고', unit: '분', baseAmount: 10, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 407, title: '노션 정리', unit: '분', baseAmount: 10, baseExp: 25, hp: 3, mp: 2),
      Mission(id: 408, title: '문서 백업 정리', unit: '분', baseAmount: 10, baseExp: 20, hp: 4, mp: 1),
      Mission(id: 409, title: '메일함 정리', unit: '분', baseAmount: 15, baseExp: 20, hp: 1, mp: 4),
      Mission(id: 410, title: '캘린더 계획 세우기', unit: '분', baseAmount: 15, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 411, title: '자기계발 책 읽기', unit: '분', baseAmount: 30, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 412, title: '집중시간 타이머 사용', unit: '분', baseAmount: 30, baseExp: 30, hp: 4, mp: 1),
      Mission(id: 413, title: '회의록 정리', unit: '회', baseAmount: 1, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 414, title: '포트폴리오 업데이트', unit: '회', baseAmount: 1, baseExp: 35, hp: 3, mp: 2),
      Mission(id: 415, title: '정리정돈', unit: '분', baseAmount: 10, baseExp: 10, hp: 3, mp: 2),
      Mission(id: 416, title: '블로그 글쓰기', unit: '건', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 417, title: '새 툴 익히기', unit: '분', baseAmount: 30, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 418, title: '학습 로그 작성', unit: '줄', baseAmount: 5, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 419, title: '할 일 미루지 않기', unit: '회', baseAmount: 1, baseExp: 30, hp: 4, mp: 1),
      Mission(id: 420, title: '업무 자동화 시도', unit: '회', baseAmount: 1, baseExp: 25, hp: 1, mp: 4),
      Mission(id: 421, title: '간단한 스크립트 작성', unit: '회', baseAmount: 20, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 422, title: '코딩 학습', unit: '분', baseAmount: 60, baseExp: 35, hp: 3, mp: 2),
      Mission(id: 423, title: '정리된 폴더 구조 만들기', unit: '분', baseAmount: 10, baseExp: 10, hp: 2, mp: 3),
      Mission(id: 424, title: 'To-Do 앱 정리', unit: '회', baseAmount: 1, baseExp: 15, hp: 2, mp: 3),
      Mission(id: 425, title: '자기개발 피드백 기록', unit: '줄', baseAmount: 5, baseExp: 20, hp: 1, mp: 4),
      Mission(id: 426, title: '회고 질문 답하기', unit: '문항', baseAmount: 3, baseExp: 20, hp: 1, mp: 4),
      Mission(id: 427, title: '새로운 공부법 시도', unit: '개', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 428, title: '시작 시간 지키기', unit: '회', baseAmount: 1, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 429, title: '집중 방해 요소 제거', unit: '개', baseAmount: 1, baseExp: 25, hp: 3, mp: 2),
    ],
    "탐험가" : [
      Mission(id: 500, title: '지도에서 가보고 싶은 곳 마크', unit: '분', baseAmount: 30, baseExp: 25, hp: 1, mp: 4),
      Mission(id: 501, title: '가보지 않은 카페 방문', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 502, title: '새로운 취미 아이템 검색', unit: '분', baseAmount: 15, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 503, title: '유튜브로 여행 영상 보기', unit: '분', baseAmount: 30, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 504, title: '가이드북 훑어보기', unit: '분', baseAmount: 60, baseExp: 30, hp: 3, mp: 2),
      Mission(id: 505, title: '특이한 산책로 탐색', unit: '분', baseAmount: 15, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 506, title: '새로운 액티비티 체험', unit: '회', baseAmount: 1, baseExp: 25, hp: 1, mp: 4),
      Mission(id: 507, title: '즉흥 산책', unit: '분', baseAmount: 10, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 508, title: '사진 찍기', unit: '장', baseAmount: 10, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 509, title: '오늘 처음 보는 것 기록', unit: '회', baseAmount: 3, baseExp: 20, hp: 3, mp: 2),
      Mission(id: 510, title: '새로운 음악 듣기', unit: '분', baseAmount: 15, baseExp: 25, hp: 2, mp: 3),
      Mission(id: 511, title: '색다른 패션 스타일 입어보기', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 512, title: '소풍 스타일 점심 준비', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 513, title: '도보로 새로운 길 탐색', unit: '회', baseAmount: 1, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 514, title: '근처 명소 찾아가기', unit: '회', baseAmount: 1, baseExp: 35, hp: 2, mp: 3),
      Mission(id: 515, title: '사진첩에서 여행 사진 SNS업로드', unit: '장', baseAmount: 5, baseExp: 10, hp: 1, mp: 4),
      Mission(id: 516, title: '도전하고 싶은 리스트 작성', unit: '개', baseAmount: 3, baseExp: 30, hp: 3, mp: 2),
      Mission(id: 517, title: '모르는 동네 검색하기', unit: '분', baseAmount: 10, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 518, title: '즉흥 계획 짜기', unit: '회', baseAmount: 1, baseExp: 25, hp: 3, mp: 2),
      Mission(id: 519, title: '아침 일찍 일어나기', unit: '회', baseAmount: 1, baseExp: 30, hp: 2, mp: 3),
      Mission(id: 520, title: '도전과제 브레인스토밍', unit: '회', baseAmount: 1, baseExp: 25, hp: 3, mp: 2),
      Mission(id: 521, title: '방문한 장소 리뷰 작성', unit: '회', baseAmount: 1, baseExp: 25, hp: 4, mp: 1),
      Mission(id: 522, title: '걷기 앱으로 기록 남기기', unit: '회', baseAmount: 1, baseExp: 35, hp: 1, mp: 4),
      Mission(id: 523, title: '방문 장소 블로그 기록', unit: '회', baseAmount: 1, baseExp: 10, hp: 2, mp: 3),
      Mission(id: 524, title: 'AI와 대화하기', unit: '분', baseAmount: 5, baseExp: 15, hp: 2, mp: 3),
      Mission(id: 525, title: '특이한 간판 찍기', unit: '장', baseAmount: 2, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 526, title: '즉석 장소 추천 받아가기', unit: '회', baseAmount: 1, baseExp: 20, hp: 2, mp: 3),
      Mission(id: 527, title: '낯선 곳에서 커피 마시기', unit: '회', baseAmount: 1, baseExp: 30, hp: 1, mp: 4),
      Mission(id: 528, title: '매일 다른 향수 뿌리기', unit: '회', baseAmount: 1, baseExp: 20, hp: 4, mp: 1),
      Mission(id: 529, title: '모르는 사람에게 말걸기', unit: '회', baseAmount: 1, baseExp: 25, hp: 3, mp: 2),
    ]
  };


}
