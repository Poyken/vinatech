# 🔍 TẬP 3: CẨM NANG VẬN HÀNH, CHẨN ĐOÁN VÀ KHẮC PHỤC SỰ CỐ THEO SCREEN ID
> **VINATECH SYSTEM OPERATIONS, TRACING ENGINE & HOTFIX SPECIFICATION (VOLUME 3)**
>
> **Môi trường:** Production SQL Server Instance: `dbserver.hycap.co.kr,5398`
>
> ← [Quay lại Mục lục chính](README.md) | 🏛️ [Tập 1: Kiến trúc & CSDL (VOL_01)](VOL_01_SYSTEM_ARCHITECTURE.md) | 📖 [Tập 2: Quy trình nghiệp vụ (VOL_02)](VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md)

---

## 🕵️ 1. Quy Trình Trace Bug 5 Bước Chuẩn Y Khoa

Khi tiếp nhận báo lỗi từ hiện trường, kỹ sư hỗ trợ ứng dụng (EA) hoặc lập trình viên tuyệt đối không được đoán mò mà phải thực hiện quy trình 5 bước xác thực dữ liệu:

```
[Hiện trường báo lỗi]
         │
         ▼ (Bước 1: Thu thập triệu chứng)
Mã TCode, Barcode/Lot, Thao tác bấm nút, Ảnh chụp thông báo lỗi
         │
         ▼ (Bước 2: Tìm Stored Procedure liên kết qua SmartFramework)
SELECT ScreenName FROM STB_ScreenInfo WHERE TCode = '...'
SELECT ObjectName, LinkURL FROM STB_ScreenObjects WHERE ScreenName = '...'
         │
         ▼ (Bước 3: Kiểm tra sức khỏe dữ liệu thực tế)
SELECT * FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '...'
SELECT * FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = '...'
         │
         ▼ (Bước 4: Kiểm tra cấu hình thuộc tính & Master Data)
F110 (IsLotUse, IsUseBarcode), A410 (Vol/Farad size), A310 (BOM)
         │
         ▼ (Bước 5: Phân tích log thô & log biến SP)
SELECT * FROM STB_ProcessTerminalDataLog WITH(NOLOCK)
SELECT * FROM STB_ProcedureLog WITH(NOLOCK)
```

---

## 📋 2. Cẩm Nang Khắc Phục Sự Cố Chi Tiết Theo Screen ID (TCode Map)

Dưới đây là cẩm nang tra cứu và khắc phục lỗi thực tế phân loại theo Screen ID trải dài qua tất cả các phân hệ:

### 2.1 Nhóm Màn Hình Đăng Ký Hệ Thống & Phân Quyền (Z-Screens)

#### 🔐 Z410 — User Configuration (Cấu hình tài khoản & phân quyền)
*   **Chức năng:** Khai báo tài khoản người dùng, gán mã nhân viên (`Appendix8`), chọn ngôn ngữ hiển thị, và bật cờ hoạt động (`AllowFlag`).
*   **CSDL bị tác động:** Bảng `SmartFramework.dbo.STB_UserInfo`.
*   **Sự cố 1: Không đăng nhập được MES sau khi đổi mật khẩu**
    *   *Triệu chứng:* Đổi mật khẩu trên Groupware thành công nhưng MES báo lỗi mật khẩu không hợp lệ.
    *   *Nguyên nhân:* Hệ thống phân loại tài khoản: tài khoản Hàn Quốc (`CdCompany = 1000`) đồng bộ tự động với ERP/Groupware qua API `ERPiUVerify`, tài khoản Việt Nam (`CdCompany = 2000`) lưu mật khẩu cục bộ (`PWDCOMPARE`).
    *   *Khắc phục:* Nếu là tài khoản VN, IT cần reset mật khẩu thủ công về mặc định (`vinatech1!`) trong **Z410** để người dùng đăng nhập và đổi lại trên MES GUI.
