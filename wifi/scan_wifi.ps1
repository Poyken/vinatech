
# WiFi Password Matcher - Bo qua quyen Location, dung netsh profiles thay the
$wifiDir = 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\wifi'

# BUOC 1: Doc mat khau tu tat ca XML files
$wifiMap = @{}
$xmlFiles = Get-ChildItem -Path $wifiDir -Filter '*.xml'
foreach ($file in $xmlFiles) {
    try {
        [xml]$xml = Get-Content $file.FullName -Encoding UTF8
        $ssid = $xml.WLANProfile.SSIDConfig.SSID.name
        $keyMaterial = $xml.WLANProfile.MSM.security.sharedKey.keyMaterial
        if ($ssid) {
            $wifiMap[$ssid] = if ($keyMaterial) { $keyMaterial } else { "(khong co mat khau / open)" }
        }
    } catch {}
}
Write-Host "Doc duoc $($wifiMap.Count) SSID tu XML." -ForegroundColor Cyan

# BUOC 2: WiFi dang ket noi hien tai
Write-Host ""
Write-Host "=== WIFI DANG KET NOI ===" -ForegroundColor Yellow
$interfaces = netsh wlan show interfaces 2>&1
$currentSSID = ""
foreach ($line in $interfaces) {
    if ($line -match "^\s+SSID\s+:\s(.+)$") {
        $candidate = $matches[1].Trim()
        if ($candidate -notmatch "BSSID") {
            $currentSSID = $candidate
        }
    }
}
if ($currentSSID) {
    $pw = if ($wifiMap.ContainsKey($currentSSID)) { $wifiMap[$currentSSID] } else { "(khong tim thay trong XML)" }
    Write-Host "  SSID   : $currentSSID" -ForegroundColor Green
    Write-Host "  Password: $pw" -ForegroundColor Green
} else {
    Write-Host "  Khong co ket noi WiFi hien tai." -ForegroundColor Red
}

# BUOC 3: Tat ca profiles da luu tren may va mat khau tuong ung
Write-Host ""
Write-Host "=== TAT CA PROFILES DA LUU TREN MAY (match voi XML) ===" -ForegroundColor Yellow
Write-Host ("{0,-35} {1}" -f "SSID", "Mat khau")
Write-Host ("-" * 80)

$profilesOutput = netsh wlan show profiles 2>&1
foreach ($line in $profilesOutput) {
    if ($line -match "All User Profile\s*:\s*(.+)$" -or $line -match "User Profile\s*:\s*(.+)$") {
        $profileName = $matches[1].Trim()
        $pw = if ($wifiMap.ContainsKey($profileName)) { $wifiMap[$profileName] } else { "--- (chua co trong XML folder)" }
        Write-Host ("{0,-35} {1}" -f $profileName, $pw)
    }
}

Write-Host ""
Write-Host "=== DANH SACH DAY DU TU XML (SSID + Password) ===" -ForegroundColor Cyan
Write-Host ("{0,-35} {1}" -f "SSID", "Mat khau")
Write-Host ("-" * 80)
foreach ($key in ($wifiMap.Keys | Sort-Object)) {
    Write-Host ("{0,-35} {1}" -f $key, $wifiMap[$key])
}
