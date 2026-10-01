# ==============================================================================
# VINATECH ENTERPRISE REMINDER INJECTOR (Lifecycle PreInvocation Hook)
# Author: vanduc (Nguyen Van Duc - EA Team)
# Purpose: Injects compliance guidelines before model execution.
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$resp = @{
    injectSteps = @(
        @{
            ephemeralMessage = "🛡️ [VINATECH ENTERPRISE GATEWAY ACTIVE]: Hãy luôn tuân thủ nghiêm ngặt: (1) Rule 18 (Author='vanduc', ChangeUserID='vanduc'), (2) Rule 21 (Bắt buộc dùng CLI Hubs, tối đa 1-2 tool calls trúng đích), (3) Rule 22 (Định danh sự cố Kiosk là POP, tuyệt đối không ghi MES), (4) Rule 23 (ops.ps1 first), (5) Rule 24 (Snapshot & 1-Click Rollback)."
        }
    )
}

Write-Output (ConvertTo-Json $resp -Compress)