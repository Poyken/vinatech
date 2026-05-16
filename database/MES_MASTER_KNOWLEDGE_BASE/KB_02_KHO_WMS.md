# KB_02 — Kho Nguyên Vật Liệu (WMS)

> **Màn hình liên quan:** F330, F312, F430, F110, F721, C220
> ← [Về INDEX](KB_INDEX.md)

---

## 4. 📦 Kho Nguyên Vật Liệu (WMS)

### 4.1 Tìm kiếm F721 trả về cả danh sách (không lọc được)

**Nguyên nhân:** Điều kiện lọc trong SP bị sai hoặc tham số truyền vào rỗng.

**Debug:**
```sql
-- Xem SP đang dùng điều kiện gì
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_vvt_MaterialLotInfo_get'))
-- Tìm đến phần WHERE → Kiểm tra điều kiện lọc theo MaterialCode
```

---

### 4.2 Không tìm thấy mã lot ở màn C512

**3 Nguyên nhân phổ biến:**

| # | Nguyên nhân | Cách xử lý |
|---|-------------|------------|
| TH1 | Lot đã tồn tại rồi, không cần tạo lại | Báo lại user kiểm tra lại barcode |
| TH2 | Chưa thiết lập A410 (OQC Type, Inspection Type) | Liên hệ anh Huy setup A410, sau đó tắt C151 → mở lại |
| TH3 (Hà Nam) | Mã test bắt đầu từ Route `VE02` nên không hiện | Kiểm tra route bắt đầu của Lot |

```sql
-- Kiểm tra Lot đang ở route nào
SELECT Barcode, CurrentRouteCode, InputLineCode FROM STB_SetInfo
WHERE Barcode = 'Mã_Barcode_Cần_Tìm'

-- Kiểm tra A410 đã setup chưa (ModelBasicInfo)
SELECT * FROM STB_ModelBasicInfo WHERE ModelCode = 'Mã_Model'
-- Nếu OqcType hoặc InspectionType NULL → chưa setup → cần anh Huy
```

> ⚠️ Mã Barcode ở C512 phải do bên **Sản xuất** cung cấp cho QC, không tự nhập.

---

### 4.3 Chỉnh lại Kho bị nhập sai ở màn F330

**Triệu chứng:** Hàng nhập vào đúng nhưng kho bị chọn sai (VD: nhập vào kho BG nhưng lẽ ra phải vào kho BN).

> ⚠️ Phải UPDATE đồng thời **3 bảng**: `STB_MaterialDocInfo`, `STB_MaterialDocLotInfo`, `STB_MaterialLotInfo`.
> Không update đủ 3 bảng sẽ gây lệch dữ liệu giữa phiếu và thực tế tồn kho.

**Quy trình sửa:**
```sql
-- Bước 1: Xác định MaterialDocNo từ thông tin user cung cấp
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250221000220'
-- Ghi nhớ: TargetMaterialWarehouseCode hiện tại đang là gì

-- Bước 2: Sửa header phiếu
UPDATE STB_MaterialDocInfo
SET TargetMaterialWarehouseCode = 'ROH_HN_WH'  -- Thay bằng mã kho đúng
WHERE MaterialDocNo = '250221000220'

-- Bước 3: Tìm các LotID trong phiếu
SELECT LotID, MaterialLocationCode FROM STB_MaterialDocLotInfo
WHERE MaterialDocNo = '250221000220'
-- Ghi lại danh sách LotID

-- Bước 4: Update vị trí trong phiếu
UPDATE STB_MaterialDocLotInfo
SET MaterialLocationCode = 'ROH_HN_WH_01'  -- Thay bằng Location đúng
WHERE LotID IN ('LotID1', 'LotID2', ...)  -- Dán danh sách LotID vào đây

-- Bước 5: Update tồn kho thực tế (quan trọng nhất)
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_HN_WH',
    MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN ('LotID1', 'LotID2', ...)
```

**Mã kho hay dùng:**

| Nhà máy | WarehouseCode | LocationCode |
|---------|--------------|-------------|
| Bắc Giang | `ROH_BG_WH` | `ROH_BG_WH_01` |
| Hà Nam | `ROH_HN_WH` | `ROH_HN_WH_01` |
| Bắc Ninh (VVT) | `ROH_VN_WH` | `ROH_VN_WH_01` |

---

### 4.4 Chỉnh Code NVL nhập sai ở màn F312

**Triệu chứng:** Nhập nhầm mã NVL khi làm phiếu nhập kho F312 (cột "Số tài liệu" = `MaterialDocNo`).

```sql
-- Bước 1: Xem phiếu hiện tại
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocDetail WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250806000399'

-- Bước 2: Sửa mã NVL trong Detail (dòng phiếu)
UPDATE STB_MaterialDocDetail
SET MaterialCode = 'MÃ_ĐÚNG'
WHERE MaterialDocNo = '250806000399' AND MaterialCode = 'MÃ_SAI'

-- Bước 3: Sửa mã NVL trong LotInfo (từng lô hàng)
UPDATE STB_MaterialDocLotInfo
SET MaterialCode = 'MÃ_ĐÚNG'
WHERE MaterialDocNo = '250806000399' AND MaterialCode = 'MÃ_SAI'

-- Bước 4: Sửa tồn kho thực tế
UPDATE STB_MaterialLotInfo
SET MaterialCode = 'MÃ_ĐÚNG'
WHERE LotID IN (
    SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250806000399'
)
```

