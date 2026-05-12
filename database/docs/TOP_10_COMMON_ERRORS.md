# 🔥 TOP 10 COMMON ERRORS - QUICK REFERENCE

> **Mục đích:** Giải pháp nhanh cho 10 lỗi thường gặp nhất
> **Tần suất:** Chiếm 80% tất cả bug reports
> **Thời gian giải quyết:** < 2 phút với reference này
> **Cập nhật:** 2026-05-12

---

## 1️⃣ LỖI: Barcode không tồn tại trong STB_SetInfo

**Triệu chứng:** "Barcode không tìm thấy", "Lot không tồn tại"

**Nguyên nhân thường gặp:**
- User nhập sai Barcode
- Barcode chưa được tạo (chưa in tem)
- ControlNo khác với Barcode

**Giải pháp nhanh:**
```sql
-- Check 1: Tìm theo Barcode
SELECT * FROM STB_SetInfo WHERE Barcode = 'VE260506-001'

-- Check 2: Tìm theo ControlNo (nếu Barcode sai)
SELECT * FROM STB_SetInfo WHERE ControlNo = 'VE260506-001'

-- Check 3: Tìm gần đúng (LIKE)
SELECT * FROM STB_SetInfo WHERE Barcode LIKE '%260506%'
```

**KB liên quan:** KB_03, KB_04

---

## 2️⃣ LỖI: "부임공정 실적처리 에러" (Lỗi xử lý kết quả công đoạn tiếp theo)

**Triệu chứng:** Lỗi khi hoàn thành công đoạn, Actual Qty = 0

**Nguyên nhân thường gặp:**
- Barcode chưa qua các công đoạn trước
- Missing record trong STB_ProdRouteHist
- ControlNo mapping sai

**Giải pháp nhanh:**
```sql
-- Check routing history
SELECT * FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
ORDER BY CreateDateTime

-- Nếu thiếu record → Xem KB_03 để thêm
-- Nếu mapping sai → Check ControlNo vs Barcode
```

**KB liên quan:** KB_03

---

## 3️⃣ LỖI: Không gộp Box được (HN523/B523)

**Triệu chứng:** "Không gộp được", "Lot đã gộp rồi"

**Nguyên nhân thường gặp:**
- F110 chưa cấu hình (IsLotUse = 0)
- QC chưa Pass (LotDecisionResult = NULL/Fail)
- Lot đã gộp vào Box khác

**Giải pháp nhanh:**
```sql
-- Check 1: F110 cấu hình
SELECT * FROM STB_MaterialStockAttributeInfo WHERE MaterialCode = 'MÃ_VẬT_TƯ'

-- Check 2: QC status
SELECT LotDecisionResult, IsDefect FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE'

-- Check 3: Đã gộp chưa
SELECT PackingID, CurrentQty FROM STB_MaterialLotInfo WHERE LotNo = 'MÃ_LOT'
```

**KB liên quan:** KB_02, KB_05

---

## 4️⃣ LỖI: Số lượng sai ở B789 (Packing Time)

**Triệu chứng:** Số lượng in tem sai, Packing Qty âm

**Nguyên nhân thường gặp:**
- User nhập sai số lượng
- SP logic lỗi
- Duplicate record

**Giải pháp nhanh:**
```sql
-- Tìm record sai
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'MÃ_LOT'

-- Sửa số lượng
UPDATE STB_SavePackingTime_VVT
SET PackQty = [SỐ LƯỢNG ĐÚNG]
WHERE LotNo = 'MÃ_LOT' AND id = [ID]

-- Xóa nếu cần
DELETE FROM STB_SavePackingTime_VVT
WHERE LotNo = 'MÃ_LOT' AND id = [ID]
```

**KB liên quan:** KB_03, KB_04

---

## 5️⃣ LỖI: B597 báo lỗi chuỗi điện cực

**Triệu chứng:** "Chưa CONFIG trong bảng STB_SLITTINGLOCATIONCONFIG_VVT"

**Nguyên nhân thường gặp:**
- Độ dày thiết lập sai (200 vs 200.000000)
- Model chưa có trong config
- Lot slitting không mapping

**Giải pháp nhanh:**
```sql
-- Check config
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'

-- Check độ dày
SELECT MBIExtText04 FROM STB_ModelBasicInfo WHERE ModelCode = 'ECVT30-270'

-- Nếu cần → Thêm exception vào SP hoặc thêm config
```

**KB liên quan:** KB_05

---

## 6️⃣ LỖI: Kho nhập sai Warehouse (F330)

**Triệu chứng:** Hàng vào sai kho, cần chuyển

**Nguyên nhân thường gặp:**
- User chọn sai warehouse khi nhập
- Logic auto-assign sai

**Giải pháp nhanh:**
```sql
-- Cần update đồng thời 3 bảng:
-- 1. STB_MaterialDocInfo
UPDATE STB_MaterialDocInfo
SET TargetMaterialWarehouseCode = 'ROH_HN_WH'
WHERE MaterialDocNo = '250221000220'

-- 2. STB_MaterialDocLotInfo
UPDATE STB_MaterialDocLotInfo
SET MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN (...)

-- 3. STB_MaterialLotInfo
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN (...)
```

