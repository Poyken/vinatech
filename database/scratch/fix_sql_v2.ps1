$path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\fn_VVT_getdatebyVendorLot_MergeCode.sql"
$bytes = [System.IO.File]::ReadAllBytes($path)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# Chuyển đổi từ chuỗi bị lỗi font (UTF-8 interpreted as ANSI) về chuẩn UTF-8
# Chúng ta lấy byte theo chuẩn Windows-1252 (iso-8859-1) và dịch lại sang UTF-8
$ansiEncoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
$fixedBytes = $ansiEncoding.GetBytes($text)
$fixedText = [System.Text.Encoding]::UTF8.GetString($fixedBytes)

# Kiểm tra nếu sau khi fix mà vẫn còn ký tự rác thì dùng chuỗi gốc (trường hợp file đã chuẩn rồi)
if ($fixedText -like "*Chuyển đổi*") {
    $text = $fixedText
}

# Làm sạch dòng trống: Chỉ giữ lại tối đa 1 dòng trống liên tiếp
$lines = $text -split "\r?\n"
$cleanedLines = New-Object System.Collections.Generic.List[string]
$lastLineWasEmpty = $false

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ($trimmed -eq "") {
        if (-not $lastLineWasEmpty) {
            $cleanedLines.Add("")
            $lastLineWasEmpty = $true
        }
    } else {
        $cleanedLines.Add($line)
        $lastLineWasEmpty = $false
    }
}

# Lưu file với định dạng UTF-8 có BOM (chuẩn cho SQL Server)
$finalText = $cleanedLines -join "`r`n"
$utf8WithBOM = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, $finalText, $utf8WithBOM)

Write-Host "Đã sửa lỗi font và làm sạch code cho: $path"
