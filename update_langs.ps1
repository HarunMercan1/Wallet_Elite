$translations = @{
    'en' = '"budgets": "Budgets", "search": "Search"';
    'tr' = '"budgets": "Bütçeler", "search": "Ara"';
    'es' = '"budgets": "Presupuestos", "search": "Buscar"';
    'de' = '"budgets": "Budgets", "search": "Suchen"';
    'fr' = '"budgets": "Budgets", "search": "Rechercher"';
    'it' = '"budgets": "Budget", "search": "Cerca"';
    'ru' = '"budgets": "Бюджеты", "search": "Поиск"';
    'ar' = '"budgets": "الميزانيات", "search": "بحث"';
    'ja' = '"budgets": "予算", "search": "検索"';
    'ko' = '"budgets": "예산", "search": "검색"';
    'pt' = '"budgets": "Orçamentos", "search": "Pesquisar"';
    'zh' = '"budgets": "预算", "search": "搜索"';
    'id' = '"budgets": "Anggaran", "search": "Cari"'
}

$files = Get-ChildItem "lib\l10n\*.arb"

foreach ($file in $files) {
    $lang = $file.Name.Substring(4, 2)
    if ($translations.ContainsKey($lang)) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        # Remove the last closing brace and any trailing whitespace
        $content = $content.TrimEnd()
        if ($content.EndsWith("}")) {
            $content = $content.Substring(0, $content.Length - 1).TrimEnd()
        }
        
        # Add comma if not present at the end of content
        if (-not $content.TrimEnd().EndsWith(",") -and -not $content.TrimEnd().EndsWith("{")) {
            $content += ","
        }
        
        # Append new keys
        $newKeys = $translations[$lang]
        $content += "`n    $newKeys`n}"
        
        Set-Content $file.FullName $content -Encoding UTF8
        Write-Host "Updated $($file.Name)"
    }
}
