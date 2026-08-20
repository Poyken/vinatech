# check_sp_sync.ps1 — Kiem tra dong bo Stored Procedure & Function giua Workspace Local va Database Production

param (
    [string]$Path = ".\sql",
    [string]$SPName,
    [switch]$Pull,
    [switch]$Detailed
)

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

# Ham chuan hoa code SQL de so sanh chinh xac noi dung
function Normalize-SqlContent([string]$sql) {
    if ([string]::IsNullOrEmpty($sql)) { return "" }
    
    # 1. Chuan hoa line endings
    $normalized = $sql -replace "\r\n", "`n" -replace "\r", "`n"
    
    # 2. Chuan hoa header CREATE / ALTER
    $normalized = $normalized -replace "(?mi)^\s*CREATE\s+OR\s+ALTER\s+", "ALTER "
    $normalized = $normalized -replace "(?mi)^\s*CREATE\s+", "ALTER "
    
    # 3. Loai bo khoang trang dau/cuoi moi dong
    $lines = $normalized -split "`n" | ForEach-Object { $_.TrimEnd() }
    $normalized = ($lines -join "`n").Trim()
    
    return $normalized
}

# Ham tinh ma bam SHA256
function Get-StringHash([string]$str) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($str)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha256.ComputeHash($bytes)
    return [BitConverter]::ToString($hashBytes) -replace "-"
}

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " VINATECH MES - SP & FUNCTION SYNC CHECKER" -ForegroundColor Cyan
Write-Host " Server: $($config.Server) | Database: $($config.Database)" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan

$conn = Get-DbConnection
try {
    $conn.Open()
} catch {
    Write-Error "Khong the ket noi toi Database: $_"
    exit 1
}

# Tap hop danh sach file can kiem tra
$filesToCheck = @()

if ($SPName) {
    # Kiem tra theo ten SP cu the
    $specificFile = Get-ChildItem -Path $PSScriptRoot -Filter "$SPName.sql" -Recurse | Select-Object -First 1
    if ($specificFile) {
        $filesToCheck += $specificFile
    } else {
        Write-Host "Khong tim thay file local '$SPName.sql'. Kiem tra truc tiep tren DB..." -ForegroundColor Yellow
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT o.name, o.type_desc, o.modify_date, m.definition FROM sys.objects o LEFT JOIN sys.sql_modules m ON o.object_id = m.object_id WHERE o.name = @objName;"
        $cmd.Parameters.AddWithValue("@objName", $SPName) | Out-Null
        $reader = $cmd.ExecuteReader()
        if ($reader.Read()) {
            $dbName = $reader["name"]
            $dbType = $reader["type_desc"]
            $dbModDate = [DateTime]$reader["modify_date"]
            Write-Host " [DB EXISTS] Object '$dbName' ($dbType) - ModifyDate tren DB: $($dbModDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Green
            $reader.Close()
            if ($Pull) {
                $procDir = Join-Path $PSScriptRoot "sql\procedures"
                if (!(Test-Path $procDir)) { New-Item -ItemType Directory -Force -Path $procDir | Out-Null }
                $outPath = Join-Path $procDir "$SPName.sql"
                $cmdDef = $conn.CreateCommand()
                $cmdDef.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('$SPName');"
                $defn = $cmdDef.ExecuteScalar()
                [System.IO.File]::WriteAllText($outPath, $defn, (New-Object System.Text.UTF8Encoding $true))
                Write-Host " Da keo ban moi nhat tu DB ve: $outPath" -ForegroundColor Green
            }
        } else {
            Write-Host " Khong tim thay Object '$SPName' trong Database!" -ForegroundColor Red
            $reader.Close()
        }
        $conn.Close()
        exit 0
    }
} else {
    # Quet toan bo file trong thu muc
    $targetPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $PSScriptRoot $Path }
    if (Test-Path $targetPath) {
        $filesToCheck = Get-ChildItem -Path $targetPath -Filter "*.sql" -Recurse | Where-Object { $_.FullName -notmatch "\\backup\\" }
    } else {
        Write-Host "Thu muc '$targetPath' khong ton tai." -ForegroundColor Red
        $conn.Close()
        exit 1
    }
}

if ($filesToCheck.Count -eq 0) {
    Write-Host "Khong co file .sql nao trong thu muc '$Path' de kiem tra." -ForegroundColor Yellow
    $conn.Close()
    exit 0
}

Write-Host "Dang quet va so sanh $($filesToCheck.Count) file SQL voi Database..." -ForegroundColor Gray
Write-Host ""

$results = @()
$matchCount = 0
$outOfSyncCount = 0
$notInDbCount = 0

