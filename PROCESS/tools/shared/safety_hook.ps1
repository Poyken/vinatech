# ==============================================================================
# VINATECH ENTERPRISE SAFETY GATEWAY (Lifecycle PreToolUse Hook)
# Author: vanduc (Nguyen Van Duc - EA Team)
# Purpose: Pre-execution inspection for run_command to prevent destructive operations.
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$inputJson = $input | Out-String
if ([string]::IsNullOrWhiteSpace($inputJson)) {
    Write-Output '{"decision":"allow"}'
    exit 0
}

try {
    $data = ConvertFrom-Json $inputJson
    $cmd = $data.toolCall.args.CommandLine
    if ($cmd) {
        # Check 1: Prevent DROP TABLE or TRUNCATE TABLE
        if ($cmd -match "(?i)\b(DROP\s+TABLE|DROP\s+DATABASE|TRUNCATE\s+TABLE)\b") {
            $resp = @{
                decision = "deny"
                reason = "⛔ VINATECH PRODUCTION SAFETY GATE: Lệnh phá hủy cấu trúc DDL bị chặn (DROP/TRUNCATE). Vui lòng kiểm tra lại!"
            }
            Write-Output (ConvertTo-Json $resp -Compress)
            exit 0
        }

        # Check 2: Prevent unconstrained DELETE FROM without WHERE
        if ($cmd -match "(?i)\bDELETE\s+FROM\b" -and $cmd -notmatch "(?i)\bWHERE\b") {
            $resp = @{
                decision = "deny"
                reason = "⛔ VINATECH PRODUCTION SAFETY GATE: Lệnh DELETE không có mệnh đề WHERE bị chặn để chống mất dữ liệu hàng loạt!"
            }
            Write-Output (ConvertTo-Json $resp -Compress)
            exit 0
        }

        # Check 3: Warn on broad UPDATE without WHERE
        if ($cmd -match "(?i)\bUPDATE\s+\w+\s+SET\b" -and $cmd -notmatch "(?i)\bWHERE\b") {
            $resp = @{
                decision = "force_ask"
                reason = "⚠️ VINATECH PRODUCTION SAFETY GATE: Phát hiện câu lệnh UPDATE diện rộng không có điều kiện WHERE. Cần xác nhận của kỹ sư!"
            }
            Write-Output (ConvertTo-Json $resp -Compress)
            exit 0
        }
    }

    Write-Output '{"decision":"allow"}'
} catch {
    Write-Output '{"decision":"allow"}'
}