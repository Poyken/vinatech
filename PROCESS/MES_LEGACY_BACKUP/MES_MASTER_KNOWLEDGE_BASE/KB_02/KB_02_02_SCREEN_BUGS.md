
<!--
AI-READY METADATA
Purpose: Sổ tay các kịch bản lỗi & hướng dẫn khắc phục theo TCode của phân hệ Kho WMS (A130, F110, F130, F330, F430, F721, F741-F748, F750, F761, HN00, HN101)
Scope: WMS Screen Bug Troubleshooting
Single Source of Truth: KB_02_02_SCREEN_BUGS.md (WMS Bug Fixbook)
Target Screens: A130, F110, F130, F140, F312, F330, F430, F721, F741-F748, F750, F761, HN00, HN101
Target Tables: STB_MaterialLotInfo, STB_MaterialDocInfo, STB_MaterialDocLotInfo, STB_WarehouseLocation
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_02 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/INDEX.md)
  - [KB_02_01_WMS_CORE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md)
-->

# KB_02_02 — WMS Screen Bugs & Troubleshooting

> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_02 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/INDEX.md)

---


### [F330] — Lỗi 1: Không hiển thị hoặc thiếu vị trí kho (Location) khi làm thủ tục nhập kho hoặc chuyển kho
*   **Triệu chứng:** Khi thực hiện nhập kho tại **F330** hoặc điều chuyển kho, người dùng không thấy vị trí kho (Location) trong danh sách để chọn, hoặc hệ thống báo lỗi không tồn tại vị trí.
*   **Nguyên nhân gốc:** Chưa khai báo Location hoặc cờ sử dụng bị tắt (`IsUsed = 0`) trong bảng danh mục kho `STB_WarehouseLocation`.
*   **Cách khắc phục:** Vào màn hình **A130** (hoặc check trực tiếp bảng `STB_WarehouseLocation`), cấu hình thêm vị trí kho tương ứng cho mã kho và bật cờ hoạt động.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_07/KB_07_01_OVERVIEW.md § 8](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md#8-a130-kholocation--đối-tác).

---


## [F110] — Operating Properties (Cấu hình thuộc tính quản lý tồn kho)

### [B523]/[B525] — Lỗi 1: Vật tư mới không thực hiện gộp Box được tại hoặc
*   **Triệu chứng:** Khi công nhân quét gộp Box tại chuyền sản xuất, hệ thống báo lỗi chặn giao dịch do thiếu Lot hoặc cờ Barcode của mã vật tư đó.
*   **Nguyên nhân gốc:** Bảng cấu hình thuộc tính quản lý kho `STB_MaterialStockAttributeInfo` chưa được tạo dòng cho mã vật tư mới, hoặc các cờ quản lý `IsLotUse`, `IsUseBarcode` đang bị tắt (bằng 0).
*   **Cách khắc phục:** Vào màn hình **F110**, tìm mã vật tư, tick chọn `IsLotUse` và `IsUseBarcode` rồi nhấn Lưu. Hoặc chạy SQL cập nhật trực tiếp:
    ```sql
    UPDATE STB_MaterialStockAttributeInfo SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'MÃ_VẬT_TƯ';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#2-cấu-hình-vận-hành-f110).

---


## [F130] / [F140] / [A210] — Supplier Mapping & Material Sync (Luồng tích hợp nhà cung cấp & đồng bộ vật tư)

### [F312] — Lỗi 1: Popup chọn Nhà cung cấp trống không khi tạo phiếu nhập kho ở
*   **Triệu chứng:** Thủ kho tạo phiếu nhập kho tại **F312** nhưng khi mở popup chọn nhà cung cấp thì danh sách trống rỗng.
*   **Nguyên nhân gốc:** Nhà cung cấp chưa được mapping liên kết được phép cung cấp mã vật tư tương ứng trong bảng `STB_MaterialVendorMapping` (Màn hình **F130** hoặc **F140**).
*   **Cách khắc phục:** Vào màn hình **F130** (chọn NCC, tick chọn các vật tư được phép cung cấp) hoặc **F140** (chọn vật tư, tick chọn NCC được phép mua) rồi nhấn Lưu. Hoặc chạy SQL chèn trực tiếp:
    ```sql
    INSERT INTO STB_MaterialVendorMapping (MaterialCode, VendorCode, IsUsed, CreateDateTime, CreateUserID)
    VALUES ('MÃ_VẬT_TƯ', 'MÃ_NCC', 1, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại ../KB_07/KB_07_01_OVERVIEW_FLOWS.md § 6.

---


## [F330] — Goods Receipt & Part Labels (Nhập kho nguyên vật liệu)

### Lỗi 1: Báo lỗi "Exception occurred" khi lưu phiếu nhập kho
*   **Triệu chứng:** Thủ kho nhập thông tin và click Lưu phiếu tại **F330** hệ thống văng popup báo lỗi Exception.
*   **Nguyên nhân gốc:** Trường `LotAttr10` (Đặc tính 10 / Ngày sản xuất Vendor) bị Null hoặc do định dạng quét mã Lot nhà cung cấp in quá dài vượt quá giới hạn thiết lập của trường.
*   **Cách khắc phục:**
    1. Cấu hình lại chiều dài quét cắt chuỗi mã Lot Vendor trên tab 3 giao diện F330.
    2. Sửa SQL Function parse ngày SX `fn_VVT_getdatebyVendorLot_MergeCode` nếu NCC thay đổi định dạng in Lot trên tem (Xem chi tiết tại [KB_02 § 4.11](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#411-lỗi-không-lưu-được-f330---cấu-hình-và-sửa-lỗi-đọc-đặc-tính-10-vendor-lot-no)).

### [F330] — Lỗi 2: Cần hủy/xóa phiếu nhập kho đã được Xác nhận (Confirmed)
*   **Triệu chứng:** Thủ kho click xác nhận nhập nhầm số lượng/mã hàng và cần hủy phiếu nhập kho.
*   **Nguyên nhân gốc:** Giao dịch đã Confirmed và sinh LotInfo nên không thể xóa trực tiếp trên giao diện UI.
*   **Cách khắc phục:**
    Chạy SQL Script xóa theo thứ tự ngược (xóa IQC trước nếu có, sau đó xóa LotInfo, DocLotInfo, DocDetail và cuối cùng là DocInfo) để tránh vi phạm khóa ngoại FK:
    ```sql
    -- Hủy phiếu nhập F330
    DELETE FROM STB_MaterialLotInfo WHERE LotID IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU');
    DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU';
    DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = 'MÃ_PHIẾU';
    DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'MÃ_PHIẾU';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 4.16](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#416-hủy-phiếu-nhập-kho-f330-đã-confirmed).

### Lỗi 3: Không đọc được ngày sản xuất cho nguyên vật liệu PCB/dây điện (không tự động nhảy hạn dùng, tự động vào kho HOLDING)
*   **Triệu chứng:** Khi quét mã Lot nhà cung cấp cho các mã PCB (`BEPCBA-%`) và dây điện (`BEMC00-%`) tại F330, nếu mã Lot không bắt đầu bằng ký tự `'2'` (không theo format date-based lot thông thường), hệ thống không parse được ngày sản xuất, lưu `1900-01-01` vào DB, gây lỗi hạn sử dụng hoặc tự động đưa Lot vào kho `HOLDING`. Ngoài ra, khi người dùng sửa ngày sản xuất trên lưới F330 và nhấn nút "Lot 변경" (Lot Change), hệ thống không cập nhật ngày sản xuất thực tế (`LotAttr10`) trong bảng tồn kho `STB_MaterialLotInfo`.
*   **Nguyên nhân gốc:** 
    1. Hàm SQL `fn_VVT_getdatebyVendorLot_MergeCode` không có nhánh xử lý fallback cho mã PCB/dây điện khi Vendor Lot không bắt đầu bằng `'2'`.
    2. SP `usp_DoChangeMaterialDocLotInfo` khi update tồn kho `STB_MaterialLotInfo` chỉ cập nhật cột `LotNo` mà bỏ quên cột `LotAttr10` (ngày sản xuất / MFG Date).
*   **Cách khắc phục:**
    1. Cập nhật SQL Function `fn_VVT_getdatebyVendorLot_MergeCode` để tự động fallback về ngày hiện tại (`GETDATE()` / ngày về) cho các mã PCB (`BEPCBA-%`), dây điện (`BEMC00-%`) và phụ kiện liên quan nếu Vendor Lot không đúng định dạng.
    2. Cập nhật SP `usp_DoChangeMaterialDocLotInfo` để khi bấm Lot 변경 (Lot Change) sẽ cập nhật cả cột `LotAttr10` trong `STB_MaterialLotInfo` và `STB_MaterialDocLotInfo`.

---

## [F430] — Goods Issue / Production Material Request (Xuất kho ra chuyền)

### Lỗi 1: Chặn quét xuất kho báo lỗi vi phạm nguyên tắc FIFO
*   **Triệu chứng:** Quét xuất Lot NVL ra chuyền tại **F430** hệ thống chặn và báo lỗi vi phạm FIFO (Lot nhập sau không được xuất trước).
*   **Nguyên nhân gốc:** Bật cờ `IsFIFO = 1` tại F110 và SP `usp_VVTMaterialWarehouse_validFIFO` phát hiện có Lot khác cùng mã có ngày nhập kho `CreateDateTime` cũ hơn đang tồn kho.
*   **Cách khắc phục:**
    1. Yêu cầu thủ kho tìm đúng Lot cũ nhất trong kho để xuất trước.
    2. Trường hợp khẩn cấp (hàng cũ bị hỏng hoặc thất lạc chưa kiểm kê), IT có thể bypass bằng cách lùi ngày tạo `CreateDateTime` của Lot hiện tại trên DB, hoặc tạm thời tắt check FIFO của mã vật tư đó bằng cách update cờ `IsFIFO = 0` tại bảng `STB_MaterialStockAttributeInfo`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 4.9](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#49-fifo--validation-nvl-tắtbật-chặn).

### Lỗi 2: Cần thu hồi Lot nguyên liệu đã xuất nhầm lên chuyền (Revert xuất kho)
*   **Triệu chứng:** Lot hàng đã bấm xuất ra chuyền tại F430 nhưng công nhân không chạy và cần trả lại kho gốc ROH.
*   **Nguyên nhân gốc:** Giao dịch xuất kho đã chèn log lịch sử vào bảng `STB_MaterialWarehouseInOutHist` và cập nhật kho ảo trên chuyền.
*   **Cách khắc phục:**
    Sử dụng Transaction xóa dòng log giao dịch và cập nhật kéo Lot về kho vật lý ban đầu:
    ```sql
    BEGIN TRAN;
    DELETE FROM STB_MaterialWarehouseInOutHist WHERE LotID = 'MÃ_LOT' AND MaterialWarehouseInOutHistNo = 'MÃ_GIAO_DỊCH_XUẤT_SAI';
    UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01' WHERE LotID = 'MÃ_LOT';
    COMMIT TRAN;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 4.17](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#417-thu-hồi-lot-từ-f430-về-kho-revert-xuất-kho).

### Lỗi 3: Cần sửa/lùi ngày xuất kho của Lot vật tư đã xuất ra chuyền ở màn F430
*   **Triệu chứng:** Người dùng yêu cầu thay đổi/lùi ngày xuất kho thực tế của các mã Lot đã xuất về một ngày nhất định trong quá khứ để làm báo cáo hoặc sửa sai sót thời gian.
*   **Nguyên nhân gốc:** Khi bấm xác nhận xuất kho tại F430, hệ thống ghi nhận thời gian xuất kho vào trường `CreateDateTime` của bảng lịch sử giao dịch `STB_MaterialWarehouseInOutHist`.
*   **Cách khắc phục:**
    1. Tra cứu mã giao dịch xuất kho (`MaterialWarehouseInOutHistNo`) của Lot:
       ```sql
       SELECT MaterialWarehouseInOutHistNo, LotID, CreateDateTime FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK) WHERE LotID = 'MÃ_LOT' ORDER BY CreateDateTime DESC;
       ```
    2. Cập nhật lùi ngày trong `STB_MaterialWarehouseInOutHist` qua Transaction (giữ nguyên giờ phút giây):
       ```sql
       BEGIN TRAN;
       UPDATE STB_MaterialWarehouseInOutHist
       SET CreateDateTime = CAST('YYYY-MM-DD' AS DATETIME) + CAST(CreateDateTime AS TIME)
       WHERE MaterialWarehouseInOutHistNo = 'MÃ_GIAO_DỊCH_XUẤT_SAI';
       COMMIT TRAN;
       ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 4.6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#46-sửa-ngày-xuất-kho-màn-f430).

### Lỗi 4: Ô "Mã kho hàng (Tới)" thiếu kho Hưng Yên và ô "Mã chuyền" bị trống khi xuất kho inter-factory sang Hưng Yên (VVT_F5)
*   **Triệu chứng:** Người dùng mở popup xuất kho `VNT_MaterialWarehouseInOutHistReg` tại F430/F433 để xuất chuyển NVL sang nhà máy Hưng Yên (`VVT_F5`), nhưng ô "Mã kho hàng (Tới)" không hiển thị kho Hưng Yên. Đồng thời ô "Mã chuyền" bị trắng tinh không có dữ liệu để chọn. Nếu dùng `UNION ALL` trong SP popup sẽ bị lỗi trùng khóa chính / trùng dòng trên lưới (`Duplicate primary key`).
*   **Nguyên nhân gốc:** 
    1. Popup `TargetMaterialWarehouse_Search` gọi SP `usp_TargetMaterialWarehouse_popup` lọc theo nhà máy hiện tại (`WorkCenterCode = 'VVT_F1'`/`'VVT_F2'`), lọc bỏ các kho của `VVT_F5`.
    2. Popup ô Mã chuyền (`LineInfo_InoutMaterial`) gọi SP `usp_LineInfo_popup_InoutMaterial` lọc `WHERE LI.MaterialWarehouseCode = @SourceMaterialWarehouse`. Mã chuyền `HY_BN`/`HY_BG` bị `MaterialWarehouseCode = NULL` hoặc khi chọn các kho Hưng Yên khác nhau (`HOLDING_HY_WH`, `ROUTE_HY_WH`...) bị so sánh sai.
*   **Cách khắc phục:**
    1. Bổ sung `UNION` (⚠️ **BẮT BUỘC DÙNG `UNION`, KHÔNG DÙNG `UNION ALL`** để khử trùng lặp bản ghi kho, tránh lỗi trùng khóa chính Duplicate Key trên UI) nhóm kho Hưng Yên (`WorkCenterCode = 'VVT_F5'`) vào SP `usp_TargetMaterialWarehouse_popup`.
    2. Chèn 2 mã chuyền đại diện `HY_BN` (Bắc Ninh - `VVT_F1`) và `HY_BG` (Bắc Giang - `VVT_F2`) vào `STB_LineInfo` với `MaterialWarehouseCode = 'ROH_HY_WH'`.
    3. Cập nhật SP `usp_LineInfo_popup_InoutMaterial` nhận diện linh hoạt các kho Hưng Yên:
       ```sql
       WHERE ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) 
         AND ((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))
         AND (LI.MaterialWarehouseCode = @SourceMaterialWarehouse OR (LI.LineCode IN ('HY_BN', 'HY_BG') AND @SourceMaterialWarehouse LIKE '%HY%'))
         AND LI.IsUsed = 1
       ```
*   **Chi tiết nghiệp vụ:** Xem SP `usp_TargetMaterialWarehouse_popup` và `usp_LineInfo_popup_InoutMaterial`. Updated by vanduc & Mrs.VanOc (2026-07-21). Hải Triều note: dùng `UNION` khử trùng khóa chính.

### Lỗi 5: Kiểm tra và theo dõi hàng xuất điều chuyển từ Bắc Ninh (BN) sang Hưng Yên (HY)
*   **Triệu chứng:** Người dùng tại Bắc Ninh xuất kho điều chuyển vật tư/bán thành phẩm sang nhà máy Hưng Yên nhưng hệ thống NAIS bên Hưng Yên không tìm thấy hoặc không kiểm tra được dữ liệu nhận hàng.
*   **Nguyên nhân gốc:** Khi tạo giao dịch xuất kho tại F430/F433 ở Bắc Ninh, người dùng chọn sai mã kho đích (Target Warehouse) hoặc không chọn mã kho chuẩn của Hưng Yên.
*   **Cách khắc phục:**
    1. Khi xuất chuyển từ Bắc Ninh sang Hưng Yên, bắt buộc chọn **Mã kho hàng (Tới)** là `ROH-HY-WH` (Kho nguyên vật liệu / linh kiện Hưng Yên).
    2. Đảm bảo mã Line tương ứng đã được thiết lập `MaterialWarehouseCode = 'ROH_HY_WH'`.

---


## [F721] — WMS Material Stock (Tồn kho nguyên vật liệu)

### Lỗi 1: Tồn kho của Lot bị treo ở trạng thái HOLD (không xuất được sản xuất)
*   **Triệu chứng:** Lot hàng hiển thị tồn kho đầy đủ tại màn hình **F721** nhưng khi quét ở F430 báo lỗi HOLD cấm xuất.
*   **Nguyên nhân gốc:** Do Lot đang ở kho ảo `HOLDING_WH` (hoặc `HOLDING_VN_WH`, `HOLDING_HN_WH`) do QC chưa đánh giá hoặc do hệ thống tự động đưa vào vì thiếu Đặc tính 10 lúc nhập kho.
*   **Cách khắc phục:**
    Kiểm tra chất lượng mẫu đo. Nếu QC đã PASS thực tế, chạy script chuyển kho thủ công kéo Lot về kho chính ROH:
    ```sql
    UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01' WHERE LotID = 'MÃ_LOT';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 4.7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#47-chuyển-từ-kho-holding-sang-kho-chính).

---


## [F741] — Lot Splitting (Quy trình tách Lot NVL)

### Lỗi 1: Lỗi không thực hiện tách được Lot NVL trên giao diện
*   **Triệu chứng:** OP thao tác chia nhỏ Lot NVL tại **F741** báo lỗi không in được tem hoặc sai số lượng chia.
*   **Nguyên nhân gốc:** Thiết lập quy cách đóng gói và cờ thuộc tính Lot tại F110 bị thiếu.
*   **Cách khắc phục:**
    Kiểm tra và thực hiện cấu hình đúng quy trình tách Lot trên UI, đảm bảo số lượng của các Lot con tổng cộng bằng Lot mẹ (Xem chi tiết tại [../KB_02/KB_02_01_WMS_CORE.md § 4.20](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#420-f741--quy-trình-tách-lot-nguyên-vật-liệu-lot-splitting)).

---


## [F742] / [F746] — Slitting & Curling (Chia cuộn điện cực / Bo miệng)

### Lỗi 1: Cần hủy hoặc rollback giao dịch chia cuộn Slitting
*   **Triệu chứng:** Công nhân nhập sai thông số số lượng/chiều dài cuộn con sau chia cuộn Slitting tại **F742** và cần hoàn tác giao dịch.
*   **Nguyên nhân gốc:** Giao dịch đã sinh các Lot con liên kết khóa ngoại với Lot mẹ.
*   **Cách khắc phục:**
    Chạy script xóa ngược: bắt buộc phải tìm và xóa các bản ghi giao dịch của các Lot con trong bảng `STB_RawMaterialInputHist` (hoặc `STB_MaterialDocLotInfo` tùy trạm) trước, sau đó mới tiến hành xóa/revert Lot mẹ tại F742.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 10.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#101-hủyrollback-slitting-f742-và-f746).

### Lỗi 2: Mismatch logic tính tuổi thọ dao Slitting và Hardcode địa lý Bắc Giang
*   **Triệu chứng:** Máy chia cuộn điện cực tại nhà máy Hà Nam hoặc Hưng Yên bị bypass hoàn toàn việc kiểm tra dao cắt (không cảnh báo thay dao), hoặc báo lỗi không tìm thấy máy nếu cố cấu hình dao. Hoặc dao slitting bị khóa thay dao quá sớm do tính sai hao mòn.
*   **Nguyên nhân gốc:** 
    1. SP `usp_DoCreateSlittingResult` bị hardcode lọc cứng nhà máy Bắc Giang (`RouteCode = 'V-11_BG'`).
    2. Hệ thống đếm số lần cắt (số cuộn con) thay vì tổng số mét cắt thực tế (`GoodQtyLength`) để so sánh với tuổi thọ thiết kế (`StandardQty`), dẫn đến dao bị khóa sớm.
*   **Cách khắc phục:** 
    Cập nhật SP `usp_DoCreateSlittingResult`: sửa điều kiện lọc `RouteCode LIKE 'V-11%'` để hỗ trợ toàn hệ thống và đổi cơ chế tính tuổi thọ sang dùng `SUM(GoodQtyLength)`:
    ```sql
    -- 1. Sửa RouteCode check hỗ trợ toàn hệ thống
    IF @MachineCode IN (select MachineCode from STB_ProductMachine where RouteCode LIKE 'V-11%') and @KnifeCheck > 0
    
    -- 2. Đo tuổi thọ thực tế bằng tổng số mét cắt
    SELECT @ProdQtyCheck = ISNULL(SUM(GoodQtyLength), 0) from STB_ElectrodeSlittingResult where SlittingKnifeLotID = @SlittingKnifeLotID
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

---


## [F743]~[F748] / [C243] — Electrode Slitting & QC (Slitting & QC Điện cực Hà Nam)

### [F744] — Lỗi 1: Cảnh báo "Trùng mã nguyên liệu" khi thiết lập chiều rộng cắt ở
*   **Triệu chứng:** Khai báo chiều rộng cắt cho Model mới tại **F744** bị hệ thống báo lỗi trùng mã và từ chối lưu.
*   **Nguyên nhân gốc:** Bản ghi cấu hình chiều rộng cho mã vật liệu tương ứng đã tồn tại trong bảng cấu hình master.
*   **Cách khắc phục:** Kiểm tra lại danh sách cấu hình hiện tại để chỉnh sửa trực tiếp thông số `Width` của bản ghi cũ thay vì tạo mới.

### [F430] — Lỗi 2: Lỗi "Lot không tồn tại" khi quét xuất kho điện cực tại
*   **Triệu chứng:** Quét mã Lot cuộn điện cực sau khi slitting tại **F430** để xuất lên chuyền sản xuất bị báo lỗi Lot không tồn tại.
*   **Nguyên nhân gốc:** Lô hàng sau khi chốt slitting tại **F743** chưa được bộ phận QC tiến hành kiểm định và xác nhận PASS tại màn hình **C243**.
*   **Cách khắc phục:** QC truy cập màn hình **C243**, tìm Lot điện cực tương ứng, thực hiện kiểm định và xác nhận kết quả chất lượng PASS để Lot được kích hoạt tồn kho.

### [F743] — Lỗi 3: Cần hủy hoặc rollback kết quả chia cuộn Slitting để cắt lại tại
*   **Triệu chứng:** OP nhập sai thông số chiều dài/số lượng cuộn con khi chia cuộn và cần rollback để thực hiện lại từ đầu.
*   **Nguyên nhân gốc:** Giao dịch chốt Slitting đã ghi nhận các Lot con vào bảng lịch sử.
*   **Cách khắc phục:** OP truy cập màn hình lịch sử slitting **F746**, tìm và xóa bỏ các dòng lịch sử của Lot con tương ứng trước, sau đó mới có thể thực hiện rollback/xóa Lot mẹ tại màn hình rollback **F742**.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 10.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#101-flow-slitting-hà-nam).

### [F744] — Lỗi 4: Không tìm thấy mã Foil mới trong popup để thiết lập chiều rộng cắt ở
*   **Triệu chứng:** Khi bấm nút Thêm trên giao diện F744 để cấu hình chiều rộng slitting cho model/foil mới, người dùng không tìm thấy mã foil cần chọn trong popup. Hoặc trên lưới F744 thiếu dòng của mã foil con.
*   **Nguyên nhân gốc:** 
    1. Mã foil con (ví dụ: `10199058855` - U199 58.8VFS 5.5mm) chưa được khai báo trong danh mục vật tư `STB_MaterialMaster`. Popup của màn hình F744 (gọi stored procedure `usp_SlittingMaterial_popup_2`) chỉ lấy các vật tư đã đăng ký trong `STB_MaterialMaster` thuộc các nhóm `ProductGroupCode` là `ANODE-FOIL`, `CATHODE-FOIL`, `CON-PAPER`, `RadialTaping`.
    2. Bảng cấu hình chiều rộng `STB_WidthSlitting` chưa có dòng thiết lập chiều rộng cho mã foil tương ứng.
*   **Cách khắc phục:**
    1. Đăng ký mã foil con vào bảng `STB_MaterialMaster` (ví dụ mã `10199058855` với `ProductGroupCode = 'ANODE-FOIL'`, `MaterialTypeCode = 'ROH'`, `MaterialUnit = 'M2'`).
    2. Cấu hình thuộc tính tồn kho trong `STB_MaterialStockAttributeInfo` cho mã foil mới.
    3. Thêm bản ghi cấu hình chiều rộng cắt (ví dụ: `Width = 5.5`) vào bảng `STB_WidthSlitting`.
    
    *Tham chiếu SQL script mẫu đã lưu tại local: **add_foil_f744_5.5mm.sql***

### [F743] — Lỗi 5: Tạo tem NG bị quá số lượng / Số lượng còn lại bị âm (★ DEPLOYED 2026-07-21)
*   **Triệu chứng:** Khi bấm nút "Tạo tem NG" tại F743, hệ thống tạo tem NG với số lượng vượt xa lượng còn lại thực tế (ví dụ: thực tế còn `1.13m`, nhưng sinh tem NG `25.7m`). Khi F5 lại màn hình, tổng tem chia vượt quá số lượng xuất và ô "Slg còn lại" bị âm (`-24.57m`).
*   **Nguyên nhân gốc:** Stored Procedure `usp_CreateLotSlitting_NG_HN_uid` tính số lượng NG bằng `InitialQty` (độ dài cuộn thô ban đầu trong `STB_MaterialLotInfo`, ví dụ 58m) trừ tổng tem chia OK, thay vì dùng `ActualExportQuantity` trong `STB_MaterialWarehouseInOutHist` (số lượng thực tế xuất sang kho Slitting Hà Nam, ví dụ 33.43m).
*   **Cách khắc phục:**
    1. ALTER SP `usp_CreateLotSlitting_NG_HN_uid`: lấy `ActualExportQuantity` từ `STB_MaterialWarehouseInOutHist` (lọc theo kho `ROH_HN_WH` -> `SLITTING_HN_WH`) trước khi tính `@TemCurrentQtyNG`. Không xóa code cũ mà comment khối `/* ... */`. *(Comment đánh dấu chuẩn: `-- vanduc edited by Mr.Le Quang Tai 20260721 START ... END`)*.
    2. Xóa tem NG tạo sai số lượng trên DB: `DELETE FROM STB_MaterialLotInfo WHERE LotID = 'SL20260721000089'`.
*   **Đã kiểm chứng thực tế (2026-07-21):** Lot `SL20250522000064` (Xuất Slitting `33.43m`, đã chia OK `32.30m`) bấm nút "Tạo tem NG" đã sinh đúng tem NG `SL20260721000103` số lượng `1.13m`, và ô "Slg còn lại" hiển thị chính xác `0.0000000000`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_01_QC_AND_ELECTRODE_CORE.md § 10.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#101-flow-slitting-hà-nam).

### [F742] — Lỗi 6: Cuộn nguyên liệu (Lot cha) không hiển thị trên danh sách "Chờ cắt" màn hình F742
*   **Triệu chứng:** Người dùng yêu cầu đẩy lại cuộn nguyên liệu (Lot cha, ví dụ: `SL20250522000064` / cuộn `U147-90.4VFS 33.43 m2`) lên màn hình **F742** nhưng không tìm thấy trong danh sách "Chờ cắt".
*   **Nguyên nhân gốc:** 
    1. Lot mẹ đã bị đánh dấu đã cắt (`IsSlitting = 1` hoặc `true` thay vì `0` hoặc `NULL`).
    2. Số lượng hiện tại của Lot mẹ trong bảng tồn kho bị reset về `0` (`CurrentQty = 0.00`) sau khi thực hiện giao dịch chia cuộn trước đó.
    3. Stored procedure `usp_ListInputNeedSlitting_HN` lọc điều kiện hiển thị: `IsParrent = '1'`, `IsSlitting = 0` hoặc `NULL`, và nằm ở kho `SLITTING_HN_WH`.
*   **Cách khắc phục (Script bọc transaction cho User chạy):**
    Reset lại trạng thái chưa slitting và cập nhật lại số lượng tồn kho tương ứng với số lượng thực tế cần cắt (lấy từ cột `ActualExportQuantity` của giao dịch chuyển kho gần nhất):
    ```sql
    BEGIN TRAN;
    
    -- Cập nhật trạng thái và số lượng cho Lot mẹ
    UPDATE STB_MaterialLotInfo
    SET IsSlitting = 0,
        CurrentQty = 33.43 -- Số lượng thực tế cần slitting (m2)
    WHERE LotID = 'SL20250522000064';
    
    -- Kiểm tra lại
    SELECT LotID, MaterialCode, MaterialLotNo, InitialQty, CurrentQty, MaterialWarehouseCode, IsParrent, IsSlitting 
    FROM STB_MaterialLotInfo WITH(NOLOCK)
    WHERE LotID = 'SL20250522000064';
    
    -- COMMIT TRAN; -- Đổi thành COMMIT sau khi kiểm tra OK
    ROLLBACK TRAN;
    ```

*   **Các truy vấn truy vết chi tiết (Tracert Queries):**
    1. **Tìm mã vật tư dòng U147:**
       ```sql
       SELECT TOP 10 MaterialCode, MaterialName, ProductGroupCode 
       FROM STB_MaterialMaster WITH(NOLOCK) 
       WHERE MaterialCode LIKE '%U147%' OR MaterialName LIKE '%U147%' OR MaterialCode LIKE '%90.4%';
       ```
    2. **Tìm trong lịch sử chuyển kho (lọc theo lượng xuất ~33.43 m2):**
       ```sql
       SELECT TOP 20 LotID, SourceMaterialWarehouseCode, TargetMaterialWarehouseCode, ActualExportQuantity, CreateDateTime, CreateUserID 
       FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK) 
       WHERE ActualExportQuantity BETWEEN 33.42 AND 33.44 
       ORDER BY CreateDateTime DESC;
       ```
    3. **Truy vấn trạng thái tồn kho thực tế của Lot mẹ:**
       ```sql
       SELECT LotID, MaterialCode, MaterialLotNo, InitialQty, CurrentQty, PickingQty, MaterialWarehouseCode, IsParrent, IsSlitting, LotAttr10 
       FROM STB_MaterialLotInfo WITH(NOLOCK) 
       WHERE LotID = 'SL20250522000064';
       ```

*   **Script khôi phục trạng thái ban đầu (Backup / Rollback script nếu cần hoàn tác):**
    Nếu lỡ chạy lệnh UPDATE trên mà muốn khôi phục lại trạng thái cũ lúc chưa sửa của Lot (để đối soát hoặc trả lại trạng thái lỗi ban đầu):
    ```sql
    UPDATE STB_MaterialLotInfo
    SET IsSlitting = 1,
        CurrentQty = 0.00
    WHERE LotID = 'SL20250522000064';
    ```

---




## [F750] — Stocktaking (Kiểm kê kho vật tư)

### Lỗi 1: Cảnh báo "Nguyên liệu phải được xuất kho lên Line trước khi chia nhỏ..." khi tách lô giá đỡ / chất mang (Substrate)
*   **Triệu chứng:** Khi chạy tác vụ chia/tách lô vật liệu giá đỡ substrate, hệ thống hiển thị thông báo lỗi chặn giao dịch (bằng tiếng Hàn hoặc tiếng Việt).
*   **Nguyên nhân gốc:** Lô vật liệu gốc chưa được thực hiện xuất kho lên chuyền sản xuất (chưa nằm ở kho công đoạn có cờ `IsRouteWarehouse = 1` mà vẫn đang tồn ở kho chính ROH), vi phạm điều kiện kiểm tra của Stored Procedure `usp_DoMakeStocktakingPlanResultForSupport`.
*   **Cách khắc phục:** Thủ kho thực hiện xuất kho Lot vật liệu gốc lên chuyền sản xuất trước (qua màn hình **F430**), sau đó mới thực hiện thao tác chia tách lô trên giao diện UI.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_02_SCREEN_BUGS_QC.md#f742f746--lỗi-1-hủyrollback-slitting-phải-xóa-trước](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md#f742f746--lỗi-1-hủyrollback-slitting-phải-xóa-trước).

---


## [F761] — Material GR History (Lịch sử vật tư vào kho)

### Lỗi 1: Lệch số liệu báo cáo đối soát kho kế toán do hiểu nhầm giao dịch hiển thị chữ tiếng Hàn
*   **Triệu chứng:** Khi đối soát số liệu xuất nhập kho tại **F761**, kế toán phát hiện các dòng giao dịch có cột `DocTypeName` chứa ký tự chữ Hàn Quốc gây sai lệch số liệu nhập mới.
*   **Nguyên nhân gốc:** Ký tự tiếng Hàn đại diện cho loại giao dịch "hoàn trả vật tư thừa từ sản xuất về kho ROH" (Revert từ F430) chứ không phải nhập mới từ nhà cung cấp.
*   **Cách khắc phục:** Hướng dẫn bộ phận kế toán phân biệt loại giao dịch: Giao dịch có tên tiếng Hàn là giao dịch trả hàng ảo/revert từ sản xuất về, còn giao dịch nhập mới thực tế được sinh ra từ phiếu nhập **F312**.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#5-báo-cáo-tồn-kho--lịch-sử-kho-f721-f761-f740).

---


## [HN00] / [HN101] — Hà Nam Accounting (Tồn kho & Đơn giá Hà Nam)

### [HN00] — Lỗi 1: Báo cáo tồn kho thành phẩm Hà Nam hiển thị Đơn giá bằng 0
*   **Triệu chứng:** Lưới báo cáo tồn kho HN00 hiển thị số lượng đúng nhưng cột Đơn giá và Thành tiền bị trống hoặc bằng 0.
*   **Nguyên nhân gốc:** Model sản phẩm mới chưa được khai báo đơn giá kế toán tương ứng tại màn hình **HN101** để mapping tính toán.
*   **Cách khắc phục:**
    Vào màn hình **HN101** thêm dòng thiết lập đơn giá mới cho Model, hoặc chạy script chèn trực tiếp:
    ```sql
    INSERT INTO STB_PublicCodeAndPrice (PublicCode, Price, IsUsed, WorkCenterCode, CreateDateTime, CreateUserID)
    VALUES ('MÃ_MODEL_MỚI_HOẶC_MÃ_KẾ_TOÁN', ĐƠN_GIÁ_USD, 1, 'VVT_F3', GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#7-hn101--thiết-lập-đơn-giá-theo-mã-kế-toán).

---


## [F140] — Vendor-Material Mapping (Ánh xạ NCC - Vật tư)

> 🔗 **Nội dung đầy đủ đã có tại:** [F130 / F140 / A210](#f130--f140--a210--supplier-mapping--material-sync) phía trên (triệu chứng Popup NCC trống + SQL insert + KB_07 ref).

---


## [F312] — Material Doc Edit (Sửa số lượng tài liệu nhập kho NVL)

### Lỗi 1: Cần sửa số lượng NVL đã nhập kho (MaterialDocNo)
*   **Triệu chứng:** Thủ kho nhập sai số lượng vào phiếu nhập kho, cần sửa lại.
*   **Nguyên nhân gốc:** Cột "Số tài liệu" = `MaterialDocNo` trong `STB_MaterialDocDetail`.
*   **Cách khắc phục:** Vào F312, tìm phiếu nhập kho theo MaterialDocNo, sửa số lượng. Kho chị Xuân phụ trách.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 4.5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md) và ../KB_07/KB_07_01_OVERVIEW_FLOWS.md.

---


## [F320] — Material Transfer (Chuyển kho NVL)

### Lỗi 1: Chuyển kho NVL bị lỗi hoặc không cập nhật tồn kho
*   **Triệu chứng:** Thực hiện chuyển NVL giữa các kho tại F320 nhưng số lượng tồn kho không giảm/tăng tương ứng.
*   **Nguyên nhân gốc:** Trigger `tgMaterialLotInfoForUpdate` trên `STB_MaterialLotInfo` tự động đồng bộ tồn kho. Nếu Trigger bị disable hoặc lỗi thì tồn kho không cập nhật.
*   **Cách khắc phục:** Kiểm tra trạng thái Trigger, kiểm tra bảng `STB_MaterialStock` xem số lượng.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md).

---


## [F610] — Delivery Order (Đơn giao hàng)

### [F610] — Lỗi 1: Không tạo được đơn giao hàng tại
*   **Triệu chứng:** Tạo đơn giao hàng tại F610 bị lỗi hoặc không hiện sản phẩm.
*   **Nguyên nhân gốc:** Sản phẩm chưa qua QC Audit (C530) hoặc chưa nhập kho thành phẩm.
*   **Cách khắc phục:** Kiểm tra sản phẩm đã PASS QC Audit và đã nhập kho FG.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md).

---


## [F620] — Delivery History (Lịch sử giao hàng)

### [F620] — Lỗi 1: Lịch sử giao hàng hiển thị thiếu phiếu giao
*   **Triệu chứng:** Phiếu giao đã tạo tại F610 nhưng không hiện tại F620.
*   **Nguyên nhân gốc:** Phiếu chưa được confirm/approve hoặc bộ lọc ngày bị sai.
*   **Cách khắc phục:** Kiểm tra lại bộ lọc ngày tìm kiếm, mở rộng khoảng thời gian.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md).

---


## [F710] — Warehouse Inventory (Tồn kho tổng hợp)

### [F710] — Lỗi 1: Tồn kho không khớp với thực tế
*   **Triệu chứng:** Số lượng tồn kho hiển thị tại F710 bị lệch so với kiểm kê thực tế.
*   **Nguyên nhân gốc:** Trigger `tgMaterialLotInfoForUpdate` bị lỗi hoặc tồn tại phiếu nhập/xuất chưa confirm.
*   **Cách khắc phục:** Chạy kiểm kê bằng F750 để điều chỉnh, hoặc kiểm tra trực tiếp `STB_MaterialStock`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md).

---


## [F740] — Lot Splitting & Merge (Tách/Gộp Lot NVL)

### Lỗi 1: Tách Lot NVL bị lỗi không tạo được Lot con
*   **Triệu chứng:** Thực hiện tách Lot tại F740 nhưng hệ thống không sinh Lot con.
*   **Nguyên nhân gốc:** Số lượng tách vượt quá `CurrentQty` còn lại của Lot gốc.
*   **Cách khắc phục:** Kiểm tra `CurrentQty` trong `STB_MaterialLotInfo` của Lot gốc, đảm bảo số lượng tách hợp lệ.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md) và [../KB_03/KB_03_02_CELL_LINE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md).

