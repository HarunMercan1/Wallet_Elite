// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Кошелёк Элит';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get add => 'Добавить';

  @override
  String get ok => 'ОК';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успешно';

  @override
  String get loading => 'Загрузка...';

  @override
  String get search => 'Поиск...';

  @override
  String get all => 'Все';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get notFound => 'не найдено';

  @override
  String get home => 'Главная';

  @override
  String get transactions => 'Транзакции';

  @override
  String get statistics => 'Статистика';

  @override
  String get settings => 'Настройки';

  @override
  String get welcome => 'Добро пожаловать,';

  @override
  String get totalBalance => 'Общий баланс';

  @override
  String get recentTransactions => 'Недавние транзакции';

  @override
  String get noTransactions => 'Нет транзакций';

  @override
  String get addFirstTransaction => 'Нажмите +, чтобы добавить!';

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String get amount => 'Сумма';

  @override
  String get category => 'Категория';

  @override
  String get note => 'Заметка';

  @override
  String get date => 'Дата';

  @override
  String get wallet => 'Кошелек';

  @override
  String get addTransaction => 'Добавить транзакцию';

  @override
  String get editTransaction => 'Редактировать транзакцию';

  @override
  String get deleteTransaction => 'Удалить транзакцию';

  @override
  String get transactionAdded => 'Транзакция добавлена';

  @override
  String get transactionUpdated => 'Транзакция обновлена';

  @override
  String get transactionDeleted => 'Транзакция удалена';

  @override
  String get enterAmount => 'Введите сумму';

  @override
  String get selectWallet => 'Выберите кошелек';

  @override
  String get addNote => 'Добавить заметку...';

  @override
  String get more => 'Ещё';

  @override
  String get searchTransactions => 'Поиск транзакций...';

  @override
  String get noIncomeFound => 'Доходы не найдены';

  @override
  String get noExpenseFound => 'Расходы не найдены';

  @override
  String get confirmDelete => 'Вы уверены, что хотите удалить?';

  @override
  String get categories => 'Категории';

  @override
  String get incomeCategories => 'Категории доходов';

  @override
  String get expenseCategories => 'Категории расходов';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get newIncomeCategory => 'Новая категория доходов';

  @override
  String get newExpenseCategory => 'Новая категория расходов';

  @override
  String get categoryName => 'Название категории';

  @override
  String get selectIcon => 'Выберите иконку:';

  @override
  String get categoryAdded => 'Категория добавлена';

  @override
  String get createCategories => 'Создать категории';

  @override
  String get noCategories => 'Нет категорий';

  @override
  String get longPressToFavorite => 'Долгое нажатие для избранного';

  @override
  String addedToFavorites(String name) {
    return '$name добавлено в избранное';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name удалено из избранного';
  }

  @override
  String get wallets => 'Кошельки';

  @override
  String get addWallet => 'Добавить кошелек';

  @override
  String get walletName => 'Название кошелька';

  @override
  String get walletType => 'Тип кошелька';

  @override
  String get initialBalance => 'Начальный баланс';

  @override
  String get cash => 'Наличные';

  @override
  String get bank => 'Банк';

  @override
  String get creditCard => 'Кредитная карта';

  @override
  String get savings => 'Сбережения';

  @override
  String get walletAdded => 'Кошелек добавлен';

  @override
  String get walletDeleted => 'Кошелек удален';

  @override
  String get editWallet => 'Редактировать кошелек';

  @override
  String get walletUpdated => 'Кошелек обновлен';

  @override
  String get deleteWallet => 'Удалить кошелек';

  @override
  String get deleteWalletConfirm =>
      'Вы уверены? Все транзакции будут удалены навсегда.';

  @override
  String get noWallets => 'Нет кошельков';

  @override
  String get manageWallets => 'Управление кошельками';

  @override
  String get categoryNotFound => 'Категория не найдена';

  @override
  String get walletNotFound => 'Кошелек не найден';

  @override
  String errorWithDetails(String details) {
    return 'Ошибка: $details';
  }

  @override
  String get networkError =>
      'Ошибка сетевого соединения. Пожалуйста, проверьте интернет.';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get dark => 'Темная';

  @override
  String get light => 'Светлая';

  @override
  String get system => 'Системная';

  @override
  String get selectTheme => 'Выберите тему';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get colorScheme => 'Цветовая схема';

  @override
  String get account => 'Аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get user => 'Пользователь';

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get haveAccount => 'Уже есть аккаунт?';

  @override
  String get loginSuccess => 'Вход выполнен!';

  @override
  String get registerSuccess => 'Регистрация успешна!';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get lastMonth => 'Прошлый месяц';

  @override
  String get thisYear => 'Этот год';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get daily => 'Ежедневно';

  @override
  String get totalIncome => 'Общий доход';

  @override
  String get totalExpense => 'Общий расход';

  @override
  String get balance => 'Баланс';

  @override
  String get categoryBreakdown => 'Разбивка по категориям';

  @override
  String get cat_food => 'Еда';

  @override
  String get cat_transport => 'Транспорт';

  @override
  String get cat_shopping => 'Покупки';

  @override
  String get cat_entertainment => 'Развлечения';

  @override
  String get cat_bills => 'Счета';

  @override
  String get cat_health => 'Здоровье';

  @override
  String get cat_education => 'Образование';

  @override
  String get cat_rent => 'Аренда';

  @override
  String get cat_taxes => 'Налоги';

  @override
  String get cat_salary => 'Зарплата';

  @override
  String get cat_freelance => 'Фриланс';

  @override
  String get cat_investment => 'Инвестиции';

  @override
  String get cat_gift => 'Подарок';

  @override
  String get cat_other => 'Прочее';

  @override
  String get cat_pets => 'Питомцы';

  @override
  String get cat_groceries => 'Продукты';

  @override
  String get cat_electronics => 'Электроника';

  @override
  String get cat_charity => 'Благотворительность';

  @override
  String get cat_insurance => 'Страхование';

  @override
  String get cat_gym => 'Спортзал';

  @override
  String get cat_travel => 'Путешествия';

  @override
  String get statisticsTitle => 'Обзор статистики';

  @override
  String get periodFilter => 'Период';

  @override
  String get allTime => 'Все время';

  @override
  String get last7Days => 'Последние 7 дней';

  @override
  String get last30Days => 'Последние 30 дней';

  @override
  String get averageDailySpending => 'Средний расход в день';

  @override
  String get totalTransactions => 'Всего транзакций';

  @override
  String get incomeCount => 'Количество доходов';

  @override
  String get expenseCount => 'Количество расходов';

  @override
  String get topCategories => 'Топ категорий';

  @override
  String get savingsRate => 'Норма сбережений';

  @override
  String get biggestIncome => 'Самый большой доход';

  @override
  String get biggestExpense => 'Самый большой расход';

  @override
  String get noData => 'Нет данных за этот период';

  @override
  String get spendingTrend => 'Тренд расходов';

  @override
  String get incomeVsExpense => 'Доходы vs Расходы';

  @override
  String get loginTab => 'Вход';

  @override
  String get registerTab => 'Регистрация';

  @override
  String get tagline => 'Ваша финансовая свобода в ваших руках';

  @override
  String get enterFullName => 'Введите полное имя';

  @override
  String get nameTooShort => 'Имя должно содержать минимум 2 символа';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get validEmail => 'Введите действительный email';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get passwordTooShort => 'Пароль должен содержать минимум 6 символов';

  @override
  String get forgotPasswordTitle => 'Сброс пароля';

  @override
  String get forgotPasswordText => 'Мы отправим ссылку для сброса пароля.';

  @override
  String get send => 'Отправить';

  @override
  String get passwordResetSent => 'Ссылка для сброса отправлена.';

  @override
  String get loginFailed => 'Ошибка входа. Проверьте email или пароль.';

  @override
  String get registerFailed =>
      'Ошибка регистрации. Email может быть уже использован.';

  @override
  String get googleLoginFailed => 'Ошибка входа через Google';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get orDivider => 'или';

  @override
  String get privacyText =>
      'Продолжая, вы соглашаетесь с Условиями использования и Политикой конфиденциальности';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get welcomeTitle => 'Добро пожаловать в\\nWallet Elite! 👋';

  @override
  String get welcomeSubtitle =>
      'Несколько простых шагов до вашей финансовой свободы.';

  @override
  String get manageWalletsDesc => 'Отслеживайте все счета в одном месте';

  @override
  String get analyzeSpending => 'Анализируйте расходы';

  @override
  String get analyzeSpendingDesc => 'Смотрите, куда уходят деньги';

  @override
  String get debtBook => 'Книга долгов';

  @override
  String get debtBookDesc => 'Отслеживайте дебиторку и кредиторку';

  @override
  String get backButton => 'Назад';

  @override
  String get continueButton => 'Далее';

  @override
  String get startButton => 'Начать';

  @override
  String get selectCurrency => 'Выберите валюту';

  @override
  String get selectCurrencyDesc => 'Выберите валюту для всех счетов';

  @override
  String get turkishLira => 'Турецкая лира';

  @override
  String get usDollar => 'Доллар США';

  @override
  String get euro => 'Евро';

  @override
  String get britishPound => 'Британский фунт';

  @override
  String get createFirstWallet => 'Создайте первый кошелек';

  @override
  String get createWalletDesc => 'Создайте кошелек для отслеживания денег';

  @override
  String get walletNameHint => 'напр.: Мои наличные';

  @override
  String get cashType => 'Наличные';

  @override
  String get bankAccount => 'Банковский счет';

  @override
  String get creditCardType => 'Кредитная карта';

  @override
  String get investmentType => 'Золото/Инвестиции';

  @override
  String get initialBalanceOptional => 'Начальный баланс (необязательно)';

  @override
  String get initialBalanceHint =>
      'Введите, сколько денег у вас сейчас. Можете изменить позже.';

  @override
  String get enterWalletName => 'Введите название кошелька';

  @override
  String get onboardingSuccess => 'Регистрация успешна! Можете войти.';

  @override
  String get mon => 'Пн';

  @override
  String get tue => 'Вт';

  @override
  String get wed => 'Ср';

  @override
  String get thu => 'Чт';

  @override
  String get fri => 'Пт';

  @override
  String get sat => 'Сб';

  @override
  String get sun => 'Вс';

  @override
  String get addExpense => 'Добавить расход';

  @override
  String get addIncome => 'Добавить доход';

  @override
  String get expenseAdded => 'Расход добавлен';

  @override
  String get incomeAdded => 'Доход добавлен';

  @override
  String get debtTracking => 'Учет долгов';

  @override
  String get myLends => 'Одолжил';

  @override
  String get myDebts => 'Взял в долг';

  @override
  String get personName => 'Имя человека';

  @override
  String get dueDate => 'Срок возврата';

  @override
  String get recordPayment => 'Записать платеж';

  @override
  String daysRemaining(int days) {
    return 'Осталось $days дней';
  }

  @override
  String get overdue => 'Просрочено';

  @override
  String get remaining => 'Остаток';

  @override
  String get lend => 'Одолжил';

  @override
  String get borrow => 'Взял в долг';

  @override
  String get upcomingDues => 'Ближайшие сроки';

  @override
  String get allRecords => 'Все записи';

  @override
  String get hideCompleted => 'Скрыть завершенные';

  @override
  String get showCompleted => 'Показать завершенные';

  @override
  String get markAsCompleted => 'Отметить как завершенное';

  @override
  String get debtAdded => 'Запись добавлена';

  @override
  String get debtUpdated => 'Запись обновлена';

  @override
  String get debtDeleted => 'Запись удалена';

  @override
  String get paymentRecorded => 'Платеж записан';

  @override
  String get noDebts => 'Записей о долгах нет';

  @override
  String get addDebt => 'Добавить запись';

  @override
  String get debtAmount => 'Сумма';

  @override
  String get debtDescription => 'Описание (опционально)';

  @override
  String get selectDueDate => 'Выберите срок возврата';

  @override
  String get totalLent => 'Всего одолжено';

  @override
  String get totalBorrowed => 'Всего взято в долг';

  @override
  String people(int count) {
    return '$count человек';
  }

  @override
  String memberSince(String date) {
    return 'Участник с $date';
  }

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get profileUpdated => 'Профиль обновлен';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get notifications => 'Уведомления';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get thisMonthSummary => 'Сводка за месяц';

  @override
  String get financialScore => 'Финансовый рейтинг';

  @override
  String get financialScoreDesc => 'Ваш рейтинг финансового здоровья';

  @override
  String get spendingTips => 'Советы по расходам';

  @override
  String get spendingTipsDesc => 'Рекомендации по экономии';

  @override
  String get categoryAnalysis => 'Анализ категорий';

  @override
  String get categoryAnalysisDesc => 'Детализация расходов';

  @override
  String get monthlyComparison => 'Сравнение по месяцам';

  @override
  String get monthlyComparisonDesc => 'Сравнить с предыдущими месяцами';

  @override
  String get budgetProgress => 'Прогресс бюджета';

  @override
  String get budgetProgressDesc => 'Насколько близки к целям';

  @override
  String get viewDetails => 'Подробнее';

  @override
  String get excellent => 'Отлично';

  @override
  String get good => 'Хорошо';

  @override
  String get average => 'Средне';

  @override
  String get needsImprovement => 'Требует улучшения';

  @override
  String get poor => 'Плохо';

  @override
  String get comparedToLastMonth => 'По сравнению с прошлым месяцем';

  @override
  String get youSpentLess => 'вы потратили меньше';

  @override
  String get youSpentMore => 'вы потратили больше';

  @override
  String get noChange => 'Без изменений';

  @override
  String get allWallets => 'Все кошельки';

  @override
  String get budgets => 'Бюджеты';

  @override
  String get history => 'История';

  @override
  String get sort => 'Сортировка';

  @override
  String get payment => 'Платеж';

  @override
  String get completedDebts => 'Закрытые долги';

  @override
  String get noCompletedDebts => 'Нет закрытых долгов';

  @override
  String get lent => 'Одолжено';

  @override
  String get borrowed => 'Взято в долг';

  @override
  String get deleteDebt => 'Удалить';

  @override
  String get deleteDebtConfirm =>
      'Удалить эту запись? Это действие необратимо.';

  @override
  String get paymentHistory => 'История платежей';

  @override
  String get noPaymentsYet => 'Платежей пока нет';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get customDateRange => 'Свой период';

  @override
  String get startDate => 'Дата начала';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get selectDateRange => 'Выбрать период';

  @override
  String get transactionSummary => 'Сводка транзакций';

  @override
  String get topSpendingCategory => 'Макс. расход';

  @override
  String get leastSpendingCategory => 'Мин. расход';

  @override
  String get averageTransaction => 'Средняя транзакция';

  @override
  String get weekdaySpending => 'Расходы в будни';

  @override
  String get weekendSpending => 'Расходы в выходные';

  @override
  String get vsLastMonth => 'vs Прошлый месяц';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get lastWeek => 'Прошлая неделя';

  @override
  String get last3Months => 'Последние 3 месяца';

  @override
  String get last6Months => 'Последние 6 месяцев';

  @override
  String get viewAllCategories => 'Все категории';

  @override
  String get viewTrendDetails => 'Подробности тренда';

  @override
  String get budgetTips => 'Советы по бюджету';

  @override
  String get savingsGoal => 'Цель сбережений';

  @override
  String get potentialSavings => 'Потенциальная экономия';

  @override
  String ifYouReduce(String category, int percent, String amount) {
    return 'Если сократить $category на $percent%, вы сможете экономить $amount ежемесячно';
  }

  @override
  String get allCategories => 'Все категории';

  @override
  String get categoryDetails => 'Детали категории';

  @override
  String get trendDetails => 'Детали тренда';

  @override
  String get periodComparison => 'Сравнение периодов';

  @override
  String get noExpenseData => 'Нет данных о расходах';

  @override
  String get spendingPatterns => 'Модели расходов';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get recurringTransactions => 'Повторяющиеся транзакции';

  @override
  String get addRecurringTransaction => 'Добавить повторяющуюся транзакцию';

  @override
  String get editRecurringTransaction =>
      'Редактировать повторяющуюся транзакцию';

  @override
  String get deleteRecurringTransaction => 'Удалить повторяющуюся транзакцию';

  @override
  String get deleteRecurringConfirmation =>
      'Вы уверены, что хотите удалить эту повторяющуюся транзакцию?';

  @override
  String get noRecurringTransactions => 'Пока нет повторяющихся транзакций';

  @override
  String get addRecurringTransactionHint =>
      'Экономьте время, добавляя регулярные транзакции, такие как зарплата и счета';

  @override
  String get frequency => 'Частота';

  @override
  String get yearly => 'Ежегодно';

  @override
  String get dayOfMonth => 'День месяца';

  @override
  String get dayOfWeek => 'День недели';

  @override
  String get nextExecution => 'Следующее выполнение';

  @override
  String get active => 'Активный';

  @override
  String get inactive => 'Неактивный';

  @override
  String get optional => 'Необязательно';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get description => 'Описание';

  @override
  String get descriptionHint => 'напр. Подписка Netflix';

  @override
  String get selectAccount => 'Выберите счёт';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get pleaseEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String get pleaseEnterValidAmount => 'Пожалуйста, введите корректную сумму';

  @override
  String get pleaseSelectAccount => 'Пожалуйста, выберите счёт';

  @override
  String get budget => 'Бюджет';

  @override
  String get addBudget => 'Добавить бюджет';

  @override
  String get editBudget => 'Редактировать бюджет';

  @override
  String get deleteBudget => 'Удалить бюджет';

  @override
  String get deleteBudgetConfirmation =>
      'Вы уверены, что хотите удалить этот бюджет?';

  @override
  String get noBudgets => 'Пока нет бюджетов';

  @override
  String get addBudgetHint => 'Создайте бюджет для контроля расходов';

  @override
  String get budgetName => 'Название бюджета';

  @override
  String get budgetNameHint => 'напр. Месячный бюджет на еду';

  @override
  String get pleaseEnterBudgetName => 'Пожалуйста, введите название бюджета';

  @override
  String get budgetAmount => 'Лимит бюджета';

  @override
  String get budgetPeriod => 'Период бюджета';

  @override
  String get budgetStartDay => 'День начала периода';

  @override
  String get allExpenses => 'Все расходы';

  @override
  String get notifyAtPercent => 'Процент предупреждения';

  @override
  String get notifyWhenExceeded => 'Уведомить при превышении';

  @override
  String get used => 'использовано';

  @override
  String get exceeded => 'превышен';

  @override
  String get secureData => 'Ваши данные защищены и зашифрованы';

  @override
  String get cloudSync => 'Синхронизация на всех устройствах';

  @override
  String get smartInsights => 'Умные аналитические данные о финансах';

  @override
  String get discoverFeatures => 'Откройте функции';

  @override
  String get discoverFeaturesDesc => 'Всё необходимое для управления финансами';

  @override
  String get budgetTracking => 'Отслеживание бюджета';

  @override
  String get budgetTrackingDesc =>
      'Установите лимиты расходов и придерживайтесь их';

  @override
  String get recurringTransactionsDesc => 'Автоматизируйте регулярные платежи';

  @override
  String get selectLanguageDesc => 'Выберите предпочитаемый язык';

  @override
  String get selectThemeDesc => 'Персонализируйте ваш опыт';

  @override
  String get themeOcean => 'Океан';

  @override
  String get themeSunset => 'Закат';

  @override
  String get themeForest => 'Лес';

  @override
  String get themeLavender => 'Лаванда';

  @override
  String get themeMidnight => 'Полночь';

  @override
  String get themeRose => 'Роза';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get japaneseYen => 'Японская иена';

  @override
  String get russianRuble => 'Российский рубль';

  @override
  String get categoryDistribution => 'Распределение по категориям';

  @override
  String get other => 'Другое';

  @override
  String get last7DaysSpending => 'Расходы за последние 7 дней';

  @override
  String get currencyLabel => 'Валюта';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountConfirmTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountConfirmMessage =>
      'Ваш аккаунт и все данные (кошельки, транзакции, категории, бюджеты и долги) будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get deleteAccountConfirmButton => 'Удалить навсегда';

  @override
  String get deleteAccountSuccess => 'Ваш аккаунт удалён.';

  @override
  String get filter => 'Фильтр';

  @override
  String get transactionTypeLabel => 'Тип операции';

  @override
  String get highestAmount => 'Самая большая сумма';

  @override
  String get lowestAmount => 'Самая маленькая сумма';

  @override
  String get appSettingsSection => 'Приложение';

  @override
  String get replayAppTour => 'Посмотреть обзор снова';

  @override
  String get replayAppTourDesc => 'Узнайте о возможностях приложения';

  @override
  String get watchAdToUnlock => 'Посмотрите рекламу, чтобы открыть';

  @override
  String get premiumThemeUnlockMessage =>
      'Посмотрите короткую рекламу, чтобы навсегда открыть эту премиум-тему.';

  @override
  String get watchAd => 'Смотреть рекламу';

  @override
  String get uploadYourPhoto => 'Загрузить своё фото';

  @override
  String get orPickAvatar => 'или выберите аватар';

  @override
  String get signingIn => 'Выполняется вход...';

  @override
  String get appTour => 'Обзор приложения';

  @override
  String get languageSupportTitle => '18 языков 🌍';

  @override
  String get languageSupportDesc => 'Пользуйтесь на своём языке';

  @override
  String get colorThemesTitle => 'Цветовые темы 🎨';

  @override
  String get colorThemesDesc => 'Выберите свой стиль + Тёмная тема';

  @override
  String get darkModeAvailable => 'Тёмная тема тоже доступна!';

  @override
  String get multiCurrencyTitle => 'Несколько валют 💰';

  @override
  String get multiCurrencyDesc => 'Мы поддерживаем валюты со всего мира';

  @override
  String get nextButton => 'Далее';

  @override
  String get errInvalidCredentials => 'Неверный email или пароль';

  @override
  String get errEmailNotConfirmed => 'Подтвердите свой адрес email';

  @override
  String get errTooManyRequests => 'Слишком много попыток, подождите немного';

  @override
  String get errEmailInUse => 'Этот адрес email уже используется';

  @override
  String get errWeakPassword => 'Слишком слабый пароль';

  @override
  String get errInvalidEmail => 'Недействительный адрес email';

  @override
  String get errGoogleConfig => 'Ошибка настройки входа через Google (код 10).';

  @override
  String get errPlayServices =>
      'Сервисы Google Play устарели или не поддерживаются на этом устройстве.';

  @override
  String get newestFirst => 'Сначала новые';

  @override
  String get oldestFirst => 'Сначала старые';

  @override
  String get deleteAccountConfirmWord => 'УДАЛИТЬ';

  @override
  String deleteAccountTypeToConfirm(String word) {
    return 'Введите $word для подтверждения';
  }

  @override
  String get premiumTitle => 'Wallet Elite Premium';

  @override
  String get premiumSubtitle => 'Откройте все возможности';

  @override
  String get premiumFeatureNoAds => 'Без рекламы';

  @override
  String get premiumFeatureThemes => 'Все премиум-темы';

  @override
  String get premiumFeatureUnlimited => 'Неограниченные кошельки и бюджеты';

  @override
  String get premiumFeatureExport => 'Экспорт данных (CSV / Excel)';

  @override
  String get planMonthly => 'Ежемесячно';

  @override
  String get planYearly => 'Ежегодно';

  @override
  String get planLifetime => 'Навсегда';

  @override
  String get perMonth => 'в месяц';

  @override
  String get perYear => 'в год';

  @override
  String get oneTimePayment => 'Разовый платёж';

  @override
  String get bestValue => 'Выгоднее всего';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get purchaseSuccess => 'Добро пожаловать в Premium! 🎉';

  @override
  String get restoreSuccess => 'Покупки восстановлены.';

  @override
  String get purchasePending =>
      'Платёж ожидает подтверждения. Premium активируется после подтверждения.';

  @override
  String get restoreNothing =>
      'Для этого аккаунта не найдено предыдущих покупок.';

  @override
  String get purchaseNotAvailable =>
      'Покупки сейчас недоступны. Попробуйте позже.';

  @override
  String get subscriptionTerms =>
      'Подписки продлеваются автоматически до отмены. Отменить можно в любое время в Google Play > Платежи и подписки.';

  @override
  String get premiumActive => 'Premium активен';

  @override
  String get premiumActiveDesc => 'Спасибо, что поддерживаете Wallet Elite!';

  @override
  String get goPremium => 'Перейти на Premium';

  @override
  String get goPremiumDesc =>
      'Без рекламы, все темы, неограниченные кошельки и бюджеты';

  @override
  String walletLimitReached(int count) {
    return 'В бесплатном тарифе можно создать до $count кошельков. Перейдите на Premium для неограниченного количества.';
  }

  @override
  String budgetLimitReached(int count) {
    return 'В бесплатном тарифе можно создать до $count активных бюджетов. Перейдите на Premium для неограниченного количества.';
  }

  @override
  String unlockThemeTitle(String name) {
    return 'Открыть $name';
  }

  @override
  String get rewardedThemeUnlockMessage =>
      'Посмотрите короткую рекламу, чтобы пользоваться этой темой 24 часа, или перейдите на Premium, чтобы навсегда открыть все темы.';

  @override
  String get adNotReady =>
      'Реклама ещё не готова. Попробуйте ещё раз через минуту.';

  @override
  String get themeUnlocked24h => 'Тема открыта на 24 часа';

  @override
  String get adPrivacySettings => 'Настройки конфиденциальности рекламы';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get exportDataDesc =>
      'Поделитесь операциями в виде CSV-файла (открывается в Excel)';

  @override
  String get exportFailed => 'Не удалось выполнить экспорт';

  @override
  String get exportNoData => 'Нет операций для экспорта.';

  @override
  String get cat_clothing => 'Одежда';

  @override
  String get supportSection => 'Поддержка';

  @override
  String get sendFeedback => 'Написать разработчику';

  @override
  String get sendFeedbackDesc =>
      'Отправьте предложение, жалобу или пожелание по почте';

  @override
  String emailAppNotFound(String email) {
    return 'Почтовое приложение не найдено. Пишите на: $email';
  }

  @override
  String get rateApp => 'Оцените нас';

  @override
  String get rateAppDesc => 'Поставьте оценку в Google Play';

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String get updateAvailableMessage =>
      'Доступна новая версия Wallet Elite. Обновите, чтобы получить новые функции и исправления.';

  @override
  String get updateNow => 'Обновить';

  @override
  String get later => 'Позже';

  @override
  String get summaryImage => 'Изображение сводки';

  @override
  String get summaryImageDesc =>
      'Сохраните сводку как изображение или поделитесь ею';

  @override
  String get saveToGallery => 'Сохранить в галерею';

  @override
  String get share => 'Поделиться';

  @override
  String get imageSaved => 'Изображение сохранено в галерею';

  @override
  String get imageSaveFailed => 'Не удалось сохранить изображение';

  @override
  String get premiumFeatureStats => 'Подробная статистика и сравнения';

  @override
  String get premiumStatsMessage => 'Подробная аналитика доступна в Premium.';

  @override
  String savePercent(int percent) {
    return 'Скидка $percent%';
  }

  @override
  String pricePerMonth(String price) {
    return '$price в месяц';
  }

  @override
  String freeTrialDays(int days) {
    return '$days дней бесплатно';
  }

  @override
  String get startFreeTrial => 'Начать бесплатный период';
}
