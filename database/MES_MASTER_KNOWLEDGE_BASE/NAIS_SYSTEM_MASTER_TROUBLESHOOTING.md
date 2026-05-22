# 📘 NAIS SYSTEM MASTER TROUBLESHOOTING

> Tài liệu tổng hợp các lỗi thực tế đã xử lý, kèm phương pháp trace và script fix.
> Để tra cứu chi tiết theo chủ đề → xem các file KB_0x tương ứng.

---

## 1. LỖI THIẾU THIẾT LẬP VỎ NHÔM (B597)

**Triệu chứng:** `"Không tồn tại thiết lập Vỏ Nhôm của LotNo... với mã Vỏ Nhôm: GBDYAC-004 <<>> ECVT30-367"`

**Root cause:** Bảng `STB_AluCaseMapping_VVT` **KHÔNG TỒN TẠI**. Logic kiểm tra vỏ nhôm được hardcode hoàn toàn bên trong SP `usp_Vietnam_RawMaterialInputHist_uid` bằng IF/NOT IN.

**Trace:**
```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- Ctrl+F tìm: 'Vỏ Nhôm' hoặc 'GBDYAC'
-- Tìm đến đoạn: IF (@MaterialCode = 'ECVT30-367' AND @pRawMaterialBarcode NOT IN (...))
```

**Fix — chỉ có 1 cách:**
```sql
-- Thêm mã vỏ mới vào danh sách NOT IN trong SP
-- Ví dụ đoạn cần sửa:
IF (@MaterialCode = 'ECVT30-367' AND @pRawMaterialBarcode NOT IN ('GBRLAC-004', 'GBDYAC-004'))
BEGIN
    SET @count = 0;
END
-- → Thêm mã vỏ mới: NOT IN ('GBRLAC-004', 'GBDYAC-004', 'MÃ_VỎ_MỚI')
-- → ALTER PROCEDURE để deploy lại
```

---

## 2. LỖI GỘP TÚI BÓNG QTY = 0 (HN544)

**Triệu chứng:** Màn hình HN544 hiển thị Qty = 0 cho các túi vừa gộp, không in được tem.

**Trace:**
```sql
SELECT MaterialLotNo, CurrentQty, InitialQty, CreateUserID
FROM STB_MaterialLotInfo
WHERE MaterialLotNo = 'Mã_Lot_Bị_Lỗi'
-- CurrentQty = 0 nhưng thực tế hàng vẫn còn → SP đã Reset nhầm số lượng về 0
```

**Fix:**
```sql
UPDATE STB_MaterialLotInfo
SET CurrentQty = [Số_Lượng_Thực_Tế],
    InitialQty = [Số_Lượng_Thực_Tế]
WHERE MaterialLotNo = 'Mã_Lot_Cần_Sửa'
```

---

## 3. LỖI VENDOR LOT (F330 — Nhập kho NVL)

**Triệu chứng:** `"Không thể chuyển đổi mã Vendor Lot thành ngày tháng"`

**Root cause:** Nhà cung cấp đổi định dạng mã Lot, hàm `fn_VVT_getdatebyVendorLot_MergeCode` không parse được.

**Trace:**
```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_getdatebyVendorLot_MergeCode'))
-- Đọc logic cắt chuỗi hiện tại
-- VD: 2 ký tự đầu = năm (25=2025), 2 tiếp = tháng, 2 tiếp = ngày
```

**Fix:** Báo anh Tùng cập nhật Function để nhận dạng định dạng mới. Workaround tạm: nhập tay `LotAttr10` bằng SQL sau khi nhập phiếu.

---

## 4. LỖI TRACE KẾ HOẠCH SAI LINE (B450)

**Triệu chứng:** 2 Model khác nhau nhảy chung vào 1 Line trên báo cáo.

**Kỹ thuật Quét cửa sổ thời gian (Time Window):**
```sql
-- Tìm 1 mã DayPlanNo bị sai → lấy CreateUserID và CreateDateTime
-- Quét tất cả kế hoạch của User đó trong vòng 5-10 giây xung quanh
SELECT DayPlanNo, PlanDate, LineCode, MaterialCode, CreateDateTime
FROM STB_DayProdPlan
WHERE CreateUserID = 'ID_Người_Lập'
  AND CreateDateTime BETWEEN '2026-05-16 08:00:00' AND '2026-05-16 08:00:10'
ORDER BY DayPlanNo ASC
```

**Fix:**
- Chưa có sản lượng → Hủy kế hoạch sai tại B450 → Tạo lại đúng Line
- Đã có sản lượng → Dùng script Chuyển Line (KB_03 §5.9)

---

## 5. LỖI POPUP TRỐNG (B270)

