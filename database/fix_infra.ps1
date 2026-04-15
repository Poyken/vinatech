$f = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Vinatech_MES_Complete_DataFlow.md"
$txt = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$marker = "## " + [char]0x1F3D7 + [char]0xFE0F + " Infrastructure"
$idx = $txt.IndexOf($marker)
if ($idx -lt 0) { Write-Host "Not found"; exit }

$before = $txt.Substring(0, $idx)
$after = @'
## Infrastructure & Plant Codes

| Thanh phan | Chi tiet |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database chinh** | `SmartFactoryV2` |
| **Database phu** | `SmartFramework` (STB_LabelInfo, usp_DoCreateSerial) |
| **Auth** | SQL Server Auth: `vinaadmin` |
| **Audit** | `STB_ProcedureLog` - log moi thuc thi SP |
| **Batch processing** | OPENXML + CURSOR pattern |
| **Atomicity** | BEGIN TRAN / ROLLBACK TRAN |

### Nha may (Plant Codes)

| Code | Ten | WorkCenterCode | Ghi chu |
|------|-----|---------------|---------|
| **VNT** | Nha may 1 - Binh Duong | VNT | Route prefix: V-xx; Winding -> Korea HQ |
| **VVT** | Nha may 2 - Binh Duong | VVT | Route prefix: E-xx; Full production cycle |
| **HN** | Nha may 3 - **Ha Nam** (PHAT HIEN MO!) | VVT_F3 | Dung FinishGoodMESInstock_HN view |

> **QUAN TRONG:** WorkCenterCode='VVT_F3' dung label format 'NewVietNam_HN' trong usp_DivideAndPrintPackagingLabels. Nha may Ha Nam CHUA duoc document truoc day!

### Objects dac biet

| Object | Loai | Vai tro |
|--------|------|---------|
| `FinishGoodMESInstock_HN` | VIEW | FG Ha Nam - dung trong Phase 5 label printing |
| `SmartFramework.dbo.STB_LabelInfo` | TABLE (DB khac) | Template nhan in |
| `stb_vvt_OpenExpiredMaterial` | TABLE | Vat tu het han da phe duyet (FIFO bypass) |
| `dbo.fnGetJobDateShiftTime` | FUNCTION | Tinh JobDate/ShiftCode tu ProcessDateTime |

### Cross-Factory: VNT Winding -> Korea HQ

VNT thuc hien Winding -> ban thanh pham gui Korea HQ (ban사) xu ly tiep.
Logic: neu LineCompanyCode='VNT' -> GRWarehouse = lookup REPLACE(RouteCode,'V-','E-')
Luu y: GR tai VN location KHONG tu dong vao danh sach nhap du kien -> lam thu cong.

---

## SP Khong tim thay trong Database

| SP | Ghi chu |
|----|---------|
| `usp_ExportWarehouseFinshGood_RD_HN_uid` | Khong ton tai trong SmartFactoryV2 |

---

## Khoang trong ngoai 21 SPs da phan tich

| Buoc | Tables lien quan | Cach thuc hien |
|------|-----------------|---------------|
| Tao lenh SX (PONo) | STB_ProductionOrderInfo, STB_ProductionOrderRouting, STB_ProductionOrderBom | SP khac / UI MES |
| Lap ke hoach ngay | STB_DayPlanInfo, STB_DayPlanDetail | Nhap tay / MRP |
| In barcode SX | STB_SetInfo (ControlNo) | SP khac / UI |
| Quan ly ca | fnGetJobDateShiftTime | DB function |
| HN FG tracking | FinishGoodMESInstock_HN | VIEW read-only |

---

*Tai lieu tong hop tu 21 SPs trong SmartFactoryV2 - 2026-04-08. Bo sung: Phase 2.5, Nha may Ha Nam (VVT_F3), cross-factory flow.*
'@

$newContent = $before + $after
[System.IO.File]::WriteAllText($f, $newContent, [System.Text.Encoding]::UTF8)
$lines = (Get-Content $f).Count
Write-Host "Done. Total lines: $lines"
