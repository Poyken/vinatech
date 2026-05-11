$path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\fn_VVT_getdatebyVendorLot_MergeCode.sql"
$text = [System.IO.File]::ReadAllText($path)

# Bảng tra cứu các ký tự lỗi font phổ biến
$replacements = @{
    "á»ƒ" = "ể";
    "Ã " = "à";
    "Ä‘" = "đ";
    "á» " = "ọ";
    "áº£" = "ả";
    "áº¥" = "ấ";
    "á»‹" = "ị";
    "á»…" = "ễ";
    "á»›" = "ớ";
    "á»±" = "ự";
    "Ã¡" = "á";
    "Ã³" = "ó";
    "Ãº" = "ú";
    "Ãª" = "ê";
    "Ã´" = "ô";
    "Æ¡" = "ơ";
    "Æ°" = "ư";
    "á» " = "ò";
    "á»§" = "ủ";
    "á»¹" = "ỹ";
    "á»Ÿ" = "ở";
    "á»£" = "ợ";
    "áº§" = "ầ";
    "áº¿" = "ế";
    "Ã¹" = "ù";
    "Ã¬" = "ì";
    "á»‹" = "ị";
    "á»¥" = "ụ"
}

foreach ($key in $replacements.Keys) {
    $text = $text.Replace($key, $replacements[$key])
}

# Làm sạch dòng trống (Chỉ giữ lại tối đa 1 dòng trống liên tiếp)
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

# Lưu lại file chuẩn UTF-8 với BOM
$utf8WithBOM = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, ($cleanedLines -join "`r`n"), $utf8WithBOM)

Write-Host "Đã quét sạch lỗi font và dọn dẹp dòng trống thành công!"