*   **Sự cố 2: Nhân viên nghỉ việc nhưng tài khoản MES vẫn mở**
    *   *Nguyên nhân:* Nhân sự quên gạt cờ `AllowFlag` sang `Deny` cho nhân viên Việt Nam trong **Z410**.
    *   *Khắc phục:* Tìm tài khoản nhân viên trong bảng `STB_UserInfo` và khóa cứng:
        ```sql
        UPDATE SmartFramework.dbo.STB_UserInfo SET AllowFlag = 'Deny' WHERE UserID = 'MÃ_NHÂN_VIÊN';
        ```

#### ⚙️ Z220 / Z330 — Authority Config (Phân quyền chức năng & Menu)
*   **Chức năng:** Phân quyền mở màn hình, quyền thêm/sửa/xóa (`Authority`) cho từng nhóm người dùng.
*   **CSDL bị tác động:** `SmartFramework.dbo.STB_UserAuthority`, `STB_GroupMenu`.
*   **Sự cố: Nút "Save/Confirm" bị mờ (Grey out) hoặc không nhấn được**
    *   *Nguyên nhân:* Người dùng có quyền xem màn hình nhưng không có quyền ghi dữ liệu (`SaveAuthority = 0`).
    *   *Khắc phục:* Vào **Z330**, tìm nhóm quyền của nhân viên, tích chọn quyền **Save / Execute** cho Screen ID tương ứng và nhấn Lưu.

---

### 2.2 Nhóm Màn Hình Kho Nguyên Vật Liệu (F-Screens WMS)

#### 📥 F330 — Goods Receipt (Nhận nguyên vật liệu)
*   **Chức năng:** Thủ kho quét nhận hàng thực tế từ xe giao hàng của nhà cung cấp, phân tách lô hàng thành các cuộn/bao bì nhỏ và in tem Lot nhãn vật tư (`Part Label`).
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_MaterialLotInfo`, `STB_MaterialDocInfo`, `STB_MaterialDocDetail`.
*   **Sự cố 1: Lỗi "Exception occurred" khi tạo Lot in tem**
    *   *Triệu chứng:* Quét mã vạch nhà cung cấp hoặc bấm in tem thì màn hình báo lỗi hệ thống xoay vòng.
    *   *Nguyên nhân:* Cột ngày sản xuất của nhà cung cấp `LotAttr10` bị rỗng (`NULL`) dẫn đến hàm Datecode `fn_VVT_getdatebyVendorLot` bị lỗi tràn kiểu dữ liệu khi cộng hạn dùng.
    *   *Khắc phục:* Điền ngày sản xuất bằng tay bằng cách chạy script update tạm thời cho Lot:
        ```sql
        UPDATE SmartFactoryV2.dbo.STB_MaterialDocLotInfo SET LotAttr10 = '14/06/2026' WHERE LotID = 'MÃ_LOT_BỊ_LỖI';
        ```
*   **Sự cố 2: Xóa phiếu nhập F330 đã được duyệt (Confirm)**
    *   *Khắc phục:* Dùng SP hủy chứng từ có set cờ bypass trigger để tránh làm lệch Picking Qty của kho:
        ```sql
        SET CONTEXT_INFO 0x999997; -- Bypass trigger
        EXEC SmartFactoryV2.dbo.usp_DoCancelMaterialDoc @pDocNo = 'MÃ_PHIẾU_NHẬP_F330';
        SET CONTEXT_INFO 0x0; -- Tắt bypass
        ```

#### 📦 F721 — Location Stock View (Báo cáo tồn kho & FIFO)
*   **Chức năng:** Tra cứu số dư tồn kho thực tế của từng Lot nguyên vật liệu theo Vị trí (`LocationCode`), theo dõi hạn dùng (`Safe / Warning / Expired`).
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_MaterialLotInfo`, `STB_MaterialStock`.
*   **Sự cố: Tồn kho thực tế đầy kệ nhưng F721 hiển thị trống trơn**
    *   *Nguyên nhân:* Lệch đồng bộ dữ liệu giữa bảng tồn kho Lot (`STB_MaterialLotInfo`) và bảng tồn kho tổng hợp (`STB_MaterialStock`) do trigger bị ngắt hoặc do lỗi cập nhật Lot trùng lặp (Sự cố BG2, tài khoản ID `23091804`).
    *   *Khắc phục:* Chạy script loại bỏ tài khoản trùng lặp và tính toán lại Stock Qty thực tế:
        ```sql
        SELECT MaterialLotNo, CurrentQty FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE CreateUserID <> '23091804';
        ```