---

### 4.5 Sửa số lượng màn F312 (Kho chị Xuân)

**Triệu chứng:** Số lượng phiếu nhập bị sai.

```sql
-- Bước 1: Xem số lượng hiện tại
SELECT * FROM STB_MaterialDocDetail
WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0'

-- Bước 2: Sửa tất cả các cột số lượng
UPDATE STB_MaterialDocDetail
SET RequestQty = 200000, AllowQty = 200000, PickingAssignQty = 200000
WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0'
```

---

### 4.6 Sửa ngày xuất kho màn F430

**Triệu chứng:** Hàng xuất kho bị ghi nhận sai ngày (VD: xuất ngày 30/06 nhưng hệ thống ghi 01/07).

```sql
-- Bước 1: Tìm bản ghi cần sửa
SELECT * FROM STB_MaterialWarehouseInOutHist
WHERE LotID IN ('ML20250620000036', 'ML20250520000061')

-- Bước 2: Sửa ngày (giữ nguyên giờ phút giây)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2025-06-30' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE LotID IN ('ML20250620000036', 'ML20250520000061')
```

---

### 4.7 Chuyển Lot từ kho Holding ra kho chính

**Nguyên nhân phổ biến:** Hàng nhập vào kho Holding do chờ kiểm tra IQC, sau khi IQC pass muốn chuyển sang kho chính.

> Không cần xóa lịch sử — chỉ cần cập nhật lại mã kho và location.

> **Mã HOLDING thực tế (xác minh DB):** `HOLDING_VN_WH` (Bắc Ninh), `HOLDING_BG_WH` (Bắc Giang), `HOLDING_HN_WH` (Hà Nam).

```sql
-- Bước 1: Xem trạng thái Lot hiện tại
SELECT LotID, MaterialWarehouseCode, MaterialLocationCode
FROM STB_MaterialLotInfo
WHERE LotID = 'ML20250430000174'

-- Bước 2: Cập nhật lịch sử xuất nhập (nếu có)
UPDATE STB_MaterialWarehouseInOutHist
SET TargetMaterialWarehouseCode = 'ROH_VN_WH'
WHERE LotID = 'ML20250430000174'

-- Bước 3: Cập nhật trạng thái tồn kho hiện tại
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_VN_WH',
    MaterialLocationCode = 'ROH_VN_WH_01'
WHERE LotID = 'ML20250430000174'
```

---

### 4.8 Sửa Location vật tư (F721 - Thuộc tính LotAttr09)

**Bảng liên quan:** `STB_MaterialDocLotInfo` (LotAttr09), `STB_MaterialLotInfo`

```sql
-- Xem location hiện tại
SELECT LotID, LotAttr09 AS [Location], MaterialLocationCode
FROM STB_MaterialDocLotInfo
WHERE LotID = 'ML...'

-- Sửa location
UPDATE STB_MaterialDocLotInfo SET LotAttr09 = 'Vị_Trí_Mới' WHERE LotID = 'ML...'
UPDATE STB_MaterialLotInfo SET MaterialLocationCode = 'Vị_Trí_Mới' WHERE LotID = 'ML...'
```
> **Xem vị trí trực quan:** `192.168.1.234:9000/tv`

---

### 4.9 FIFO & Validation NVL (Tắt/Bật chặn)

**Khi nào tắt:** Nhà máy cần sử dụng hàng mới mà chưa hết hàng cũ (bypass FIFO), hoặc cần nhập NVL không có trong BOM tạm thời.

- **Tắt FIFO cho toàn bộ:** Tìm SP `usp_MaterialWarehouseInOutHist_iud` → Comment out dòng FIFO check
- **Tắt FIFO cho NVL cụ thể:** SP `usp_VVTMaterialWarehouse_validFIFO`

> ⚠️ **Lưu ý Nordex Audit (từ 2026-02-05):** Logic chặn quét sai BOM (`RAISERROR('생산중인 제품 BOM...')`) trong SP `usp_RawMaterialInputHist_iud` đang bị **Comment Out tạm thời**. Hệ thống hiện chấp nhận NVL không có trong BOM — cần bật lại sau khi audit xong.

> ⚠️ **HOLD Warehouse Codes thực tế (xác minh DB 2026-05-17):** `HOLDING_VN_WH` (Bắc Ninh), `HOLDING_BG_WH` (Bắc Giang), `HOLDING_HN_WH` (Hà Nam). Kiểm tra HOLD bằng cách SELECT `MaterialWarehouseCode` từ `STB_MaterialLotInfo`.

---

### 4.10 Kiểm tra Hạn sử dụng NVL (Expiry Date)

**Khi B597 báo "Hết hạn sử dụng"**, tra cứu theo công thức:

