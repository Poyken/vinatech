$docPath = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE\L?i tr?n NAIS System_T?i b?n.docx'
$outPath = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\docx_extracted.txt'

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    
    # Find the file
    $files = Get-ChildItem 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE\' -Filter '*.docx'
    $docFile = $files | Where-Object { $_.Name -like '*NAIS*' -or $_.Name -like '*L?i*' -or $_.Name -like '*System*' } | Select-Object -First 1
    
    if ($docFile) {
        Write-Host "Opening: $($docFile.FullName)"
        $doc = $word.Documents.Open($docFile.FullName)
        $text = $doc.Content.Text
        $doc.Close([ref]$false)
        $word.Quit()
        $text | Out-File -FilePath $outPath -Encoding UTF8 -Force
        $lines = ($text -split "`r`n|`n|`r").Count
        Write-Host "Done. Total chars: $($text.Length), Lines: $lines"
    } else {
        Write-Host "File not found!"
        $files | ForEach-Object { Write-Host $_.Name }
    }
} catch {
    Write-Host "Error: $_"
    try { $word.Quit() } catch {}
}
