$f = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Vinatech_MES_Complete_DataFlow.md"
$lines = Get-Content $f -Encoding UTF8
$total = $lines.Count
Write-Host "Total lines: $total"

# Tim dong co "Infrastructure"
$infraLine = -1
for ($i = 0; $i -lt $total; $i++) {
    if ($lines[$i] -like "*Infrastructure*") {
        $infraLine = $i
        Write-Host "Found at line $($i+1): $($lines[$i])"
        break
    }
}

if ($infraLine -lt 0) { Write-Host "Not found!"; exit }

# Lay phan truoc (lines 0 den infraLine-1)
$before = $lines[0..($infraLine-1)] -join "`r`n"

$newSection = @"

## Infrastructure & Plant Codes

| Thanh phan | Chi tiet |
|-----------|---------|
| **Server** | ``dbserver.hycap.co.kr,5398`` |
| **Database chinh** | ``SmartFactoryV2`` |
| **Database phu** | ``SmartFramework`` (STB_LabelInfo, usp_DoCreateSerial) |
| **Auth** | SQL Server Auth: ``vinaadmin`` |
| **Audit** | ``STB_ProcedureLog`` ghi log moi thuc thi SP quan trong |
| **Batch processing** | OPENXML + CURSOR pattern cho bulk operations |
| **Atomicity** | BEGIN TRAN / ROLLBACK TRAN cho operations da bang |

### Nha may (Plant Codes)

| Code | Ten | WorkCenterCode | Route Prefix | Ghi chu |
|------|-----|---------------|-------------|---------|
| VNT | Nha may 1 - Binh Duong | VNT | V-xx | Winding -> gui Korea HQ |
| VVT | Nha may 2 - Binh Duong | VVT | E-xx | Full production cycle |
| HN | **Nha may 3 - Ha Nam** (PHAT HIEN MOI) | VVT_F3 | E-xx | Dung FinishGoodMESInstock_HN |

QUAN TRONG: WorkCenterCode='VVT_F3' dung label format 'NewVietNam_HN' trong usp_DivideAndPrintPackagingLabels. Nha may Ha Nam CHUA duoc document truoc day!

### Objects dac biet

| Object | Loai | Vai tro |
|--------|------|---------|
| ``FinishGoodMESInstock_HN`` | VIEW | FG Ha Nam - Phase 5 label printing |
| ``SmartFramework.dbo.STB_LabelInfo`` | TABLE DB khac | Template nhan in |
| ``stb_vvt_OpenExpiredMaterial`` | TABLE | Vat tu het han da phe duyet (FIFO bypass) |
| ``dbo.fnGetJobDateShiftTime`` | FUNCTION | Tinh JobDate/ShiftCode tu ProcessDateTime |

Cross-Factory: VNT thuc hien Winding -> ban thanh pham gui Korea HQ xu ly tiep.
Logic: IF LineCompanyCode='VNT' THEN GRWarehouse = lookup REPLACE(RouteCode,'V-','E-')
Luu y: GR tai VN location KHONG tu dong vao danh sach nhap du kien - phai lam thu cong.

---

## SP Khong tim thay trong Database

| SP | Ghi chu |
|----|---------|
| ``usp_ExportWarehouseFinshGood_RD_HN_uid`` | Khong ton tai trong SmartFactoryV2 |

---

## Khoang trong ngoai 21 SPs da phan tich

| Buoc | Tables lien quan | Cach thuc hien |
|------|-----------------|---------------|
| Tao lenh SX (PONo) | STB_ProductionOrderInfo, STB_ProductionOrderRouting, STB_ProductionOrderBom | SP khac / UI MES |
| Lap ke hoach ngay | STB_DayPlanInfo, STB_DayPlanDetail | Nhap tay / MRP |
| In barcode SX | STB_SetInfo (ControlNo) | SP khac / UI |
| Quan ly ca | fnGetJobDateShiftTime function | DB function |

---

*Tai lieu tong hop tu 21 SPs trong SmartFactoryV2 - 2026-04-08. Bo sung: Phase 2.5, Nha may Ha Nam (VVT_F3), cross-factory flow.*
"@

$full = $before + $newSection
$bytes = [System.Text.Encoding]::UTF8.GetBytes($full)
[System.IO.File]::WriteAllBytes($f, $bytes)
$newLines = (Get-Content $f -Encoding UTF8).Count
Write-Host "Done. New total lines: $newLines"
