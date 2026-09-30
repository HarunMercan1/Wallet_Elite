// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'المحفظة إيليت';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get ok => 'حسناً';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get search => 'بحث...';

  @override
  String get all => 'الكل';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get notFound => 'غير موجود';

  @override
  String get home => 'الرئيسية';

  @override
  String get transactions => 'المعاملات';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get welcome => 'مرحباً،';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get noTransactions => 'لا توجد معاملات';

  @override
  String get addFirstTransaction => 'اضغط + للإضافة!';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'مصروف';

  @override
  String get amount => 'المبلغ';

  @override
  String get category => 'الفئة';

  @override
  String get note => 'ملاحظة';

  @override
  String get date => 'التاريخ';

  @override
  String get wallet => 'المحفظة';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get editTransaction => 'تعديل معاملة';

  @override
  String get deleteTransaction => 'حذف معاملة';

  @override
  String get transactionAdded => 'تمت إضافة المعاملة';

  @override
  String get transactionUpdated => 'تم تحديث المعاملة';

  @override
  String get transactionDeleted => 'تم حذف المعاملة';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get selectWallet => 'اختر المحفظة';

  @override
  String get addNote => 'أضف ملاحظة...';

  @override
  String get more => 'المزيد';

  @override
  String get searchTransactions => 'بحث في المعاملات...';

  @override
  String get noIncomeFound => 'لم يتم العثور على دخل';

  @override
  String get noExpenseFound => 'لم يتم العثور على مصروف';

  @override
  String get confirmDelete => 'هل أنت متأكد من الحذف؟';

  @override
  String get categories => 'الفئات';

  @override
  String get incomeCategories => 'فئات الدخل';

  @override
  String get expenseCategories => 'فئات المصروفات';

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String get newIncomeCategory => 'فئة دخل جديدة';

  @override
  String get newExpenseCategory => 'فئة مصروف جديدة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get selectIcon => 'اختر أيقونة:';

  @override
  String get categoryAdded => 'تمت إضافة الفئة';

  @override
  String get createCategories => 'إنشاء فئات';

  @override
  String get noCategories => 'لا توجد فئات';

  @override
  String get longPressToFavorite => 'اضغط مطولاً للمفضلة';

  @override
  String addedToFavorites(String name) {
    return 'تمت إضافة $name للمفضلة';
  }

  @override
  String removedFromFavorites(String name) {
    return 'تمت إزالة $name من المفضلة';
  }

  @override
  String get wallets => 'المحافظ';

  @override
  String get addWallet => 'إضافة محفظة';

  @override
  String get walletName => 'اسم المحفظة';

  @override
  String get walletType => 'نوع المحفظة';

  @override
  String get initialBalance => 'الرصيد الافتتاحي';

  @override
  String get cash => 'نقدي';

  @override
  String get bank => 'بنك';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get savings => 'ادخار';

  @override
  String get walletAdded => 'تمت إضافة المحفظة';

  @override
  String get walletDeleted => 'تم حذف المحفظة';

  @override
  String get editWallet => 'تعديل المحفظة';

  @override
  String get walletUpdated => 'تم تحديث المحفظة';

  @override
  String get deleteWallet => 'حذف المحفظة';

  @override
  String get deleteWalletConfirm =>
      'هل أنت متأكد من حذف هذه المحفظة؟ سيتم حذف جميع المعاملات بشكل دائم.';

  @override
  String get noWallets => 'لا توجد محافظ';

  @override
  String get manageWallets => 'إدارة المحافظ';

  @override
  String get categoryNotFound => 'لم يتم العثور على فئة';

  @override
  String get walletNotFound => 'لم يتم العثور على محفظة';

  @override
  String errorWithDetails(String details) {
    return 'خطأ: $details';
  }

  @override
  String get networkError => 'خطأ في اتصال الشبكة. يرجى التحقق من الإنترنت.';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get language => 'الغة';

  @override
  String get dark => 'داكن';

  @override
  String get light => 'فاتح';

  @override
  String get system => 'النظام';

  @override
  String get selectTheme => 'اختر السمة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get colorScheme => 'نظام الألوان';

  @override
  String get account => 'الحساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get user => 'المستخدم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get registerSuccess => 'تم التسجيل بنجاح!';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get thisYear => 'هذه السنة';

  @override
  String get monthly => 'شهري';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get daily => 'يومي';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get totalExpense => 'إجمالي المصروفات';

  @override
  String get balance => 'الرصيد';

  @override
  String get categoryBreakdown => 'توزيع الفئات';

  @override
  String get cat_food => 'طعام';

  @override
  String get cat_transport => 'نقل';

  @override
  String get cat_shopping => 'تسوق';

  @override
  String get cat_entertainment => 'ترفيه';

  @override
  String get cat_bills => 'فواتير';

  @override
  String get cat_health => 'صحة';

  @override
  String get cat_education => 'تعليم';

  @override
  String get cat_rent => 'إيجار';

  @override
  String get cat_taxes => 'ضرائب';

  @override
  String get cat_salary => 'راتب';

  @override
  String get cat_freelance => 'عمل حر';

  @override
  String get cat_investment => 'استثمار';

  @override
  String get cat_gift => 'هدية';

  @override
  String get cat_other => 'أخرى';

  @override
  String get cat_pets => 'حيوانات أليفة';

  @override
  String get cat_groceries => 'بقالة';

  @override
  String get cat_electronics => 'إلكترونيات';

  @override
  String get cat_charity => 'صدقة';

  @override
  String get cat_insurance => 'تأمين';

  @override
  String get cat_gym => 'رياضة';

  @override
  String get cat_travel => 'سفر';

  @override
  String get statisticsTitle => 'نظرة عامة على الإحصائيات';

  @override
  String get periodFilter => 'الفترة';

  @override
  String get allTime => 'كل الأوقات';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get last30Days => 'آخر 30 يوم';

  @override
  String get averageDailySpending => 'متوسط الإنفاق اليومي';

  @override
  String get totalTransactions => 'إجمالي المعاملات';

  @override
  String get incomeCount => 'عدد الدخل';

  @override
  String get expenseCount => 'عدد المصروفات';

  @override
  String get topCategories => 'أعلى الفئات';

  @override
  String get savingsRate => 'معدل التوفير';

  @override
  String get biggestIncome => 'أكبر دخل';

  @override
  String get biggestExpense => 'أكبر مصروف';

  @override
  String get noData => 'لا توجد بيانات لهذه الفترة';

  @override
  String get spendingTrend => 'اتجاه الإنفاق';

  @override
  String get incomeVsExpense => 'الدخل مقابل المصروف';

  @override
  String get loginTab => 'تسجيل الدخول';

  @override
  String get registerTab => 'تسجيل';

  @override
  String get tagline => 'حريتك المالية بين يديك';

  @override
  String get enterFullName => 'أدخل الاسم الكامل';

  @override
  String get nameTooShort => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get validEmail => 'أدخل بريد إلكتروني صالح';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordText => 'سنرسل لك رابط إعادة التعيين.';

  @override
  String get send => 'إرسال';

  @override
  String get passwordResetSent => 'تم إرسال رابط إعادة التعيين.';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. تحقق من البريد أو كلمة المرور.';

  @override
  String get registerFailed => 'فشل التسجيل. قد يكون البريد مستخدم بالفعل.';

  @override
  String get googleLoginFailed => 'فشل تسجيل الدخول بواسطة Google';

  @override
  String get continueWithGoogle => 'المتابعة مع Google';

  @override
  String get orDivider => 'أو';

  @override
  String get privacyText =>
      'بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get welcomeTitle => 'مرحباً بك في\\nWallet Elite! 👋';

  @override
  String get welcomeSubtitle =>
      'بضع خطوات بسيطة لبدء رحلتك نحو الحرية المالية.';

  @override
  String get manageWalletsDesc => 'تتبع جميع الحسابات في مكان واحد';

  @override
  String get analyzeSpending => 'حلل إنفاقك';

  @override
  String get analyzeSpendingDesc => 'شاهد أين تذهب أموالك';

  @override
  String get debtBook => 'دفتر الديون';

  @override
  String get debtBookDesc => 'تتبع المستحقات والمطلوبات';

  @override
  String get backButton => 'رجوع';

  @override
  String get continueButton => 'متابعة';

  @override
  String get startButton => 'ابدأ';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get selectCurrencyDesc =>
      'اختر العملة التي ستستخدمها في جميع الحسابات';

  @override
  String get turkishLira => 'الليرة التركية';

  @override
  String get usDollar => 'الدولار الأمريكي';

  @override
  String get euro => 'اليورو';

  @override
  String get britishPound => 'الجنيه الإسترليني';

  @override
  String get createFirstWallet => 'أنشئ محفظتك الأولى';

  @override
  String get createWalletDesc => 'أنشئ محفظة لتتبع أموالك';

  @override
  String get walletNameHint => 'مثال: نقودي';

  @override
  String get cashType => 'نقدي';

  @override
  String get bankAccount => 'حساب بنكي';

  @override
  String get creditCardType => 'بطاقة ائتمان';

  @override
  String get investmentType => 'ذهب/استثمار';

  @override
  String get initialBalanceOptional => 'الرصيد الافتتاحي (اختياري)';

  @override
  String get initialBalanceHint => 'أدخل كم لديك الآن. يمكنك التغيير لاحقاً.';

  @override
  String get enterWalletName => 'يرجى إدخال اسم المحفظة';

  @override
  String get onboardingSuccess => 'تم التسجيل بنجاح! يمكنك الدخول الآن.';

  @override
  String get mon => 'الاثنين';

  @override
  String get tue => 'الثلاثاء';

  @override
  String get wed => 'الأربعاء';

  @override
  String get thu => 'الخميس';

  @override
  String get fri => 'الجمعة';

  @override
  String get sat => 'السبت';

  @override
  String get sun => 'الأحد';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addIncome => 'إضافة دخل';

  @override
  String get expenseAdded => 'تمت إضافة المصروف';

  @override
  String get incomeAdded => 'تمت إضافة الدخل';

  @override
  String get debtTracking => 'تتبع الديون';

  @override
  String get myLends => 'أموال أقرضتها';

  @override
  String get myDebts => 'أموال استلفتها';

  @override
  String get personName => 'اسم الشخص';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String daysRemaining(int days) {
    return '$days يوم متبقي';
  }

  @override
  String get overdue => 'متأخر';

  @override
  String get remaining => 'المتبقي';

  @override
  String get lend => 'أقرضت';

  @override
  String get borrow => 'استلفت';

  @override
  String get upcomingDues => 'استحقاقات قادمة';

  @override
  String get allRecords => 'جميع السجلات';

  @override
  String get hideCompleted => 'إخفاء المكتملة';

  @override
  String get showCompleted => 'إظهار المكتملة';

  @override
  String get markAsCompleted => 'وضع علامة مكتمل';

  @override
  String get debtAdded => 'تمت إضافة السجل';

  @override
  String get debtUpdated => 'تم تحديث السجل';

  @override
  String get debtDeleted => 'تم حذف السجل';

  @override
  String get paymentRecorded => 'تم تسجيل الدفعة';

  @override
  String get noDebts => 'لا توجد سجلات ديون بعد';

  @override
  String get addDebt => 'إضافة سجل';

  @override
  String get debtAmount => 'المبلغ';

  @override
  String get debtDescription => 'الوصف (اختياري)';

  @override
  String get selectDueDate => 'اختر تاريخ الاستحقاق';

  @override
  String get totalLent => 'إجمالي المُقرض';

  @override
  String get totalBorrowed => 'إجمالي المستلف';

  @override
  String people(int count) {
    return '$count أشخاص';
  }

  @override
  String memberSince(String date) {
    return 'عضو منذ $date';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get thisMonthSummary => 'ملخص هذا الشهر';

  @override
  String get financialScore => 'النقاط المالية';

  @override
  String get financialScoreDesc => 'نقاط صحتك المالية';

  @override
  String get spendingTips => 'نصائح الإنفاق';

  @override
  String get spendingTipsDesc => 'اقتراحات التوفير';

  @override
  String get categoryAnalysis => 'تحليل الفئات';

  @override
  String get categoryAnalysisDesc => 'تفصيل الإنفاق';

  @override
  String get monthlyComparison => 'المقارنة الشهرية';

  @override
  String get monthlyComparisonDesc => 'مقارنة مع الأشهر السابقة';

  @override
  String get budgetProgress => 'تقدم الميزانية';

  @override
  String get budgetProgressDesc => 'مدى قربك من أهدافك';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get excellent => 'ممتاز';

  @override
  String get good => 'جيد';

  @override
  String get average => 'متوسط';

  @override
  String get needsImprovement => 'يحتاج تحسين';

  @override
  String get poor => 'ضعيف';

  @override
  String get comparedToLastMonth => 'مقارنة بالشهر الماضي';

  @override
  String get youSpentLess => 'أنفقت أقل';

  @override
  String get youSpentMore => 'أنفقت أكثر';

  @override
  String get noChange => 'لا تغيير';

  @override
  String get allWallets => 'جميع المحافظ';

  @override
  String get budgets => 'Budgets';

  @override
  String get history => 'السجل';

  @override
  String get sort => 'ترتيب';

  @override
  String get payment => 'دفعة';

  @override
  String get completedDebts => 'الديون المكتملة';

  @override
  String get noCompletedDebts => 'لا توجد ديون مكتملة';

  @override
  String get lent => 'أقرضت';

  @override
  String get borrowed => 'استلفت';

  @override
  String get deleteDebt => 'حذف';

  @override
  String get deleteDebtConfirm =>
      'هل تريد حذف هذا السجل؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get paymentHistory => 'سجل الدفعات';

  @override
  String get noPaymentsYet => 'لا توجد دفعات بعد';

  @override
  String get displayName => 'اسم العرض';

  @override
  String get customDateRange => 'نطاق مخصص';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get selectDateRange => 'اختر نطاق التاريخ';

  @override
  String get transactionSummary => 'ملخص المعاملات';

  @override
  String get topSpendingCategory => 'أعلى إنفاق';

  @override
  String get leastSpendingCategory => 'أقل إنفاق';

  @override
  String get averageTransaction => 'متوسط المعاملة';

  @override
  String get weekdaySpending => 'إنفاق أيام الأسبوع';

  @override
  String get weekendSpending => 'إنفاق نهاية الأسبوع';

  @override
  String get vsLastMonth => 'مقابل الشهر الماضي';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get lastWeek => 'الأسبوع الماضي';

  @override
  String get last3Months => 'آخر 3 أشهر';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get viewAllCategories => 'عرض جميع الفئات';

  @override
  String get viewTrendDetails => 'عرض تفاصيل الاتجاه';

  @override
  String get budgetTips => 'نصائح الميزانية';

  @override
  String get savingsGoal => 'هدف التوفير';

  @override
  String get potentialSavings => 'التوفير المحتمل';

  @override
  String ifYouReduce(String category, int percent, String amount) {
    return 'إذا قللت $category بنسبة $percent%، يمكنك توفير $amount شهرياً';
  }

  @override
  String get allCategories => 'جميع الفئات';

  @override
  String get categoryDetails => 'تفاصيل الفئة';

  @override
  String get trendDetails => 'تفاصيل الاتجاه';

  @override
  String get periodComparison => 'مقارنة الفترات';

  @override
  String get noExpenseData => 'لا توجد بيانات مصروفات';

  @override
  String get spendingPatterns => 'أنماط الإنفاق';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get recurringTransactions => 'المعاملات المتكررة';

  @override
  String get addRecurringTransaction => 'إضافة معاملة متكررة';

  @override
  String get editRecurringTransaction => 'تعديل المعاملة المتكررة';

  @override
  String get deleteRecurringTransaction => 'حذف المعاملة المتكررة';

  @override
  String get deleteRecurringConfirmation =>
      'هل أنت متأكد من حذف هذه المعاملة المتكررة؟';

  @override
  String get noRecurringTransactions => 'لا توجد معاملات متكررة بعد';

  @override
  String get addRecurringTransactionHint =>
      'وفر الوقت بإضافة معاملات منتظمة كالراتب والفواتير';

  @override
  String get frequency => 'التكرار';

  @override
  String get yearly => 'سنوي';

  @override
  String get dayOfMonth => 'يوم الشهر';

  @override
  String get dayOfWeek => 'يوم الأسبوع';

  @override
  String get nextExecution => 'التنفيذ التالي';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get optional => 'اختياري';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get description => 'الوصف';

  @override
  String get descriptionHint => 'مثال: اشتراك نتفليكس';

  @override
  String get selectAccount => 'اختر حساب';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get pleaseEnterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get pleaseEnterValidAmount => 'الرجاء إدخال مبلغ صالح';

  @override
  String get pleaseSelectAccount => 'الرجاء اختيار حساب';

  @override
  String get budget => 'ميزانية';

  @override
  String get addBudget => 'إضافة ميزانية';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get deleteBudget => 'حذف الميزانية';

  @override
  String get deleteBudgetConfirmation => 'هل أنت متأكد من حذف هذه الميزانية؟';

  @override
  String get noBudgets => 'لا توجد ميزانيات بعد';

  @override
  String get addBudgetHint => 'أنشئ ميزانية للتحكم في نفقاتك';

  @override
  String get budgetName => 'اسم الميزانية';

  @override
  String get budgetNameHint => 'مثال: ميزانية الطعام الشهرية';

  @override
  String get pleaseEnterBudgetName => 'الرجاء إدخال اسم الميزانية';

  @override
  String get budgetAmount => 'حد الميزانية';

  @override
  String get budgetPeriod => 'فترة الميزانية';

  @override
  String get budgetStartDay => 'يوم بداية الفترة';

  @override
  String get allExpenses => 'جميع المصروفات';

  @override
  String get notifyAtPercent => 'نسبة التنبيه';

  @override
  String get notifyWhenExceeded => 'إشعار عند التجاوز';

  @override
  String get used => 'مستخدم';

  @override
  String get exceeded => 'تم تجاوزه';

  @override
  String get secureData => 'بياناتك آمنة ومشفرة';

  @override
  String get cloudSync => 'المزامنة عبر جميع أجهزتك';

  @override
  String get smartInsights => 'رؤى ذكية حول أموالك';

  @override
  String get discoverFeatures => 'اكتشف الميزات';

  @override
  String get discoverFeaturesDesc => 'كل ما تحتاجه لإدارة أموالك';

  @override
  String get budgetTracking => 'تتبع الميزانية';

  @override
  String get budgetTrackingDesc => 'حدد حدود الإنفاق والتزم بها';

  @override
  String get recurringTransactionsDesc => 'أتمت مدفوعاتك المنتظمة';

  @override
  String get selectLanguageDesc => 'اختر لغتك المفضلة';

  @override
  String get selectThemeDesc => 'خصص تجربة التطبيق';

  @override
  String get themeOcean => 'المحيط';

  @override
  String get themeSunset => 'غروب الشمس';

  @override
  String get themeForest => 'الغابة';

  @override
  String get themeLavender => 'اللافندر';

  @override
  String get themeMidnight => 'منتصف الليل';

  @override
  String get themeRose => 'الوردي';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get japaneseYen => 'الين الياباني';

  @override
  String get russianRuble => 'الروبل الروسي';

  @override
  String get categoryDistribution => 'توزيع الفئات';

  @override
  String get other => 'أخرى';

  @override
  String get last7DaysSpending => 'إنفاق آخر 7 أيام';

  @override
  String get currencyLabel => 'العملة';
}
