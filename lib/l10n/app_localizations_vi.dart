// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Ví Tiền Ưu Tú';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get saved => 'Đã lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Sửa';

  @override
  String get add => 'Thêm';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Lỗi';

  @override
  String get success => 'Thành công';

  @override
  String get loading => 'Đang tải...';

  @override
  String get search => 'Tìm kiếm...';

  @override
  String get all => 'Tất cả';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get notFound => 'không tìm thấy';

  @override
  String get home => 'Trang chủ';

  @override
  String get transactions => 'Giao dịch';

  @override
  String get statistics => 'Thống kê';

  @override
  String get settings => 'Cài đặt';

  @override
  String get welcome => 'Chào mừng,';

  @override
  String get totalBalance => 'Tổng số dư';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get noTransactions => 'Chưa có giao dịch nào';

  @override
  String get addFirstTransaction => 'Nhấn + để thêm giao dịch đầu tiên!';

  @override
  String get income => 'Thu nhập';

  @override
  String get expense => 'Chi tiêu';

  @override
  String get amount => 'Số tiền';

  @override
  String get category => 'Danh mục';

  @override
  String get note => 'Ghi chú';

  @override
  String get date => 'Ngày';

  @override
  String get wallet => 'Ví';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get editTransaction => 'Sửa giao dịch';

  @override
  String get deleteTransaction => 'Xóa giao dịch';

  @override
  String get transactionAdded => 'Đã thêm giao dịch';

  @override
  String get transactionUpdated => 'Đã cập nhật giao dịch';

  @override
  String get transactionDeleted => 'Đã xóa giao dịch';

  @override
  String get enterAmount => 'Nhập số tiền';

  @override
  String get selectWallet => 'Chọn ví';

  @override
  String get addNote => 'Thêm ghi chú...';

  @override
  String get more => 'Thêm';

  @override
  String get searchTransactions => 'Tìm kiếm giao dịch...';

  @override
  String get noIncomeFound => 'Không tìm thấy thu nhập';

  @override
  String get noExpenseFound => 'Không tìm thấy chi tiêu';

  @override
  String get confirmDelete =>
      'Bạn có chắc muốn xóa giao dịch này? Không thể hoàn tác.';

  @override
  String get categories => 'Danh mục';

  @override
  String get incomeCategories => 'Danh mục thu nhập';

  @override
  String get expenseCategories => 'Danh mục chi tiêu';

  @override
  String get newCategory => 'Danh mục mới';

  @override
  String get newIncomeCategory => 'Danh mục thu nhập mới';

  @override
  String get newExpenseCategory => 'Danh mục chi tiêu mới';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get selectIcon => 'Chọn biểu tượng:';

  @override
  String get categoryAdded => 'Đã thêm danh mục';

  @override
  String get createCategories => 'Tạo danh mục';

  @override
  String get noCategories => 'Chưa có danh mục nào';

  @override
  String get longPressToFavorite => 'Nhấn giữ để thêm/xóa yêu thích';

  @override
  String addedToFavorites(String name) {
    return '$name đã thêm vào yêu thích';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name đã xóa khỏi yêu thích';
  }

  @override
  String get wallets => 'Ví';

  @override
  String get addWallet => 'Thêm ví';

  @override
  String get walletName => 'Tên ví';

  @override
  String get walletType => 'Loại ví';

  @override
  String get initialBalance => 'Số dư ban đầu';

  @override
  String get cash => 'Tiền mặt';

  @override
  String get bank => 'Ngân hàng';

  @override
  String get creditCard => 'Thẻ tín dụng';

  @override
  String get savings => 'Tiết kiệm';

  @override
  String get walletAdded => 'Đã thêm ví';

  @override
  String get walletDeleted => 'Đã xóa ví';

  @override
  String get editWallet => 'Sửa ví';

  @override
  String get walletUpdated => 'Đã cập nhật ví';

  @override
  String get deleteWallet => 'Xóa ví';

  @override
  String get deleteWalletConfirm =>
      'Bạn có chắc muốn xóa ví này? Tất cả giao dịch sẽ bị xóa vĩnh viễn.';

  @override
  String get noWallets => 'Chưa có ví nào';

  @override
  String get manageWallets => 'Quản lý ví';

  @override
  String get categoryNotFound => 'Không tìm thấy danh mục';

  @override
  String get walletNotFound => 'Không tìm thấy ví';

  @override
  String errorWithDetails(String details) {
    return 'Lỗi: $details';
  }

  @override
  String get networkError => 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';

  @override
  String get appearance => 'Giao diện';

  @override
  String get theme => 'Chủ đề';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get dark => 'Tối';

  @override
  String get light => 'Sáng';

  @override
  String get system => 'Hệ thống';

  @override
  String get selectTheme => 'Chọn chủ đề';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get colorScheme => 'Bảng màu';

  @override
  String get account => 'Tài khoản';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get signOutConfirm => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get user => 'Người dùng';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get forgotPassword => 'Quên mật khẩu';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get haveAccount => 'Đã có tài khoản?';

  @override
  String get loginSuccess => 'Đăng nhập thành công!';

  @override
  String get registerSuccess => 'Đăng ký thành công! Vui lòng xác minh email.';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get lastMonth => 'Tháng trước';

  @override
  String get thisYear => 'Năm nay';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get weekly => 'Hàng tuần';

  @override
  String get daily => 'Hàng ngày';

  @override
  String get totalIncome => 'Tổng thu nhập';

  @override
  String get totalExpense => 'Tổng chi tiêu';

  @override
  String get balance => 'Số dư';

  @override
  String get categoryBreakdown => 'Phân tích danh mục';

  @override
  String get cat_food => 'Ăn uống';

  @override
  String get cat_transport => 'Di chuyển';

  @override
  String get cat_shopping => 'Mua sắm';

  @override
  String get cat_entertainment => 'Giải trí';

  @override
  String get cat_bills => 'Hóa đơn';

  @override
  String get cat_health => 'Sức khỏe';

  @override
  String get cat_education => 'Giáo dục';

  @override
  String get cat_rent => 'Thuê nhà';

  @override
  String get cat_taxes => 'Thuế';

  @override
  String get cat_salary => 'Lương';

  @override
  String get cat_freelance => 'Freelance';

  @override
  String get cat_investment => 'Đầu tư';

  @override
  String get cat_gift => 'Quà tặng';

  @override
  String get cat_other => 'Khác';

  @override
  String get cat_pets => 'Thú cưng';

  @override
  String get cat_groceries => 'Tạp hóa';

  @override
  String get cat_electronics => 'Điện tử';

  @override
  String get cat_charity => 'Từ thiện';

  @override
  String get cat_insurance => 'Bảo hiểm';

  @override
  String get cat_gym => 'Gym';

  @override
  String get cat_travel => 'Du lịch';

  @override
  String get statisticsTitle => 'Tổng quan thống kê';

  @override
  String get periodFilter => 'Thời gian';

  @override
  String get allTime => 'Tất cả';

  @override
  String get last7Days => '7 ngày qua';

  @override
  String get last30Days => '30 ngày qua';

  @override
  String get averageDailySpending => 'Chi tiêu TB ngày';

  @override
  String get totalTransactions => 'Tổng giao dịch';

  @override
  String get incomeCount => 'Số thu nhập';

  @override
  String get expenseCount => 'Số chi tiêu';

  @override
  String get topCategories => 'Danh mục hàng đầu';

  @override
  String get savingsRate => 'Tỷ lệ tiết kiệm';

  @override
  String get biggestIncome => 'Thu nhập lớn nhất';

  @override
  String get biggestExpense => 'Chi tiêu lớn nhất';

  @override
  String get noData => 'Không có dữ liệu cho kỳ này';

  @override
  String get spendingTrend => 'Xu hướng chi tiêu';

  @override
  String get incomeVsExpense => 'Thu nhập vs Chi tiêu';

  @override
  String get loginTab => 'Đăng nhập';

  @override
  String get registerTab => 'Đăng ký';

  @override
  String get tagline => 'Tự do tài chính, trong tầm tay bạn';

  @override
  String get enterFullName => 'Nhập họ và tên';

  @override
  String get nameTooShort => 'Tên phải có ít nhất 2 ký tự';

  @override
  String get enterEmail => 'Nhập email';

  @override
  String get validEmail => 'Nhập email hợp lệ';

  @override
  String get enterPassword => 'Nhập mật khẩu';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get forgotPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get forgotPasswordText =>
      'Chúng tôi sẽ gửi liên kết đặt lại mật khẩu đến email của bạn.';

  @override
  String get send => 'Gửi';

  @override
  String get passwordResetSent => 'Đã gửi liên kết đặt lại mật khẩu.';

  @override
  String get loginFailed => 'Đăng nhập thất bại. Kiểm tra email hoặc mật khẩu.';

  @override
  String get registerFailed =>
      'Đăng ký thất bại. Email có thể đã được sử dụng.';

  @override
  String get googleLoginFailed => 'Đăng nhập Google thất bại';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get orDivider => 'hoặc';

  @override
  String get privacyText =>
      'Tiếp tục đồng nghĩa với việc bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật';

  @override
  String get errorOccurred => 'Đã xảy ra lỗi';

  @override
  String get welcomeTitle => 'Chào mừng đến với\\nVí Tiền Ưu Tú! 👋';

  @override
  String get welcomeSubtitle =>
      'Chỉ vài bước đơn giản để bắt đầu hành trình tự do tài chính.';

  @override
  String get manageWalletsDesc => 'Theo dõi tất cả tài khoản tại một nơi';

  @override
  String get analyzeSpending => 'Phân tích chi tiêu';

  @override
  String get analyzeSpendingDesc => 'Xem tiền của bạn đi đâu';

  @override
  String get debtBook => 'Sổ nợ';

  @override
  String get debtBookDesc => 'Theo dõi công nợ';

  @override
  String get backButton => 'Quay lại';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String get startButton => 'Bắt đầu';

  @override
  String get selectCurrency => 'Chọn tiền tệ';

  @override
  String get selectCurrencyDesc =>
      'Chọn tiền tệ bạn sẽ sử dụng trong tất cả tài khoản';

  @override
  String get turkishLira => 'Lira Thổ Nhĩ Kỳ';

  @override
  String get usDollar => 'Đô la Mỹ';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'Bảng Anh';

  @override
  String get createFirstWallet => 'Tạo ví đầu tiên';

  @override
  String get createWalletDesc => 'Tạo ví để bắt đầu theo dõi tiền của bạn';

  @override
  String get walletNameHint => 'ví dụ: Tiền mặt';

  @override
  String get cashType => 'Tiền mặt';

  @override
  String get bankAccount => 'Tài khoản ngân hàng';

  @override
  String get creditCardType => 'Thẻ tín dụng';

  @override
  String get investmentType => 'Vàng/Đầu tư';

  @override
  String get initialBalanceOptional => 'Số dư ban đầu (tùy chọn)';

  @override
  String get initialBalanceHint =>
      'Nhập số tiền bạn hiện có. Bạn có thể thay đổi sau.';

  @override
  String get enterWalletName => 'Vui lòng nhập tên ví';

  @override
  String get onboardingSuccess =>
      'Đăng ký thành công! Bây giờ bạn có thể đăng nhập.';

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';

  @override
  String get addExpense => 'Thêm chi tiêu';

  @override
  String get addIncome => 'Thêm thu nhập';

  @override
  String get expenseAdded => 'Đã thêm chi tiêu';

  @override
  String get incomeAdded => 'Đã thêm thu nhập';

  @override
  String get debtTracking => 'Theo dõi nợ';

  @override
  String get myLends => 'Tiền cho vay';

  @override
  String get myDebts => 'Tiền vay';

  @override
  String get personName => 'Tên người';

  @override
  String get dueDate => 'Ngày đến hạn';

  @override
  String get recordPayment => 'Ghi nhận thanh toán';

  @override
  String daysRemaining(int days) {
    return 'Còn $days ngày';
  }

  @override
  String get overdue => 'Quá hạn';

  @override
  String get remaining => 'Còn lại';

  @override
  String get lend => 'Tôi cho vay';

  @override
  String get borrow => 'Tôi vay';

  @override
  String get upcomingDues => 'Sắp đến hạn';

  @override
  String get allRecords => 'Tất cả bản ghi';

  @override
  String get hideCompleted => 'Ẩn hoàn thành';

  @override
  String get showCompleted => 'Hiện hoàn thành';

  @override
  String get markAsCompleted => 'Đánh dấu hoàn thành';

  @override
  String get debtAdded => 'Đã thêm bản ghi';

  @override
  String get debtUpdated => 'Đã cập nhật bản ghi';

  @override
  String get debtDeleted => 'Đã xóa bản ghi';

  @override
  String get paymentRecorded => 'Đã ghi nhận thanh toán';

  @override
  String get noDebts => 'Chưa có bản ghi nợ nào';

  @override
  String get addDebt => 'Thêm bản ghi';

  @override
  String get debtAmount => 'Số tiền';

  @override
  String get debtDescription => 'Mô tả (tùy chọn)';

  @override
  String get selectDueDate => 'Chọn ngày đến hạn';

  @override
  String get totalLent => 'Tổng cho vay';

  @override
  String get totalBorrowed => 'Tổng đã vay';

  @override
  String people(int count) {
    return '$count người';
  }

  @override
  String memberSince(String date) {
    return 'Thành viên từ $date';
  }

  @override
  String get editProfile => 'Sửa hồ sơ';

  @override
  String get profileUpdated => 'Đã cập nhật hồ sơ';

  @override
  String get changePhoto => 'Đổi ảnh';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get chooseFromGallery => 'Chọn từ thư viện';

  @override
  String get removePhoto => 'Xóa ảnh';

  @override
  String get notifications => 'Thông báo';

  @override
  String get quickActions => 'Thao tác nhanh';

  @override
  String get thisMonthSummary => 'Tóm tắt tháng này';

  @override
  String get financialScore => 'Điểm tài chính';

  @override
  String get financialScoreDesc => 'Điểm sức khỏe tài chính của bạn';

  @override
  String get spendingTips => 'Mẹo chi tiêu';

  @override
  String get spendingTipsDesc => 'Gợi ý tiết kiệm';

  @override
  String get categoryAnalysis => 'Phân tích danh mục';

  @override
  String get categoryAnalysisDesc => 'Phân tích chi tiêu chi tiết';

  @override
  String get monthlyComparison => 'So sánh hàng tháng';

  @override
  String get monthlyComparisonDesc => 'So sánh với các tháng trước';

  @override
  String get budgetProgress => 'Tiến độ ngân sách';

  @override
  String get budgetProgressDesc => 'Tiến độ đạt mục tiêu';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String get excellent => 'Xuất sắc';

  @override
  String get good => 'Tốt';

  @override
  String get average => 'Trung bình';

  @override
  String get needsImprovement => 'Cần cải thiện';

  @override
  String get poor => 'Kém';

  @override
  String get comparedToLastMonth => 'So với tháng trước';

  @override
  String get youSpentLess => 'bạn chi tiêu ít hơn';

  @override
  String get youSpentMore => 'bạn chi tiêu nhiều hơn';

  @override
  String get noChange => 'Không thay đổi';

  @override
  String get allWallets => 'Tất cả ví';

  @override
  String get budgets => 'Ngân sách';

  @override
  String get history => 'Lịch sử';

  @override
  String get sort => 'Sắp xếp';

  @override
  String get payment => 'Thanh toán';

  @override
  String get completedDebts => 'Nợ đã hoàn thành';

  @override
  String get noCompletedDebts => 'Không có nợ hoàn thành';

  @override
  String get lent => 'Cho vay';

  @override
  String get borrowed => 'Đã vay';

  @override
  String get deleteDebt => 'Xóa bản ghi';

  @override
  String get deleteDebtConfirm =>
      'Bạn có chắc muốn xóa bản ghi này? Không thể hoàn tác.';

  @override
  String get paymentHistory => 'Lịch sử thanh toán';

  @override
  String get noPaymentsYet => 'Chưa có thanh toán nào';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get customDateRange => 'Tùy chỉnh';

  @override
  String get startDate => 'Ngày bắt đầu';

  @override
  String get endDate => 'Ngày kết thúc';

  @override
  String get selectDateRange => 'Chọn khoảng thời gian';

  @override
  String get transactionSummary => 'Tóm tắt giao dịch';

  @override
  String get topSpendingCategory => 'Chi tiêu nhiều nhất';

  @override
  String get leastSpendingCategory => 'Chi tiêu ít nhất';

  @override
  String get averageTransaction => 'Giao dịch TB';

  @override
  String get weekdaySpending => 'Chi tiêu ngày thường';

  @override
  String get weekendSpending => 'Chi tiêu cuối tuần';

  @override
  String get vsLastMonth => 'So với tháng trước';

  @override
  String get thisWeek => 'Tuần này';

  @override
  String get lastWeek => 'Tuần trước';

  @override
  String get last3Months => '3 tháng qua';

  @override
  String get last6Months => '6 tháng qua';

  @override
  String get viewAllCategories => 'Xem tất cả danh mục';

  @override
  String get viewTrendDetails => 'Xem chi tiết xu hướng';

  @override
  String get budgetTips => 'Mẹo ngân sách';

  @override
  String get savingsGoal => 'Mục tiêu tiết kiệm';

  @override
  String get potentialSavings => 'Tiết kiệm tiềm năng';

  @override
  String ifYouReduce(String category, int percent, String amount) {
    return 'Nếu bạn giảm $category $percent%, bạn có thể tiết kiệm $amount mỗi tháng';
  }

  @override
  String get allCategories => 'Tất cả danh mục';

  @override
  String get categoryDetails => 'Chi tiết danh mục';

  @override
  String get trendDetails => 'Chi tiết xu hướng';

  @override
  String get periodComparison => 'So sánh thời kỳ';

  @override
  String get noExpenseData => 'Không có dữ liệu chi tiêu';

  @override
  String get spendingPatterns => 'Mẫu chi tiêu';

  @override
  String get apply => 'Áp dụng';

  @override
  String get reset => 'Đặt lại';
}