#### 🔄 F430 — Inventory Movement (Điều chuyển kho nội bộ)
*   **Chức năng:** Quét dịch chuyển Lot nguyên liệu từ kho chính sang kho ảo cạnh chuyền (`ROUTE_WH`) hoặc kho khóa chất lượng (`HOLDING_WH`).
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_MaterialWarehouseInOutHist`.
*   **Sự cố: Chặn chuyển Lot nguyên liệu vì vi phạm FIFO**
    *   *Triệu chứng:* Giao diện báo lỗi *"Lot scan không phải Lot cũ nhất trong kho"*.
    *   *Khắc phục:* Nếu QC xác nhận Lot này được ưu tiên dùng trước, IT cần khai báo Lot vào bảng "Ân Xá" để bypass FIFO:
        ```sql
        INSERT INTO SmartFactoryV2.dbo.stb_vvt_OpenExpiredMaterial (LotID, CreateDateTime, CreateUserID)
        VALUES ('MÃ_LOT_NVL', GETDATE(), 'admin_bypass');
        ```

---

### 2.3 Nhóm Màn Hình Vận Hành Sản Xuất & Chạy Máy (B-Screens)

#### 📅 B450 — Daily Production Plan (Lập kế hoạch chạy ngày)
*   **Chức năng:** Tổ trưởng sản xuất tiếp nhận kế hoạch ngày từ Groupware, gán Line chạy máy, bấm chốt kế hoạch ngày (`IsFixed = 1`) và in tem nhãn lô thành phẩm (`Assemble Label`) phát xuống chuyền.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_DayProdPlan`, `STB_SetInfo`.
*   **Sự cố: Không in được tem Lot, báo "Plan is locked" hoặc "Chưa chốt kế hoạch ngày"**
    *   *Nguyên nhân:* Người dùng chưa nhấn nút Xác nhận mục tiêu trên Groupware hoặc chưa bấm nút chốt kế hoạch ngày tại **B450**.
    *   *Khắc phục:* Vào **B450**, tick chọn dòng kế hoạch ngày và nhấn nút **Chốt kế hoạch (IsFixed = 1)** trên thanh công cụ MES.

