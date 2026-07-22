<!--
AI-READY METADATA
Purpose: PowerShell scripts, SQL templates, debug recipes, impact checks và công cụ tự động cho AI Agent
Scope: Execution Scripts & Debug Recipes
Single Source of Truth: SKILLS.md (SQL & Debug Scripts)
Related Files:
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [KNOWLEDGE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/KNOWLEDGE.md)
  - [run_query.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/run_query.ps1)
  - [verify_bug.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/powershell_tools/verify_bug.ps1)
  - [sp_impact.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/powershell_tools/sp_impact.ps1)
  - [log_hotfix.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/powershell_tools/log_hotfix.ps1)
-->

# ⚡ SKILLS — Vinatech MES Agent (PowerShell & SQL Templates)

> **Mục đích:** Các script template & công cụ tự động hóa sẵn sàng dùng.

---

## 1. 🔌 KẾT NỐI DB & CÔNG CỤ TỰ ĐỘNG HÓA TỐI ƯU TOKEN

Dùng trực tiếp các công cụ PowerShell trong `AI_AGENT_CONFIG/powershell_tools/`:

```powershell
# 1. Auto-Verify dữ liệu lỗi theo Screen ID (Tiết kiệm 95% Token)
.\AI_AGENT_CONFIG\powershell_tools\verify_bug.ps1 -ScreenID "B597" -Key "ML20260713000165"

# 2. Phân tích ảnh hưởng chéo của SP trước khi sửa code
.\AI_AGENT_CONFIG\powershell_tools\sp_impact.ps1 -SPName "usp_Vietnam_RawMaterialInputHist_uid"

# 3. Ghi nhật ký Hotfix tự động vào HOTFIX_LOG.md và KI
.\AI_AGENT_CONFIG\powershell_tools\log_hotfix.ps1 -ScreenID "B597" -Issue "Tràn chuỗi NVL" -RootCause "NVARCHAR(100)" -FixSQL "ALTER TABLE..."

# 4. Truy vấn dạng bảng tiêu chuẩn
.\run_query.ps1 -Query "SELECT TOP 10 Barcode, MaterialCode FROM STB_SetInfo WITH(NOLOCK)"
```

---

## 2. 🔍 DEBUG BARCODE (SQL)

```sql
-- Step 1: Trạng thái Barcode
SELECT Barcode, ControlNo, MaterialCode, ProdQty, 
       LotDecisionResult, IsDefect, DefectQty, IsProdFinish, InputLineCode
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '@BARCODE';

-- Step 2: Routing History  
SELECT ProcSeq, RouteCode, ProdQty, JobDate, CreateDateTime, CreateUserID
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '@BARCODE')
ORDER BY CreateDateTime ASC;

-- Step 3: Packing Info
SELECT MaterialLotNo, LotNo, MaterialCode, CurrentQty, PackingID
FROM STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotNo = '@BARCODE';

-- Step 4: NVL Input (V-23/V-24)
SELECT Barcode, RouteCode, MaterialCode, RawMaterialBarcode, CreateDateTime
FROM STB_RawMaterialInputHist WITH(NOLOCK)
WHERE Barcode = '@BARCODE';
```

---

## 3. 🏭 TÌM SP ĐẰNG SAU MÀN HÌNH

```sql
-- Step 1: Tìm ScreenName từ TCode
SELECT Name AS ScreenName, Caption, TCode 
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE TCode = '@TCODE';

-- Step 2: Tìm SP tương ứng
SELECT ObjectName, Caption, ObjectType, Description
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = '@SCREEN_NAME';
```

---

## 4. 📦 CHECK GỘP BOX [B523]

```sql
-- 1. F110 — IsLotUse?
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo WHERE MaterialCode = '@MAT_CODE';

-- 2. QC Pass?
SELECT Barcode, LotDecisionResult, IsDefect
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '@BARCODE';

-- 3. Đã gộp chưa?
SELECT LotNo, PackingID, CurrentQty
FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = '@BARCODE';

-- 4. Tiêu chuẩn đóng gói?
SELECT * FROM STB_PackingStandard WHERE MaterialTypeCode = 'FERT';
```

---

## 5. 🔐 ĐỌC SP SOURCE

```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_TenSP'));
-- Hoặc:
SELECT definition FROM sys.sql_modules 
WHERE object_id = OBJECT_ID('usp_TenSP');
```

---

## 6. 🏭 CHECK QC STATUS

```sql
SELECT CIDH.CommInspDocNo, CIDH.CommInspResult, CIDH.CreateDateTime
FROM STB_CommInspDocHistory CIDH WITH(NOLOCK)
JOIN STB_SetInfo SI WITH(NOLOCK) ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = '@BARCODE'
ORDER BY CIDH.CreateDateTime DESC;
```

---

## 7. 📋 CHECK BLOCK SESSION

```sql
SELECT blocking_session_id AS [Blocker], session_id AS [Blocked],
       wait_time/1000 AS [WaitSec], wait_type
FROM sys.dm_exec_requests WHERE blocking_session_id <> 0;
```

---

## 8. 💡 LESSONS LEARNED

1. **Gate 20 phút KHÔNG hoạt động** — Bug trong `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`: dùng `= Null` thay vì `IS NULL`
2. **STB_MaterialHoldInfo KHÔNG tồn tại** — HOLD dùng `MaterialWarehouseCode = 'HOLDING_*'`
3. **CompleteRoute='1' set cho MỌI route** — Không dùng để xác định route cuối, dùng `IsOutputRoute`
4. **STB_BarrelBarcodeInfo KHÔNG tồn tại** — Bảng thực: `STB_VietNam_CheckBarcode_2624`
5. **STB_AluCaseMapping_VVT KHÔNG tồn tại** — Logic vỏ nhôm hardcode trong SP
6. **Git root là Desktop** — Luôn scope git commands vào `MES/`
7. **Electrode SP naming** — `usp_ElectrodeStep_get` (không phải `usp_ElectrodeStep_Vietnam`)
8. **Packing SP** — `usp_Vietnam_DoProcessProdPacking_VVT` (không phải `usp_DeProcessProdPacking_VVT`)
9. **WarehouseCode ≠ MaterialWarehouseCode** — Cột đúng là `MaterialWarehouseCode` trong `STB_MaterialLotInfo`
10. **usp_DoCreateSerial = 470 callers** — KHÔNG sửa SP này trừ khi dùng `sp_impact.ps1` kiểm tra
11. **STB_VVT_ESRDATA = 398M rows / 61GB** — Luôn WHERE cụ thể + WITH(NOLOCK)
12. **STB_MaterialMaster = 874 SPs đọc** — Sửa cột = impact rất rộng
13. **CRLF warning** — Không mass-edit KB .md files bằng replace_file_content (risk corruption).
