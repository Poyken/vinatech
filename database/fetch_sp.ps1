<#
.SYNOPSIS
    Fetch Stored Procedure từ SQL Server Database
    
.DESCRIPTION
    Script để lấy source code của Stored Procedure từ Vinatech MES Database
    Phục vụ mục đích debug và phân tích lỗi
    
.PARAMETER SPName
    Tên SP cần lấy. Nếu không điền thì lấy tất cả SP bắt đầu bằng 'usp_'
    
.PARAMETER OutputPath
    Thư mục lưu file. Mặc định: ./sp_output/
    
.EXAMPLE
    .\fetch_sp.ps1 -SPName "usp_DoProcessProdRouteHist"
    .\fetch_sp.ps1 -SPName "usp_Vietnam_RawMaterialInputHist_uid" -OutputPath "C:\temp\sp"
    .\fetch_sp.ps1 -SPName ""  # Lấy tất cả SP

.NOTES
    Server: dbserver.hycap.co.kr,5398
    Database: SmartFactoryV2
    Username: vinaadmin
    Created: 2026-05-12
#>

param(
    [string]$SPName = "",
    [string]$OutputPath = ".\sp_output"
)

# =====================================================
# CONFIG - Kết nối Database
# =====================================================
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"

# =====================================================
# MAIN
# =====================================================

# Tạo thư mục output nếu chưa tồn tại
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "[INFO] Created output directory: $OutputPath" -ForegroundColor Green
}

# Kết nối SQL Server
Write-Host "[INFO] Connecting to $Server..." -ForegroundColor Cyan

try {
    $ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    $SqlConnection.Open()
    Write-Host "[OK] Connected successfully!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Cannot connect to database: $_" -ForegroundColor Red
    exit 1
}

# =====================================================
# Lấy danh sách SP
# =====================================================

if ($SPName -eq "") {
    # Lấy tất cả SP bắt đầu bằng usp_
    $query = @"
SELECT name 
FROM sys.procedures 
WHERE name LIKE 'usp_%' 
ORDER BY name
"@
    $SPList = @("usp_DoProcessProdRouteHist", "usp_Vietnam_RawMaterialInputHist_uid", "usp_DoProcessProdGIMaterialByBOM", "usp_MaterialWarehouseInOutHist_iud", "usp_VVTMaterialWarehouse_validFIFO", "usp_SetInfo_iud", "usp_ProductionOrderInfo_get", "usp_BomHeader_iud", "usp_RouteInfo_iud")
    Write-Host "[INFO] Fetching common SPs (no filter specified)..." -ForegroundColor Yellow
} else {
    $SPList = @($SPName)
    Write-Host "[INFO] Fetching SP: $SPName" -ForegroundColor Yellow
}

# =====================================================
# Fetch từng SP
# =====================================================

$successCount = 0
$errorCount = 0

foreach ($sp in $SPList) {
    Write-Host "  Fetching: $sp ..." -NoNewline
    
    try {
        # Lấy definition của SP
        $query = @"
SELECT 
    OBJECT_DEFINITION(OBJECT_ID('$sp')) AS SPDefinition
"@
        
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
        $result = $SqlCmd.ExecuteScalar()
        
        if ($result -ne $null -and $result -ne "") {
            # Lưu vào file
            $filename = "$OutputPath\$sp.sql"
            $result | Out-File -FilePath $filename -Encoding UTF8 -Force
            Write-Host " [OK] Saved to $filename" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host " [WARN] SP not found or empty" -ForegroundColor Yellow
            $errorCount++
        }
        
    } catch {
        Write-Host " [ERROR] $_" -ForegroundColor Red
        $errorCount++
    }
}

# =====================================================
# Cleanup và Summary
# =====================================================

$SqlConnection.Close()

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Success: $successCount SPs" -ForegroundColor Green
Write-Host "  Error:   $errorCount SPs" -ForegroundColor Red
Write-Host "  Output:  $OutputPath" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# =====================================================
# Helper Functions
# =====================================================

function Get-SPList {
    <#
    .SYNOPSIS
        Liệt kê tất cả SP trong database
    #>
    $query = "SELECT name FROM sys.procedures WHERE name LIKE 'usp_%' ORDER BY name"
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset)
    return $dataset.Tables[0]
}

function Get-SPSearch {
    <#
    .SYNOPSIS
        Tìm SP theo từ khóa trong tên
    #>
    param([string]$Keyword)
    
    $query = "SELECT name FROM sys.procedures WHERE name LIKE '%$Keyword%' ORDER BY name"
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $SqlConnection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset)
    return $dataset.Tables[0]
}

# =====================================================
# EXAMPLES - Cách sử dụng
# =====================================================
<#
# Ví dụ 1: Lấy SP cụ thể
#   .\fetch_sp.ps1 -SPName "usp_DoProcessProdRouteHist" -OutputPath "C:\temp\mes_sp"

# Ví dụ 2: Lấy SP liên quan đến "Material"
#   .\fetch_sp.ps1 -SPName "Material" -OutputPath ".\sp_material"

# Ví dụ 3: Liệt kê tất cả SP
#   Get-SPList

# Ví dụ 4: Tìm SP có chữ "Route"
#   Get-SPSearch -Keyword "Route"

# Ví dụ 5: Lấy nhiều SP cùng lúc (sửa $SPList trong script)
#   $SPList = @("usp_DoProcessProdRouteHist", "usp_Vietnam_RawMaterialInputHist_uid")
#   .\fetch_sp.ps1
#>