**Triệu chứng:** Nhấn vào nút chọn (Popup) nhưng không hiện ra dữ liệu.

**Root cause:** Máy chưa được gán vào Line/Route đó.

```sql
-- Kiểm tra mapping
SELECT * FROM STB_ProductMachine WHERE MachineCode = 'Mã_Máy'
-- Nếu trống → vào B230 thêm mapping
```

**Fix — Thêm mapping Route cho máy:**
```sql
BEGIN TRANSACTION
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT 'MÃ_MÁY', 'MÃ_LINE', r.RouteCode, GETDATE(), 'vinaadmin'
FROM (
    SELECT 'V-22_BG' AS RouteCode UNION ALL SELECT 'V-23_BG' UNION ALL SELECT 'V-24_BG' UNION ALL
    SELECT 'V-25_BG' UNION ALL SELECT 'V-26_BG' UNION ALL SELECT 'V-27_BG' UNION ALL SELECT 'V-28_BG'
) r
WHERE NOT EXISTS (
    SELECT 1 FROM STB_ProductMachine WHERE MachineCode = 'MÃ_MÁY' AND RouteCode = r.RouteCode
)
COMMIT
```

---

## 6. LỖI KHÔNG ĐĂNG NHẬP ĐƯỢC MES

**Triệu chứng:** Màn hình login bị lỗi.

**Fix theo thứ tự:**
1. Chạy file Update trong folder cài đặt → vào lại NAIS
2. Xóa tất cả thư mục trong `C:\AwooSystem` → cài lại từ `http://mes.hycap.co.kr:9952/`
3. Kiểm tra tài khoản DB:
```sql
SELECT UserID, UserName, AllowFlag FROM SmartFramework.dbo.STB_UserInfo WHERE UserID = 'tên_user'
-- AllowFlag = 0 → tài khoản bị khóa → vào Z410 bật lại
```

---

## 7. LỖI B597 — CHECKLIST ĐẦY ĐỦ

```
Theo thứ tự SP usp_Vietnam_RawMaterialInputHist_uid kiểm tra:
□ 1. HOLDING? → SELECT MaterialWarehouseCode FROM STB_MaterialLotInfo (Check 'HOLDING_%')
□ 2. Hết hạn? → Kiểm tra LotAttr10 + MMExtInt01
□ 3. Sai chủng loại? → Kiểm tra BOM có mã NVL đó không (STB_BomDetail)
□ 4. Sai độ dày điện cực? → Kiểm tra MaterialThickness (phải là số nguyên, không có .000)
□ 5. Sai mã Electrolyte? → Kiểm tra CTE eleclyte1 trong SP
□ 6. Thiếu cấu hình Vỏ Nhôm? → Sửa hardcode trong SP (xem §1 trên)
□ 7. Thiếu cấu hình Slitting? → Kiểm tra stb_slittinglocationconfig_vvt
```

**Chi tiết kiểm tra hạn sử dụng NVL:**
```sql
-- Tra cứu nhanh hạn sử dụng của 1 Lot
SELECT
    MDLI.LotID,
    MDLI.LotAttr10 AS [Ngày_SX],
    MM.MMExtInt01 AS [Hạn_Tháng],
    DATEADD(MONTH, MM.MMExtInt01, MDLI.LotAttr10) AS [Ngày_Hết_Hạn],
    CASE WHEN DATEADD(MONTH, MM.MMExtInt01, MDLI.LotAttr10) < GETDATE()
         THEN 'ĐÃ HẾT HẠN' ELSE 'CÒN HẠN' END AS [Trạng_Thái]
FROM STB_MaterialDocLotInfo MDLI
JOIN STB_MaterialMaster MM ON MDLI.MaterialCode = MM.MaterialCode
WHERE MDLI.LotID = 'ML...'

-- Bypass NVL hết hạn (khi QC đã đồng ý)
INSERT INTO stb_vvt_OpenExpiredMaterial
    (MaterialCode, LotID, ExpiredDate, OpenDate, OpenUserID, Remark)
VALUES
    ('mã_nvl', 'lot_id', '2026-04-10', GETDATE(), 'admin', 'QC đã kiểm tra OK')
```

---

## 💡 NGUYÊN TẮC VÀNG KHI TỰ SỬA

1. **Luôn SELECT trước khi UPDATE** — đảm bảo WHERE chỉ tác động đúng dòng cần sửa
2. **Dùng BEGIN TRAN ... ROLLBACK/COMMIT** khi sửa dữ liệu quan trọng
3. **Sửa đủ bảng** — thiếu 1 bảng gây lệch dữ liệu (VD: F330 cần sửa 3 bảng)
4. **Ghi log thao tác** — để audit sau

*Cập nhật: 2026-05-22*
