
$baseDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE"
$word = New-Object -ComObject Word.Application
$word.Visible = $false

# Lấy đúng tên file từ filesystem (tránh lỗi encoding)
$docFiles = Get-ChildItem -Path $baseDir -Filter "*.docx" | Where-Object { $_.Name -notlike "~*" }

foreach ($file in $docFiles) {
    Write-Output "========== FILE: $($file.Name) =========="
    try {
        $doc = $word.Documents.Open($file.FullName)
        $text = $doc.Content.Text
        $doc.Close($false)
        Write-Output $text
    } catch {
        Write-Output "ERROR reading $($file.Name): $_"
    }
    Write-Output ""
}

$word.Quit()
