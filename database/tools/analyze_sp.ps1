$file = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\SP_Source_FromDB.md"
$outFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\SP_DataFlow_Analysis.md"
$content = [System.IO.File]::ReadAllText($file)

# Split by SP sections
$sections = $content -split '(?m)^## '
$results = [System.Collections.Generic.List[string]]::new()
$results.Add("# SP DATA FLOW ANALYSIS — Tables Read/Written per SP")
$results.Add("> Auto-extracted from actual SP source code in SmartFactoryV2 DB")
$results.Add("")

foreach ($section in $sections) {
    if ($section -notmatch '^(usp_|pop_)') { continue }
    
    $lines = $section -split "`r?`n"
    $spName = $lines[0].Trim()
    
    # Extract SQL body (inside ```sql block)
    $sqlMatch = [regex]::Match($section, '```sql([\s\S]*?)```')
    if (-not $sqlMatch.Success) { continue }
    $sql = $sqlMatch.Groups[1].Value
    
    # Find tables being READ (FROM, JOIN)
    $readMatches = [regex]::Matches($sql, '(?i)(?:FROM|JOIN)\s+(\[?dbo\]?\.\[?[A-Za-z_]+\]?|\[?[A-Za-z_]+\]?)\s*(?:AS\s+\w+|WITH\s*\(\s*NOLOCK\s*\))?\s')
    $readTables = @()
    foreach ($m in $readMatches) {
        $t = $m.Groups[1].Value -replace '\[|\]', '' -replace 'dbo\.', ''
        if ($t -match '^STB_|^VW_|^STB') { $readTables += $t }
    }
    $readTables = $readTables | Sort-Object -Unique
    
    # Find tables being WRITTEN (INSERT, UPDATE, DELETE, MERGE target)
    $writeMatches = [regex]::Matches($sql, '(?i)(?:INSERT\s+(?:INTO\s+)?|UPDATE\s+|DELETE\s+(?:FROM\s+)?|MERGE\s+)(\[?dbo\]?\.\[?[A-Za-z_]+\]?|\[?[A-Za-z_]+\]?)\s')
    $writeTables = @()
    foreach ($m in $writeMatches) {
        $t = $m.Groups[1].Value -replace '\[|\]', '' -replace 'dbo\.', ''
        if ($t -match '^STB_|^VW_') { $writeTables += $t }
    }
    $writeTables = $writeTables | Sort-Object -Unique
    
    # Check for EXEC calls (sub-SP)
    $execMatches = [regex]::Matches($sql, '(?i)EXEC(?:UTE)?\s+(?:dbo\.)?(\w+)')
    $execSPs = @()
    foreach ($m in $execMatches) {
        $sp = $m.Groups[1].Value
        if ($sp -match '^usp_|^pop_') { $execSPs += $sp }
    }
    
    # Check key business logic keywords  
    $logic = @()
    if ($sql -match '(?i)RAISERROR|THROW') { $logic += 'Error handling' }
    if ($sql -match '(?i)BEGIN TRAN') { $logic += 'Transaction' }
    if ($sql -match '(?i)MERGE') { $logic += 'MERGE (upsert)' }
    if ($sql -match '(?i)OPENXML') { $logic += 'OPENXML (bulk XML)' }
    if ($sql -match '(?i)VET') { $logic += 'VET check' }
    if ($sql -match '(?i)FIFO') { $logic += 'FIFO validation' }
    if ($sql -match '(?i)BOM|backflush') { $logic += 'BOM/Backflush' }
    if ($sql -match '(?i)SmartGen|fn_GetNextNo') { $logic += 'Serial generation' }
    if ($sql -match '(?i)CURSOR') { $logic += 'CURSOR loop' }
    if ($sql -match '(?i)GETDATE') { $logic += 'DateTime stamp' }
    
    $results.Add("## $spName")
    $results.Add("")
    $results.Add("**📥 Tables READ:**")
    if ($readTables.Count -gt 0) {
        $readTables | ForEach-Object { $results.Add("- ``$_``") }
    } else { $results.Add("- _(none / params only)_") }
    
    $results.Add("")
    $results.Add("**📤 Tables WRITTEN:**")
    if ($writeTables.Count -gt 0) {
        $writeTables | ForEach-Object { $results.Add("- ``$_``") }
    } else { $results.Add("- _(none)_") }
    
    if ($execSPs.Count -gt 0) {
        $results.Add("")
        $results.Add("**🔗 Calls SP:**")
        $execSPs | ForEach-Object { $results.Add("- ``$_``") }
    }
    
    $results.Add("")
    $results.Add("**⚙️ Business Logic:**")
    if ($logic.Count -gt 0) {
        $results.Add(($logic -join " | "))
    }
    $results.Add("")
    $results.Add("---")
    $results.Add("")
    
    Write-Host "Analyzed: $spName"
}

[System.IO.File]::WriteAllLines($outFile, $results, [System.Text.UTF8Encoding]::new($false))
Write-Host "DONE: $outFile"
