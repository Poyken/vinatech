
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$word = New-Object -ComObject Word.Application
$word.Visible = $false

$files = @(
    "Bật tắt thành phẩm và nvl.docx",
    "Lỗi trên NAIS System_Tái bản.docx",
    "Một số lỗi Nais System.docx"
)

$baseDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE"

foreach ($file in $files) {
    $fullPath = Join-Path $baseDir $file
    Write-Output "========== FILE: $file =========="
    $doc = $word.Documents.Open($fullPath)
    $text = $doc.Content.Text
    $doc.Close($false)
    Write-Output $text
    Write-Output ""
}

$word.Quit()
