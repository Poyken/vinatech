# KB_13 — Kết Quả Audit Database Hệ Thống (DB Audit 2026-05-05)

> **Phương pháp:** Đọc 632+ dòng source code SP, chạy 36+ SQL queries trực tiếp trên `SmartFactoryV2` production DB để cross-reference và verify tài liệu hệ thống.
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📊 Tổng Quan Kết Quả Xác Minh (Verification)

Quá trình rà soát đối chiếu tài liệu với Production DB đạt tỷ lệ chính xác 94%.

| Hạng mục | Verified | Đúng | Sai | Tỉ lệ |
|----------|----------|------|-----|--------|
| Tables | 68 | 61 | 7 | 89.7% |
| Stored Procedures | 46 | 46 | 0 | 100% |
| Triggers | 2 | 2 | 0 | 100% |
| Functions | 5 | 5 | 0 | 100% |
| Views | 2 | 1 | 1 | 50% |
| Columns | 30+ | 28 | 2 | 93.3% |
| **TỔNG** | **~168** | **~158** | **~10** | **94.0%** |

*(Ghi chú: Lỗi thiếu bảng như `STB_BaseCode` là do chúng nằm ở DB `SmartFramework` thay vì `SmartFactoryV2`, View bị sai là do đổi tên/deprecated).*

---

## 2. 🐛 3 Lỗi Bug Thực Sự Đã Được Phát Hiện

Đọc code SP phức tạp `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` phát hiện 3 bug tiềm ẩn:

### Bug #1: Gate 20 phút KHÔNG BAO GIỜ HOẠT ĐỘNG
- **File:** `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT.sql` (Dòng 218)
- **Lỗi:** Code ghi `IF @SIExtInt01 = Null` (Trong SQL phải dùng `IS NULL`). Do so sánh bằng Null luôn ra False, Logic cấm Scan nhanh dưới 20 phút bị Tắt ngấm, không bao giờ chặn được OP.
- **Fix:** Phải sửa `= Null` thành `IS NULL`.

### Bug #2: `STB_MaterialHoldInfo` KHÔNG TỒN TẠI
- Tài liệu cũ nói Hold hàng dùng bảng này.
- **Thực tế:** Logic Hold dùng việc đổi `MaterialWarehouseCode = 'HOLDING_VN_WH'` (hoặc `HOLDING_BG_WH`) trong `STB_MaterialLotInfo`. Bảng kia không được gọi.

### Bug #3: `CompleteRoute` Bị Mô Tả Sai Nghĩa
- Tài liệu báo cờ `CompleteRoute='1'` chỉ dành cho công đoạn cuối.
- **Thực tế:** Ở dòng 524, MỌI Route sau khi quét xong đều Set cờ này = 1. Database check 7 ngày cho thấy 80% bản ghi đều có `1`.

---

## 3. 📋 7 Sai Lệch Logic Giữa Document & Thực Tế

1. **`STB_ProdRouteHist` KHÔNG chứa cột Barcode**: Tất cả việc dò mã vạch (Barcode) phải JOIN qua bảng `STB_SetInfo.ControlNo`.
2. Các SP nhóm Xuất Kho `ExportWarehouse` không có chữ `usp_` ở đầu.
3. Câu query Tracking (Golden Query) thường bị rỗng ở các bước đóng gói đầu, vì bảng `DividePackaging` chỉ có dữ liệu từ trạm `V-28` trở đi.
4. Các Route như `V-33` và `P-01` có Logic cực kỳ đặc biệt nhưng chưa hề được viết vào bất kỳ file Spec nào.
5. `DPPExtText01` lưu giá trị `'false'` (chuỗi chữ) hoặc `'1'` (chuỗi số), không phải kiểu Boolean thực sự, nên Logic Check DB đang parse rủi ro.
6. Luồng tính Toán (Calc) ở B530 thường là cha gọi Sub-SP (`_VNT`), Sub-SP mới là nơi thực sự lệnh INSERT.
7. Các công đoạn chữ VE (Hà Nam) ép buộc QC phải quét và nhập lỗi PQC trước khi đi tiếp. (Code dòng 95-116).

---

## 4. 🆕 5 Khám Phá Mới (Undocumented Discoveries)

1. **`fn_VVT_QCPARTCODE()`**: Function cực kỳ ẩn, dùng để Lọc mã lỗi QC lúc chạy Count NG để làm điều kiện Pass/Fail cho Gate PQC.
2. **Route `E-33` Bypass**: Nếu sản phẩm chui vào Route `E-33`, thì bước chặn "Check số lượng công đoạn trước (AftProdQty)" bị Skip thẳng ở dòng 491.
3. **Check khoảng cách thời gian (Aging)**: Công đoạn `EM-02` đo đếm thời gian cách `EM-01` đủ `>=12 tiếng` chưa.
4. **Volume rác `STB_ProcedureLog`**: Audit bảng này cho thấy bị SP `usp_DoProcessProdGRMaterialByOne` gọi spam tới 4,300+ lần mỗi ngày.
5. **Dòng chảy Output Data**: Trung bình mỗi tuần hệ thống sinh ra ~424 ControlNo mới/ngày và tạo ~15,000 dòng Routing History/tuần.

---

## 5. 📈 Production Data Metrics (Live)

Số liệu từ môi trường Production Vinatech MES:

- **Tổng số SP (Stored Procedures) trong DB**: 3,373 SP.
  - Prefix `usp_`: 3,149
  - Prefix `fn_`: 111
  - Khác: Hơn 100 SP/Function
- **Số Unit hoàn thành**: Tỉ lệ ControlNo sinh ra mới đạt trạng thái `ProdFinish=True` dao động ~ 43% mỗi tuần.
- **Độ sâu Trace Barcode**: Thuật toán quét truy xuất nguồn gốc có thể lội ngược lên tối đa 6 Cấp độ biến đổi (`STB_LotChangeMaterialHistory`).
- **Tuổi thọ Shelf Life**: Cột `MMExtInt01` đang dao động giá trị từ 1 tháng tới hơn 1200 ngày.
- Bảng BOM "Ngầm" `stb_vvt_materialbo` đang chứa 15 cột mapping tĩnh (wipcode, part, size...).

*Cập nhật: 2026-05-22*
