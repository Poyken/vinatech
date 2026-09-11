param (
    [string]$LotNumber = "VVQR0720001E40",
    [string]$Profile = "SmartFactoryV2"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$backupDir = Join-Path $PSScriptRoot "backups"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

. (Join-Path $PSScriptRoot "db_shared.ps1")

$conn = Get-DbConnection -Profile $Profile
if ($conn -eq $null) {
    Write-Error "Khong the ket noi CSDL de backup!"
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

try {
    # 1. Backup STB_ElectrodeMixStepInfo
    $sqlSteps = "SELECT * FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = '$LotNumber' ORDER BY Seq;"
    $cmdSteps = New-Object System.Data.SqlClient.SqlCommand($sqlSteps, $conn)
    $daSteps = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSteps)
    $dtSteps = New-Object System.Data.DataTable
    $daSteps.Fill($dtSteps) | Out-Null

    # 2. Backup STB_ElectrodeMixInfo
    $sqlMix = "SELECT * FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = '$LotNumber';"
    $cmdMix = New-Object System.Data.SqlClient.SqlCommand($sqlMix, $conn)
    $daMix = New-Object System.Data.SqlClient.SqlDataAdapter($cmdMix)
    $dtMix = New-Object System.Data.DataTable
    $daMix.Fill($dtMix) | Out-Null

    # 3. Backup STB_SetInfo
    $sqlSet = "SELECT * FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$LotNumber';"
    $cmdSet = New-Object System.Data.SqlClient.SqlCommand($sqlSet, $conn)
    $daSet = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSet)
    $dtSet = New-Object System.Data.DataTable
    $daSet.Fill($dtSet) | Out-Null

    # Save to JSON
    $backupData = @{
        LotNumber = $LotNumber
        BackupDateTime = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Database = $conn.Database
        ElectrodeMixStepInfo_Count = $dtSteps.Rows.Count
        ElectrodeMixInfo_Count = $dtMix.Rows.Count
        SetInfo_Count = $dtSet.Rows.Count
        ElectrodeMixStepInfo = $dtSteps
        ElectrodeMixInfo = $dtMix
        SetInfo = $dtSet
    }

    $jsonFile = Join-Path $backupDir "backup_${LotNumber}_${timestamp}.json"
    $jsonContent = $backupData | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($jsonFile, $jsonContent, [System.Text.Encoding]::UTF8)

    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "   DA BACKUP THANH CONG DU LIEU LOT: $LotNumber" -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "  File Backup JSON: $jsonFile" -ForegroundColor Cyan
    Write-Host "  STB_ElectrodeMixStepInfo : $($dtSteps.Rows.Count) dong" -ForegroundColor Yellow
    Write-Host "  STB_ElectrodeMixInfo     : $($dtMix.Rows.Count) dong" -ForegroundColor Yellow
    Write-Host "  STB_SetInfo              : $($dtSet.Rows.Count) dong" -ForegroundColor Yellow

    # Tao them file SQL Rollback (Restore script) de de phong can hoan tac
    $sqlRestoreFile = Join-Path $backupDir "restore_${LotNumber}_${timestamp}.sql"
    $restoreSql = @"
USE SmartFactoryV2;
GO

-- RESTORE SCRIPT FOR LOT: $LotNumber
-- Backup Date: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Restore STB_ElectrodeMixStepInfo
    DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = '$LotNumber';
"@

    foreach ($row in $dtSteps.Rows) {
        $bInTime = if ($row.BinderInputTime) { "'$($row.BinderInputTime)'" } else { "NULL" }
        $bOutTime = if ($row.BinderOutputTime) { "'$($row.BinderOutputTime)'" } else { "NULL" }
        $restoreSql += @"

    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        '$($row.ElectrodeLotNumber)', '$($row.ElectrodeStep)', $($row.Seq), '$($row.ElectrodeMaterialCode)',
        $($row.InputQty1), $($row.InputQty2), '$($row.MaterialLotNumber)', $bInTime, $bOutTime,
        GETDATE(), N'RESTORE_USER'
    );
"@
    }

    $restoreSql += @"

    COMMIT TRANSACTION;
    PRINT '==> [RESTORE SUCCESS] Da phuc hoi thanh cong du lieu ve trang thai goc!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@Err, 16, 1);
END CATCH;
GO
"@

    $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($sqlRestoreFile, $restoreSql, $utf8WithBom)
    Write-Host "  File SQL Restore         : $sqlRestoreFile" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Green

} catch {
    Write-Error "Loi trong qua trinh backup: $_"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
