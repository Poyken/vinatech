# KB_12 — Phân Tích Sâu Cốt Lõi & Audit Database (Deep Analysis & Audit)

> **Mục đích:** Giải thích bản chất thiết kế của hệ thống MES NAIS phía dưới database (dành cho IT/Developer) kết hợp với kết quả kiểm tra (Audit) thực tế trên database SmartFactoryV2 và SmartFramework.
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🧠 DNA Hệ Thống — 5 Triết Lý Thiết Kế Cốt Lõi

### Triết lý 1: "Database là não, UI chỉ là tay"
Hầu hết các hệ thống MES phương Tây nhúng business logic vào application layer (C#, Java). NAIS làm ngược lại: **toàn bộ logic nghiệp vụ nằm trong Database**.
*   Khi bấm nút "Hoàn thành", UI chỉ đọc tên SP từ `SmartFramework.STB_ScreenObjects` rồi gọi nó.
*   SP tự tính toán, tự validate, tự write. UI không biết gì.
*   **Hệ quả:** Sửa SP = sửa logic, không cần deploy phần mềm. Khó test và debug nếu không có quyền DB.

### Triết lý 2: "Barcode là passport, Routing History là visa stamp"
Một viên tụ điện = Một "người" đi qua hải quan quốc tế.
*   `ControlNo`/`Barcode` = Số hộ chiếu (không đổi suốt đời).
*   `STB_SetInfo` = Sổ hộ chiếu.
*   `STB_ProdRouteHist` = Visa stamp tại từng điểm.
*   Bỏ qua trạm = Vi phạm xuất nhập cảnh → bị chặn.
Hệ thống tự động tìm công đoạn `N+1` từ `RouteIndex` chứ không cần config thủ công "bước này đến bước nào".

### Triết lý 3: "Validation tại Database, không phải UI"
Ví dụ B597 có 3 cổng chặn cứng từ SP `usp_Vietnam_RawMaterialInputHist_uid`:
1.  Check HOLD.
2.  Check Expiry Date (tính bằng `MMExtInt01`).
3.  Check BOM ngầm trong `stb_vvt_materialbo`.

### Triết lý 4: "Tồn kho được tính trong lúc chạy, không phải lưu sẵn"
SP `usp_vvt_MaterialLotInfo_get` (Màn F721) tính hạn sử dụng real-time mỗi lần load, thay vì lưu vào field `ExpiredDate` cố định. Cảnh báo Warning sẽ tự bật (15 ngày cho cuộn, 30 ngày cho vật tư thường).

### Triết lý 5: "Audit Trail không thể xóa, không thể sửa"
Bảng `STB_ProcedureLog` là camera an ninh. Mỗi lần SP quan trọng chạy đều INSERT thông tin User, Barcode, Time, Parameters. Khi OP khiếu nại mất dữ liệu, IT có thể xem lại bảng này để biết ai làm.

---

## 2. 📊 Kết Quả Audit Database Hệ Thống (DB Audit 2026-05-05)

> **Phương pháp:** Đọc 632+ dòng source code SP, chạy 36+ SQL queries trực tiếp trên `SmartFactoryV2` production DB để cross-reference và verify tài liệu hệ thống.

### 2.1 Tổng Quan Kết Quả Xác Minh (Verification)
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

### 2.2 🐛 3 Lỗi Bug Thực Sự Đã Được Phát Hiện & Xác Minh

Rà soát mã nguồn thực tế của Stored Procedure `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` và cấu hình hệ thống đã xác minh 3 lỗi sau:

#### Bug #1: Gate 20 phút KHÔNG BAO GIỜ HOẠT ĐỘNG
*   **File:** `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` (Dòng 264)
*   **Chi tiết mã lỗi:** 
    ```sql
    IF @CompanyCode = 'VNT' AND @SIExtInt01 = Null AND @RouteIndex > 1 AND @RouteCode <> 'E-25' AND @RouteCode <> 'E-23'
    ```
*   **Nguyên nhân:** Biến `@SIExtInt01` được so sánh bằng toán tử `= Null`. Trong SQL Server, mọi phép so sánh với `Null` bằng toán tử `=` luôn trả về `UNKNOWN` (False trong điều kiện `IF`). Do đó, khối lệnh chặn scan nhanh dưới 20 phút không bao giờ được thực thi, làm vô hiệu hóa hoàn toàn cổng chặn.
*   **Giải pháp:** Phải sửa `@SIExtInt01 = Null` thành `@SIExtInt01 IS NULL`.

#### Bug #2: `STB_MaterialHoldInfo` KHÔNG TỒN TẠI
*   Tài liệu vận hành cũ mô tả việc giữ hàng (Hold) sử dụng bảng này.
*   **Xác minh thực tế:** Bảng `STB_MaterialHoldInfo` hoàn toàn không tồn tại trong CSDL `SmartFactoryV2` hay `SmartFramework`, và không được tham chiếu bởi bất kỳ Stored Procedure nào (0 kết quả trả về khi quét `sys.sql_modules`).
*   **Cơ chế thực tế:** Nghiệp vụ Hold hàng được cài đặt bằng cách cập nhật cột `MaterialWarehouseCode` thành `'HOLDING_VN_WH'` hoặc `'HOLDING_BG_WH'` trong bảng `STB_MaterialLotInfo`.

#### Bug #3: Cờ `CompleteRoute` Ghi Nhận Cho MỌI Công Đoạn
*   Tài liệu cũ ghi nhận cờ `CompleteRoute='1'` chỉ được bật cho công đoạn cuối của PO.
*   **Xác minh thực tế:** Ở cuối SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` (dòng 573), lệnh `UPDATE STB_ProdRouteHist` thực hiện cập nhật `CompleteRoute = '1'` cho **mọi công đoạn** sau khi xử lý thành công.

### 2.3 📋 7 Sai Lệch Logic Giữa Document & Thực Tế

1.  **`STB_ProdRouteHist` KHÔNG chứa cột Barcode**: Tất cả việc dò mã vạch (Barcode) phải JOIN qua bảng `STB_SetInfo.ControlNo`.
2.  Các SP nhóm Xuất Kho `ExportWarehouse` không có chữ `usp_` ở đầu.
3.  Câu query Tracking (Golden Query) thường bị rỗng ở các bước đóng gói đầu, vì bảng `DividePackaging` chỉ có dữ liệu từ trạm `V-28` trở đi.
4.  Các Route như `V-33` và `P-01` có Logic cực kỳ đặc biệt nhưng chưa hề được viết vào bất kỳ file Spec nào.
5.  `DPPExtText01` lưu giá trị `'false'` (chuỗi chữ) hoặc `'1'` (chuỗi số), không phải kiểu Boolean thực sự, nên Logic Check DB đang parse rủi ro.
6.  Luồng tính Toán (Calc) ở B530 thường là cha gọi Sub-SP (`_VNT`), Sub-SP mới là nơi thực sự lệnh INSERT.
7.  Các công đoạn chữ VE (Hà Nam) ép buộc QC phải quét và nhập lỗi PQC trước khi đi tiếp. (Code dòng 95-116).

### 2.4 🆕 Các Khám Phá Mới (Undocumented Discoveries - Cập nhật 2026-06-14)

1.  **`fn_VVT_QCPARTCODE()`**: Function cực kỳ ẩn, dùng để Lọc mã lỗi QC lúc chạy Count NG để làm điều kiện Pass/Fail cho Gate PQC.
2.  **Route `E-33` Bypass**: Nếu sản phẩm chui vào Route `E-33`, thì bước chặn "Check số lượng công đoạn trước (AftProdQty)" bị Skip thẳng ở dòng 491.
3.  **Check khoảng cách thời gian (Aging)**: Công đoạn `EM-02` đo đếm thời gian cách `EM-01` đủ `>=12 tiếng` chưa.
4.  **Nhật ký SP thực tế `STB_ProcedureLog`**: Không phải là bảng log lỗi như tài liệu cũ mô tả, mà là bảng camera giám sát ghi nhận tham số chạy của SP (lưu cột `Idx`, `ProcedureName`, `VariableName` và `VariableValue`).
5.  **Cơ chế Stage Prices nhà máy Hưng Yên (`_HY` - VVT_F4)**:
    *   Hưng Yên sử dụng các mã công đoạn có tiền tố `P-` (ví dụ: `P-01` -> `P-06`).
    *   Khi tính đơn giá công đoạn, do bảng `STB_VVT_StagePrices` không có các cột mang tên Hưng Yên, hệ thống tự động ánh xạ các công đoạn `P-` này vào các cột `RouteVP01` -> `RouteVP08` và `PriceVP01` -> `PriceVP08`.
6.  **Logic tự ngắt cascade của Route `V-33` & `P-01`**:
    *   Tại SP `ForCalc`, khi gặp `V-33` hoặc `P-01`, truy vấn tìm công đoạn kế tiếp dùng toán tử `>=` (`APOR.RouteIndex >= POR.RouteIndex`), làm cho `@AftRouteCode` trỏ ngược lại chính nó.
    *   Điều này cố ý phá vỡ chuỗi tự động tạo Lot Input cho công đoạn tiếp theo, buộc trạm sau phải quét thủ công, đồng thời để lại cờ `CompleteRoute` ở dạng rỗng/NULL (thực tế xác minh 2,582 bản ghi `V-33` đều có `CompleteRoute` rỗng).
7.  **Rủi ro sập luồng của hàm `fn_VVT_getdatebyVendorLot`**:
    *   Hàm phân tích ngày sản xuất từ mã Lot của nhà cung cấp sử dụng các hàm cắt chuỗi tĩnh (`substring`). Khi gặp mã hàng `WRHI00-002`, hàm thực hiện lệnh `convert(date, @vendorlot, 103)`. Nếu mã `@vendorlot` không tuân thủ định dạng ngày `dd/mm/yyyy`, toàn bộ giao dịch sản xuất hoặc SELECT tồn kho F721 sẽ bị crash (lỗi chuyển đổi kiểu dữ liệu).
8.  **Phân hệ chấm công và điểm danh nhân sự kỹ thuật (`P111`)**:
    *   Sử dụng bảng `STB_TechnicalPersonnelAttendanceInfo` kết hợp các SP `usp_TechnicalPersonnelAttendanceInfo_get`, `_iud`, `_interface` và `usp_TechnicalPersonnelAttendance_confirm`.
    *   Hỗ trợ theo dõi giờ đến (`AttendanceDateTime`), giờ về (`LeavingDateTime`), trạng thái xác nhận duyệt công (`IsConfirm`), và đồng bộ dữ liệu vân tay qua màn hình `Z711` (`FingerAttendance`).

---

## 3. 🔄 Luồng Dữ Liệu Thực Tế Từ Source Code

### 3.1 Luồng chính tại B530 (Đóng Lot / Nhập sản lượng)
Khi OP bấm "Hoàn thành", `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` thực thi qua 17 bước, đáng chú ý:
*   **GATE Điện Cực:** Check YP=dương, BY=âm đã scan chưa.
*   **Xóa Dữ liệu tạm:** DELETE `STB_InterimProdQtyInfo` (InbrinskQty).
*   **GATE 20 Phút:** Bắt buộc chờ 20 phút giữa 2 công đoạn (Bug: Đang bị lỗi `@SIExtInt01 = Null` làm gate này không hoạt động).
*   **Ghi Takt Time:** Cho VVT.

### 3.2 Luồng B597 (Scan NVL) — Lớp Validation khổng lồ
*   Cơ chế **Chain Barcode**: Trace lịch sử đổi mã barcode đến 6 cấp qua bảng `STB_LotChangeMaterialHistory` để so khớp:
    ```sql
    -- SP B597 theo dõi lịch sử đổi barcode đến 6 cấp:
    SELECT @LotNonew1 = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode=@pBarcode
    SELECT @LotNonew2 = NewBarcode ... WHERE OldBarcode=@LotNonew1
    -- ... đến @LotNonew6
    -- Sau đó JOIN STB_SetInfo với danh sách IN (@pBarcode, @LotNonew1, ..., @LotNonew6)
    ```
*   Trích xuất **ModelSize**: Kích thước như 0813 (8x13mm) được bóc từ `STB_ModelBasicInfo` để match với điện giải.

### 3.3 Luồng F721 — UPDATE khi đang SELECT & Logic Tồn Kho
*   SP `usp_vvt_MaterialLotInfo_get` (F721) thực tế có lệnh **UPDATE** 2 bảng `STB_MaterialDocLotInfo` và `STB_MaterialLotInfo` mỗi khi chạy. Hàm `fn_VVT_getdatebyVendorLot` parse mã Vendor Lot để điền ngày sản xuất nếu bị thiếu. Việc này là auto-heal nhưng tiềm ẩn lỗi Race condition.
*   **Logic tính StockQty thực tế** (sau khi cấn trừ phần đã chia lô):
    ```sql
    CASE
        WHEN LTDX.DIVIDE_STOCKQTY > 0 OR LTDX.DIVIDE_STOCKQTY IS NOT NULL
        THEN ISNULL(MLI.CurrentQty, mdli.StockQty) - LTDX.DIVIDE_STOCKQTY
        ELSE ISNULL(MLI.CurrentQty, mdli.StockQty)
    END AS StockQty
    ```
*   **Trạng thái hạn dùng (Aging):** 'Safe' (Hạn dùng > 30 ngày, hoặc > 15 ngày đối với Coating/Slitting), 'Warning' (< 30 ngày), 'Expired' (đã hết hạn).
*   **Loại trừ Lot trùng lặp (Sự cố BG2):** Thêm điều kiện lọc cứng `AND CreateUserID <> '23091804'`.

---

## 4. 🗃️ Bảng Ẩn Chứa Logic Quan Trọng (Custom Vietnam)

Những bảng này do team Vietnam tự tạo thêm, không nằm trong framework gốc Hàn Quốc. Nếu không biết chúng, bạn không thể debug được.

| Bảng | Mục đích thực tế |
|------|------------------|
| `stb_vvt_materialbo` | "BOM Ngầm" của B597. Define Model Size nào dùng loại Tancha/Sleeve mã nào. Nếu có model mới, PHẢI thêm vào đây. |
| `STB_LotChangeMaterialHistory` | Lưu lịch sử đổi Barcode (OldBarcode → NewBarcode). B597 dùng bảng này để dò ngược 6 cấp lấy mã gốc. |
| `stb_vvt_OpenExpiredMaterial` | Danh sách "Ân Xá" cho NVL hết hạn. Thêm LotID vào bảng này = Bypass kiểm tra Hạn Sử Dụng. |
| `STB_InterimProdQtyInfo` | Bảng nháp số lượng giữa chừng (InbrinskQty tại B530). Bị xóa trắng mỗi lần Submit. |
| `stb_slittinglocationconfig_vvt` | Cấu hình Slitting động. Tránh việc hard-code cấu hình trong SP. |
| `STB_VN_DIVIDEMATERIALSMAL` | Quản lý chia nhỏ Lot nguyên vật liệu thành các lô nhỏ hơn. |

---

## 5. ⚠️ 5 Điểm Nguy Hiểm ẨN — Developer Phải Biết

1.  **Nguy hiểm 1 (F721 Update)**: SP F721 Write khi đang Read. Không có transaction. Nếu parse Date sai, sẽ ghi Date sai hàng loạt.
2.  **Nguy hiểm 2 (Bug Null)**: Logic `IF @SIExtInt01 = Null` trong SP B530 làm Gate 20 phút bị tắt ngấm. (SQL phải dùng `IS NULL`).
3.  **Nguy hiểm 3 (No Rollback)**: Bending/Tapping (B717) chỉ lưu 1 lần, ghi đè hoặc insert, nếu sai chỉ có thể Update bằng tay trong DB, trên UI không có nút Sửa/Xóa.
4.  **Nguy hiểm 4 (Hardcode User)**: SP `usp_Set_VVT_Info_get` (B452) hardcode danh sách User được phép đổi Line (`mrluan`, `phuong`). Mất quyền nếu đổi username.
5.  **Nguy hiểm 5 (Hardcode Model)**: Cả tá model name được Hardcode trong `usp_Vietnam_RawMaterialInputHist_uid`. Có model mới → Phải vào SP gõ thêm dòng SELECT.

---

## 6. 📡 Các Functions Quan Trọng

### `fn_VVT_getdatebyVendorLot(MaterialCode, LotNo)`
*   **Mục đích:** Chuyển mã Lot của Vendor thành Date (`YYYY-MM-DD`).
*   **Nơi dùng:** F721, Chi tiết Lot.
*   **Rủi ro:** Vendor đổi định dạng mã → Hàm crash → Tồn kho F721 bị lỗi (Ngày SX rỗng).

### `fn_GetJobDateShiftTime(DateTime, CompanyCode, WorkCenter, Line, Route, NULL)`
*   **Mục đích:** Tính Ca sản xuất tự động (`JobDate`, `ShiftCode A/B/C`).
*   **Tại sao:** Ngăn gian lận ca bằng cách tự động tính từ thời gian Scan thực tế, khóa cứng không cho Client chọn ngày/ca.

---

## 7. 🎯 Hướng Dẫn & Golden Rules Khi Debug NAIS

### 7.1 Golden Rules Khi Debug NAIS

1.  **Lỗi FIFO / Hết hạn B597:**
    *   Kiểm tra HOLD: ⚠️ Bảng `STB_MaterialHoldInfo` **KHÔNG TỒN TẠI** (lỗi dùng bảng do tài liệu cũ mô tả sai). Logic HOLD đúng dùng warehouse code:
        ```sql
        SELECT LotID, MaterialWarehouseCode 
        FROM STB_MaterialLotInfo 
        WHERE LotID = 'MÃ_LOT_CẦN_CHECK' 
          AND (MaterialWarehouseCode LIKE 'HOLDING_%' OR MaterialWarehouseCode = 'HOLDING_VN_WH')
        ```
    *   Kiểm tra Expiry: `LotAttr10` + (`MMExtInt01` * 30 ngày)
    *   Bảng Ân Xá: `SELECT * FROM stb_vvt_OpenExpiredMaterial WHERE LotID = 'MÃ_LOT_CẦN_CHECK'`
2.  **Lỗi B530 "Chưa nhập đủ":**
    *   Check BOM: `SELECT * FROM STB_ProductionOrderRouting WHERE PONo = 'MÃ_PO_CẦN_CHECK'`
    *   Check lịch sử Scan: `SELECT * FROM STB_RawMaterialInputHist WHERE ProdLotQty = '...'`
3.  **F721 Tồn kho trắng trơn hoặc Exception:**
    *   K.tra `LotAttr10`: `SELECT LotAttr10 FROM STB_MaterialDocLotInfo WHERE LotID = '...'` (Nếu NULL = hàm VendorLot Date bị fail).

### 7.2 Production Data Metrics (Live)

Số liệu từ môi trường Production Vinatech MES:

*   **Tổng số SP (Stored Procedures) trong DB**: 3,373 SP.
    *   Prefix `usp_`: 3,149
    *   Prefix `fn_`: 111
    *   Khác: Hơn 100 SP/Function
*   **Số Unit hoàn thành**: Tỉ lệ ControlNo sinh ra mới đạt trạng thái `ProdFinish=True` dao động ~ 43% mỗi tuần.
*   **Độ sâu Trace Barcode**: Thuật toán quét truy xuất nguồn gốc có thể lội ngược lên tối đa 6 Cấp độ biến đổi (`STB_LotChangeMaterialHistory`).
*   **Tuổi thọ Shelf Life**: Cột `MMExtInt01` đang dao động giá trị từ 1 tháng tới hơn 1200 ngày.
*   Bảng BOM "Ngầm" `stb_vvt_materialbo` đang chứa 15 cột mapping tĩnh (wipcode, part, size...).

---
*Cập nhật: 2026-06-12 | Gộp KB_12 và KB_13*

---

## 8. 🔬 Deep Structural X-Ray (Phân Tích Cấu Trúc Sâu — 2026-06-18)

### 8.1 Top 15 Bảng Lớn Nhất (by Row Count)

| # | Bảng | Rows | Ghi chú |
|---|---|---|---|
| 1 | **STB_VVT_ESRDATA** | **398,078,765** | Dữ liệu đo ESR — bảng lớn nhất hệ thống |
| 2 | STB_ProductStockInfo | 64,556,565 | Tồn kho thành phẩm |
| 3 | STB_CommInspMeasureHist | 60,071,432 | Lịch sử đo kiểm PQC |
| 4 | STB_ESRInspectionData | 39,668,717 | Dữ liệu kiểm tra ESR |
| 5 | STB_CommInspDocItem | 33,138,367 | Chi tiết phiếu kiểm tra |
| 6 | STB_IoTMeasureHist | 28,786,078 | Dữ liệu IoT sensor |
| 7 | STB_Vvt_SdProds | 22,868,733 | SD Products tổng hợp |
| 8 | STB_MaterialQcSampleResult | 19,943,218 | Kết quả mẫu QC |
| 9 | **STB_ProcedureLog** | **19,317,963** | Camera giám sát SP (log mọi SP chạy) |
| 10 | STB_VN_FINISHGOODS_CAPTURE | 13,555,570 | Snapshot thành phẩm (Agent Job) |
| 11 | stb_DetailAgaingHN | 11,113,742 | Chi tiết Aging Hà Nam |
| 12 | STB_MaterialLotSnapshot | 9,912,516 | Snapshot tồn kho NVL |
| 13 | stb_SDValueTest | 9,885,729 | Dữ liệu test SD |
| 14 | STB_ProductStockInfoUpload | 9,241,518 | Upload tồn kho TP |
| 15 | STB_VietnamSemiInventory | 8,212,627 | Bán thành phẩm VN |

> ⚠️ **398 triệu dòng ESR** = rủi ro performance lớn nhất. Query trên bảng này không có WHERE clause chính xác sẽ timeout.

### 8.2 SP Coding Patterns (Phong cách viết code)

| Pattern | Số SPs | Tỉ lệ | Ghi chú |
|---|---|---|---|
| **TRY/CATCH** | 564 | 16.6% | Error handling chuẩn |
| **CURSOR** | 550 | 16.2% | Duyệt từng dòng (đặc trưng NAIS) |
| **OPENXML** | 520 | 15.3% | UI gửi data qua XML → SP parse |
| **BEGIN TRAN** | 50 | 1.5% | Transaction rõ ràng (rất ít!) |
| **DYNAMIC SQL** | 9 | 0.3% | sp_executesql |

> ⚠️ **Chỉ 50/3,395 SPs (1.5%) dùng Transaction tường minh.** Phần lớn SP không wrap trong BEGIN TRAN → nếu crash giữa chừng, data có thể bị partial write.
>
> ⚠️ **550 SPs dùng CURSOR** = pattern đặc trưng của NAIS Korea. CURSOR tốn memory và chậm hơn set-based operations, nhưng logic phức tạp (chạy từng dòng, gọi sub-SP) buộc phải dùng.

### 8.3 Structural Constraints (Ràng buộc cấu trúc)

| Metric | Giá trị | Ý nghĩa |
|---|---|---|
| **Foreign Keys** | **27** (trên 994 tables) | Rất ít FK → data integrity phụ thuộc vào SP logic, không phải DB engine |
| **Indexes** | 1,021 | Đủ cho performance cơ bản |
| **SQL Views** | 62 | VW_WipResult (lớn nhất, 17K chars, join 9 tables) |
| **Vinatech custom tables** | 201 / 994 | 20.2% tables do Vinatech tự tạo |

> 💡 **27 FK trên 994 tables = hệ thống "tin tưởng SP"**: NAIS thiết kế để SP đảm bảo data integrity thay vì dựa vào FK constraints. Khi IT Admin UPDATE trực tiếp bằng SQL, **không có FK nào chặn** → phải tự kiểm tra tính toàn vẹn.

### 8.4 STB_ProcedureLog — Camera Giám Sát Real-Time

```sql
-- Xem SP nào đang chạy ngay bây giờ
SELECT TOP 10 ProcedureName, VariableName, VariableValue, CreateDateTime
FROM STB_ProcedureLog WITH(NOLOCK)
ORDER BY CreateDateTime DESC

-- Kết quả mẫu (2026-06-18 21:00:09):
-- usp_DoProcessProdRouteHistForBarcode2 | @ProdRouteHistNo | 20260618001462
-- usp_DoProcessProdRouteHist            | @ProdRouteHistNo | 20260618001462
```

> **19.3 triệu dòng** log = ~5+ năm dữ liệu. Mỗi lần worker quét barcode → SP ghi 1 dòng vào bảng này. Dùng để:
> - Truy vết: "Ai quét barcode này lúc mấy giờ?"
> - Debug: "SP nhận tham số gì khi bị lỗi?"
> - Audit: "Có bao nhiêu sản phẩm qua công đoạn hôm nay?"
