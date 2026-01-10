// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Wallet Elite';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get add => 'Aggiungi';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Errore';

  @override
  String get success => 'Successo';

  @override
  String get loading => 'Caricamento...';

  @override
  String get search => 'Cerca...';

  @override
  String get all => 'Tutti';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get notFound => 'non trovato';

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Transazioni';

  @override
  String get statistics => 'Statistiche';

  @override
  String get settings => 'Impostazioni';

  @override
  String get welcome => 'Benvenuto,';

  @override
  String get totalBalance => 'Saldo Totale';

  @override
  String get recentTransactions => 'Transazioni Recenti';

  @override
  String get noTransactions => 'Nessuna transazione';

  @override
  String get addFirstTransaction => 'Tocca + per aggiungerne una!';

  @override
  String get income => 'Entrata';

  @override
  String get expense => 'Spesa';

  @override
  String get amount => 'Importo';

  @override
  String get category => 'Categoria';

  @override
  String get note => 'Nota';

  @override
  String get date => 'Data';

  @override
  String get wallet => 'Portafoglio';

  @override
  String get addTransaction => 'Aggiungi Transazione';

  @override
  String get editTransaction => 'Modifica Transazione';

  @override
  String get deleteTransaction => 'Elimina Transazione';

  @override
  String get transactionAdded => 'Transazione aggiunta';

  @override
  String get transactionUpdated => 'Transazione aggiornata';

  @override
  String get transactionDeleted => 'Transazione eliminata';

  @override
  String get enterAmount => 'Inserisci importo';

  @override
  String get selectWallet => 'Seleziona portafoglio';

  @override
  String get addNote => 'Aggiungi nota...';

  @override
  String get more => 'Altro';

  @override
  String get searchTransactions => 'Cerca transazioni...';

  @override
  String get noIncomeFound => 'Nessuna entrata trovata';

  @override
  String get noExpenseFound => 'Nessuna spesa trovata';

  @override
  String get confirmDelete =>
      'Sei sicuro di voler eliminare questa transazione? Non può essere annullato.';

  @override
  String get categories => 'Categorie';

  @override
  String get incomeCategories => 'Categorie Entrate';

  @override
  String get expenseCategories => 'Categorie Spese';

  @override
  String get newCategory => 'Nuova Categoria';

  @override
  String get newIncomeCategory => 'Nuova Categoria Entrata';

  @override
  String get newExpenseCategory => 'Nuova Categoria Spesa';

  @override
  String get categoryName => 'Nome Categoria';

  @override
  String get selectIcon => 'Seleziona Icona:';

  @override
  String get categoryAdded => 'Categoria aggiunta';

  @override
  String get createCategories => 'Crea Categorie';

  @override
  String get noCategories => 'Nessuna categoria';

  @override
  String get longPressToFavorite =>
      'Premi a lungo per aggiungere/rimuovere preferiti';

  @override
  String addedToFavorites(String name) {
    return '$name aggiunto ai preferiti';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name rimosso dai preferiti';
  }

  @override
  String get wallets => 'Portafogli';

  @override
  String get addWallet => 'Aggiungi Portafoglio';

  @override
  String get walletName => 'Nome Portafoglio';

  @override
  String get walletType => 'Tipo Portafoglio';

  @override
  String get initialBalance => 'Saldo Iniziale';

  @override
  String get cash => 'Contanti';

  @override
  String get bank => 'Banca';

  @override
  String get creditCard => 'Carta di Credito';

  @override
  String get savings => 'Risparmi';

  @override
  String get walletAdded => 'Portafoglio aggiunto';

  @override
  String get noWallets => 'Nessun portafoglio';

  @override
  String get manageWallets => 'Gestisci Portafogli';

  @override
  String get categoryNotFound => 'Nessuna categoria trovata';

  @override
  String get walletNotFound => 'Nessun portafoglio trovato';

  @override
  String errorWithDetails(String details) {
    return 'Errore: $details';
  }

  @override
  String get networkError =>
      'Errore di connessione. Controlla la tua connessione internet.';

  @override
  String get appearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Lingua';

  @override
  String get dark => 'Scuro';

  @override
  String get light => 'Chiaro';

  @override
  String get system => 'Sistema';

  @override
  String get selectTheme => 'Seleziona Tema';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get colorScheme => 'Schema di Colori';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Esci';

  @override
  String get signOutConfirm => 'Sei sicuro di voler uscire?';

  @override
  String get user => 'Utente';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Registrati';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get forgotPassword => 'Password Dimenticata';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get haveAccount => 'Hai già un account?';

  @override
  String get loginSuccess => 'Accesso riuscito!';

  @override
  String get registerSuccess =>
      'Registrazione riuscita! Verifica la tua email.';

  @override
  String get thisMonth => 'Questo Mese';

  @override
  String get lastMonth => 'Mese Scorso';

  @override
  String get thisYear => 'Quest\'Anno';

  @override
  String get monthly => 'Mensile';

  @override
  String get weekly => 'Settimanale';

  @override
  String get daily => 'Giornaliero';

  @override
  String get totalIncome => 'Entrate Totali';

  @override
  String get totalExpense => 'Spese Totali';

  @override
  String get balance => 'Saldo';

  @override
  String get categoryBreakdown => 'Ripartizione per Categoria';

  @override
  String get cat_food => 'Cibo';

  @override
  String get cat_transport => 'Trasporti';

  @override
  String get cat_shopping => 'Shopping';

  @override
  String get cat_entertainment => 'Intrattenimento';

  @override
  String get cat_bills => 'Bollette';

  @override
  String get cat_health => 'Salute';

  @override
  String get cat_education => 'Istruzione';

  @override
  String get cat_rent => 'Affitto';

  @override
  String get cat_taxes => 'Tasse';

  @override
  String get cat_salary => 'Stipendio';

  @override
  String get cat_freelance => 'Freelance';

  @override
  String get cat_investment => 'Investimento';

  @override
  String get cat_gift => 'Regalo';

  @override
  String get cat_other => 'Altro';

  @override
  String get cat_pets => 'Animali';

  @override
  String get cat_groceries => 'Spesa';

  @override
  String get cat_electronics => 'Elettronica';

  @override
  String get cat_charity => 'Beneficenza';

  @override
  String get cat_insurance => 'Assicurazione';

  @override
  String get cat_gym => 'Palestra';

  @override
  String get cat_travel => 'Viaggio';

  @override
  String get statisticsTitle => 'Panoramica Statistiche';

  @override
  String get periodFilter => 'Periodo';

  @override
  String get allTime => 'Tutto il Tempo';

  @override
  String get last7Days => 'Ultimi 7 Giorni';

  @override
  String get last30Days => 'Ultimi 30 Giorni';

  @override
  String get averageDailySpending => 'Spesa Media Giornaliera';

  @override
  String get totalTransactions => 'Transazioni Totali';

  @override
  String get incomeCount => 'Numero Entrate';

  @override
  String get expenseCount => 'Numero Spese';

  @override
  String get topCategories => 'Categorie Principali';

  @override
  String get savingsRate => 'Tasso di Risparmio';

  @override
  String get biggestIncome => 'Entrata Maggiore';

  @override
  String get biggestExpense => 'Spesa Maggiore';

  @override
  String get noData => 'Nessun dato per questo periodo';

  @override
  String get spendingTrend => 'Tendenza Spese';

  @override
  String get incomeVsExpense => 'Entrate vs Spese';

  @override
  String get loginTab => 'Accedi';

  @override
  String get registerTab => 'Registrati';

  @override
  String get tagline => 'La tua libertà finanziaria, nelle tue mani';

  @override
  String get enterFullName => 'Inserisci nome completo';

  @override
  String get nameTooShort => 'Il nome deve avere almeno 2 caratteri';

  @override
  String get enterEmail => 'Inserisci email';

  @override
  String get validEmail => 'Inserisci un\'email valida';

  @override
  String get enterPassword => 'Inserisci password';

  @override
  String get passwordTooShort => 'La password deve avere almeno 6 caratteri';

  @override
  String get forgotPasswordTitle => 'Reimposta Password';

  @override
  String get forgotPasswordText =>
      'Invieremo un link per reimpostare la password alla tua email.';

  @override
  String get send => 'Invia';

  @override
  String get passwordResetSent => 'Link per reimpostare la password inviato.';

  @override
  String get loginFailed => 'Accesso fallito. Controlla email o password.';

  @override
  String get registerFailed =>
      'Registrazione fallita. L\'email potrebbe essere già in uso.';

  @override
  String get googleLoginFailed => 'Accesso Google fallito';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get orDivider => 'oppure';

  @override
  String get privacyText =>
      'Continuando, accetti i nostri Termini di Servizio e Informativa sulla Privacy';

  @override
  String get errorOccurred => 'Si è verificato un errore';

  @override
  String get welcomeTitle => 'Benvenuto in\\nWallet Elite! 👋';

  @override
  String get welcomeSubtitle =>
      'Solo pochi semplici passaggi per iniziare il tuo percorso verso la libertà finanziaria.';

  @override
  String get manageWalletsDesc => 'Traccia tutti i conti in un unico posto';

  @override
  String get analyzeSpending => 'Analizza Spese';

  @override
  String get analyzeSpendingDesc => 'Scopri dove vanno i tuoi soldi';

  @override
  String get debtBook => 'Registro Debiti';

  @override
  String get debtBookDesc => 'Traccia crediti e debiti';

  @override
  String get backButton => 'Indietro';

  @override
  String get continueButton => 'Continua';

  @override
  String get startButton => 'Inizia';

  @override
  String get selectCurrency => 'Seleziona Valuta';

  @override
  String get selectCurrencyDesc =>
      'Seleziona la valuta che userai in tutti i conti';

  @override
  String get turkishLira => 'Lira Turca';

  @override
  String get usDollar => 'Dollaro USA';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'Sterlina Britannica';

  @override
  String get createFirstWallet => 'Crea il Tuo Primo Portafoglio';

  @override
  String get createWalletDesc =>
      'Crea un portafoglio per iniziare a tracciare i tuoi soldi';

  @override
  String get walletNameHint => 'es. I Miei Contanti';

  @override
  String get cashType => 'Contanti';

  @override
  String get bankAccount => 'Conto Bancario';

  @override
  String get creditCardType => 'Carta di Credito';

  @override
  String get investmentType => 'Oro/Investimento';

  @override
  String get initialBalanceOptional => 'Saldo Iniziale (Opzionale)';

  @override
  String get initialBalanceHint =>
      'Inserisci quanto denaro hai attualmente. Puoi modificarlo in seguito.';

  @override
  String get enterWalletName => 'Inserisci il nome del portafoglio';

  @override
  String get onboardingSuccess => 'Registrazione riuscita! Ora puoi accedere.';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Gio';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sab';

  @override
  String get sun => 'Dom';

  @override
  String get addExpense => 'Aggiungi Spesa';

  @override
  String get addIncome => 'Aggiungi Entrata';

  @override
  String get expenseAdded => 'Spesa aggiunta';

  @override
  String get incomeAdded => 'Entrata aggiunta';

  @override
  String get debtTracking => 'Tracciamento Debiti';

  @override
  String get myLends => 'Soldi Prestati';

  @override
  String get myDebts => 'Soldi Presi in Prestito';

  @override
  String get personName => 'Nome Persona';

  @override
  String get dueDate => 'Data Scadenza';

  @override
  String get recordPayment => 'Registra Pagamento';

  @override
  String daysRemaining(int days) {
    return '$days giorni rimanenti';
  }

  @override
  String get overdue => 'Scaduto';

  @override
  String get remaining => 'Rimanente';

  @override
  String get lend => 'Ho Prestato';

  @override
  String get borrow => 'Ho Preso in Prestito';

  @override
  String get upcomingDues => 'Prossime Scadenze';

  @override
  String get allRecords => 'Tutti i Record';

  @override
  String get hideCompleted => 'Nascondi Completati';

  @override
  String get showCompleted => 'Mostra Completati';

  @override
  String get markAsCompleted => 'Segna come Completato';

  @override
  String get debtAdded => 'Record aggiunto';

  @override
  String get debtUpdated => 'Record aggiornato';

  @override
  String get debtDeleted => 'Record eliminato';

  @override
  String get paymentRecorded => 'Pagamento registrato';

  @override
  String get noDebts => 'Nessun record di debiti';

  @override
  String get addDebt => 'Aggiungi Record';

  @override
  String get debtAmount => 'Importo';

  @override
  String get debtDescription => 'Descrizione (opzionale)';

  @override
  String get selectDueDate => 'Seleziona data scadenza';

  @override
  String get totalLent => 'Totale Prestato';

  @override
  String get totalBorrowed => 'Totale Preso in Prestito';

  @override
  String people(int count) {
    return '$count persone';
  }

  @override
  String memberSince(String date) {
    return 'Membro dal $date';
  }

  @override
  String get editProfile => 'Modifica Profilo';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String get changePhoto => 'Cambia Foto';

  @override
  String get takePhoto => 'Scatta Foto';

  @override
  String get chooseFromGallery => 'Scegli dalla Galleria';

  @override
  String get removePhoto => 'Rimuovi Foto';

  @override
  String get notifications => 'Notifiche';

  @override
  String get quickActions => 'Azioni Rapide';

  @override
  String get thisMonthSummary => 'Riepilogo Mese';

  @override
  String get financialScore => 'Punteggio Finanziario';

  @override
  String get financialScoreDesc => 'Il tuo punteggio di salute finanziaria';

  @override
  String get spendingTips => 'Consigli Spese';

  @override
  String get spendingTipsDesc => 'Suggerimenti risparmio';

  @override
  String get categoryAnalysis => 'Analisi Categorie';

  @override
  String get categoryAnalysisDesc => 'Dettaglio spese';

  @override
  String get monthlyComparison => 'Confronto Mensile';

  @override
  String get monthlyComparisonDesc => 'Confronta con mesi precedenti';

  @override
  String get budgetProgress => 'Progresso Budget';

  @override
  String get budgetProgressDesc => 'Quanto vicino ai tuoi obiettivi';

  @override
  String get viewDetails => 'Vedi Dettagli';

  @override
  String get excellent => 'Eccellente';

  @override
  String get good => 'Buono';

  @override
  String get average => 'Medio';

  @override
  String get needsImprovement => 'Da Migliorare';

  @override
  String get poor => 'Scarso';

  @override
  String get comparedToLastMonth => 'Rispetto al mese scorso';

  @override
  String get youSpentLess => 'hai speso meno';

  @override
  String get youSpentMore => 'hai speso di più';

  @override
  String get noChange => 'Nessun cambiamento';

  @override
  String get allWallets => 'Tutti i Portafogli';
}
