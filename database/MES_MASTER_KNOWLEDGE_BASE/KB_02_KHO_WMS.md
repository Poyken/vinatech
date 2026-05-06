# KB_02 — Kho Nguyên Vật Liệu (WMS)

> **Màn hình liên quan:** F330, F312, F430, F110, F721
> ← [Về INDEX](KB_INDEX.md)

---

## 4. 📦 Kho Nguyên Vật Liệu (WMS)

### 4.1 Tìm kiếm theo mã nguyên liệu ra cả danh sách (F721)

**Nguyên nhân:** Điều kiện tìm kiếm trong SP bị sai.

**Cách xử lý:** Vào `usp_vvt_MaterialLotInfo_get` → Kiểm tra lại điều kiện tìm kiếm.

---

### 4.2 Không tìm thấy mã lot khi tìm kiếm ở C512

- **TH1:** Liên hệ anh Huy để anh thêm thông tin model ở màn **B410**.
- **TH2 (Hà Nam):** Các mã test tháng 12 bắt đầu từ Route `VE02` nên không hiện.

---

### 4.3 Chỉnh lại Kho bị nhập sai ở màn F330

> ⚠️ Phải update đồng thời **3 bảng**: `STB_MaterialDocInfo`, `STB_MaterialDocDetail`, `STB_MaterialDocLotInfo` và `STB_MaterialLotInfo`.

```sql
-- B1: Xem và sửa Header
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250221000220'
UPDATE STB_MaterialDocInfo
SET TargetMaterialWarehouseCode = 'ROH_HN_WH'
WHERE MaterialDocNo = '250221000220'

-- B2: Tìm các LotID trong phiếu
SELECT * FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250221000220'

-- B3: Update tất cả các LotID (thay các LotID vào IN)
UPDATE STB_MaterialDocLotInfo
SET MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN (...)

UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN (...)
```

---

### 4.4 Chỉnh Code NVL nhập sai ở màn F312

> **Cột "Số tài liệu"** = `MaterialDocNo`. Sửa ở 2 bảng: `STB_MaterialDocDetail` và `STB_MaterialDocLotInfo`.

```sql
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocDetail WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250806000399'

-- Sau khi xác định → UPDATE MaterialCode tại STB_MaterialDocDetail và STB_MaterialDocLotInfo
```

---

### 4.5 Sửa số lượng màn F312 (Kho chị Xuân)

```sql
UPDATE STB_MaterialDocDetail
SET RequestQty = 200000, AllowQty = 200000, PickingAssignQty = 200000
WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0'
```

---

### 4.6 Sửa ngày xuất màn F430

```sql
-- Xem trước
SELECT * FROM STB_MaterialWarehouseInOutHist
WHERE LotID IN ('ML20250620000036', 'ML20250520000061', 'ML20250527000412')

-- Cập nhật ngày xuất (SP: usp_MaterialWarehouseInOutHist_get)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2025-06-30' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE LotID IN ('ML20250620000036', 'ML20250520000061', 'ML20250527000412')
```

---

### 4.7 Chỉnh sửa từ kho Holding ra kho chính (Theo yêu cầu chị Phượng)

> Không cần xóa lịch sử xuất nhập — chỉ cần chuyển mã kho.

```sql
-- Xem dữ liệu
SELECT * FROM STB_MaterialWarehouseInOutHist WHERE LotID = 'ML20250430000174'
SELECT * FROM STB_MaterialLotInfo WHERE LotID = 'ML20250430000174'

-- Cập nhật lịch sử xuất
UPDATE STB_MaterialWarehouseInOutHist
SET TargetMaterialWarehouseCode = 'ROH_VN_WH'
WHERE LotID = 'ML20250430000174'

-- Cập nhật trạng thái hiện tại
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_VN_WH', MaterialLocationCode = 'ROH_VN_WH_01'
WHERE LotID = 'ML20250430000174'
```

---

### 4.8 Chỉnh sửa Location (Thuộc tính LotAttr09)

- **Xem ở màn F721**
- **Xem tại bảng:** `STB_MaterialDocLotInfo`
- **Xem tại màn hình Location:** `192.168.1.234:9000/tv`
- **Xem tại bảng:** `STB_MaterialLotInfo`

---

### 4.9 FIFO & Validation NVL (Tắt/Bật Chặn)

- **Tắt FIFO cho toàn bộ:** Tìm SP `usp_MaterialWarehouseInOutHist_iud`
- **Tắt FIFO cho NVL cụ thể:** SP `usp_VVTMaterialWarehouse_validFIFO`

> ⚠️ **Lưu ý đặc biệt (Nordex Audit Block):** 
> Kể từ **2026-02-05**, logic chặn quét sai BOM (`RAISERROR('생산중인 제품 BOM에 적합하지 않은 자재입니다...')`) trong SP `usp_RawMaterialInputHist_iud` đang bị **Comment Out (Vô hiệu hóa tạm thời)**. 
> - **Hiện tượng:** Công nhân quét NVL không có trong BOM vẫn được hệ thống chấp nhận. 
> - **Nguyên nhân:** Đang trong giai đoạn Audit hệ thống Nordex.

---

### 4.10 Công thức tính Hạn sử dụng (Expiry Date)

Khi hệ thống báo lỗi **"Hết hạn sử dụng"**, hãy kiểm tra dữ liệu theo công thức sau:
- **Ngày sản xuất (Base Date):** Cột `LotAttr10` trong bảng `STB_MaterialDocLotInfo`.
- **Số tháng Shelf Life:** Cột `MMExtInt01` trong bảng `STB_MaterialMaster` của mã vật tư đó.
- **Hạn sử dụng:** `LotAttr10` + `MMExtInt01` (tháng).

*SQL kiểm tra nhanh:*
```sql
SELECT MDLI.LotID, MDLI.Lotattr10 AS [Ngày SX], MM.MMExtInt01 AS [Hạn tháng],
DATEADD(MONTH, MM.MMExtInt01, MDLI.Lotattr10) AS [Ngày Hết Hạn Thực Tế]
FROM STB_MaterialDocLotInfo MDLI
JOIN STB_MaterialMaster MM ON MDLI.MaterialCode = MM.MaterialCode
WHERE MDLI.LotID = 'ML...'
```

---

### 4.11 Lỗi không lưu được Lot màn F330 Đặc tính 10 (Hà Nam)

**Nguyên nhân:** Lỗi do format mã Lot nhà cung cấp không đúng chuẩn (Vendor Lot format).

**Cách xử lý:**
1. **Hỏi user** về công thức, Lot No và cách đọc mã cụ thể.
2. Vào SP `usp_DoChangeMaterialDocLotInfo` (BG2) để xem logic đọc mã.
3. Tìm trong Function `fn_VVT_getdatebyVendorLot_MergeCode` để tìm nguyên nhân parsing sai.

---

### 4.12 Xóa mã Sparepart thừa (H131)

```sql
-- Tìm tới store: STB_VNSparePartInfo
DELETE FROM STB_VNSparePartInfo
WHERE sparepartcode = '[Mã sparepart cần xóa]'
```

---

### 4.13 FIFO Kho thành phẩm (FG)

- **VVT:** SP `usp_VN_Update_ExportExcel`
- **Bắc Giang:** SP `usp_VN_Update_ExportExcel_BG`

> Tick option tại màn **F110** để bật/tắt FIFO cho kho thành phẩm.
