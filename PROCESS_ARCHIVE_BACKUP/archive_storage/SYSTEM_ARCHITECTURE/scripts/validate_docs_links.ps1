# Script kiểm tra link tài liệu nâng cao cho cấu trúc mới
$files = @(
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\README.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\DATABASE\VINATECH_GROUP\README.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\README.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\SYSTEM_MASTER_KNOWLEDGE_BASE\README.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\SYSTEM_MASTER_KNOWLEDGE_BASE\VOL_01_SYSTEM_ARCHITECTURE.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\SYSTEM_MASTER_KNOWLEDGE_BASE\VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\SYSTEM_MASTER_KNOWLEDGE_BASE\VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\SYSTEM_MASTER_KNOWLEDGE_BASE\MES_DAILY_PLAYBOOK.md",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\SYSTEM_MASTER_KNOWLEDGE_BASE\MES_OPERATIONAL_LOG.md"
)

$all_valid = $true

foreach ($file_path in $files) {
    if (-not (Test-Path $file_path)) {
        Write-Host "File not found: $file_path" -ForegroundColor Red
        $all_valid = $false
        continue
    }

    Write-Host "Analyzing file: $(Split-Path $file_path -Leaf)" -ForegroundColor Cyan
    $content = Get-Content -Path $file_path -Raw
    
    # Regex tìm các link dạng [text](link)
    # Loại trừ link http/https và anchor thuần túy (#anchor)
    $regex = '\[([^\]]+)\]\(((?!http|https|#)[^\)]+)\)'
    $matches = [regex]::Matches($content, $regex)
    
    Write-Host "Found $($matches.Count) local/file links."
    
    $file_dir = Split-Path $file_path
    
    foreach ($match in $matches) {
        $text = $match.Groups[1].Value
        $url = $match.Groups[2].Value
        
        # Chuyển đổi url
        $local_path = ""
        if ($url -like "file://*") {
            $local_path = $url -replace 'file:///', '' -replace '%20', ' ' -replace '/', '\'
            # Đối với Windows absolute path nếu bắt đầu bằng C:
            if ($local_path -match '^[a-zA-Z]:') {
                # Giữ nguyên
            } else {
                # Nếu là đường dẫn tương đối bắt đầu bằng file:///
                $local_path = Join-Path $file_dir $local_path
            }
        } else {
            # Link tương đối
            $local_path = Join-Path $file_dir ($url -replace '%20', ' ' -replace '/', '\')
        }
        
        # Loại bỏ phần hash
        if ($local_path -match '#') {
            $local_path = $local_path -split '#' | Select-Object -First 1
        }
        
        if (Test-Path -Path $local_path) {
            Write-Host "  [OK] Link '$text' -> $local_path" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] Link '$text' -> $local_path" -ForegroundColor Red
            $all_valid = $false
        }
    }
}

if ($all_valid) {
    Write-Host "All links are verified and valid." -ForegroundColor Green
} else {
    Write-Error "Some links are invalid!"
}
