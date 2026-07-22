$matches = Select-String -Path "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\*.md", "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\*\*.md", "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\*\*\*.md" -Pattern '\]\((?!(file:///|http://|https://|#))'
foreach ($m in $matches) {
    Write-Host "$($m.Filename):$($m.LineNumber) -> $($m.Line)"
}
