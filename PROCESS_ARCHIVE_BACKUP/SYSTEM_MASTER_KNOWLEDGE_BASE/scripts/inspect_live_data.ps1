# Script truy vấn và kiểm tra dữ liệu thực tế gần đây từ các database
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$queries = @(
    @{
        name = "1. Giao dịch tài liệu gần đây (Groupware VINA_DOCUMENT_SAVE)"
        sql = "SELECT TOP 3 DOCUMENT_SAVE_CODE, DOCUMENT_TYPE_ID, DOCUMENT_SAVE_STATE, NO_EMP_WRITER, DOCUMENT_SAVE_SUBJECT, DOCUMENT_SAVE_REG_DATE FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH(NOLOCK) ORDER BY DOCUMENT_SAVE_REG_DATE DESC"
    },
    @{
        name = "2. Lot nguyên vật liệu gần đây (MES STB_MaterialLotInfo)"
        sql = "SELECT TOP 3 MaterialLotNo, MaterialCode, WarehouseCode, CurrentQty, LotState, CreateDateTime, LotAttr10 FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE CurrentQty > 0 ORDER BY CreateDateTime DESC"
    },
    @{
        name = "3. Lịch sử chạy máy sản xuất gần đây (MES STB_ProdRouteHist)"
        sql = "SELECT TOP 3 ControlNo, RouteCode, MachineCode, ProdDateTime, InQty, ProdQty, DefectQty, CreateUserID FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) ORDER BY ProdDateTime DESC"
    },
    @{
        name = "4. Sản phẩm đóng gói/Set Info gần đây (MES STB_SetInfo)"
        sql = "SELECT TOP 3 ControlNo, Barcode, MaterialCode, InputLineCode, ProcessState, InputJobDate, CreateDateTime FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) ORDER BY CreateDateTime DESC"
    },
    @{
        name = "5. Giao dịch Cash Management gần đây (WCMS_ACCOUNT_TRNX_LOG)"
        sql = "SELECT TOP 3 ACCOUNT_NO, TRNX_DATE, IN_AMOUNT, OUT_AMOUNT, ERP_FLAG, ERP_TX_MSG FROM WCMS_STANDARD_NEW.dbo.WCMS_ACCOUNT_TRNX_LOG WITH(NOLOCK) ORDER BY TRNX_DATE DESC"
    },
    @{
        name = "6. Tài khoản người dùng gần đây (SmartFramework STB_UserInfo)"
        sql = "SELECT TOP 3 UserID, UserName, AllowFlag, Appendix8, CreateDateTime FROM SmartFramework.dbo.STB_UserInfo WITH(NOLOCK) ORDER BY CreateDateTime DESC"
    },
    @{
        name = "7. Token SSO gần đây (VINATECH_RESTFUL VINA_SSO_TOKEN)"
        sql = "SELECT TOP 3 ID_USER, SSO_TOKEN_CLIENT_IP, SSO_TOKEN_REG_DATE, SSO_TOKEN_DIVICE FROM VINATECH_RESTFUL.dbo.VINA_SSO_TOKEN WITH(NOLOCK) ORDER BY SSO_TOKEN_REG_DATE DESC"
    }
)

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $conn.Open()
    Write-Host "========== BẮT ĐẦU TRUY VẤN DỮ LIỆU THỰC TẾ GẦN ĐÂY ==========" -ForegroundColor Green
    
    foreach ($query in $queries) {
        Write-Host ""
        Write-Host ">>> $($query.name)" -ForegroundColor Cyan
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $query.sql
        
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dataTable = New-Object System.Data.DataTable
        $adapter.Fill($dataTable) | Out-Null
        
        $dataTable | Format-Table -AutoSize | Out-String -Width 1000 | Write-Host
    }
    Write-Host "========== HOÀN TẤT TRUY VẤN DỮ LIỆU ==========" -ForegroundColor Green
} catch {
    Write-Error "Truy vấn database thất bại: $_"
} finally {
    $conn.Close()
}
