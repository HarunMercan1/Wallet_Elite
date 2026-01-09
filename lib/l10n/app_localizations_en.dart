// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Wallet Elite';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get search => 'Search...';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get notFound => 'not found';

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Transactions';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get welcome => 'Welcome,';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get addFirstTransaction => 'Tap + to add your first!';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get note => 'Note';

  @override
  String get date => 'Date';

  @override
  String get wallet => 'Wallet';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get selectWallet => 'Select wallet';

  @override
  String get addNote => 'Add note...';

  @override
  String get more => 'More';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get noIncomeFound => 'No income found';

  @override
  String get noExpenseFound => 'No expense found';

  @override
  String get confirmDelete =>
      'Are you sure you want to delete this transaction? This cannot be undone.';

  @override
  String get categories => 'Categories';

  @override
  String get incomeCategories => 'Income Categories';

  @override
  String get expenseCategories => 'Expense Categories';

  @override
  String get newCategory => 'New Category';

  @override
  String get newIncomeCategory => 'New Income Category';

  @override
  String get newExpenseCategory => 'New Expense Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get selectIcon => 'Select Icon:';

  @override
  String get categoryAdded => 'Category added';

  @override
  String get createCategories => 'Create Categories';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get longPressToFavorite => 'Long press to add/remove favorites';

  @override
  String addedToFavorites(String name) {
    return '$name added to favorites';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get wallets => 'Wallets';

  @override
  String get addWallet => 'Add Wallet';

  @override
  String get walletName => 'Wallet Name';

  @override
  String get walletType => 'Wallet Type';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get cash => 'Cash';

  @override
  String get bank => 'Bank';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get savings => 'Savings';

  @override
  String get walletAdded => 'Wallet added';

  @override
  String get noWallets => 'No wallets yet';

  @override
  String get manageWallets => 'Manage Wallets';

  @override
  String get categoryNotFound => 'No category found';

  @override
  String get walletNotFound => 'No wallet found';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get networkError =>
      'Network connection error. Please check your internet.';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get colorScheme => 'Color Scheme';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get user => 'User';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get registerSuccess =>
      'Registration successful! Please verify your email.';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get daily => 'Daily';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get balance => 'Balance';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get cat_food => 'Food';

  @override
  String get cat_transport => 'Transport';

  @override
  String get cat_shopping => 'Start Shopping';

  @override
  String get cat_entertainment => 'Entertainment';

  @override
  String get cat_bills => 'Bills';

  @override
  String get cat_health => 'Health';

  @override
  String get cat_education => 'Education';

  @override
  String get cat_rent => 'Rent';

  @override
  String get cat_taxes => 'Taxes';

  @override
  String get cat_salary => 'Salary';

  @override
  String get cat_freelance => 'Freelance';

  @override
  String get cat_investment => 'Investment';

  @override
  String get cat_gift => 'Gift';

  @override
  String get cat_other => 'Other';

  @override
  String get cat_pets => 'Pets';

  @override
  String get cat_groceries => 'Groceries';

  @override
  String get cat_electronics => 'Electronics';

  @override
  String get cat_charity => 'Charity';

  @override
  String get cat_insurance => 'Insurance';

  @override
  String get cat_gym => 'Gym';

  @override
  String get cat_travel => 'Travel';

  @override
  String get statisticsTitle => 'Statistics Overview';

  @override
  String get periodFilter => 'Period';

  @override
  String get allTime => 'All Time';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get averageDailySpending => 'Avg. Daily Spending';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get incomeCount => 'Income Count';

  @override
  String get expenseCount => 'Expense Count';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get savingsRate => 'Savings Rate';

  @override
  String get biggestIncome => 'Biggest Income';

  @override
  String get biggestExpense => 'Biggest Expense';

  @override
  String get noData => 'No data for this period';

  @override
  String get spendingTrend => 'Spending Trend';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get loginTab => 'Sign In';

  @override
  String get registerTab => 'Sign Up';

  @override
  String get tagline => 'Your financial freedom, in your hands';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get validEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordText =>
      'We will send a password reset link to your email.';

  @override
  String get send => 'Send';

  @override
  String get passwordResetSent => 'Password reset link sent.';

  @override
  String get loginFailed => 'Login failed. Check your email or password.';

  @override
  String get registerFailed =>
      'Registration failed. Email may already be in use.';

  @override
  String get googleLoginFailed => 'Google sign-in failed';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get privacyText =>
      'By continuing, you agree to our Terms of Service and Privacy Policy';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get welcomeTitle => 'Welcome to\\nWallet Elite! 👋';

  @override
  String get welcomeSubtitle =>
      'Just a few simple steps to start your journey to financial freedom.';

  @override
  String get manageWalletsDesc => 'Track all accounts in one place';

  @override
  String get analyzeSpending => 'Analyze Spending';

  @override
  String get analyzeSpendingDesc => 'See where your money goes';

  @override
  String get debtBook => 'Debt Book';

  @override
  String get debtBookDesc => 'Track receivables and payables';

  @override
  String get backButton => 'Back';

  @override
  String get continueButton => 'Continue';

  @override
  String get startButton => 'Start';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get selectCurrencyDesc =>
      'Select the currency you\'ll use in all accounts';

  @override
  String get turkishLira => 'Turkish Lira';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'British Pound';

  @override
  String get createFirstWallet => 'Create Your First Wallet';

  @override
  String get createWalletDesc => 'Create a wallet to start tracking your money';

  @override
  String get walletNameHint => 'e.g. My Cash';

  @override
  String get cashType => 'Cash';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get creditCardType => 'Credit Card';

  @override
  String get investmentType => 'Gold/Investment';

  @override
  String get initialBalanceOptional => 'Initial Balance (Optional)';

  @override
  String get initialBalanceHint =>
      'Enter how much money you currently have. You can change it later.';

  @override
  String get enterWalletName => 'Please enter wallet name';

  @override
  String get onboardingSuccess =>
      'Registration successful! You can now sign in.';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get expenseAdded => 'Expense added';

  @override
  String get incomeAdded => 'Income added';
}
