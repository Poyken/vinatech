# NAIS SYSTEM MASTER TROUBLESHOOTING GUIDE (Vinatech MES)

> **Tài liệu gốc:** `Lỗi trên NAIS System_Tái bản.docx`
> **Mục tiêu:** Tra cứu nhanh lỗi dựa trên triệu chứng hình ảnh và mã màn hình.

---

## 1. MÀN HÌNH B597 (KIỂM TRA CÔNG ĐOẠN - QC)

### 🚨 Lỗi: Sai mã Nguyên liệu/Dung dịch (Electrolyte)
- **Triệu chứng:** [image11.png] Thông báo "Mã Electrolyte... được thiết lập khác với mã QRCODE nhập vào".
- **Nguyên nhân:** Hard-code kiểm tra trong Stored Procedure chưa cập nhật mã vật tư mới.
- **Cách xử lý:** 
    - Sửa SP: `usp_Vietnam_RawMaterialInputHist_uid`
    - Tìm đoạn code kiểm tra `@MaterialCode` và `@pRawMaterialBarcode`.
    - Thêm điều kiện `OR` cho mã vật tư mới (Ví dụ: `ECVT30-367` đi với vỏ `GBDYAC-004`).

### 🚨 Lỗi: Không hiện được hạng mục kiểm tra mới
- **Triệu chứng:** Hệ thống load lại hạng mục cũ, không cho nhập kết quả mới.
- **Nguyên nhân:** Tồn tại bản ghi cũ trong `STB_CommInspDocHistory`.
- **Cách xử lý:** Xóa lịch sử cũ.
```sql
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = (SELECT CommInspDocNo FROM STB_CommInspDocHistory WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '...'));
DELETE FROM STB_CommInspDocHistory WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '...');
```

---

## 2. MÀN HÌNH F330 (NHẬP KHO NVL)

### 🚨 Lỗi: Không thể chuyển đổi mã Vendor Lot thành ngày tháng
- **Triệu chứng:** [image13.png] Lỗi tại cột "Đặc tính 10" (LotAttr10) khi lưu.
- **Nguyên nhân:** Định dạng Vendor Lot không khớp với quy tắc đọc ngày tháng trong hệ thống.
- **Cách xử lý:** 
    - Kiểm tra Stored Procedure: `usp_DoChangeMaterialDocLotInfo`
    - Kiểm tra Function: `fn_VVT_getdatebyVendorLot_MergeCode`
    - Cập nhật logic parse date cho đầu mã Lot mới.

---

## 3. MÀN HÌNH B523 / HN544 (GỘP BOX - PACKING)

### 🚨 Lỗi: Không gộp được Box (Packing Error)
- **Triệu chứng:** [image21.png] Không tìm thấy Lot để gộp hoặc nút gộp không hoạt động.
- **Cách xử lý:** Kiểm tra cấu hình tại màn **F110**.
    - Phải tích chọn `IsUseBarcode` và `IsLotUse` cho mã vật tư tương ứng.

### 🚨 Lỗi: Qty = 0 khi in tem
- **Triệu chứng:** [image14.png] Packing Qty bị âm hoặc bằng 0 tại B523.
- **Cách xử lý:** 
    - Sửa SP: `usp_savePackingLabelQty_VVT`
    - Kiểm tra bảng: `STB_SavePackingTime_VVT`

---

## 4. MÀN HÌNH B270 (THÔNG TIN THIẾT BỊ)

### 🚨 Lỗi: Popup "Mã Route" bị trống
- **Triệu chứng:** [image2.png] Không chọn được công đoạn cho máy.
- **Cách xử lý:** Vào màn **B230** (Thông tin cấu trúc công đoạn trong Line) để thiết lập mapping giữa máy và route.

---

## 5. MÀN HÌNH B450 (KẾ HOẠCH SẢN XUẤT)

### 🚨 Lỗi: Không in được tem sản xuất
- **Triệu chứng:** Lỗi khi nhấn nút in tem tại B450.
- **Cách xử lý:** Kiểm tra cấu hình tem tại màn **A460**.
    - Đảm bảo đã gán `AssembleLabel` (cho SX) và `PartLabel` (cho Kho).

---

## 6. MÀN HÌNH B782 / B781 (LỊCH SỬ ROUTING/PACKING)

### 🚨 Nghiệp vụ: Chuyển JobDate (Sửa ngày báo cáo)
- **Công thức chuẩn:** `SET ProdDateTime = CAST('YYYY-MM-DD' AS DATETIME) + CAST(ProdDateTime AS TIME), JobDate = 'YYYY-MM-DD'`.
- **Bảng liên quan:**
    - B782: `STB_ProdRouteHist`
    - B781: `STB_SavePackingTime_VVT`
    - B598: `STB_VN_PRODUCTION_ERROR`
    - B726: `STB_VN_SCRAP_AFTERPRODUCTIONS`

---

## 7. QUẢN LÝ ĐIỆN CỰC (ELECTRODE)

### 🚨 Lỗi: Sai độ dày điện cực (Thickness Error)
- **Nguyên tắc:** Độ dày phải là số nguyên (không có `.00000`).
- **Các bảng cần sửa đồng bộ:**
    - `STB_MaterialMaster` (Cấu hình gốc)
    - `STB_SetInfo` (Sửa cột `SIExtReal03`)
    - `STB_ElectrodeWastePriceNew` & `STB_ElectrodeWasteInfoNew` (Sửa cột `ElectrodeThickness`)