**KB liên quan:** KB_02

---

## 7️⃣ LỖI: Model mới không hiện Vol/Farad

**Triệu chứng:** In tem thiếu thông số kỹ thuật

**Nguyên nhân thường gặp:**
- Model chưa có trong STB_ModelBasicInfo
- MaterialTypeCode sai
- Views không hiển thị được

**Giải pháp nhanh:**
```sql
-- Check Model có trong MaterialMaster chưa
SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'RDMD00-358'

-- Thêm vào ModelBasicInfo nếu chưa có
INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, ...)
VALUES (...)

-- Hoặc sửa MaterialTypeCode
UPDATE STB_MaterialMaster SET MaterialTypeCode = '...' WHERE MaterialCode = '...'
```

**KB liên quan:** KB_06

---

## 8️⃣ LỖI: Không in được tem (B450)

**Triệu chứng:** "Không in được", "Template không tìm thấy"

**Nguyên nhân thường gặp:**
- Mẫu tem chưa được approve
- FormatName sai
- Label config thiếu

**Giải pháp nhanh:**
```sql
-- Kiểm tra mẫu tem
SELECT FormatName, IsApproval, ApplyDate 
FROM SmartFramework.dbo.STB_LabelInfo 
WHERE FormatName LIKE '%HN%' AND IsApproval = 1

-- Nếu chưa có → Vào A460 thêm mẫu tem
```

**KB liên quan:** KB_01, KB_04

---

## 9️⃣ LỖI: FIFO bị chặn

**Triệu chứng:** "Lot cũ chưa xuất", "Phải xuất Lot cũ trước"

**Nguyên nhân thường gặp:**
- Lot cũ còn tồn kho
- Logic FIFO trong SP
- Holding lot

**Giải pháp nhanh:**
```sql
-- Tìm Lot cũ nhất
SELECT TOP 5 LotID, MaterialCode, CurrentQty, CreateDateTime
FROM STB_MaterialLotInfo
WHERE MaterialCode = 'GBAKAC-004'
    AND CurrentQty > 0
    AND MaterialWarehouseCode NOT LIKE '%HOLDING%'
ORDER BY CreateDateTime ASC

-- Check Holding
SELECT * FROM STB_MaterialLotInfo
WHERE LotID = 'ML20260501000001'
    AND MaterialWarehouseCode LIKE '%HOLDING%'
```

**KB liên quan:** KB_02

---

## 🔟 LỖI: Groupware - Không thấy PO trên MES

**Triệu chứng:** PO đã tạo trên Groupware nhưng không hiện trên B310/B450

**Nguyên nhân thường gặp:**
- PO chưa được "Xác nhận lô hàng"
- BOM Version không đúng (khác 2001)
- Chưa đồng bộ xuống MES

**Giải pháp nhanh:**
```sql
-- Check PO trên MES
SELECT * FROM STB_ProductionOrderInfo WHERE PONo = '260505000026'

-- Nếu không có → Check Groupware:
-- 1. Trạng thái PO đã chuyển sang "Sản xuất" chưa?
-- 2. BOM Version có đúng 2001 không?
-- 3. Đã đồng bộ xuống MES chưa?
```

**KB liên quan:** KB_07

---

## 🎯 QUICK DECISION MATRIX

| Lỗi | Check đầu tiên | Tool | Thời gian |
|-----|----------------|------|-----------|
| Barcode không tồn tại | SELECT STB_SetInfo | debug_queries.sql #2 | 30s |
| Lỗi công đoạn tiếp theo | SELECT STB_ProdRouteHist | debug_queries.sql #1 | 30s |
| Không gộp Box | Check F110 + QC | auto_check_common_issues.ps1 | 1m |
| Số lượng sai B789 | SELECT STB_SavePackingTime_VVT | debug_queries.sql #3 | 30s |
| Lỗi điện cực B597 | Check slitting config | KB_05 + debug_queries.sql #7 | 1m |
| Kho sai Warehouse | Check 3 bảng | KB_02 | 2m |
| Không Vol/Farad | Check ModelBasicInfo | KB_06 + auto_check_common_issues.ps1 | 1m |
| Không in tem B450 | Check STB_LabelInfo | KB_01 | 30s |
| FIFO bị chặn | Check Lot cũ nhất | debug_queries.sql #4 | 30s |
| Groupware không thấy PO | Check PO status | KB_07 | 1m |

---

## 🚀 AUTO-FIX SCRIPTS

### Script 1: Auto-check barcode existence
```powershell
.\auto_debug_barcode.ps1 -Barcode "VE260506-001"
```

### Script 2: Auto-check common issues
```powershell
.\auto_check_common_issues.ps1 -Barcode "VE260506-001" -MaterialCode "7R5RL470MB9XXXT101"
```

---

**Sử dụng reference này để giải quyết 80% lỗi trong < 2 phút!**