foreach ($file in $filesToCheck) {
    $relativePath = $file.FullName.Replace($PSScriptRoot, "").TrimStart("\")
    $localContent = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # 1. Trich xuat ten object tu cu phap CREATE/ALTER hoac tu ten file
    $objectName = ""
    if ($localContent -match "(?mi)^\s*(?:CREATE|ALTER)\s+(?:OR\s+ALTER\s+)?(?:PROCEDURE|PROC|FUNCTION|VIEW)\s+(?:\[?dbo\]?\.)?\[?([a-zA-Z0-9_#]+)\]?") {
        $objectName = $matches[1]
    } else {
        # Fallback ten file (bo .sql)
        $objectName = $file.BaseName
    }
    
    # 2. Truy van thong tin object tu sys.objects + sys.sql_modules
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT o.name, o.type_desc, o.modify_date, m.definition FROM sys.objects o JOIN sys.sql_modules m ON o.object_id = m.object_id WHERE o.name = @objName;"
    $cmd.Parameters.AddWithValue("@objName", $objectName) | Out-Null
    
    $reader = $cmd.ExecuteReader()
    $dbObj = $null
    if ($reader.Read()) {
        $dbObj = @{
            Name = $reader["name"].ToString()
            TypeDesc = $reader["type_desc"].ToString()
            ModifyDate = [DateTime]$reader["modify_date"]
            Definition = $reader["definition"].ToString()
        }
    }
    $reader.Close()
    
    if ($null -eq $dbObj) {
        # Khong tim thay trong DB (file script/patch hoac temp)
        $notInDbCount++
        $results += [PSCustomObject]@{
            File = $relativePath
            ObjectName = if ($objectName) { $objectName } else { "N/A" }
            Type = "SCRIPT / PATCH"
            DBModifyDate = "--"
            LocalWriteTime = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            Status = "NOT_IN_DB"
        }
    } else {
        # Chuan hoa va so sanh hash
        $normLocal = Normalize-SqlContent $localContent
        $normDb = Normalize-SqlContent $dbObj.Definition
        
        $localHash = Get-StringHash $normLocal
        $dbHash = Get-StringHash $normDb
        
        $isMatch = ($localHash -eq $dbHash)
        $status = ""
        
        if ($isMatch) {
            $matchCount++
            $status = "MATCH (SYNCED)"
        } else {
            $outOfSyncCount++
            if ($dbObj.ModifyDate -gt $file.LastWriteTime.AddMinutes(5)) {
                $status = "OUT_OF_SYNC (DB_NEWER)"
            } else {
                $status = "OUT_OF_SYNC (DIFF)"
            }
            
            # Tu dong keo tu DB neu co co -Pull
            if ($Pull) {
                [System.IO.File]::WriteAllText($file.FullName, $dbObj.Definition, (New-Object System.Text.UTF8Encoding $true))
                $status += " -> PULLED"
            }
        }
        
        $results += [PSCustomObject]@{
            File = $relativePath
            ObjectName = $dbObj.Name
            Type = $dbObj.TypeDesc
            DBModifyDate = $dbObj.ModifyDate.ToString("yyyy-MM-dd HH:mm")
            LocalWriteTime = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            Status = $status
        }
    }
}

$conn.Close()

# In bang ket qua
Write-Host ("{0,-38} {1,-32} {2,-17} {3,-17} {4}" -f "FILE LOCAL", "OBJECT DB", "DB MODIFY", "LOCAL TIME", "TRANG THAI") -ForegroundColor White
Write-Host ("-" * 125) -ForegroundColor DarkGray

foreach ($r in $results) {
    $color = "White"
    if ($r.Status -like "*MATCH*") {
        $color = "Green"
    } elseif ($r.Status -like "*OUT_OF_SYNC*") {
        $color = "Red"
    } elseif ($r.Status -eq "NOT_IN_DB") {
        $color = "DarkGray"
    }
    
    Write-Host ("{0,-38} {1,-32} {2,-17} {3,-17} {4}" -f $r.File, $r.ObjectName, $r.DBModifyDate, $r.LocalWriteTime, $r.Status) -ForegroundColor $color
}

Write-Host ("-" * 125) -ForegroundColor DarkGray
Write-Host ""
Write-Host "TONG KET DONG BO:" -ForegroundColor Cyan
Write-Host "  [OK] DONG BO (Khop 100% voi DB): $matchCount file" -ForegroundColor Green
if ($outOfSyncCount -gt 0) {
    Write-Host "  [!] LECH CODE (Out of Sync):     $outOfSyncCount file (Chay '.\check_sp_sync.ps1 -Pull' de cap nhat ban moi nhat tu DB)" -ForegroundColor Red
} else {
    Write-Host "  [!] LECH CODE (Out of Sync):     0 file" -ForegroundColor Gray
}
Write-Host "  [i] SCRIPT / PATCH (Khong co tren DB): $notInDbCount file" -ForegroundColor DarkGray
Write-Host "======================================================================" -ForegroundColor Cyan
