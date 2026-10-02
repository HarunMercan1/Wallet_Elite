// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Portefeuille Elite';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get saved => 'Enregistré';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get loading => 'Chargement...';

  @override
  String get search => 'Recherche...';

  @override
  String get all => 'Tout';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get notFound => 'introuvable';

  @override
  String get home => 'Accueil';

  @override
  String get transactions => 'Transactions';

  @override
  String get statistics => 'Statistiques';

  @override
  String get settings => 'Paramètres';

  @override
  String get welcome => 'Bienvenue,';

  @override
  String get totalBalance => 'Solde Total';

  @override
  String get recentTransactions => 'Transactions Récentes';

  @override
  String get noTransactions => 'Aucune transaction';

  @override
  String get addFirstTransaction => 'Appuyez sur + pour ajouter!';

  @override
  String get income => 'Revenus';

  @override
  String get expense => 'Dépenses';

  @override
  String get amount => 'Montant';

  @override
  String get category => 'Catégorie';

  @override
  String get note => 'Note';

  @override
  String get date => 'Date';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get addTransaction => 'Ajouter Transaction';

  @override
  String get editTransaction => 'Modifier Transaction';

  @override
  String get deleteTransaction => 'Supprimer Transaction';

  @override
  String get transactionAdded => 'Transaction ajoutée';

  @override
  String get transactionUpdated => 'Transaction mise à jour';

  @override
  String get transactionDeleted => 'Transaction supprimée';

  @override
  String get enterAmount => 'Entrer montant';

  @override
  String get selectWallet => 'Choisir portefeuille';

  @override
  String get addNote => 'Ajouter note...';

  @override
  String get more => 'Plus';

  @override
  String get searchTransactions => 'Chercher transactions...';

  @override
  String get noIncomeFound => 'Aucun revenu trouvé';

  @override
  String get noExpenseFound => 'Aucune dépense trouvée';

  @override
  String get confirmDelete => 'Êtes-vous sûr de vouloir supprimer?';

  @override
  String get categories => 'Catégories';

  @override
  String get incomeCategories => 'Catégories de Revenus';

  @override
  String get expenseCategories => 'Catégories de Dépenses';

  @override
  String get newCategory => 'Nouvelle Catégorie';

  @override
  String get newIncomeCategory => 'Nouvelle Catégorie Revenu';

  @override
  String get newExpenseCategory => 'Nouvelle Catégorie Dépense';

  @override
  String get categoryName => 'Nom de Catégorie';

  @override
  String get selectIcon => 'Choisir Icône:';

  @override
  String get categoryAdded => 'Catégorie ajoutée';

  @override
  String get createCategories => 'Créer Catégories';

  @override
  String get noCategories => 'Pas de catégories';

  @override
  String get longPressToFavorite => 'Appui long pour favoris';

  @override
  String addedToFavorites(String name) {
    return '$name ajouté aux favoris';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name retiré des favoris';
  }

  @override
  String get wallets => 'Portefeuilles';

  @override
  String get addWallet => 'Ajouter Portefeuille';

  @override
  String get walletName => 'Nom du Portefeuille';

  @override
  String get walletType => 'Type de Portefeuille';

  @override
  String get initialBalance => 'Solde Initial';

  @override
  String get cash => 'Espèces';

  @override
  String get bank => 'Banque';

  @override
  String get creditCard => 'Carte Crédit';

  @override
  String get savings => 'Épargne';

  @override
  String get walletAdded => 'Portefeuille ajouté';

  @override
  String get walletDeleted => 'Portefeuille supprimé';

  @override
  String get editWallet => 'Modifier Portefeuille';

  @override
  String get walletUpdated => 'Portefeuille mis à jour';

  @override
  String get deleteWallet => 'Supprimer Portefeuille';

  @override
  String get deleteWalletConfirm =>
      'Êtes-vous sûr? Toutes les transactions seront supprimées définitivement.';

  @override
  String get noWallets => 'Pas de portefeuilles';

  @override
  String get manageWallets => 'Gérer Portefeuilles';

  @override
  String get categoryNotFound => 'Catégorie non trouvée';

  @override
  String get walletNotFound => 'Portefeuille non trouvé';

  @override
  String errorWithDetails(String details) {
    return 'Erreur: $details';
  }

  @override
  String get networkError =>
      'Erreur de connexion réseau. Veuillez vérifier votre internet.';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get selectTheme => 'Choisir Thème';

  @override
  String get selectLanguage => 'Choisir Langue';

  @override
  String get colorScheme => 'Schéma de Couleur';

  @override
  String get account => 'Compte';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get signOutConfirm => 'Se déconnecter?';

  @override
  String get user => 'Utilisateur';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get noAccount => 'Pas de compte?';

  @override
  String get haveAccount => 'Déjà un compte?';

  @override
  String get loginSuccess => 'Connexion réussie!';

  @override
  String get registerSuccess => 'Inscription réussie!';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get lastMonth => 'Mois Dernier';

  @override
  String get thisYear => 'Cette Année';

  @override
  String get monthly => 'Mensuel';

  @override
  String get weekly => 'Hebdo';

  @override
  String get daily => 'Quotidien';

  @override
  String get totalIncome => 'Revenus Totaux';

  @override
  String get totalExpense => 'Dépenses Totales';

  @override
  String get balance => 'Solde';

  @override
  String get categoryBreakdown => 'Détail Catégories';

  @override
  String get cat_food => 'Nourriture';

  @override
  String get cat_transport => 'Transport';

  @override
  String get cat_shopping => 'Courses';

  @override
  String get cat_entertainment => 'Divertissement';

  @override
  String get cat_bills => 'Factures';

  @override
  String get cat_health => 'Santé';

  @override
  String get cat_education => 'Éducation';

  @override
  String get cat_rent => 'Loyer';

  @override
  String get cat_taxes => 'Impôts';

  @override
  String get cat_salary => 'Salaire';

  @override
  String get cat_freelance => 'Freelance';

  @override
  String get cat_investment => 'Investissement';

  @override
  String get cat_gift => 'Cadeau';

  @override
  String get cat_other => 'Autre';

  @override
  String get cat_pets => 'Animaux';

  @override
  String get cat_groceries => 'Épicerie';

  @override
  String get cat_electronics => 'Électronique';

  @override
  String get cat_charity => 'Don';

  @override
  String get cat_insurance => 'Assurance';

  @override
  String get cat_gym => 'Sport';

  @override
  String get cat_travel => 'Voyage';

  @override
  String get statisticsTitle => 'Aperçu des Statistiques';

  @override
  String get periodFilter => 'Période';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get last7Days => '7 derniers jours';

  @override
  String get last30Days => '30 derniers jours';

  @override
  String get averageDailySpending => 'Dépense quotidienne moy.';

  @override
  String get totalTransactions => 'Total des transactions';

  @override
  String get incomeCount => 'Nombre de revenus';

  @override
  String get expenseCount => 'Nombre de dépenses';

  @override
  String get topCategories => 'Top catégories';

  @override
  String get savingsRate => 'Taux d\'épargne';

  @override
  String get biggestIncome => 'Plus grand revenu';

  @override
  String get biggestExpense => 'Plus grande dépense';

  @override
  String get noData => 'Pas de données pour cette période';

  @override
  String get spendingTrend => 'Tendance des dépenses';

  @override
  String get incomeVsExpense => 'Revenus vs Dépenses';

  @override
  String get loginTab => 'Connexion';

  @override
  String get registerTab => 'Inscription';

  @override
  String get tagline => 'Votre liberté financière, entre vos mains';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get nameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get validEmail => 'Entrez un email valide';

  @override
  String get enterPassword => 'Entrez le mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordText =>
      'Nous vous enverrons un lien de réinitialisation.';

  @override
  String get send => 'Envoyer';

  @override
  String get passwordResetSent => 'Lien de réinitialisation envoyé.';

  @override
  String get loginFailed =>
      'Échec de connexion. Vérifiez email ou mot de passe.';

  @override
  String get registerFailed =>
      'Échec d\'inscription. L\'email est peut-être utilisé.';

  @override
  String get googleLoginFailed => 'Échec de connexion Google';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get orDivider => 'ou';

  @override
  String get privacyText =>
      'En continuant, vous acceptez les Conditions d\'utilisation et la Politique de confidentialité';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get welcomeTitle => 'Bienvenue sur\\nWallet Elite! 👋';

  @override
  String get welcomeSubtitle =>
      'Quelques étapes simples pour votre liberté financière.';

  @override
  String get manageWalletsDesc => 'Suivez tous vos comptes en un seul endroit';

  @override
  String get analyzeSpending => 'Analysez vos Dépenses';

  @override
  String get analyzeSpendingDesc => 'Voyez où va votre argent';

  @override
  String get debtBook => 'Carnet de Dettes';

  @override
  String get debtBookDesc => 'Suivez ce que vous devez et ce qu\'on vous doit';

  @override
  String get backButton => 'Retour';

  @override
  String get continueButton => 'Continuer';

  @override
  String get startButton => 'Commencer';

  @override
  String get selectCurrency => 'Choisir la Devise';

  @override
  String get selectCurrencyDesc => 'Choisissez la devise que vous utiliserez';

  @override
  String get turkishLira => 'Livre Turque';

  @override
  String get usDollar => 'Dollar Américain';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'Livre Sterling';

  @override
  String get createFirstWallet => 'Créez votre Premier Portefeuille';

  @override
  String get createWalletDesc =>
      'Créez un portefeuille pour commencer à suivre votre argent';

  @override
  String get walletNameHint => 'ex: Mon Argent';

  @override
  String get cashType => 'Espèces';

  @override
  String get bankAccount => 'Compte Bancaire';

  @override
  String get creditCardType => 'Carte de Crédit';

  @override
  String get investmentType => 'Or/Investissement';

  @override
  String get initialBalanceOptional => 'Solde Initial (Optionnel)';

  @override
  String get initialBalanceHint =>
      'Entrez combien d\'argent vous avez actuellement.';

  @override
  String get enterWalletName => 'Veuillez entrer le nom du portefeuille';

  @override
  String get onboardingSuccess =>
      'Inscription réussie! Vous pouvez vous connecter.';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Jeu';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sam';

  @override
  String get sun => 'Dim';

  @override
  String get addExpense => 'Ajouter Dépense';

  @override
  String get addIncome => 'Ajouter Revenu';

  @override
  String get expenseAdded => 'Dépense ajoutée';

  @override
  String get incomeAdded => 'Revenu ajouté';

  @override
  String get debtTracking => 'Suivi des Dettes';

  @override
  String get myLends => 'Argent Prêté';

  @override
  String get myDebts => 'Argent Emprunté';

  @override
  String get personName => 'Nom de la Personne';

  @override
  String get dueDate => 'Date d\'Échéance';

  @override
  String get recordPayment => 'Enregistrer Paiement';

  @override
  String daysRemaining(int days) {
    return '$days jours restants';
  }

  @override
  String get overdue => 'En retard';

  @override
  String get remaining => 'Restant';

  @override
  String get lend => 'J\'ai prêté';

  @override
  String get borrow => 'J\'ai emprunté';

  @override
  String get upcomingDues => 'Échéances à Venir';

  @override
  String get allRecords => 'Tous les Enregistrements';

  @override
  String get hideCompleted => 'Masquer Terminés';

  @override
  String get showCompleted => 'Afficher Terminés';

  @override
  String get markAsCompleted => 'Marquer comme Terminé';

  @override
  String get debtAdded => 'Enregistrement ajouté';

  @override
  String get debtUpdated => 'Enregistrement mis à jour';

  @override
  String get debtDeleted => 'Enregistrement supprimé';

  @override
  String get paymentRecorded => 'Paiement enregistré';

  @override
  String get noDebts => 'Pas encore d\'enregistrements de dettes';

  @override
  String get addDebt => 'Ajouter Enregistrement';

  @override
  String get debtAmount => 'Montant';

  @override
  String get debtDescription => 'Description (optionnel)';

  @override
  String get selectDueDate => 'Sélectionner date d\'échéance';

  @override
  String get totalLent => 'Total Prêté';

  @override
  String get totalBorrowed => 'Total Emprunté';

  @override
  String people(int count) {
    return '$count personnes';
  }

  @override
  String memberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get editProfile => 'Modifier Profil';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get changePhoto => 'Changer Photo';

  @override
  String get takePhoto => 'Prendre Photo';

  @override
  String get chooseFromGallery => 'Choisir de la Galerie';

  @override
  String get removePhoto => 'Supprimer Photo';

  @override
  String get notifications => 'Notifications';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get thisMonthSummary => 'Résumé de Ce Mois';

  @override
  String get financialScore => 'Score Financier';

  @override
  String get financialScoreDesc => 'Votre score de santé financière';

  @override
  String get spendingTips => 'Conseils Dépenses';

  @override
  String get spendingTipsDesc => 'Suggestions d\'économies';

  @override
  String get categoryAnalysis => 'Analyse par Catégorie';

  @override
  String get categoryAnalysisDesc => 'Détail des dépenses';

  @override
  String get monthlyComparison => 'Comparaison Mensuelle';

  @override
  String get monthlyComparisonDesc => 'Comparer avec les mois précédents';

  @override
  String get budgetProgress => 'Progrès Budget';

  @override
  String get budgetProgressDesc => 'Proximité de vos objectifs';

  @override
  String get viewDetails => 'Voir Détails';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Bon';

  @override
  String get average => 'Moyen';

  @override
  String get needsImprovement => 'À améliorer';

  @override
  String get poor => 'Faible';

  @override
  String get comparedToLastMonth => 'Par rapport au mois dernier';

  @override
  String get youSpentLess => 'vous avez dépensé moins';

  @override
  String get youSpentMore => 'vous avez dépensé plus';

  @override
  String get noChange => 'Aucun changement';

  @override
  String get allWallets => 'Tous les Portefeuilles';

  @override
  String get budgets => 'Budgets';

  @override
  String get history => 'Historique';

  @override
  String get sort => 'Trier';

  @override
  String get payment => 'Paiement';

  @override
  String get completedDebts => 'Dettes terminées';

  @override
  String get noCompletedDebts => 'Aucune dette terminée';

  @override
  String get lent => 'Prêté';

  @override
  String get borrowed => 'Emprunté';

  @override
  String get deleteDebt => 'Supprimer';

  @override
  String get deleteDebtConfirm =>
      'Voulez-vous supprimer cet enregistrement? Cette action est irréversible.';

  @override
  String get paymentHistory => 'Historique des paiements';

  @override
  String get noPaymentsYet => 'Aucun paiement pour le moment';

  @override
  String get displayName => 'Nom affiché';

  @override
  String get customDateRange => 'Plage personnalisée';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get selectDateRange => 'Sélectionner la plage';

  @override
  String get transactionSummary => 'Résumé transactions';

  @override
  String get topSpendingCategory => 'Plus grande dépense';

  @override
  String get leastSpendingCategory => 'Plus petite dépense';

  @override
  String get averageTransaction => 'Transaction moyenne';

  @override
  String get weekdaySpending => 'Dépenses en semaine';

  @override
  String get weekendSpending => 'Dépenses week-end';

  @override
  String get vsLastMonth => 'vs Mois dernier';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get lastWeek => 'Semaine dernière';

  @override
  String get last3Months => '3 derniers mois';

  @override
  String get last6Months => '6 derniers mois';

  @override
  String get viewAllCategories => 'Voir toutes les catégories';

  @override
  String get viewTrendDetails => 'Voir détails tendance';

  @override
  String get budgetTips => 'Conseils budget';

  @override
  String get savingsGoal => 'Objectif d\'épargne';

  @override
  String get potentialSavings => 'Économies potentielles';

  @override
  String ifYouReduce(String category, int percent, String amount) {
    return 'Si vous réduisez $category de $percent%, vous pourriez économiser $amount par mois';
  }

  @override
  String get allCategories => 'Toutes les Catégories';

  @override
  String get categoryDetails => 'Détails de la Catégorie';

  @override
  String get trendDetails => 'Détails tendance';

  @override
  String get periodComparison => 'Comparaison des Périodes';

  @override
  String get noExpenseData => 'Pas de données dépenses';

  @override
  String get spendingPatterns => 'Habitudes de dépenses';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get recurringTransactions => 'Transactions récurrentes';

  @override
  String get addRecurringTransaction => 'Ajouter une transaction récurrente';

  @override
  String get editRecurringTransaction => 'Modifier la transaction récurrente';

  @override
  String get deleteRecurringTransaction =>
      'Supprimer la transaction récurrente';

  @override
  String get deleteRecurringConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette transaction récurrente ?';

  @override
  String get noRecurringTransactions => 'Aucune transaction récurrente encore';

  @override
  String get addRecurringTransactionHint =>
      'Gagnez du temps en ajoutant des transactions régulières comme le salaire et les factures';

  @override
  String get frequency => 'Fréquence';

  @override
  String get yearly => 'Annuel';

  @override
  String get dayOfMonth => 'Jour du mois';

  @override
  String get dayOfWeek => 'Jour de la semaine';

  @override
  String get nextExecution => 'Prochaine exécution';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get optional => 'Optionnel';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'ex: Abonnement Netflix';

  @override
  String get selectAccount => 'Sélectionner un compte';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get pleaseEnterAmount => 'Veuillez entrer le montant';

  @override
  String get pleaseEnterValidAmount => 'Veuillez entrer un montant valide';

  @override
  String get pleaseSelectAccount => 'Veuillez sélectionner un compte';

  @override
  String get budget => 'Budget';

  @override
  String get addBudget => 'Ajouter un budget';

  @override
  String get editBudget => 'Modifier le budget';

  @override
  String get deleteBudget => 'Supprimer le budget';

  @override
  String get deleteBudgetConfirmation =>
      'Êtes-vous sûr de vouloir supprimer ce budget ?';

  @override
  String get noBudgets => 'Aucun budget encore';

  @override
  String get addBudgetHint => 'Créez un budget pour contrôler vos dépenses';

  @override
  String get budgetName => 'Nom du budget';

  @override
  String get budgetNameHint => 'ex: Budget alimentaire mensuel';

  @override
  String get pleaseEnterBudgetName => 'Veuillez entrer le nom du budget';

  @override
  String get budgetAmount => 'Limite du budget';

  @override
  String get budgetPeriod => 'Période du budget';

  @override
  String get budgetStartDay => 'Jour de début de période';

  @override
  String get allExpenses => 'Toutes les dépenses';

  @override
  String get notifyAtPercent => 'Pourcentage d\'alerte';

  @override
  String get notifyWhenExceeded => 'Notifier en cas de dépassement';

  @override
  String get used => 'utilisé';

  @override
  String get exceeded => 'dépassé';

  @override
  String get secureData => 'Vos données sont sécurisées et chiffrées';

  @override
  String get cloudSync => 'Synchronisez sur tous vos appareils';

  @override
  String get smartInsights => 'Informations intelligentes sur vos finances';

  @override
  String get discoverFeatures => 'Découvrir les fonctionnalités';

  @override
  String get discoverFeaturesDesc =>
      'Tout ce dont vous avez besoin pour gérer vos finances';

  @override
  String get budgetTracking => 'Suivi du budget';

  @override
  String get budgetTrackingDesc =>
      'Définissez des limites de dépenses et respectez-les';

  @override
  String get recurringTransactionsDesc => 'Automatisez vos paiements réguliers';

  @override
  String get selectLanguageDesc => 'Choisissez votre langue préférée';

  @override
  String get selectThemeDesc => 'Personnalisez votre expérience';

  @override
  String get themeOcean => 'Océan';

  @override
  String get themeSunset => 'Coucher de soleil';

  @override
  String get themeForest => 'Forêt';

  @override
  String get themeLavender => 'Lavande';

  @override
  String get themeMidnight => 'Minuit';

  @override
  String get themeRose => 'Rose';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get japaneseYen => 'Yen japonais';

  @override
  String get russianRuble => 'Rouble russe';

  @override
  String get categoryDistribution => 'Répartition par catégorie';

  @override
  String get other => 'Autre';

  @override
  String get last7DaysSpending => 'Dépenses des 7 derniers jours';

  @override
  String get currencyLabel => 'Devise';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmTitle => 'Supprimer votre compte ?';

  @override
  String get deleteAccountConfirmMessage =>
      'Votre compte et toutes vos données (portefeuilles, transactions, catégories, budgets et dettes) seront définitivement supprimés. Cette action est irréversible.';

  @override
  String get deleteAccountConfirmButton => 'Supprimer définitivement';

  @override
  String get deleteAccountSuccess => 'Votre compte a été supprimé.';

  @override
  String get filter => 'Filtrer';

  @override
  String get transactionTypeLabel => 'Type de transaction';

  @override
  String get highestAmount => 'Montant le plus élevé';

  @override
  String get lowestAmount => 'Montant le plus bas';

  @override
  String get appSettingsSection => 'Application';

  @override
  String get replayAppTour => 'Revoir la visite guidée';

  @override
  String get replayAppTourDesc =>
      'Découvrez les fonctionnalités de l\'application';

  @override
  String get watchAdToUnlock => 'Regarder une pub pour débloquer';

  @override
  String get premiumThemeUnlockMessage =>
      'Regardez une courte publicité pour débloquer définitivement ce thème premium.';

  @override
  String get watchAd => 'Regarder la pub';

  @override
  String get uploadYourPhoto => 'Téléverser votre photo';

  @override
  String get orPickAvatar => 'ou choisissez un avatar';

  @override
  String get signingIn => 'Connexion en cours...';

  @override
  String get appTour => 'Visite guidée';

  @override
  String get languageSupportTitle => '18 langues 🌍';

  @override
  String get languageSupportDesc => 'Utilisez-la dans votre langue';

  @override
  String get colorThemesTitle => 'Thèmes de couleur 🎨';

  @override
  String get colorThemesDesc => 'Choisissez votre style + Mode sombre';

  @override
  String get darkModeAvailable => 'Le mode sombre est aussi disponible !';

  @override
  String get multiCurrencyTitle => 'Plusieurs devises 💰';

  @override
  String get multiCurrencyDesc =>
      'Nous prenons en charge les devises du monde entier';

  @override
  String get nextButton => 'Suivant';

  @override
  String get errInvalidCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get errEmailNotConfirmed => 'Veuillez vérifier votre adresse e-mail';

  @override
  String get errTooManyRequests =>
      'Trop de tentatives, veuillez patienter un instant';

  @override
  String get errEmailInUse => 'Cette adresse e-mail est déjà utilisée';

  @override
  String get errWeakPassword => 'Le mot de passe est trop faible';

  @override
  String get errInvalidEmail => 'Adresse e-mail invalide';

  @override
  String get errGoogleConfig =>
      'Erreur de configuration de la connexion Google (code 10).';

  @override
  String get errPlayServices =>
      'Les services Google Play sont obsolètes ou non pris en charge sur cet appareil.';

  @override
  String get newestFirst => 'Plus récentes';

  @override
  String get oldestFirst => 'Plus anciennes';

  @override
  String get deleteAccountConfirmWord => 'SUPPRIMER';

  @override
  String deleteAccountTypeToConfirm(String word) {
    return 'Saisissez $word pour confirmer';
  }

  @override
  String get premiumTitle => 'Wallet Elite Premium';

  @override
  String get premiumSubtitle => 'Débloquez l\'expérience complète';

  @override
  String get premiumFeatureNoAds => 'Sans publicité';

  @override
  String get premiumFeatureThemes => 'Tous les thèmes premium';

  @override
  String get premiumFeatureUnlimited => 'Portefeuilles et budgets illimités';

  @override
  String get premiumFeatureExport => 'Exporter vos données (CSV / Excel)';

  @override
  String get planMonthly => 'Mensuel';

  @override
  String get planYearly => 'Annuel';

  @override
  String get planLifetime => 'À vie';

  @override
  String get perMonth => 'par mois';

  @override
  String get perYear => 'par an';

  @override
  String get oneTimePayment => 'Paiement unique';

  @override
  String get bestValue => 'Meilleure offre';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchaseSuccess => 'Bienvenue dans Premium ! 🎉';

  @override
  String get restoreSuccess => 'Achats restaurés.';

  @override
  String get purchasePending =>
      'Paiement en attente. Premium sera activé une fois confirmé.';

  @override
  String get restoreNothing => 'Aucun achat précédent trouvé pour ce compte.';

  @override
  String get purchaseNotAvailable =>
      'Les achats ne sont pas disponibles pour le moment. Réessayez plus tard.';

  @override
  String get subscriptionTerms =>
      'Les abonnements se renouvellent automatiquement jusqu\'à leur résiliation. Vous pouvez résilier à tout moment dans Google Play > Paiements et abonnements.';

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get premiumActiveDesc => 'Merci de soutenir Wallet Elite !';

  @override
  String get goPremium => 'Passer à Premium';

  @override
  String get goPremiumDesc =>
      'Sans pub, tous les thèmes, portefeuilles et budgets illimités';

  @override
  String walletLimitReached(int count) {
    return 'Le forfait gratuit permet jusqu\'à $count portefeuilles. Passez à Premium pour un nombre illimité.';
  }

  @override
  String budgetLimitReached(int count) {
    return 'Le forfait gratuit permet jusqu\'à $count budgets actifs. Passez à Premium pour un nombre illimité.';
  }

  @override
  String unlockThemeTitle(String name) {
    return 'Débloquer $name';
  }

  @override
  String get rewardedThemeUnlockMessage =>
      'Regardez une courte publicité pour utiliser ce thème pendant 24 heures, ou passez à Premium pour débloquer tous les thèmes définitivement.';

  @override
  String get adNotReady =>
      'La publicité n\'est pas encore prête. Réessayez dans un instant.';

  @override
  String get themeUnlocked24h => 'Thème débloqué pour 24 heures';

  @override
  String get adPrivacySettings => 'Paramètres de confidentialité des annonces';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportDataDesc =>
      'Partagez vos transactions dans un fichier CSV (s\'ouvre dans Excel)';

  @override
  String get exportFailed => 'Échec de l\'exportation';

  @override
  String get exportNoData => 'Aucune transaction à exporter.';

  @override
  String get cat_clothing => 'Vêtements';

  @override
  String get supportSection => 'Assistance';

  @override
  String get sendFeedback => 'Écrire au développeur';

  @override
  String get sendFeedbackDesc =>
      'Envoyez une suggestion, une réclamation ou une demande par e-mail';

  @override
  String emailAppNotFound(String email) {
    return 'Aucune application e-mail trouvée. Écrivez à : $email';
  }

  @override
  String get rateApp => 'Notez-nous';

  @override
  String get rateAppDesc => 'Donnez une note sur Google Play';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String get updateAvailableMessage =>
      'Une nouvelle version de Wallet Elite est disponible. Mettez à jour pour profiter des dernières fonctionnalités et corrections.';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get later => 'Plus tard';

  @override
  String get summaryImage => 'Image du résumé';

  @override
  String get summaryImageDesc =>
      'Enregistrez ou partagez votre résumé en image';

  @override
  String get saveToGallery => 'Enregistrer dans la galerie';

  @override
  String get share => 'Partager';

  @override
  String get imageSaved => 'Image enregistrée dans la galerie';

  @override
  String get imageSaveFailed => 'Impossible d\'enregistrer l\'image';
}