#### 🔌 B597 — Material Scanning (Quét nạp nguyên vật liệu)
*   **Chức năng:** Công nhân tại đầu line dùng súng quét mã vạch Lot nguyên liệu (Cuộn cực, keo, vỏ case) nạp vào máy. MES thực hiện validation kiểm tra trạng thái HOLD, hạn sử dụng và BOM ngầm.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_RawMaterialInputHist`, `stb_vvt_materialbo`.
*   **Sự cố 1: Báo lỗi "Sai chủng loại nguyên vật liệu so với BOM"**
    *   *Nguyên nhân:* Model mới chưa được khai báo ánh xạ mã vật tư phụ trong bảng BOM ngầm `stb_vvt_materialbo` của Việt Nam.
    *   *Khắc phục:* Khai báo bổ dung ánh xạ model size vào bảng BOM ngầm:
        ```sql
        INSERT INTO SmartFactoryV2.dbo.stb_vvt_materialbo (model, size, part_code, use_flag)
        VALUES ('MÃ_MODEL_MỚI', 'SIZE_MODEL', 'MÃ_VẬT_TƯ_PHỤ', 1);
        ```
*   **Sự cố 2: Lọc ngược 6 cấp Barcode bị lag / Timeout màn hình**
    *   *Nguyên nhân:* SP `usp_Vietnam_RawMaterialInputHist_uid` thực hiện đệ quy truy vấn bảng lịch sử đổi tem `STB_LotChangeMaterialHistory` ngược lên 6 cấp để tìm mã vạch gốc của Lot gây chậm truy vấn.
    *   *Khắc phục:* Bảo đảm các bảng được index đầy đủ cột `OldBarcode` và `NewBarcode`. Không in lại tem (Reprint) quá 3 lần cho cùng một Lot để hạn chế độ sâu đệ quy.

#### 🏭 B530 — Production Route Input (Chốt sản lượng công đoạn)
*   **Chức năng:** Công nhân hoặc máy quét tự động ở cuối công đoạn quét barcode sản phẩm, ghi nhận sản lượng hoàn thành tốt, khai báo số lượng lỗi phế (`DefectQty`) và tự động trừ kho ảo (Backflush).
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_ProdRouteHist`, `STB_DefectRepairInfo`.
*   **Sự cố 1: Báo lỗi "Bên PQC chưa nhập số lượng NG. Vui lòng bảo bên PQC nhập số lượng NG."**
    *   *Triệu chứng:* Dù lô hàng hoàn toàn đạt chất lượng, hệ thống vẫn chặn chốt sản lượng tại B530.
    *   *Nguyên nhân:* Bug logic trong SP `usp_CheckPQCInputForProductHistForBarcode` đếm số lượng lỗi phế nhưng loại trừ các mã không lỗi (mã đuôi `_00` đại diện cho Đạt) dẫn đến tổng số bản ghi lỗi trả về bằng 0 và kích hoạt khối chặn.
    *   *Khắc phục:* QC cần chèn một bản ghi đánh giá PASS tạm thời cho Lot, hoặc sửa SP để không loại trừ mã đuôi `_00`.
*   **Sự cố 2: Treo hệ thống/Lag xoay vòng khi lưu sản lượng cuối ca (Deadlock)**
    *   *Nguyên nhân:* Hàng trăm trạm cùng ghi nhận vào bảng `STB_ProdRouteHist` đồng thời với việc chạy trigger đồng bộ tồn kho liên hoàn không tối ưu hóa chỉ mục.
    *   *Khắc phục:* DBA chạy lệnh kill session gây nghẽn (Tìm qua `blocking_session_id`) và tối ưu hóa các câu lệnh SELECT trong SP bằng cách thêm `WITH(NOLOCK)`.

#### ✂️ B552 — Slitting Result (Chia cuộn điện cực)
*   **Chức năng:** Nhập kết quả cắt cuộn cực lớn (Jumbo Roll) thành các cuộn cực nhỏ (Slit Roll) và tự động tạo các mã Lot cực tương ứng.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_ElectrodeSlittingResult`, `stb_slittinglocationconfig_vvt`.
*   **Sự cố: Cảnh báo "Chưa CONFIG Slitting"**
    *   *Nguyên nhân:* Thiếu cấu hình chiều rộng chia cực dương (`BY`) và cực âm (`YP`) của mã hàng trong bảng cấu hình chia cuộn.
    *   *Khắc phục:* Khai báo thông số cấu hình Slitting vào DB:
        ```sql
        INSERT INTO SmartFactoryV2.dbo.stb_slittinglocationconfig_vvt (PartNo, SlittingCode, Width, IsUsed)
        VALUES ('MÃ_PART_NO', 'BY', '39.34', 1), ('MÃ_PART_NO', 'YP', '39.34', 1);
        ```

---

### 2.4 Nhóm Màn Hình Đóng Gói & In Tem Nhãn Khách Hàng (B500-Screens)

#### 📦 B523 — Divide Packaging (Gộp Box nhỏ)
*   **Chức năng:** Gom các cell/tụ lẻ đạt chuẩn chất lượng vào hộp nhỏ (Túi/Inner Box), in tem mã vạch dán hộp (`Packing ID`).
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_DividePackaging`, `STB_PackingStandard`.
*   **Sự cố: Không gộp được box, báo lỗi "Chưa có tiêu chuẩn đóng gói"**
    *   *Khắc phục:* Thêm cấu hình số lượng đóng gói định mức theo size model:
        ```sql
        INSERT INTO SmartFactoryV2.dbo.STB_PackingStandard (MaterialTypeCode, Size, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime)
        VALUES ('FERT', 'SIZE_MODEL_4_CHỮ_SỐ', 500, 4000, 8000, GETDATE());
        ```

