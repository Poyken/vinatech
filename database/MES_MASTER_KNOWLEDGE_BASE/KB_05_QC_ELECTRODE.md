# KB_05 — Kiểm tra Chất lượng (QC) & Điện cực

> **Màn hình liên quan:** B597, C443, C512, B270, B540, B552
> ← [Về INDEX](KB_INDEX.md)

---

## 7. 🔬 Kiểm tra Chất lượng (QC)

### 7.1 Sửa hạng mục loại hình kiểm tra ở B597 & C443

**Nguyên nhân:** Nếu Barcode đã được kiểm tra lần trước → hệ thống sẽ load lại các hạng mục kiểm tra cũ.

**Cách kiểm tra trước:**
1. Vào **B540** → Dán mã barcode vào tìm kiếm → Ấn nút **"Việt Nam_Kiểm tra thường xuyên"**.

**Cách sửa:**

*Với C443:* Vào SP `usp_GetCommInspection_HistoryForBarcode_Vietnam`

*Với B597:* Vào SP `usp_GetCommInspectionHistoryForBarcode`

```sql
-- Tìm CommInspDocNo theo Barcode
SELECT * FROM STB_CommInspDocHistory CIDH
LEFT JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = 'VVPO093R010707'

-- Xem chi tiết hạng mục
SELECT * FROM STB_CommInspDocItem
WHERE CommInspDocNo IN (
    SELECT CommInspDocNo FROM STB_CommInspDocHistory CIDH
    LEFT JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
    WHERE SI.Barcode = 'VVPO093R010707'
)

-- Tìm theo ControlNo trực tiếp
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Xóa hạng mục để tạo lại
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...'
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...'
```

---

### 7.2 Không tìm thấy ở màn C512

**Nguyên nhân có 3 trường hợp:**
- **TH1:** Đã tạo Lot rồi → không cần tạo lại.
- **TH2:** Phải thiết lập các hạng mục "Loại kiểm tra" và "Loại OQC" tại màn **A410**.
  - Sau khi thiết lập xong → Tắt màn C151 → Vào lại.
- **TH3 (Hà Nam):** Các mã test tháng 12 bắt đầu từ Route `VE02` nên không hiện.

> Mã Barcode ở C512 phải do bên **Sản xuất** cung cấp cho QC (không tự nhập).

---

## 8. ⚡ Điện cực (Electrode)

### 8.1 Chỉnh chiều rộng Slitting màn B552

```sql
-- Xem cấu hình master
SELECT * FROM STB_CoatingToSlittingMaster
-- WHERE CoatingMaterialCode = 'CRYPK0-011'

-- Cập nhật chiều rộng
UPDATE stb_slittinglocationconfig_vvt
SET Width = 16
WHERE SlittingCode = 'YP' AND SlittingSize = 200 AND PartNo = '1625' AND id = 12
```

---

### 8.2 Update Location Slitting (thêm cấu hình mới)

> ⚠️ `WarehouseLocation`, `LocationWarehouse` phải match với bảng `STB_ElectrodeSlittingResult`.

```sql
-- Template thêm cấu hình (ví dụ 3 model: 1025-10F, 1325-15F, 1030-10F)
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực dương 1025
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực âm 1025
    ('1325', 'BY', '200', '15', '18.7', 'VVT_F2', 'kho2'),  -- Cực dương 1325
    ('1325', 'YP', '180', '15', '18.7', 'VVT_F2', 'kho2'),  -- Cực âm 1325
    ('1030', 'BY', '200', '10', '23.7', 'VVT_F2', 'kho2'),  -- Cực dương 1030
    ('1030', 'YP', '180', '10', '23.7', 'VVT_F2', 'kho2')   -- Cực âm 1030

-- Xác nhận dữ liệu đã insert (thay ID thực tế)
SELECT * FROM stb_slittinglocationconfig_vvt WHERE id IN (179, 180, 181, 182, 183, 184)

-- Cập nhật số cuộn và vị trí kho
UPDATE stb_slittinglocationconfig_vvt
SET RollQty = 20, PositiveLocation = 'A6-T3', NegativeLocation = 'B6-T3'
WHERE id IN (183, 184)
```

---

### 8.3 Lỗi không lưu được NVL trên B597 (Lỗi chuỗi điện cực)