## [HYFG01] — Finished Goods WH HY (Kho & Xuất kho Thành Phẩm Hưng Yên)

### Lỗi 1: Báo xuất kho OK nhưng không thấy dữ liệu xuất / Không check được ProcessedLotID3 đã xuất
*   **Triệu chứng:** Khi thực hiện xuất kho tại màn hình **HYFG01**, hệ thống hiển thị thông báo xuất thành công (OK) nhưng trên danh sách không có dữ liệu hoặc không hiển thị cột `ProcessedLotID3` để kiểm tra đã xuất các mã ID nào.
*   **Nguyên nhân gốc:** Giao diện màn hình **HYFG01** chưa được cấu hình cột `ProcessedLotID3` và chưa thiết lập liên kết nguồn link dữ liệu tương tự như màn hình **F430** ở Bắc Ninh.
*   **Cách khắc phục:**
    1. Cấu hình giao diện **HYFG01** hiển thị cột `ProcessedLotID3` và thiết lập nguồn link dữ liệu (`ISNULL(NULLIF(ProcessedLotID, ''), LotID)`) tương tự như **F430**.
    2. Cung cấp danh sách các `ProcessedLotID3` tương ứng để IT cập nhật lại dữ liệu lịch sử xuất kho trên DB.
    3. Bổ sung cấu hình kho Hưng Yên vào hệ thống để quy trình nhập và xuất ghi nhận đầy đủ `ProcessedLotID3`.

### Lỗi 2: Xuất kho tại HYFG01 bị xuất hết toàn bộ số lượng trong hệ thống (Full Batch Export)
*   **Triệu chứng:** Người dùng chỉ có nhu cầu xuất 1 phần số lượng của lô hàng nhưng khi bấm xuất kho tại **HYFG01**, hệ thống tự động xuất sạch toàn bộ số lượng hiện có.
*   **Nguyên nhân gốc:** Logic màn hình xuất kho thành phẩm mặc định xử lý xuất theo toàn bộ số lượng của kiện hàng/Lot đang chọn nếu không chia tách số lượng hoặc không có tính năng Partial Quantity.
*   **Cách khắc phục:** 
    1. Hướng dẫn người dùng thực hiện chia tách Lot hoặc lập phiếu điều chuyển/xuất kho đúng số lượng mong muốn trước khi bấm xác nhận xuất.
    2. IT rà soát SP xử lý xuất kho thành phẩm tại Hưng Yên để hỗ trợ tham số số lượng xuất linh hoạt theo yêu cầu.

---

## Appendix — Warehouse Infrastructure (DB Verified 2026-06-18)



