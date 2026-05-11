$path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\fn_VVT_getdatebyVendorLot_MergeCode.sql"
# Đọc file thô
$text = [System.IO.File]::ReadAllText($path)

# Ép kiểu byte theo Windows-1252 để lấy lại byte gốc của UTF-8
$win1252 = [System.Text.Encoding]::GetEncoding(1252)
$utf8 = [System.Text.Encoding]::UTF8

$bytes = $win1252.GetBytes($text)
$fixedText = $utf8.GetString($bytes)

# Nếu kết quả ra tiếng Việt chuẩn thì áp dụng
if ($fixedText -like "*Chuyển đổi*") {
    $text = $fixedText
}

# Làm sạch dòng trống
$lines = $text -split "\r?\n"
$cleanedLines = New-Object System.Collections.Generic.List[string]
$lastLineWasEmpty = $false
foreach ($line in $lines) {
    if ($line.Trim() -eq "") {
        if (-not $lastLineWasEmpty) {
            $cleanedLines.Add("")
            $lastLineWasEmpty = $true
        }
    } else {
        $cleanedLines.Add($line)
        $lastLineWasEmpty = $false
    }
}

# Lưu với UTF-8 BOM
$utf8WithBOM = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, ($cleanedLines -join "`r`n"), $utf8WithBOM)

Write-Host "HOÀN TẤT: Đã sửa font chuẩn Windows-1252 và dọn dẹp dòng trống."
