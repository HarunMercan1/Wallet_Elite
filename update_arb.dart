import 'dart:io';

void main() async {
  final dir = Directory('lib/l10n');
  if (!await dir.exists()) {
    print('Directory not found');
    return;
  }

  final files = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.arb'),
  );

  final additions = {
    'quickActions': {
      'en': 'Quick Actions',
      'tr': 'Hızlı İşlemler',
      'es': 'Acciones Rápidas',
      'de': 'Schnellaktionen',
      'fr': 'Actions rapides',
      'it': 'Azioni rapide',
      'ru': 'Быстрые действия',
      'default': 'Quick Actions',
    },
    'budgets': {
      'en': 'Budgets',
      'tr': 'Bütçeler',
      'es': 'Presupuestos',
      'de': 'Budgets',
      'fr': 'Budgets',
      'it': 'Budget',
      'ru': 'Бюджеты',
      'default': 'Budgets',
    },
    'search': {
      'en': 'Search',
      'tr': 'Ara',
      'es': 'Buscar',
      'de': 'Suchen',
      'fr': 'Rechercher',
      'it': 'Cerca',
      'ru': 'Поиск',
      'default': 'Search',
    },
    'addTransaction': {
      'en': 'Add Transaction',
      'tr': 'İşlem Ekle',
      'es': 'Añadir Transacción',
      'de': 'Transaktion hinzufügen',
      'fr': 'Ajouter une transaction',
      'it': 'Aggiungi transazione',
      'ru': 'Добавить транзакцию',
      'default': 'Add Transaction',
    },
    'welcome': {
      'en': 'Welcome,',
      'tr': 'Hoş geldin,',
      'es': 'Bienvenido,',
      'default': 'Welcome,',
    },
    'user': {
      'en': 'User',
      'tr': 'Kullanıcı',
      'es': 'Usuario',
      'default': 'User',
    },
  };

  for (final file in files) {
    String content = await file.readAsString();
    final lastBrace = content.lastIndexOf('}');
    if (lastBrace == -1) continue;

    // Remove closing brace
    String jsonInner = content.substring(0, lastBrace).trimRight();
    final fileName = file.path.split(Platform.pathSeparator).last; // app_en.arb
    final langCode = fileName.split('_')[1].split('.').first; // en

    bool addedAny = false;

    // Ensure last character is comma if meaningful content exists
    if (jsonInner.isNotEmpty && !jsonInner.trimRight().endsWith(',')) {
      // Check if it's not just "{"
      if (!jsonInner.trimRight().endsWith('{')) {
        jsonInner += ',';
      }
    }

    additions.forEach((key, translations) {
      // Simple check if key exists
      if (!content.contains('"$key"')) {
        final val = translations[langCode] ?? translations['default'];
        jsonInner += '\n    "$key": "$val",';
        addedAny = true;
      }
    });

    if (addedAny) {
      // Remove trailing comma if exists (invalid json otherwise? no trailing comma allowd in standard json)
      // Actually standard JSON doesn't allow trailing comma.
      // Let's make sure we handle it. But ARB parsers usually allow it or wait, dart arb is strict?
      // Let's remove the last comma.
      if (jsonInner.trimRight().endsWith(',')) {
        jsonInner = jsonInner.trimRight();
        jsonInner = jsonInner.substring(0, jsonInner.length - 1);
      }

      final newContent = '$jsonInner\n}';
      await file.writeAsString(newContent);
      print('Updated $fileName');
    }
  }
}