- **Ngày sản xuất:** Cột `LotAttr10` trong `STB_MaterialDocLotInfo`
- **Shelf Life:** Cột `MMExtInt01` trong `STB_MaterialMaster`
- **Hạn dùng = LotAttr10 + MMExtInt01 (tháng)**

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
```

**Xử lý nếu hết hạn nhưng hàng vẫn dùng được:**
1. Báo với bộ phận QC để xác nhận gia hạn
2. Sau khi QC đồng ý → Sửa `LotAttr10` sang ngày mới hơn hoặc tăng `MMExtInt01` trong MaterialMaster

---

### 4.11 Lỗi không lưu được F330 - Định dạng Vendor Lot sai (Hà Nam)

**Triệu chứng:** F330 báo lỗi khi nhập mã Lot nhà cung cấp ở "Đặc tính 10".

**Nguyên nhân:** Nhà cung cấp đổi định dạng mã Lot, hệ thống không parse được ngày tháng.

**Debug:**
1. Lấy mã Lot lỗi từ user (VD: `25062001234`)
2. Xem hàm parse:
```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_getdatebyVendorLot_MergeCode'))
-- Đọc logic cắt chuỗi hiện tại
-- VD: 2 ký tự đầu = năm (25=2025), 2 tiếp = tháng, 2 tiếp = ngày
```
3. Nếu định dạng mới không match → Báo anh Tùng sửa Function, hoặc:
   - Workaround tạm: Nhập tay ngày tháng vào cột `LotAttr10` bằng SQL sau khi nhập phiếu

---

### 4.12 Xóa mã Sparepart thừa

```sql
-- Tìm trước
SELECT * FROM STB_VNSparePartInfo WHERE sparepartcode = '[Mã cần xóa]'
-- Xóa
DELETE FROM STB_VNSparePartInfo WHERE sparepartcode = '[Mã cần xóa]'
```

---

### 4.13 FIFO Kho thành phẩm (FG00)

- **VVT (Bắc Ninh):** SP `usp_VN_Update_ExportExcel`
- **Bắc Giang:** SP `usp_VN_Update_ExportExcel_BG`
- **Bật/tắt FIFO cho FG:** Vào màn **F110** → Tích/bỏ tích option FIFO

---

### 4.14 Lỗi "Không tồn tại thiết lập Vỏ Nhôm"

**Triệu chứng:** B597 báo lỗi `"Không tồn tại thiết lập Vỏ Nhôm của LotNo... với mã Vỏ Nhôm: GBDYAC-004 <> ECVT30-367"`

> ⚠️ **Đã xác minh (2026-05-17):** Bảng `STB_AluCaseMapping_VVT` **KHÔNG TỒN TẠI** trong `SmartFactoryV2`. Logic kiểm tra vỏ nhôm được hardcode trong SP `usp_Vietnam_RawMaterialInputHist_uid`.

**Fix — Chỉ có cách sửa SP:**
```sql
-- Đọc SP để tìm khối IF kiểm tra vỏ nhôm
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- Tìm tới đoạn IF chặn (VD: NOT IN ('GBRLAC-004', ...))
-- Thêm mã vỏ mới vào danh sách NOT IN → Deploy lại SP
```

**Muốn biết mã vỏ nào đang được cho phép:** Đọc source SP (fetch bằng `fetch_sp.ps1`) và tìm đoạn xử lý AluCase/Vỏ Nhôm.


---

### 4.15 Luồng nhập kho đầy đủ (F330) — Tham chiếu nhanh

```
Groupware (Arrival Confirmation duyệt xong)
    ↓
F330 — Nhận hàng, in tem NVL, gán Lot vào kho
    ↓
C220 — IQC kiểm tra chất lượng → PASS
    ↓
Groupware (Receiving Confirmation)
    ↓
NVL sẵn sàng cho sản xuất
```

> Nếu user báo "không nhập được F330" → Hỏi lại: Groupware đã duyệt "Arrival Confirmation" chưa?
> Nếu user báo "không làm được Receiving Confirmation" → Hỏi lại: C220 đã PASS chưa?

### 4.15 Sửa mã NVL (MaterialCode) nhập sai ở màn F312

**Triệu chứng:** Thủ kho (chị Xuân) nhập nhầm mã NVL cho phiếu nhập kho, cần sửa lại mà không muốn hủy phiếu.

```sql
-- Bước 1: Tìm MaterialDocNo từ màn hình (Số tài liệu)
-- Bước 2: Sửa đồng bộ ở 2 bảng Detail và LotInfo
DECLARE @DocNo NVARCHAR(50) = '250806000399'
DECLARE @CorrectCode NVARCHAR(50) = 'GCTN00-S01'

UPDATE STB_MaterialDocDetail
SET MaterialCode = @CorrectCode
WHERE MaterialDocNo = @DocNo

UPDATE STB_MaterialDocLotInfo
SET MaterialCode = @CorrectCode
WHERE MaterialDocNo = @DocNo
```

---

*Cập nhật: 2026-05-17*
