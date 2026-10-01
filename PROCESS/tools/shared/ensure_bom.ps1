$files = @(
    '.agents\rules\DEPLOYMENT_SOP.md',
    '.agents\rules\01_sql_safety_rules.md',
    '.agents\rules\00_vinatech_master_rules.md',
    'OPERATOR_COPILOT_GUIDE.md',
    'ops.ps1',
    'MES_POP\tools\deploy_tool.ps1',
    '.agents\skills\vinatech-enterprise-ops\SKILL.md',
    '.agents\skills\vinatech-new-model-setup\SKILL.md'
)

$utf8BOM = New-Object System.Text.UTF8Encoding($true)

foreach ($f in $files) {
    if (Test-Path $f) {
        $fullPath = (Resolve-Path $f).Path
        $content = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($fullPath, $content, $utf8BOM)
        Write-Host "[OK] UTF-8 BOM: $f" -ForegroundColor Green
    }
}
