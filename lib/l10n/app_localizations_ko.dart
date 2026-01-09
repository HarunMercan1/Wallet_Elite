// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Wallet Elite';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

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
}