#### 🏷️ B756 / B758 / B790 — Customer Labels Print (In tem nhãn khách hàng)
*   **Chức năng:** In tem nhãn Outer thùng lớn cho các khách hàng đặc thù như PAC (B756), Digi-Key (B758), Phoenix Contact (B790).
*   **CSDL bị tác động:** `SmartFramework.dbo.STB_LabelInfo`, `SmartFactoryV2.dbo.STB_HelaBarcodeOutBoxHist`.
*   **Sự cố 1: Tem in Phoenix Contact bị sai định dạng Datecode**
    *   *Khắc phục:* Kiểm tra ngày bắt đầu sản xuất của Lot trong `STB_SetInfo` và cập nhật lại nếu bị rỗng:
        ```sql
        UPDATE SmartFactoryV2.dbo.STB_SetInfo SET InputJobDate = '2026-06-12' WHERE Barcode = 'MÃ_BARCODE';
        ```
*   **Sự cố 2: In tem thùng Hela bị thiếu tem nhỏ (In 73 thay vì 80)**
    *   *Nguyên nhân:* Cột chuỗi danh sách tem nhỏ `InBoxLabelList` trong bảng `STB_HelaBarcodeOutBoxHist` bị giới hạn `VARCHAR(1000)` quá ngắn làm mất ký tự.
    *   *Khắc phục:* Đổi kiểu dữ liệu cột và biến SP lên `VARCHAR(MAX)` để lưu trữ trọn vẹn chuỗi tem.

---

### 2.5 Nhóm Màn Hình Kiểm Định Chất Lượng QC (C-Screens)

#### 🧪 C220 — IQC Receiving Inspection (QC đầu vào vật tư)
*   **Chức năng:** Đội QC đo đạc thông số kỹ thuật của mẫu vật tư thô đầu vào, nhập kết quả và chốt đánh giá **PASS / FAIL** để mở khóa cho phép kho nhập hoặc sản xuất nạp máy.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_MaterialQcInfo`.
*   **Sự cố: Không nạp được vật tư vào máy ở B597 vì Lot ở trạng thái HOLD**
    *   *Nguyên nhân:* Kết quả đo kiểm tại **C220** bị đánh giá FAIL hoặc chưa được nhấn chốt lưu kết quả.
    *   *Khắc phục:* Yêu cầu QC chốt kết quả. Nếu cần bypass nhanh để sản xuất thử nghiệm, IT cập nhật trạng thái PASS trực tiếp:
        ```sql
        UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo SET LotState = 'U', MaterialWarehouseCode = 'ROH_BG_WH' WHERE LotNo = 'MÃ_LOT';
        ```

#### 📊 C530 — OQC Audit (Kiểm định chất lượng xuất xưởng)
*   **Chức năng:** QC rút mẫu đo 20 thông số kỹ thuật của thùng hàng thành phẩm đã đóng gói, nhập kết quả mẫu và set trạng thái **StatusCheck = 'Pass'** để cho phép xuất kho.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_VN_FINISHGOODS_forQCAudit`, `STB_MaterialQcSampleResult`.
*   **Sự cố: Lưới kết quả đo chỉ hiển thị 10 dòng mẫu thay vì 20 dòng mẫu**
    *   *Nguyên nhân:* Lỗi lệch chỉ số vòng lặp bù dòng (Index Offset Bug) trong SP `usp_MaterialQcSampleResult_get` khi đồng bộ dữ liệu từ máy đo.
    *   *Khắc phục:* Chọn hạng mục đo ở lưới bên trái, nhấn nút **"Tạo danh sách mẫu" (Create Sample List)** trên thanh công cụ để hệ thống kích hoạt SP `usp_DoMakeMaterialQcSampleResult` tự động bù đủ 10 dòng trống tiếp theo.