**Nguyên nhân:**
- NVL điện cực mới đăng ký thiếu/sai **Độ dày (MaterialThickness)**.
- Hệ thống so sánh chuỗi bị lỗi khi độ dày dạng `200` != `200.000000`.

**Cách sửa:**
1. **Sửa tại SP:** Vào `usp_Vietnam_RawMaterialInputHist_uid` → Thêm exception cho trường hợp đặc biệt.
2. **Sửa dữ liệu Master:**
   - `STB_MaterialMaster`: Sửa `MaterialThickness` thành **số nguyên** (không có `.00000`).
   - `STB_SetInfo`: Nếu công nhân đã tạo Lot → sửa cột `SIExtReal03` (dạng `.00000`).
3. **Nếu bị lỗi rõ ràng hơn:** Sửa cột `ElectrodeThickness` ở 2 bảng:
   - `STB_ElectrodeWastePriceNew`
   - `STB_ElectrodeWasteInfoNew`

---

### 8.4 Lỗi không lưu được NVL trên B597 (Mã Electrolyte không khớp)

**Nguyên nhân:**
- Khi quét thẻ QR Code dung dịch ở màn B597 (VNT_SelfInspectionRawMaterial_VVT), hệ thống so sánh mã nguyên liệu đang quét (VD: `GBEC00-011`) với BOM của Model tương ứng (`STB_BomDetail`).
- Nếu trong BOM đang cấu hình là một mã khác (VD: `GBCP00-001`) mà OP lại quét `GBEC00-011` thì hệ thống sẽ báo lỗi *"Mã Electrolyte/ DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào B597"*.

**Cách xử lý:**
1. **Kiểm tra BOM:** Báo với EA/R&D kiểm tra xem sản xuất có đang dùng sai nguyên liệu hay không.
2. **Sửa tại SP:** Nếu là chủ ý đổi mã nguyên liệu chạy thay thế nhưng chưa đổi BOM, IT có thể vào Stored Procedure `usp_Vietnam_RawMaterialInputHist_uid`.
   - Tìm đến CTE `eleclyte1`.
   - Bổ sung lệnh UNION ALL ngoại lệ (ví dụ: `select 'GBEC00-011' AS electrolyte, 'WEC3R0606QG' as model, '1840' size`).
   - Cập nhật lại SP vào thẻ CSDL.

---

### 8.5 Lỗi thiếu cấu hình Slitting (STB_SLITTINGLOCATIONCONFIG_VVT)
- **Triệu chứng:** Khi lưu kết quả tự kiểm tra hoặc nhập liệu, báo lỗi: *"Không tồn tại thiết lập Điện cực của LotNo... Chưa CONFIG trong bảng: STB_SLITTINGLOCATIONCONFIG_VVT"*.
- **Nguyên nhân:** Mã sản phẩm (PartNo) và thông số kỹ thuật (Size/Farad/Width) chưa được khai báo trong bảng vị trí Slitting.
- **Cách xử lý:** Tra cứu thông số bị thiếu trong câu báo lỗi (VD: PartNo=1025, Farad=10F, Width=17.7) và thực hiện INSERT vào bảng master.
- **SQL mẫu:**
```sql
-- Kiểm tra dữ liệu hiện có cho PartNo đó
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'

-- Thêm cấu hình mới (Dựa trên thông số lỗi báo)
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'); -- Thay đổi giá trị thực tế
```

---

### 8.6 Sửa hạng mục kiểm tra chung (B597/C443)
- **Triệu chứng:** Khi vào B597 hoặc C443, hệ thống tự load lại các hạng mục kiểm tra cũ của lần trước, không cho sửa hoặc hiển thị sai hạng mục mới.
- **Nguyên nhân:** Do `STB_CommInspDocHistory` đã tồn tại bản ghi cũ cho Barcode này.
- **Cách xử lý:** Xóa lịch sử kiểm tra cũ để hệ thống khởi tạo lại.
```sql
-- 1. Tìm CommInspDocNo từ Barcode
SELECT CIDH.CommInspDocNo 
FROM STB_CommInspDocHistory CIDH
JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = 'VVPO093R010707';

-- 2. Xóa lịch sử trong 2 bảng (Dùng mã DocNo tìm được)
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...';
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...';
```
> **Lưu ý:** Sau khi xóa, QC cần tắt màn hình và mở lại để hệ thống load bộ tiêu chuẩn mới.
