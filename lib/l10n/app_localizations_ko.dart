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
  String get budgets => 'Budgets';

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
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get addRecurringTransaction => 'Add Recurring Transaction';

  @override
  String get editRecurringTransaction => 'Edit Recurring Transaction';

  @override
  String get deleteRecurringTransaction => 'Delete Recurring Transaction';

  @override
  String get deleteRecurringConfirmation =>
      'Are you sure you want to delete this recurring transaction?';

  @override
  String get noRecurringTransactions => 'No recurring transactions yet';

  @override
  String get addRecurringTransactionHint =>
      'Save time by adding regular transactions like salary and bills';

  @override
  String get frequency => 'Frequency';

  @override
  String get yearly => 'Yearly';

  @override
  String get dayOfMonth => 'Day of Month';

  @override
  String get dayOfWeek => 'Day of Week';

  @override
  String get nextExecution => 'Next Execution';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get optional => 'Optional';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'e.g. Netflix subscription';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get budget => 'Budget';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteBudgetConfirmation =>
      'Are you sure you want to delete this budget?';

  @override
  String get noBudgets => 'No budgets yet';

  @override
  String get addBudgetHint =>
      'Create a budget to keep your expenses under control';

  @override
  String get budgetName => 'Budget Name';

  @override
  String get budgetNameHint => 'e.g. Monthly Food Budget';

  @override
  String get pleaseEnterBudgetName => 'Please enter budget name';

  @override
  String get budgetAmount => 'Budget Limit';

  @override
  String get budgetPeriod => 'Budget Period';

  @override
  String get budgetStartDay => 'Period Start Day';

  @override
  String get allExpenses => 'All Expenses';

  @override
  String get notifyAtPercent => 'Warning Percentage';

  @override
  String get notifyWhenExceeded => 'Notify when exceeded';

  @override
  String get used => 'used';

  @override
  String get exceeded => 'exceeded';

  @override
  String get secureData => 'Your data is secure and encrypted';

  @override
  String get cloudSync => 'Sync across all your devices';

  @override
  String get smartInsights => 'Smart insights about your finances';

  @override
  String get discoverFeatures => 'Discover Features';

  @override
  String get discoverFeaturesDesc =>
      'Everything you need to manage your finances';

  @override
  String get budgetTracking => 'Budget Tracking';

  @override
  String get budgetTrackingDesc => 'Set spending limits and stay on track';

  @override
  String get recurringTransactionsDesc => 'Automate your regular payments';

  @override
  String get selectLanguageDesc => 'Choose your preferred language';

  @override
  String get selectThemeDesc => 'Personalize your app experience';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeRose => 'Rose';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get japaneseYen => 'Japanese Yen';

  @override
  String get russianRuble => 'Russian Ruble';
}
