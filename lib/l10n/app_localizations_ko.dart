// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '지갑 엘리트';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get saved => '저장됨';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get add => '추가';

  @override
  String get ok => '확인';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get loading => '로딩 중...';

  @override
  String get search => '검색...';

  @override
  String get all => '전체';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get notFound => '찾을 수 없음';

  @override
  String get home => '홈';

  @override
  String get transactions => '거래';

  @override
  String get statistics => '통계';

  @override
  String get settings => '설정';

  @override
  String get welcome => '환영합니다,';

  @override
  String get totalBalance => '총 잔액';

  @override
  String get recentTransactions => '최근 거래';

  @override
  String get noTransactions => '거래 내역 없음';

  @override
  String get addFirstTransaction => '+를 탭하여 추가하세요!';

  @override
  String get income => '수입';

  @override
  String get expense => '지출';

  @override
  String get amount => '금액';

  @override
  String get category => '카테고리';

  @override
  String get note => '메모';

  @override
  String get date => '날짜';

  @override
  String get wallet => '지갑';

  @override
  String get addTransaction => '거래 추가';

  @override
  String get editTransaction => '거래 편집';

  @override
  String get deleteTransaction => '거래 삭제';

  @override
  String get transactionAdded => '거래가 추가되었습니다';

  @override
  String get transactionUpdated => '거래가 업데이트되었습니다';

  @override
  String get transactionDeleted => '거래가 삭제되었습니다';

  @override
  String get enterAmount => '금액 입력';

  @override
  String get selectWallet => '지갑 선택';

  @override
  String get addNote => '메모 추가...';

  @override
  String get more => '더보기';

  @override
  String get searchTransactions => '거래 검색...';

  @override
  String get noIncomeFound => '수입 내역 없음';

  @override
  String get noExpenseFound => '지출 내역 없음';

  @override
  String get confirmDelete => '이 거래를 삭제하시겠습니까? 취소할 수 없습니다.';

  @override
  String get categories => '카테고리';

  @override
  String get incomeCategories => '수입 카테고리';

  @override
  String get expenseCategories => '지출 카테고리';

  @override
  String get newCategory => '새 카테고리';

  @override
  String get newIncomeCategory => '새 수입 카테고리';

  @override
  String get newExpenseCategory => '새 지출 카테고리';

  @override
  String get categoryName => '카테고리 이름';

  @override
  String get selectIcon => '아이콘 선택:';

  @override
  String get categoryAdded => '카테고리가 추가되었습니다';

  @override
  String get createCategories => '카테고리 생성';

  @override
  String get noCategories => '카테고리 없음';

  @override
  String get longPressToFavorite => '길게 눌러 즐겨찾기 추가/제거';

  @override
  String addedToFavorites(String name) {
    return '$name이(가) 즐겨찾기에 추가되었습니다';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name이(가) 즐겨찾기에서 제거되었습니다';
  }

  @override
  String get wallets => '지갑';

  @override
  String get addWallet => '지갑 추가';

  @override
  String get walletName => '지갑 이름';

  @override
  String get walletType => '지갑 유형';

  @override
  String get initialBalance => '초기 잔액';

  @override
  String get cash => '현금';

  @override
  String get bank => '은행';

  @override
  String get creditCard => '신용카드';

  @override
  String get savings => '저축';

  @override
  String get walletAdded => '지갑이 추가되었습니다';

  @override
  String get walletDeleted => '지갑이 삭제되었습니다';

  @override
  String get editWallet => '지갑 편집';

  @override
  String get walletUpdated => '지갑이 업데이트되었습니다';

  @override
  String get deleteWallet => '지갑 삭제';

  @override
  String get deleteWalletConfirm => '정말 삭제하시겠습니까? 모든 거래가 영구적으로 삭제됩니다.';

  @override
  String get noWallets => '지갑 없음';

  @override
  String get manageWallets => '지갑 관리';

  @override
  String get categoryNotFound => '카테고리를 찾을 수 없음';

  @override
  String get walletNotFound => '지갑을 찾을 수 없음';

  @override
  String errorWithDetails(String details) {
    return '오류: $details';
  }

  @override
  String get networkError => '네트워크 연결 오류. 인터넷 연결을 확인하세요.';

  @override
  String get appearance => '외관';

  @override
  String get theme => '테마';

  @override
  String get language => '언어';

  @override
  String get dark => '다크';

  @override
  String get light => '라이트';

  @override
  String get system => '시스템';

  @override
  String get selectTheme => '테마 선택';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get colorScheme => '색상 테마';

  @override
  String get account => '계정';

  @override
  String get signOut => '로그아웃';

  @override
  String get signOutConfirm => '로그아웃 하시겠습니까?';

  @override
  String get user => '사용자';

  @override
  String get login => '로그인';

  @override
  String get register => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get fullName => '이름';

  @override
  String get forgotPassword => '비밀번호 찾기';

  @override
  String get noAccount => '계정이 없으신가요?';

  @override
  String get haveAccount => '이미 계정이 있으신가요?';

  @override
  String get loginSuccess => '로그인 성공!';

  @override
  String get registerSuccess => '가입 성공! 이메일을 확인하세요.';

  @override
  String get thisMonth => '이번 달';

  @override
  String get lastMonth => '지난 달';

  @override
  String get thisYear => '올해';

  @override
  String get monthly => '월간';

  @override
  String get weekly => '주간';

  @override
  String get daily => '일간';

  @override
  String get totalIncome => '총 수입';

  @override
  String get totalExpense => '총 지출';

  @override
  String get balance => '잔액';

  @override
  String get categoryBreakdown => '카테고리별 분석';

  @override
  String get cat_food => '음식';

  @override
  String get cat_transport => '교통';

  @override
  String get cat_shopping => '쇼핑';

  @override
  String get cat_entertainment => '엔터테인먼트';

  @override
  String get cat_bills => '공과금';

  @override
  String get cat_health => '건강';

  @override
  String get cat_education => '교육';

  @override
  String get cat_rent => '임대료';

  @override
  String get cat_taxes => '세금';

  @override
  String get cat_salary => '급여';

  @override
  String get cat_freelance => '프리랜서';

  @override
  String get cat_investment => '투자';

  @override
  String get cat_gift => '선물';

  @override
  String get cat_other => '기타';

  @override
  String get cat_pets => '반려동물';

  @override
  String get cat_groceries => '식료품';

  @override
  String get cat_electronics => '전자제품';

  @override
  String get cat_charity => '기부';

  @override
  String get cat_insurance => '보험';

  @override
  String get cat_gym => '운동';

  @override
  String get cat_travel => '여행';

  @override
  String get statisticsTitle => '통계 개요';

  @override
  String get periodFilter => '기간';

  @override
  String get allTime => '전체 기간';

  @override
  String get last7Days => '최근 7일';

  @override
  String get last30Days => '최근 30일';

  @override
  String get averageDailySpending => '일 평균 지출';

  @override
  String get totalTransactions => '총 거래';

  @override
  String get incomeCount => '수입 횟수';

  @override
  String get expenseCount => '지출 횟수';

  @override
  String get topCategories => '상위 카테고리';

  @override
  String get savingsRate => '저축률';

  @override
  String get biggestIncome => '최대 수입';

  @override
  String get biggestExpense => '최대 지출';

  @override
  String get noData => '해당 기간 데이터 없음';

  @override
  String get spendingTrend => '지출 추세';

  @override
  String get incomeVsExpense => '수입 vs 지출';

  @override
  String get loginTab => '로그인';

  @override
  String get registerTab => '회원가입';

  @override
  String get tagline => '당신의 재정적 자유, 손 안에서';

  @override
  String get enterFullName => '이름 입력';

  @override
  String get nameTooShort => '이름은 2자 이상이어야 합니다';

  @override
  String get enterEmail => '이메일 입력';

  @override
  String get validEmail => '유효한 이메일을 입력하세요';

  @override
  String get enterPassword => '비밀번호 입력';

  @override
  String get passwordTooShort => '비밀번호는 6자 이상이어야 합니다';

  @override
  String get forgotPasswordTitle => '비밀번호 재설정';

  @override
  String get forgotPasswordText => '비밀번호 재설정 링크를 이메일로 보내드립니다.';

  @override
  String get send => '전송';

  @override
  String get passwordResetSent => '비밀번호 재설정 링크를 보냈습니다.';

  @override
  String get loginFailed => '로그인 실패. 이메일 또는 비밀번호를 확인하세요.';

  @override
  String get registerFailed => '가입 실패. 이메일이 이미 사용 중일 수 있습니다.';

  @override
  String get googleLoginFailed => 'Google 로그인 실패';

  @override
  String get continueWithGoogle => 'Google로 계속';

  @override
  String get orDivider => '또는';

  @override
  String get privacyText => '계속하면 서비스 약관 및 개인정보 보호정책에 동의하게 됩니다';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get welcomeTitle => 'Wallet Elite에\\n오신 것을 환영합니다! 👋';

  @override
  String get welcomeSubtitle => '재정적 자유를 향한 여정을 시작하기 위한 몇 가지 간단한 단계입니다.';

  @override
  String get manageWalletsDesc => '모든 계정을 한 곳에서 추적';

  @override
  String get analyzeSpending => '지출 분석';

  @override
  String get analyzeSpendingDesc => '돈이 어디로 가는지 확인';

  @override
  String get debtBook => '채무 장부';

  @override
  String get debtBookDesc => '채권과 채무 추적';

  @override
  String get backButton => '뒤로';

  @override
  String get continueButton => '계속';

  @override
  String get startButton => '시작';

  @override
  String get selectCurrency => '통화 선택';

  @override
  String get selectCurrencyDesc => '모든 계정에서 사용할 통화를 선택하세요';

  @override
  String get turkishLira => '터키 리라';

  @override
  String get usDollar => '미국 달러';

  @override
  String get euro => '유로';

  @override
  String get britishPound => '영국 파운드';

  @override
  String get createFirstWallet => '첫 번째 지갑 만들기';

  @override
  String get createWalletDesc => '돈을 추적하기 위해 지갑을 만드세요';

  @override
  String get walletNameHint => '예: 내 현금';

  @override
  String get cashType => '현금';

  @override
  String get bankAccount => '은행 계좌';

  @override
  String get creditCardType => '신용카드';

  @override
  String get investmentType => '금/투자';

  @override
  String get initialBalanceOptional => '초기 잔액 (선택사항)';

  @override
  String get initialBalanceHint => '현재 보유한 금액을 입력하세요. 나중에 변경할 수 있습니다.';

  @override
  String get enterWalletName => '지갑 이름을 입력하세요';

  @override
  String get onboardingSuccess => '가입 성공! 이제 로그인할 수 있습니다.';

  @override
  String get mon => '월';

  @override
  String get tue => '화';

  @override
  String get wed => '수';

  @override
  String get thu => '목';

  @override
  String get fri => '금';

  @override
  String get sat => '토';

  @override
  String get sun => '일';

  @override
  String get addExpense => '지출 추가';

  @override
  String get addIncome => '수입 추가';

  @override
  String get expenseAdded => '지출이 추가되었습니다';

  @override
  String get incomeAdded => '수입이 추가되었습니다';

  @override
  String get debtTracking => '채무 추적';

  @override
  String get myLends => '빌려준 돈';

  @override
  String get myDebts => '빌린 돈';

  @override
  String get personName => '상대방 이름';

  @override
  String get dueDate => '만기일';

  @override
  String get recordPayment => '결제 기록';

  @override
  String daysRemaining(int days) {
    return '$days일 남음';
  }

  @override
  String get overdue => '연체';

  @override
  String get remaining => '남은 금액';

  @override
  String get lend => '빌려줌';

  @override
  String get borrow => '빌림';

  @override
  String get upcomingDues => '다가오는 만기';

  @override
  String get allRecords => '모든 기록';

  @override
  String get hideCompleted => '완료 숨기기';

  @override
  String get showCompleted => '완료 표시';

  @override
  String get markAsCompleted => '완료로 표시';

  @override
  String get debtAdded => '기록이 추가되었습니다';

  @override
  String get debtUpdated => '기록이 업데이트되었습니다';

  @override
  String get debtDeleted => '기록이 삭제되었습니다';

  @override
  String get paymentRecorded => '결제가 기록되었습니다';

  @override
  String get noDebts => '채무 기록 없음';

  @override
  String get addDebt => '기록 추가';

  @override
  String get debtAmount => '금액';

  @override
  String get debtDescription => '설명 (선택사항)';

  @override
  String get selectDueDate => '만기일 선택';

  @override
  String get totalLent => '총 빌려준 금액';

  @override
  String get totalBorrowed => '총 빌린 금액';

  @override
  String people(int count) {
    return '$count명';
  }

  @override
  String memberSince(String date) {
    return '$date부터 회원';
  }

  @override
  String get editProfile => '프로필 편집';

  @override
  String get profileUpdated => '프로필이 업데이트되었습니다';

  @override
  String get changePhoto => '사진 변경';

  @override
  String get takePhoto => '사진 촬영';

  @override
  String get chooseFromGallery => '갤러리에서 선택';

  @override
  String get removePhoto => '사진 삭제';

  @override
  String get notifications => '알림';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get thisMonthSummary => '이번 달 요약';

  @override
  String get financialScore => '재정 점수';

  @override
  String get financialScoreDesc => '재정 건전성 점수';

  @override
  String get spendingTips => '지출 팁';

  @override
  String get spendingTipsDesc => '절약 제안';

  @override
  String get categoryAnalysis => '카테고리 분석';

  @override
  String get categoryAnalysisDesc => '상세 지출 내역';

  @override
  String get monthlyComparison => '월별 비교';

  @override
  String get monthlyComparisonDesc => '이전 달과 비교';

  @override
  String get budgetProgress => '예산 진행률';

  @override
  String get budgetProgressDesc => '목표 달성도';

  @override
  String get viewDetails => '상세 보기';

  @override
  String get excellent => '훌륭함';

  @override
  String get good => '좋음';

  @override
  String get average => '보통';

  @override
  String get needsImprovement => '개선 필요';

  @override
  String get poor => '나쁨';

  @override
  String get comparedToLastMonth => '지난달 대비';

  @override
  String get youSpentLess => '지출 감소';

  @override
  String get youSpentMore => '지출 증가';

  @override
  String get noChange => '변화 없음';

  @override
  String get allWallets => '모든 지갑';

  @override
  String get budgets => '예산';

  @override
  String get history => '기록';

  @override
  String get sort => '정렬';

  @override
  String get payment => '결제';

  @override
  String get completedDebts => '완료된 채무';

  @override
  String get noCompletedDebts => '완료된 채무 없음';

  @override
  String get lent => '빌려줌';

  @override
  String get borrowed => '빌림';

  @override
  String get deleteDebt => '삭제';

  @override
  String get deleteDebtConfirm => '이 기록을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get paymentHistory => '결제 내역';

  @override
  String get noPaymentsYet => '아직 결제 없음';

  @override
  String get displayName => '표시 이름';

  @override
  String get customDateRange => '사용자 지정 기간';

  @override
  String get startDate => '시작 날짜';

  @override
  String get endDate => '종료 날짜';

  @override
  String get selectDateRange => '기간 선택';

  @override
  String get transactionSummary => '거래 요약';

  @override
  String get topSpendingCategory => '최대 지출';

  @override
  String get leastSpendingCategory => '최소 지출';

  @override
  String get averageTransaction => '평균 거래';

  @override
  String get weekdaySpending => '평일 지출';

  @override
  String get weekendSpending => '주말 지출';

  @override
  String get vsLastMonth => 'vs 지난달';

  @override
  String get thisWeek => '이번 주';

  @override
  String get lastWeek => '지난 주';

  @override
  String get last3Months => '최근 3개월';

  @override
  String get last6Months => '최근 6개월';

  @override
  String get viewAllCategories => '모든 카테고리 보기';

  @override
  String get viewTrendDetails => '추세 상세 보기';

  @override
  String get budgetTips => '예산 팁';

  @override
  String get savingsGoal => '저축 목표';

  @override
  String get potentialSavings => '잠재 절약';

  @override
  String ifYouReduce(String category, int percent, String amount) {
    return '$category을(를) $percent% 줄이면 매월 $amount를 절약할 수 있습니다';
  }

  @override
  String get allCategories => '모든 카테고리';

  @override
  String get categoryDetails => '카테고리 세부 정보';

  @override
  String get trendDetails => '추세 상세';

  @override
  String get periodComparison => '기간 비교';

  @override
  String get noExpenseData => '지출 데이터 없음';

  @override
  String get spendingPatterns => '지출 패턴';

  @override
  String get apply => '적용';

  @override
  String get reset => '초기화';

  @override
  String get recurringTransactions => '반복 거래';

  @override
  String get addRecurringTransaction => '반복 거래 추가';

  @override
  String get editRecurringTransaction => '반복 거래 수정';

  @override
  String get deleteRecurringTransaction => '반복 거래 삭제';

  @override
  String get deleteRecurringConfirmation => '이 반복 거래를 삭제하시겠습니까?';

  @override
  String get noRecurringTransactions => '아직 반복 거래가 없습니다';

  @override
  String get addRecurringTransactionHint => '급여, 청구서 등 정기 거래를 추가하여 시간을 절약하세요';

  @override
  String get frequency => '빈도';

  @override
  String get yearly => '연간';

  @override
  String get dayOfMonth => '월의 날';

  @override
  String get dayOfWeek => '요일';

  @override
  String get nextExecution => '다음 실행';

  @override
  String get active => '활성';

  @override
  String get inactive => '비활성';

  @override
  String get optional => '선택사항';

  @override
  String get monday => '월요일';

  @override
  String get tuesday => '화요일';

  @override
  String get wednesday => '수요일';

  @override
  String get thursday => '목요일';

  @override
  String get friday => '금요일';

  @override
  String get saturday => '토요일';

  @override
  String get sunday => '일요일';

  @override
  String get description => '설명';

  @override
  String get descriptionHint => '예: 넷플릭스 구독';

  @override
  String get selectAccount => '계좌 선택';

  @override
  String get selectCategory => '카테고리 선택';

  @override
  String get pleaseEnterAmount => '금액을 입력하세요';

  @override
  String get pleaseEnterValidAmount => '유효한 금액을 입력하세요';

  @override
  String get pleaseSelectAccount => '계좌를 선택하세요';

  @override
  String get budget => '예산';

  @override
  String get addBudget => '예산 추가';

  @override
  String get editBudget => '예산 수정';

  @override
  String get deleteBudget => '예산 삭제';

  @override
  String get deleteBudgetConfirmation => '이 예산을 삭제하시겠습니까?';

  @override
  String get noBudgets => '아직 예산이 없습니다';

  @override
  String get addBudgetHint => '지출을 관리하기 위한 예산을 만드세요';

  @override
  String get budgetName => '예산 이름';

  @override
  String get budgetNameHint => '예: 월간 식비 예산';

  @override
  String get pleaseEnterBudgetName => '예산 이름을 입력하세요';

  @override
  String get budgetAmount => '예산 한도';

  @override
  String get budgetPeriod => '예산 기간';

  @override
  String get budgetStartDay => '기간 시작일';

  @override
  String get allExpenses => '모든 지출';

  @override
  String get notifyAtPercent => '경고 퍼센트';

  @override
  String get notifyWhenExceeded => '초과 시 알림';

  @override
  String get used => '사용됨';

  @override
  String get exceeded => '초과';

  @override
  String get secureData => '데이터는 안전하게 암호화됩니다';

  @override
  String get cloudSync => '모든 기기에서 동기화';

  @override
  String get smartInsights => '재정에 대한 스마트 인사이트';

  @override
  String get discoverFeatures => '기능 살펴보기';

  @override
  String get discoverFeaturesDesc => '재정 관리에 필요한 모든 것';

  @override
  String get budgetTracking => '예산 추적';

  @override
  String get budgetTrackingDesc => '지출 한도를 설정하고 지키세요';

  @override
  String get recurringTransactionsDesc => '정기 결제를 자동화하세요';

  @override
  String get selectLanguageDesc => '선호하는 언어를 선택하세요';

  @override
  String get selectThemeDesc => '앱 경험을 개인화하세요';

  @override
  String get themeOcean => '오션';

  @override
  String get themeSunset => '선셋';

  @override
  String get themeForest => '숲';

  @override
  String get themeLavender => '라벤더';

  @override
  String get themeMidnight => '미드나이트';

  @override
  String get themeRose => '로즈';

  @override
  String get darkMode => '다크 모드';

  @override
  String get japaneseYen => '일본 엔';

  @override
  String get russianRuble => '러시아 루블';

  @override
  String get categoryDistribution => '카테고리 분포';

  @override
  String get other => '기타';

  @override
  String get last7DaysSpending => '최근 7일 지출';

  @override
  String get currencyLabel => '통화';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountConfirmTitle => '계정을 삭제하시겠습니까?';

  @override
  String get deleteAccountConfirmMessage =>
      '계정과 모든 데이터(지갑, 거래, 카테고리, 예산, 부채)가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteAccountConfirmButton => '영구 삭제';

  @override
  String get deleteAccountSuccess => '계정이 삭제되었습니다.';

  @override
  String get filter => '필터';

  @override
  String get transactionTypeLabel => '거래 유형';

  @override
  String get highestAmount => '높은 금액순';

  @override
  String get lowestAmount => '낮은 금액순';

  @override
  String get appSettingsSection => '앱';

  @override
  String get replayAppTour => '앱 둘러보기 다시 보기';

  @override
  String get replayAppTourDesc => '앱의 기능 알아보기';

  @override
  String get watchAdToUnlock => '광고 보고 잠금 해제';

  @override
  String get premiumThemeUnlockMessage =>
      '짧은 광고를 보면 이 프리미엄 테마가 영구적으로 잠금 해제됩니다.';

  @override
  String get watchAd => '광고 보기';

  @override
  String get uploadYourPhoto => '내 사진 업로드';

  @override
  String get orPickAvatar => '또는 아바타 선택';

  @override
  String get signingIn => '로그인 중...';

  @override
  String get appTour => '앱 둘러보기';

  @override
  String get languageSupportTitle => '18개 언어 🌍';

  @override
  String get languageSupportDesc => '내 언어로 사용하세요';

  @override
  String get colorThemesTitle => '색상 테마 🎨';

  @override
  String get colorThemesDesc => '스타일 선택 + 다크 모드';

  @override
  String get darkModeAvailable => '다크 모드도 지원합니다!';

  @override
  String get multiCurrencyTitle => '다양한 통화 💰';

  @override
  String get multiCurrencyDesc => '전 세계 통화를 지원합니다';

  @override
  String get nextButton => '다음';

  @override
  String get errInvalidCredentials => '이메일 또는 비밀번호가 올바르지 않습니다';

  @override
  String get errEmailNotConfirmed => '이메일 주소를 인증해 주세요';

  @override
  String get errTooManyRequests => '시도 횟수가 너무 많습니다. 잠시 기다려 주세요';

  @override
  String get errEmailInUse => '이미 사용 중인 이메일 주소입니다';

  @override
  String get errWeakPassword => '비밀번호가 너무 약합니다';

  @override
  String get errInvalidEmail => '유효하지 않은 이메일 주소입니다';

  @override
  String get errGoogleConfig => 'Google 로그인 설정 오류(코드 10).';

  @override
  String get errPlayServices => 'Google Play 서비스가 오래되었거나 이 기기에서 지원되지 않습니다.';

  @override
  String get newestFirst => '최신순';

  @override
  String get oldestFirst => '오래된순';

  @override
  String get deleteAccountConfirmWord => '삭제';

  @override
  String deleteAccountTypeToConfirm(String word) {
    return '확인하려면 $word을(를) 입력하세요';
  }

  @override
  String get premiumTitle => 'Wallet Elite Premium';

  @override
  String get premiumSubtitle => '모든 기능을 잠금 해제하세요';

  @override
  String get premiumFeatureNoAds => '광고 없음';

  @override
  String get premiumFeatureThemes => '모든 프리미엄 테마';

  @override
  String get premiumFeatureUnlimited => '무제한 지갑 및 예산';

  @override
  String get premiumFeatureExport => '데이터 내보내기 (CSV / Excel)';

  @override
  String get planMonthly => '월간';

  @override
  String get planYearly => '연간';

  @override
  String get planLifetime => '평생';

  @override
  String get perMonth => '/ 월';

  @override
  String get perYear => '/ 년';

  @override
  String get oneTimePayment => '일회성 결제';

  @override
  String get bestValue => '가장 저렴';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get purchaseSuccess => 'Premium에 오신 것을 환영합니다! 🎉';

  @override
  String get restoreSuccess => '구매가 복원되었습니다.';

  @override
  String get purchasePending => '결제가 대기 중입니다. 확인되면 Premium이 활성화됩니다.';

  @override
  String get restoreNothing => '이 계정의 이전 구매 내역을 찾을 수 없습니다.';

  @override
  String get purchaseNotAvailable => '지금은 구매할 수 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get subscriptionTerms =>
      '구독은 해지할 때까지 자동으로 갱신됩니다. Google Play > 결제 및 구독에서 언제든지 해지할 수 있습니다.';

  @override
  String get premiumActive => 'Premium 활성화됨';

  @override
  String get premiumActiveDesc => 'Wallet Elite를 응원해 주셔서 감사합니다!';

  @override
  String get goPremium => 'Premium으로 업그레이드';

  @override
  String get goPremiumDesc => '광고 없음, 모든 테마, 무제한 지갑 및 예산';

  @override
  String walletLimitReached(int count) {
    return '무료 플랜에서는 지갑을 최대 $count개까지 만들 수 있습니다. 무제한으로 사용하려면 Premium으로 업그레이드하세요.';
  }

  @override
  String budgetLimitReached(int count) {
    return '무료 플랜에서는 활성 예산을 최대 $count개까지 만들 수 있습니다. 무제한으로 사용하려면 Premium으로 업그레이드하세요.';
  }

  @override
  String unlockThemeTitle(String name) {
    return '$name 잠금 해제';
  }

  @override
  String get rewardedThemeUnlockMessage =>
      '짧은 광고를 보고 이 테마를 24시간 사용하거나, Premium으로 업그레이드해 모든 테마를 영구적으로 잠금 해제하세요.';

  @override
  String get adNotReady => '광고가 아직 준비되지 않았습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get themeUnlocked24h => '테마가 24시간 동안 잠금 해제되었습니다';

  @override
  String get adPrivacySettings => '광고 개인정보 설정';

  @override
  String get exportData => '데이터 내보내기';

  @override
  String get exportDataDesc => '거래 내역을 CSV 파일로 공유 (Excel에서 열림)';

  @override
  String get exportFailed => '내보내기 실패';

  @override
  String get exportNoData => '내보낼 거래가 없습니다.';

  @override
  String get cat_clothing => '의류';

  @override
  String get supportSection => '지원';

  @override
  String get sendFeedback => '개발자에게 보내기';

  @override
  String get sendFeedbackDesc => '제안, 불만 또는 요청을 이메일로 보내기';

  @override
  String emailAppNotFound(String email) {
    return '이메일 앱을 찾을 수 없습니다. 주소: $email';
  }

  @override
  String get rateApp => '평가하기';

  @override
  String get rateAppDesc => 'Google Play에서 평점 남기기';

  @override
  String get updateAvailableTitle => '업데이트 가능';

  @override
  String get updateAvailableMessage =>
      'Wallet Elite의 새 버전이 나왔습니다. 최신 기능과 수정 사항을 위해 업데이트하세요.';

  @override
  String get updateNow => '업데이트';

  @override
  String get later => '나중에';

  @override
  String get summaryImage => '요약 이미지';

  @override
  String get summaryImageDesc => '요약을 이미지로 저장하거나 공유';

  @override
  String get saveToGallery => '갤러리에 저장';

  @override
  String get share => '공유';

  @override
  String get imageSaved => '이미지가 갤러리에 저장되었습니다';

  @override
  String get imageSaveFailed => '이미지를 저장하지 못했습니다';

  @override
  String get premiumFeatureStats => '상세 통계 및 비교';

  @override
  String get premiumStatsMessage => '상세 분석은 Premium에서 이용할 수 있습니다.';

  @override
  String savePercent(int percent) {
    return '$percent% 할인';
  }

  @override
  String pricePerMonth(String price) {
    return '월 $price';
  }

  @override
  String freeTrialDays(int days) {
    return '$days일 무료';
  }

  @override
  String get startFreeTrial => '무료 체험 시작';

  @override
  String get retry => '다시 시도';

  @override
  String get loadErrorMessage => '데이터를 불러오지 못했습니다. 연결을 확인하고 다시 시도하세요.';
}