---

### 2.6 Nhóm Màn Hình Kho Thành Phẩm & Xuất Kho (FG-Screens & PDA)

#### 📱 FG01 — PDA Outbound (Quét xuất kho tạm)
*   **Chức năng:** Thủ kho dùng thiết bị PDA cầm tay quét mã vạch các thùng hàng bán thành phẩm hoặc thành phẩm, di chuyển từ kệ kho ra khu vực đệm chờ bốc container.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_VN_FINISHGOODS_HN_New`, `STB_VN_FINISHGOODS_forQCAudit`.
*   **Sự cố: PDA báo lỗi chớp đỏ "Carton chưa được PASS OQC"**
    *   *Nguyên nhân:* Thùng hàng chưa được QC đánh giá hoặc bị đánh giá FAIL tại màn hình **C530**.
    *   *Khắc phục:* QC cần chốt trạng thái Pass cho thùng hàng. IT có thể kiểm tra trạng thái QC Audit của Carton:
        ```sql
        SELECT StatusCheck FROM SmartFactoryV2.dbo.STB_VN_FINISHGOODS_forQCAudit WHERE PackingID = 'MÃ_THÙNG';
        ```

#### 🚚 B752 — Container Loading Monitor (Giám sát bốc xếp Pallet lên Container)
*   **Chức năng:** Quét mã tem Pallet lớn khi bốc lên xe container, tự động đối chiếu chéo số lượng quét thực tế với số lượng yêu cầu của Shipment Request trên Groupware để ngăn chặn xuất thiếu/thừa hàng.
*   **CSDL bị tác động:** `SmartFactoryV2.dbo.STB_SetInfo`, `NEOE.dbo.MM_GI_LINE`.
*   **Sự cố: Không lưu được thông tin bốc xếp Pallet lên Container**
    *   *Nguyên nhân:* Trạng thái phiếu Shipment Request trên Groupware chưa ở trạng thái duyệt hoàn toàn (`APPROVED`), hoặc số lượng Pallet quét vượt quá số lượng đăng ký trên phiếu.
    *   *Khắc phục:* Yêu cầu phòng Logistics duyệt hoàn tất tờ trình xuất hàng trên Groupware trước khi bốc xếp xe.

---

## 🔬 3. Giải Quyết Sự Cố Thực Tế Tại Xưởng (Workshop Case Studies)

### 3.1 Công nhân làm "tắt" công đoạn (Bypass Routing)
*   **Triệu chứng:** Trạm B báo lỗi *"Lô hàng chưa qua trạm A"* hoặc *"Missing Operation"*, trong khi thực tế sản phẩm vật lý đã ở trạm B.
*   **Nguyên nhân:** Công nhân trạm A quên quét barcode sản phẩm trên giao diện MES B530 hoặc do mạng chập chờn lúc bấm submit nên giao dịch bị trễ.
*   **Xử lý:** EA kiểm tra sản phẩm vật lý, gọi QA/Leader xác nhận và dùng quyền Admin/Leader làm lệnh "Bù thao tác" tại trạm A để hợp lệ hóa định tuyến trên hệ thống, cho phép trạm B chạy tiếp.

### 3.2 Double Click do mạng / UI chậm (Race Condition)
*   **Triệu chứng:** Sản lượng bị nhân đôi, hoặc hệ thống báo lỗi trùng lặp dữ liệu (`Duplicate Exception` / `Primary Key Violation`) tại trạm B530.
*   **Nguyên nhân:** DB Server phản hồi chậm khi có quá nhiều trạm chốt sản lượng cuối ca. Công nhân nhấn nút "Hoàn thành" nhiều lần liên tục vì thấy giao diện quay vòng lâu.
*   **Xử lý:** EA kiểm tra dữ liệu giao dịch trong DB `SmartFactoryV2`, thực hiện xóa bản ghi trùng lặp phát sinh sát giờ nhau (sau khi được Admin phê duyệt).

### 3.3 Súng quét mã vạch bị dính chữ (Caps Lock / Unikey)
*   **Triệu chứng:** Quét mã vạch `P12345` nhưng MES nhận thành `p!@#$%` và báo lỗi mã không tồn tại.
*   **Nguyên nhân:** Máy trạm Kiosk POP đang bật Caps Lock hoặc chế độ gõ tiếng Việt của Unikey làm súng quét (mô phỏng bàn phím) bị dịch ký tự.
*   **Xử lý:** Tắt Unikey, gỡ Caps Lock trên máy trạm. Nếu súng mất cấu hình gốc, quét mã *Factory Reset* trong sách hướng dẫn của súng quét.

