// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Wallet Elite';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get add => '追加';

  @override
  String get ok => 'OK';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get loading => '読み込み中...';

  @override
  String get search => '検索...';

  @override
  String get all => 'すべて';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get notFound => '見つかりません';

  @override
  String get home => 'ホーム';

  @override
  String get transactions => '取引';

  @override
  String get statistics => '統計';

  @override
  String get settings => '設定';

  @override
  String get welcome => 'ようこそ、';

  @override
  String get totalBalance => '総残高';

  @override
  String get recentTransactions => '最近の取引';

  @override
  String get noTransactions => '取引はありません';

  @override
  String get addFirstTransaction => '+ をタップして追加！';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get amount => '金額';

  @override
  String get category => 'カテゴリ';

  @override
  String get note => 'メモ';

  @override
  String get date => '日付';

  @override
  String get wallet => 'ウォレット';

  @override
  String get addTransaction => '取引を追加';

  @override
  String get editTransaction => '取引を編集';

  @override
  String get deleteTransaction => '取引を削除';

  @override
  String get transactionAdded => '取引を追加しました';

  @override
  String get transactionUpdated => '取引を更新しました';

  @override
  String get transactionDeleted => '取引を削除しました';

  @override
  String get enterAmount => '金額を入力';

  @override
  String get selectWallet => 'ウォレットを選択';

  @override
  String get addNote => 'メモを追加...';

  @override
  String get more => 'もっと見る';

  @override
  String get searchTransactions => '取引を検索...';

  @override
  String get noIncomeFound => '収入が見つかりません';

  @override
  String get noExpenseFound => '支出が見つかりません';

  @override
  String get confirmDelete => '削除してもよろしいですか？';

  @override
  String get categories => 'カテゴリ';

  @override
  String get incomeCategories => '収入カテゴリ';

  @override
  String get expenseCategories => '支出カテゴリ';

  @override
  String get newCategory => '新しいカテゴリ';

  @override
  String get newIncomeCategory => '新しい収入カテゴリ';

  @override
  String get newExpenseCategory => '新しい支出カテゴリ';

  @override
  String get categoryName => 'カテゴリ名';

  @override
  String get selectIcon => 'アイコンを選択:';

  @override
  String get categoryAdded => 'カテゴリを追加しました';

  @override
  String get createCategories => 'カテゴリを作成';

  @override
  String get noCategories => 'カテゴリがありません';

  @override
  String get longPressToFavorite => '長押しでお気に入りに追加/削除';

  @override
  String addedToFavorites(String name) {
    return '$name をお気に入りに追加';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name をお気に入りから削除';
  }

  @override
  String get wallets => 'ウォレット';

  @override
  String get addWallet => 'ウォレットを追加';

  @override
  String get walletName => 'ウォレット名';

  @override
  String get walletType => 'ウォレットタイプ';

  @override
  String get initialBalance => '初期残高';

  @override
  String get cash => '現金';

  @override
  String get bank => '銀行';

  @override
  String get creditCard => 'クレジットカード';

  @override
  String get savings => '貯蓄';

  @override
  String get walletAdded => 'ウォレットを追加しました';

  @override
  String get noWallets => 'ウォレットがありません';

  @override
  String get manageWallets => 'ウォレットを管理';

  @override
  String get categoryNotFound => 'カテゴリが見つかりません';

  @override
  String get walletNotFound => 'ウォレットが見つかりません';

  @override
  String errorWithDetails(String details) {
    return 'エラー: $details';
  }

  @override
  String get networkError => 'ネットワーク接続エラー。インターネットを確認してください。';

  @override
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get language => '言語';

  @override
  String get dark => 'ダーク';

  @override
  String get light => 'ライト';

  @override
  String get system => 'システム';

  @override
  String get selectTheme => 'テーマを選択';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get account => 'アカウント';

  @override
  String get signOut => 'ログアウト';

  @override
  String get signOutConfirm => 'ログアウトしますか？';

  @override
  String get user => 'ユーザー';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get fullName => '氏名';

  @override
  String get forgotPassword => 'パスワードを忘れた場合';

  @override
  String get noAccount => 'アカウントをお持ちでないですか？';

  @override
  String get haveAccount => 'アカウントをお持ちですか？';

  @override
  String get loginSuccess => 'ログイン成功！';

  @override
  String get registerSuccess => '登録成功！';

  @override
  String get thisMonth => '今月';

  @override
  String get lastMonth => '先月';

  @override
  String get thisYear => '今年';

  @override
  String get monthly => '月次';

  @override
  String get weekly => '週次';

  @override
  String get daily => '日次';

  @override
  String get totalIncome => '総収入';

  @override
  String get totalExpense => '総支出';

  @override
  String get balance => '残高';

  @override
  String get categoryBreakdown => 'カテゴリ内訳';

  @override
  String get cat_food => '食事';

  @override
  String get cat_transport => '交通費';

  @override
  String get cat_shopping => '買い物';

  @override
  String get cat_entertainment => '娯楽';

  @override
  String get cat_bills => '請求書';

  @override
  String get cat_health => '医療費';

  @override
  String get cat_education => '教育';

  @override
  String get cat_rent => '家賃';

  @override
  String get cat_taxes => '税金';

  @override
  String get cat_salary => '給料';

  @override
  String get cat_freelance => 'フリーランス';

  @override
  String get cat_investment => '投資';

  @override
  String get cat_gift => '贈り物';

  @override
  String get cat_other => 'その他';

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
  String get loginTab => 'ログイン';

  @override
  String get registerTab => '登録';

  @override
  String get tagline => 'あなたの経済的自由を、手のひらに';

  @override
  String get enterFullName => '氏名を入力';

  @override
  String get nameTooShort => '名前は2文字以上必要です';

  @override
  String get enterEmail => 'メールを入力';

  @override
  String get validEmail => '有効なメールを入力してください';

  @override
  String get enterPassword => 'パスワードを入力';

  @override
  String get passwordTooShort => 'パスワードは6文字以上必要です';

  @override
  String get forgotPasswordTitle => 'パスワードをリセット';

  @override
  String get forgotPasswordText => 'パスワードリセットリンクを送信します。';

  @override
  String get send => '送信';

  @override
  String get passwordResetSent => 'リセットリンクを送信しました。';

  @override
  String get loginFailed => 'ログイン失敗。メールまたはパスワードを確認してください。';

  @override
  String get registerFailed => '登録失敗。メールが既に使用されている可能性があります。';

  @override
  String get googleLoginFailed => 'Googleログインに失敗しました';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get orDivider => 'または';

  @override
  String get privacyText => '続行することで、利用規約とプライバシーポリシーに同意します';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get welcomeTitle => 'Wallet Eliteへ\\nようこそ！👋';

  @override
  String get welcomeSubtitle => '経済的自由への旅を始めるための簡単なステップ。';

  @override
  String get manageWalletsDesc => 'すべてのアカウントを一か所で追跡';

  @override
  String get analyzeSpending => '支出を分析';

  @override
  String get analyzeSpendingDesc => 'お金がどこに行くか確認';

  @override
  String get debtBook => '借金帳';

  @override
  String get debtBookDesc => '債権と債務を追跡';

  @override
  String get backButton => '戻る';

  @override
  String get continueButton => '続行';

  @override
  String get startButton => '開始';

  @override
  String get selectCurrency => '通貨を選択';

  @override
  String get selectCurrencyDesc => 'すべてのアカウントで使用する通貨を選択';

  @override
  String get turkishLira => 'トルコリラ';

  @override
  String get usDollar => '米ドル';

  @override
  String get euro => 'ユーロ';

  @override
  String get britishPound => '英国ポンド';

  @override
  String get createFirstWallet => '最初のウォレットを作成';

  @override
  String get createWalletDesc => 'お金を追跡するためのウォレットを作成';

  @override
  String get walletNameHint => '例：私の現金';

  @override
  String get cashType => '現金';

  @override
  String get bankAccount => '銀行口座';

  @override
  String get creditCardType => 'クレジットカード';

  @override
  String get investmentType => '金/投資';

  @override
  String get initialBalanceOptional => '初期残高（任意）';

  @override
  String get initialBalanceHint => '現在いくら持っているか入力。後で変更できます。';

  @override
  String get enterWalletName => 'ウォレット名を入力してください';

  @override
  String get onboardingSuccess => '登録成功！ログインできます。';

  @override
  String get mon => '月';

  @override
  String get tue => '火';

  @override
  String get wed => '水';

  @override
  String get thu => '木';

  @override
  String get fri => '金';

  @override
  String get sat => '土';

  @override
  String get sun => '日';

  @override
  String get addExpense => '支出を追加';

  @override
  String get addIncome => '収入を追加';

  @override
  String get expenseAdded => '支出を追加しました';

  @override
  String get incomeAdded => '収入を追加しました';
}
