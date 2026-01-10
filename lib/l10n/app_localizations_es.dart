// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Wallet Elite';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Agregar';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get loading => 'Cargando...';

  @override
  String get search => 'Buscar...';

  @override
  String get all => 'Todo';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get notFound => 'no encontrado';

  @override
  String get home => 'Inicio';

  @override
  String get transactions => 'Transacciones';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get settings => 'Ajustes';

  @override
  String get welcome => 'Bienvenido,';

  @override
  String get totalBalance => 'Saldo Total';

  @override
  String get recentTransactions => 'Transacciones Recientes';

  @override
  String get noTransactions => 'No hay transacciones';

  @override
  String get addFirstTransaction => 'Toque + para agregar!';

  @override
  String get income => 'Ingresos';

  @override
  String get expense => 'Gastos';

  @override
  String get amount => 'Monto';

  @override
  String get category => 'Categoría';

  @override
  String get note => 'Nota';

  @override
  String get date => 'Fecha';

  @override
  String get wallet => 'Billetera';

  @override
  String get addTransaction => 'Agregar Transacción';

  @override
  String get editTransaction => 'Editar Transacción';

  @override
  String get deleteTransaction => 'Eliminar Transacción';

  @override
  String get transactionAdded => 'Transacción agregada';

  @override
  String get transactionUpdated => 'Transacción actualizada';

  @override
  String get transactionDeleted => 'Transacción eliminada';

  @override
  String get enterAmount => 'Ingrese monto';

  @override
  String get selectWallet => 'Seleccionar billetera';

  @override
  String get addNote => 'Agregar nota...';

  @override
  String get more => 'Más';

  @override
  String get searchTransactions => 'Buscar transacciones...';

  @override
  String get noIncomeFound => 'No se encontraron ingresos';

  @override
  String get noExpenseFound => 'No se encontraron gastos';

  @override
  String get confirmDelete => '¿Está seguro de eliminar esta transacción?';

  @override
  String get categories => 'Categorías';

  @override
  String get incomeCategories => 'Categorías de Ingresos';

  @override
  String get expenseCategories => 'Categorías de Gastos';

  @override
  String get newCategory => 'Nueva Categoría';

  @override
  String get newIncomeCategory => 'Nueva Categoría de Ingresos';

  @override
  String get newExpenseCategory => 'Nueva Categoría de Gastos';

  @override
  String get categoryName => 'Nombre de Categoría';

  @override
  String get selectIcon => 'Seleccionar Icono:';

  @override
  String get categoryAdded => 'Categoría agregada';

  @override
  String get createCategories => 'Crear Categorías';

  @override
  String get noCategories => 'Sin categorías';

  @override
  String get longPressToFavorite => 'Mantén presionado para favoritos';

  @override
  String addedToFavorites(String name) {
    return '$name agregado a favoritos';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name eliminado de favoritos';
  }

  @override
  String get wallets => 'Billeteras';

  @override
  String get addWallet => 'Agregar Billetera';

  @override
  String get walletName => 'Nombre de Billetera';

  @override
  String get walletType => 'Tipo de Billetera';

  @override
  String get initialBalance => 'Saldo Inicial';

  @override
  String get cash => 'Efectivo';

  @override
  String get bank => 'Banco';

  @override
  String get creditCard => 'Tarjeta de Crédito';

  @override
  String get savings => 'Ahorros';

  @override
  String get walletAdded => 'Billetera agregada';

  @override
  String get noWallets => 'Sin billeteras';

  @override
  String get manageWallets => 'Administrar Billeteras';

  @override
  String get categoryNotFound => 'Categoría no encontrada';

  @override
  String get walletNotFound => 'Billetera no encontrada';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get networkError =>
      'Error de conexión de red. Por favor, verifique su internet.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get colorScheme => 'Esquema de Color';

  @override
  String get account => 'Cuenta';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get signOutConfirm => '¿Cerrar sesión?';

  @override
  String get user => 'Usuario';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get haveAccount => '¿Ya tienes cuenta?';

  @override
  String get loginSuccess => '¡Inicio de sesión exitoso!';

  @override
  String get registerSuccess => '¡Registro exitoso!';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get lastMonth => 'Mes Pasado';

  @override
  String get thisYear => 'Este Año';

  @override
  String get monthly => 'Mensual';

  @override
  String get weekly => 'Semanal';

  @override
  String get daily => 'Diario';

  @override
  String get totalIncome => 'Ingresos Totales';

  @override
  String get totalExpense => 'Gastos Totales';

  @override
  String get balance => 'Saldo';

  @override
  String get categoryBreakdown => 'Desglose de Categorías';

  @override
  String get cat_food => 'Comida';

  @override
  String get cat_transport => 'Transporte';

  @override
  String get cat_shopping => 'Compras';

  @override
  String get cat_entertainment => 'Entretenimiento';

  @override
  String get cat_bills => 'Facturas';

  @override
  String get cat_health => 'Salud';

  @override
  String get cat_education => 'Educación';

  @override
  String get cat_rent => 'Alquiler';

  @override
  String get cat_taxes => 'Impuestos';

  @override
  String get cat_salary => 'Salario';

  @override
  String get cat_freelance => 'Freelance';

  @override
  String get cat_investment => 'Inversión';

  @override
  String get cat_gift => 'Regalo';

  @override
  String get cat_other => 'Otro';

  @override
  String get cat_pets => 'Mascotas';

  @override
  String get cat_groceries => 'Supermercado';

  @override
  String get cat_electronics => 'Electrónica';

  @override
  String get cat_charity => 'Caridad';

  @override
  String get cat_insurance => 'Seguro';

  @override
  String get cat_gym => 'Gimnasio';

  @override
  String get cat_travel => 'Viajes';

  @override
  String get statisticsTitle => 'Resumen de Estadísticas';

  @override
  String get periodFilter => 'Período';

  @override
  String get allTime => 'Todo el tiempo';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get averageDailySpending => 'Gasto diario promedio';

  @override
  String get totalTransactions => 'Total de transacciones';

  @override
  String get incomeCount => 'Cantidad de ingresos';

  @override
  String get expenseCount => 'Cantidad de gastos';

  @override
  String get topCategories => 'Categorías principales';

  @override
  String get savingsRate => 'Tasa de ahorro';

  @override
  String get biggestIncome => 'Mayor ingreso';

  @override
  String get biggestExpense => 'Mayor gasto';

  @override
  String get noData => 'Sin datos para este período';

  @override
  String get spendingTrend => 'Tendencia de gastos';

  @override
  String get incomeVsExpense => 'Ingresos vs Gastos';

  @override
  String get loginTab => 'Iniciar Sesión';

  @override
  String get registerTab => 'Registrarse';

  @override
  String get tagline => 'Tu libertad financiera, en tus manos';

  @override
  String get enterFullName => 'Ingrese nombre completo';

  @override
  String get nameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get enterEmail => 'Ingrese email';

  @override
  String get validEmail => 'Ingrese un email válido';

  @override
  String get enterPassword => 'Ingrese contraseña';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get forgotPasswordTitle => 'Restablecer Contraseña';

  @override
  String get forgotPasswordText =>
      'Enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get send => 'Enviar';

  @override
  String get passwordResetSent => 'Enlace de restablecimiento enviado.';

  @override
  String get loginFailed =>
      'Error al iniciar sesión. Verifique email o contraseña.';

  @override
  String get registerFailed =>
      'Error al registrar. El email puede estar en uso.';

  @override
  String get googleLoginFailed => 'Error al iniciar sesión con Google';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get orDivider => 'o';

  @override
  String get privacyText =>
      'Al continuar, aceptas los Términos de Servicio y Política de Privacidad';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get welcomeTitle => '¡Bienvenido a\\nWallet Elite! 👋';

  @override
  String get welcomeSubtitle =>
      'Solo unos pasos simples para comenzar tu libertad financiera.';

  @override
  String get manageWalletsDesc => 'Lleva todas tus cuentas en un solo lugar';

  @override
  String get analyzeSpending => 'Analiza tus Gastos';

  @override
  String get analyzeSpendingDesc => 'Ve a dónde va tu dinero';

  @override
  String get debtBook => 'Libro de Deudas';

  @override
  String get debtBookDesc => 'Lleva un registro de lo que debes y te deben';

  @override
  String get backButton => 'Atrás';

  @override
  String get continueButton => 'Continuar';

  @override
  String get startButton => 'Comenzar';

  @override
  String get selectCurrency => 'Seleccionar Moneda';

  @override
  String get selectCurrencyDesc =>
      'Selecciona la moneda que usarás en todas las cuentas';

  @override
  String get turkishLira => 'Lira Turca';

  @override
  String get usDollar => 'Dólar Estadounidense';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'Libra Esterlina';

  @override
  String get createFirstWallet => 'Crea tu Primera Billetera';

  @override
  String get createWalletDesc =>
      'Crea una billetera para comenzar a rastrear tu dinero';

  @override
  String get walletNameHint => 'ej: Mi Efectivo';

  @override
  String get cashType => 'Efectivo';

  @override
  String get bankAccount => 'Cuenta Bancaria';

  @override
  String get creditCardType => 'Tarjeta de Crédito';

  @override
  String get investmentType => 'Oro/Inversión';

  @override
  String get initialBalanceOptional => 'Saldo Inicial (Opcional)';

  @override
  String get initialBalanceHint =>
      'Ingresa cuánto dinero tienes actualmente. Puedes cambiarlo después.';

  @override
  String get enterWalletName => 'Por favor ingresa el nombre de la billetera';

  @override
  String get onboardingSuccess =>
      '¡Registro exitoso! Ya puedes iniciar sesión.';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mié';

  @override
  String get thu => 'Jue';

  @override
  String get fri => 'Vie';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String get addExpense => 'Agregar Gasto';

  @override
  String get addIncome => 'Agregar Ingreso';

  @override
  String get expenseAdded => 'Gasto agregado';

  @override
  String get incomeAdded => 'Ingreso agregado';

  @override
  String get debtTracking => 'Seguimiento de Deudas';

  @override
  String get myLends => 'Dinero Prestado';

  @override
  String get myDebts => 'Dinero Adeudado';

  @override
  String get personName => 'Nombre de Persona';

  @override
  String get dueDate => 'Fecha de Vencimiento';

  @override
  String get recordPayment => 'Registrar Pago';

  @override
  String daysRemaining(int days) {
    return '$days días restantes';
  }

  @override
  String get overdue => 'Vencido';

  @override
  String get remaining => 'Restante';

  @override
  String get lend => 'Presté';

  @override
  String get borrow => 'Pedí prestado';

  @override
  String get upcomingDues => 'Próximos Vencimientos';

  @override
  String get allRecords => 'Todos los Registros';

  @override
  String get hideCompleted => 'Ocultar Completados';

  @override
  String get showCompleted => 'Mostrar Completados';

  @override
  String get markAsCompleted => 'Marcar como Completado';

  @override
  String get debtAdded => 'Registro agregado';

  @override
  String get debtUpdated => 'Registro actualizado';

  @override
  String get debtDeleted => 'Registro eliminado';

  @override
  String get paymentRecorded => 'Pago registrado';

  @override
  String get noDebts => 'Aún no hay registros de deudas';

  @override
  String get addDebt => 'Agregar Registro';

  @override
  String get debtAmount => 'Monto';

  @override
  String get debtDescription => 'Descripción (opcional)';

  @override
  String get selectDueDate => 'Seleccionar fecha de vencimiento';

  @override
  String get totalLent => 'Total Prestado';

  @override
  String get totalBorrowed => 'Total Adeudado';

  @override
  String people(int count) {
    return '$count personas';
  }

  @override
  String memberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get changePhoto => 'Cambiar Foto';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de Galería';

  @override
  String get removePhoto => 'Eliminar Foto';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get thisMonthSummary => 'Resumen de Este Mes';

  @override
  String get financialScore => 'Puntuación Financiera';

  @override
  String get financialScoreDesc => 'Tu puntuación de salud financiera';

  @override
  String get spendingTips => 'Consejos de Gasto';

  @override
  String get spendingTipsDesc => 'Sugerencias de ahorro';

  @override
  String get categoryAnalysis => 'Análisis de Categorías';

  @override
  String get categoryAnalysisDesc => 'Desglose detallado de gastos';

  @override
  String get monthlyComparison => 'Comparación Mensual';

  @override
  String get monthlyComparisonDesc => 'Comparar con meses anteriores';

  @override
  String get budgetProgress => 'Progreso del Presupuesto';

  @override
  String get budgetProgressDesc => 'Qué tan cerca de tus metas';

  @override
  String get viewDetails => 'Ver Detalles';

  @override
  String get excellent => 'Excelente';

  @override
  String get good => 'Bueno';

  @override
  String get average => 'Promedio';

  @override
  String get needsImprovement => 'Necesita Mejora';

  @override
  String get poor => 'Pobre';

  @override
  String get comparedToLastMonth => 'Comparado con el mes pasado';

  @override
  String get youSpentLess => 'gastaste menos';

  @override
  String get youSpentMore => 'gastaste más';

  @override
  String get noChange => 'Sin cambios';

  @override
  String get allWallets => 'Todas las Billeteras';
}