### 3.4 "Sát thủ Báo cáo" làm nghẽn hệ thống cuối tháng (Deadlocks)
*   **Triệu chứng:** Toàn bộ máy trạm xưởng đều bị treo hoặc xoay vòng tròn khi bấm Save, còi Andon cảnh báo lỗi.
*   **Nguyên nhân:** Nhân sự kế toán hoặc quản lý chạy báo cáo thống kê dữ liệu quá nặng (quét từ năm 2021 đến 2026 không có `WITH(NOLOCK)`), chiếm dụng 100% CPU và khóa bảng giao dịch.
*   **Xử lý:** DBA chạy `sp_who2` để tìm Session ID đang gây block và thực hiện lệnh `KILL [Session_ID]` để giải phóng tài nguyên lập tức cho xưởng chạy máy.

---

## 🔒 4. Nguyên Tắc An Toàn Khi Sử Dụng Kịch Bản SQL Hotfix

> [!CAUTION]
> **Tuyệt đối tuân thủ 3 nguyên tắc an toàn CSDL của Vinatech:**
> 1. Chỉ thực hiện truy vấn đọc dữ liệu (`SELECT` kết hợp `WITH(NOLOCK)`). Tuyệt đối không chạy `INSERT/UPDATE/DELETE/DROP` trực tiếp trên Production mà không có Transaction bảo vệ.
> 2. Mọi kịch bản sửa đổi dữ liệu (Hotfix) phải bắt buộc bao gói trong cấu trúc Transaction (`BEGIN TRAN` ... `ROLLBACK TRAN`). Chỉ thực hiện `COMMIT TRAN` sau khi đã đối soát kỹ lưỡng số dòng bị tác động (`ROWCOUNT`).
> 3. Tuyệt đối không hardcode ID tài khoản người dùng (`UserID`) trong SP/Trigger sản xuất.

### Cấu trúc kịch bản Hotfix chuẩn mực:
```sql
BEGIN TRANSACTION;

-- Thực hiện sửa đổi dữ liệu
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
SET CurrentQty = 1000, LotState = 'U'
WHERE LotNo = 'ML202606140089';

-- Kiểm tra số lượng dòng bị ảnh hưởng
IF @@ROWCOUNT = 1
BEGIN
    PRINT 'Đã cập nhật chính xác 1 dòng. Tiến hành COMMIT.';
    COMMIT TRANSACTION;
END
ELSE
BEGIN
    PRINT 'Số dòng bị ảnh hưởng không đúng! Tiến hành ROLLBACK lập tức.';
    ROLLBACK TRANSACTION;
END
```
