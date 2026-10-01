# 🚀 VINATECH ENTERPRISE STANDARD OPERATING PROCEDURE (SOP)
## CẨM NANG QUY TRÌNH TRIỂN KHAI VẬN HÀNH THỰC CHIẾN

> **Tài liệu chuẩn:** `.agents/rules/DEPLOYMENT_SOP.md`  
> **Người thực hiện:** Kỹ sư IT Nguyễn Văn Đức (`Author='vanduc'`, `ChangeUserID='vanduc'`) & AI Copilot  
> **Áp dụng cho:** Toàn bộ hoạt động triển khai thay đổi, cấu hình, dữ liệu và can thiệp hệ thống trên 5 phân hệ: Core MES, Kiosk POP, Groupware, 15 Databases, K-System Ace ERP.

---

## 🏛️ TỔNG QUAN VÒNG ĐỜI TRIỂN KHAI DOANH NGHIỆP (5 PHA)

Mọi thay đổi triển khai trên hệ thống Vinatech bắt buộc trải qua chu trình 5 pha khép kín:

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  PHA 1: TIẾP NHẬN│ ──> │ PHA 2: LẬP KẾ    │ ──> │ PHA 3: TIỀN KIỂM │ ──> │ PHA 4: THỰC THI │ ──> │ PHA 5: NGHIỆM THU│
│  & PHÂN LOẠI     │     │ HOẠCH & SOẠN MÃ  │     │ ĐỊNH & SNAPSHOT  │     │ TRIỂN KHAI (CLI) │     │ & LƯU BÀI HỌC    │
└──────────────────┘     └──────────────────┘     └──────────────────┘     └──────────────────┘     └──────────────────┘
```

- **Pha 1: Tiếp nhận & Phân loại (Rule 22):** Phân định rạch ròi hệ thống đích (**POP** vs **MES** vs **GW** vs **DB** vs **KSYS**). Xác định đúng CSDL `Profile`.
- **Pha 2: Lập kế hoạch & Soạn mã:** Sử dụng `/plan` cho các thay đổi phức tạp. Soạn file SQL/Script theo chuẩn 4 pha với `Author='vanduc'` và `ChangeUserID='vanduc'`.
- **Pha 3: Tiền kiểm định & Chụp Snapshot:** Kiểm tra câu lệnh qua `validate_sql.ps1`. Tự động chụp JSON Snapshot và sinh mã hoàn tác `undo_<Target>.sql` vào `backups/undo/`.
- **Pha 4: Thực thi Triển khai qua CLI:** Bắt buộc dùng CLI Hubs chính thống (`ops deploy` hoặc `mes deploy`). Tuyệt đối cấm chạy ad-hoc ngoài console.
- **Pha 5: Nghiệm thu & Lưu bài học:** Chạy Golden Query kiểm tra lại trạng thái thực tế. Ghi nhận log vào `HOTFIX_LOG.jsonl` và dùng `/learn` nếu phát hiện tiền lệ mới.

---

## 📋 DANH MỤC 7 QUY TRÌNH TRIỂN KHAI THỰC CHIẾN

---

### 🔹 SOP-01: TRIỂN KHAI HOTFIX DML TRÊN CSDL PRODUCTION

**Áp dụng:** Chuyển ngày chốt B782, khôi phục thùng dung dịch 150kg, xóa mẻ trộn B552, sửa lỗi mất cột NG B782, hủy lẻ Box đóng gói B523.

#### Các bước triển khai chi tiết:
1. **Bước 1: Khảo sát hiện trạng bằng Golden Query:**
   ```powershell
   ops trace "<LotID_hoặc_Mã>"
   # Hoặc
   mes trace "<LotID>"
   ```
   Xác định chính xác `ControlNo`, `RouteCode`, `JobDate`, `ProdQty` và vị trí hiện tại của Lot trên dây chuyền.

2. **Bước 2: Sinh mã Hotfix an toàn bằng CLI Tool:**
   Sử dụng công cụ sinh mã chuyên dụng để tránh lỗi chính tả và bảo đảm chuẩn Transaction:
   - Chuyển ngày B782:
     ```powershell
     mes fix-movedate -Lots "VVQR2601001" -TargetDate "2026-10-02"
     ```
   - Cấp cứu thùng dung dịch 150kg:
     ```powershell
     mes fix-solution -Lots "VVQR2601001"
     ```
   - Xóa cuộn/mẻ trộn B552:
     ```powershell
     mes fix-electrode -Lots "VVQR2601001" -Type Slitting
     ```
   - Sửa mất cột NG B782:
     ```powershell
     mes fix-defect-null -Lots "VVQR2601001"
     ```
   - Hủy lẻ Box đóng gói:
     ```powershell
     mes fix-cancel-pack -Target "VVQR2601001" -BoxId "ECVT30-..."
     ```
   File script sẽ tự động được tạo tại `MES_POP/sql/hotfixes/` với đầy đủ Pre-flight Query, Transaction và Rollback mặc định.

3. **Bước 3: Tiền kiểm định an toàn (Pre-flight Lint):**
   Kiểm tra tính an toàn của file SQL trước khi nạp vào CSDL:
   ```powershell
   powershell -Command ".\MES_POP\tools\validate_sql.ps1 -SqlPath '.\MES_POP\sql\hotfixes\<TênFile>.sql'"
   ```

4. **Bước 4: Thực thi triển khai chính thức (Deploy Execution):**
   ```powershell
   ops deploy ".\MES_POP\sql\hotfixes\<TênFile>.sql" -Profile SmartFactoryV2
   ```
   - Hệ thống tự động kích hoạt `Export-PreflightSnapshot`, lưu bản chụp JSON và file `undo_<Target>.sql` với header `-- Profile: SmartFactoryV2`.
   - Script tự động bóc tách từng batch `GO` và thực thi qua ADO.NET Connection an toàn.

5. **Bước 5: Hậu kiểm định & Nghiệm thu (Post-flight Verification):**
   - Chạy lại:
     ```powershell
     mes trace "<LotID>"
     ```
   - Xác nhận `JobDate`, `ProdDateTime`, hoặc số lượng đã khớp với yêu cầu của Quản đốc xưởng.
   - Báo OP F5 lại màn hình WinForm trên máy trạm xưởng.

6. **Bước 6: Ghi nhận bài học (Knowledge Retention):**
   Nếu sự cố mang tính lặp lại hoặc có nguyên nhân gốc rễ mới, kích hoạt lệnh `/learn` để ghi nhận vĩnh viễn vào `02_learned_patterns.md`.

---

### 🔹 SOP-02: TRIỂN KHAI CẤU HÌNH POP KIOSK & ĐỒNG BỘ THIẾT BỊ XƯỞNG

**Áp dụng:** Đổi máy nhầm Kiosk, máy kẹt trạng thái ACTIVE, nghẽn đồng bộ Kiosk -> MES.

#### Các bước triển khai chi tiết:
1. **Đổi máy nhầm trên Kiosk (BẮT BUỘC TUÂN THỦ RULE 20.1 - ATOMIC 2 BẢNG):**
   - Tuyệt đối KHÔNG chỉ sửa 1 bảng `STB_ProdRouteHist` (sẽ gây lệch tiến độ Kiosk).
   - Lệnh triển khai 1-Shot tự động sinh hotfix chuẩn 2 bảng:
     ```powershell
     mes swap-machine -Lots "VVQR2601001" -Machine "VVMHY130" -DeployNow
     ```
   - Xác nhận: Dữ liệu trên cả `SmartFactoryV2.dbo.STB_ProdRouteHist` VÀ `VINATECH_POP.dbo.MongoToMesPerformance` đều được cập nhật sang mã máy mới.

2. **Giải phóng máy kẹt trạng thái ACTIVE trên Kiosk (Rule 20.5):**
   - Kiểm tra máy kẹt:
     ```powershell
     pop trace "<MãMáy>"
     ```
   - Mở khóa 1 máy đơn lẻ:
     ```powershell
     pop unlock "<MãMáy>" -Deploy
     ```
   - Giải phóng toàn bộ máy kẹt theo Line khi giao ca:
     ```powershell
     pop release-machines -Force
     ```

3. **Giải tỏa nghẽn pipeline đồng bộ Kiosk -> MES:**
   - Quét phát hiện Lot hoàn thành Kiosk nhưng chưa sang MES (`IsDone=1, IsTransferred=0`):
     ```powershell
     pop sync
     ```
   - Kiểm tra chi tiết theo Line:
     ```powershell
     mes sync -Line "Line01"
     ```

---

### 🔹 SOP-03: TRIỂN KHAI ONBOARDING MODEL / MASTER DATA MỚI

**Áp dụng:** Chuẩn bị sản xuất mã sản phẩm mới, thêm Model mới, khai báo BOM mới trên toàn nhà máy Vĩnh Phúc / Hưng Yên / Hà Nam.

#### Checklist 9 Bước Khai Báo Tuần Tự (Nghiêm Ngặt):

| Thứ tự | Mã Màn Hình | Tên Nghiệp Vụ & Bảng DB Liên Quan | Tiêu Chí Kiểm Tra (Acceptance Criteria) |
| :---: | :---: | :--- | :--- |
| **1** | **A230** | Khai báo Master Nguyên Vật Liệu (`STB_MaterialMaster`) | `MaterialCode`, `MaterialThickness >= 100`, gán đúng `BasicRoutingCode`. |
| **2** | **A410** | Khai báo Master Sản Phẩm / Model (`STB_ModelMaster`) | `ModelCode`, `ModelName`, `ModelType`, `Capacity`, `Voltage` đầy đủ. |
| **3** | **A418** | Cấu hình Quy Cách Đóng Gói (`STB_PackingStandard`) | Định mức chiếc/Box, chiếc/Carton, chiếc/Pallet theo Size chuẩn. |
| **4** | **A460** | Cấu hình Tem & Mẫu Nhãn In (`STB_ModelLabelInfo`) | `LabelType`, định dạng Barcode, cấu hình tem Sanmina (nếu có). |
| **5** | **B240** | Cấu hình Quy Trình Sản Xuất (`STB_BasicRoutingInfo`, `Detail`) | Tick chọn đúng danh sách công đoạn cho nhà máy (`WorkCenterCode`). |
| **6** | **B270** | Phân bổ Máy Cho Công Đoạn (`STB_ProductMachine`, `STB_RouteEqpInfo`) | Bắt buộc gán máy cho Winding, Curling, Sleeving để Kiosk hiện danh sách. |
| **7** | **A416** | Cấu hình Quy Tắc Sinh Số Lô (`STB_Vietnam_PackingPrinting`) | Prefix VJ hoặc quy tắc Lot riêng cho khách hàng. |
| **8** | **A510** | Thiết lập Tiêu Chuẩn Đánh Giá QC IQC / PQC | Khai báo tiêu chuẩn kiểm tra chất lượng trước khi nạp Lot. |
| **9** | **B802** | Khai báo Giá Bán & Đơn Giá Phế Điện Cực (`STB_ElectrodePriceB802`) | Khai báo bảng giá và kiểm tra function `fn_VVT_ElecErrorPriceMeter2KG`. |

#### Kiểm toán Nghiệm Thu Sau Khai Báo:
- Tạo thử 1 Lot Test trên WinForm.
- Dùng lệnh kiểm tra liên kết 4 bảng:
  ```powershell
  mes trace "<TestLot>"
  ```
- Nếu hiển thị đầy đủ Model, Routing, BOM NVL và không dính cảnh báo đỏ -> Nghiệm thu thành công và bàn giao cho Bộ phận Sản xuất.

---

### 🔹 SOP-04: TRIỂN KHAI NHẬP LIỆU HÀNG LOẠT QUA FILE EXCEL

**Áp dụng:** Nạp số liệu sản xuất ngoài ca, nạp kế hoạch F330 hoặc chi phí B598 từ các bộ phận chuyển sang.

#### Các bước triển khai chi tiết:
1. **Kiểm toán Tiền Khảo Sát File Excel (Pre-flight Data Linting):**
   - **RỦI RO KINH ĐIỂN:** File Excel bị lệch cột khiến mã khay `E04`, `E05` tràn vào cột thời gian `StartPeriod`, làm sập Stored Procedure tính giá.
   - Bắt buộc kiểm tra file Excel trước khi bấm Import trên giao diện:
     ```powershell
     mes validate-excel "C:\duong_dan\Kế_Hoạch_San_Xuat.xlsx" -Route F330
     # Hoặc đối với B598:
     mes validate-excel "C:\duong_dan\Báo_Cáo_B598.xlsx" -Route B598
     ```
2. **Xử lý nếu phát hiện cảnh báo lệch cột:**
   - Nếu script báo lỗi cột: Trả lại file cho người lập bảng để chuẩn hóa đúng template mẫu.
   - Tuyệt đối CẤM nạp file Excel có lỗi cấu trúc vào CSDL.
3. **Kiểm tra đơn giá hardcode trước khi chạy SP tính toán:**
   ```powershell
   mes b598-price -Target "<MãSảnPhẩm>"
   ```
   Xác nhận đơn giá USD và tỷ lệ cân trong SP `usp_vn_showproductionerror` đã cập nhật mới nhất.

---

### 🔹 SOP-05: TRIỂN KHAI CẬP NHẬT BIỂU MẪU GROUPWARE & LIÊN THÔNG ERP

**Áp dụng:** Cập nhật quy trình duyệt tờ trình mua sắm, thay đổi định mức vật tư, sửa lỗi đồng bộ Groupware -> ERP Douzone NEOE.

#### Các bước triển khai chi tiết:
1. **Khảo sát Biểu mẫu & Tuyến phê duyệt:**
   ```powershell
   gw form "<TênBiểuMẫu>"
   ```
   Hệ thống xuất ra `FormCode`, tên bảng Master (`VINA_DOCUMENT_SAVE`), bảng Detail (`VINA_PURCHASE_DETAIL`...), và danh sách các bước duyệt trong quy trình.

2. **Truy vết Chứng từ & Phả hệ Liên kết:**
   ```powershell
   gw trace "<SốVănBản_hoặc_PO>"
   ```
   Xác nhận trạng thái văn bản trên Bizbox: Đã duyệt hoàn tất (`DocStatus = '90'`) hay đang nghẽn ở cấp nào.

3. **Kiểm tra Liên thông CSDL ERP NEOE (Double-check Bridge):**
   - Kiểm tra bảng giao tiếp `NEOE.dbo.PU_PO` hoặc `PU_BL`.
   - Nếu chứng từ đã duyệt trên Groupware nhưng chưa nhảy sang ERP NEOE:
     - Kiểm tra kết nối Linked Server giữa `VINATECH_GROUP` và `NEOE`.
     - Chạy kỹ năng `groupware-erp-sync` để đối chiếu khóa ngoại và trạng thái cờ `ERP_SEND_YN`.

---

### 🔹 SOP-06: TRIỂN KHAI CẦU NỐI ERP K-SYSTEM ACE (K-SYSTEM BRIDGE)

**Áp dụng:** Liên thông dữ liệu sản xuất MES/POP với phân hệ ERP K-System Ace Web Suite (`evn.vinatech.com`).

#### Các bước triển khai chi tiết:
1. **Tra cứu phân hệ và bảng liên quan trong K-System:**
   ```powershell
   ksys find "<TừKhóa>"
   # Hoặc tra cứu Schema bảng:
   ksys schema -Table "_TPRProdResult"
   ```
2. **Quy tắc Bất Biến khi tương tác với CSDL K-System (VINATECVN):**
   - **BẮT BUỘC:** Mọi query hoặc liên kết dữ liệu phải có điều kiện `CompanySeq = 1` (Định danh Chi nhánh Việt Nam).
   - Tham chiếu bảng kết quả sản xuất: `_TPRProdResult`.
   - Tham chiếu chứng từ kế toán: `_TACSlip`.
3. **Kiểm toán Đồng bộ Số Liệu Sản Phẩm Hoàn Thành:**
   - Dùng lệnh truy vết ngược từ mã Lot về K-System:
     ```powershell
     ksys trace "<LotID>"
     ```
   - Kiểm tra xem Lot đã xuất hiện trên màn hình quản trị Lot `FrmWPDLotList` hay chưa.

---

### 🔹 SOP-07: QUY TRÌNH KÍCH HOẠT HOÀN TÁC KHẨN CẤP (1-CLICK EMERGENCY ROLLBACK)

**Áp dụng:** Khi sau khi triển khai hotfix hoặc cập nhật dữ liệu, dây chuyền xưởng báo phát sinh lỗi phụ, sai lệch số lượng hoặc Quản đốc báo nhầm thông tin Lot.

#### Các bước thực thi hoàn tác trong 3 Bước (< 10 giây):

```
┌─────────────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│ BƯỚC 1: DỪNG CHUYỀN     │ ──> │ BƯỚC 2: DRY-RUN UNDO    │ ──> │ BƯỚC 3: DEPLOY ROLLBACK │
│ Thông báo OP giữ nguyên │     │ ops rollback <ID>       │     │ ops rollback <ID> -Deploy│
└─────────────────────────┘     └─────────────────────────┘     └─────────────────────────┘
```

1. **Bước 1: Thông báo Tổ trưởng hiện trường giữ nguyên hiện trạng Lot:**
   - Yêu cầu công nhân không quét tiếp mã Lot trên bất kỳ màn hình nào để tránh phát sinh dòng lịch sử mới.

2. **Bước 2: Khảo sát file hoàn tác (Dry-run Kiểm Tra):**
   ```powershell
   ops rollback -Target "<MãLot_hoặc_MãSựCố>"
   ```
   - Hệ thống tự động tìm file undo gần nhất trong `backups/undo/undo_<Target>_*.sql`.
   - Tự động bóc tách Database Profile (`SmartFactoryV2`, `POP`, `Groupware`, `NEOE`).
   - Hiển thị toàn bộ câu lệnh `UPDATE` khôi phục giá trị ban đầu lên màn hình console để Kỹ sư IT rà soát lần cuối.

3. **Bước 3: Thực thi khôi phục nguyên trạng (1-Click Rollback Execution):**
   ```powershell
   ops rollback -Target "<MãLot_hoặc_MãSựCố>" -Deploy
   ```
   - Hệ thống tự động kết nối đúng Database Profile đích.
   - Mở Transaction, thực thi script hoàn tác, commit và thông báo thành công trong thời gian `< 1.5 giây`.

4. **Bước 4: Xác nhận hoàn tất:**
   - Chạy lại `ops trace "<MãLot>"` để xác nhận dữ liệu đã trở về nguyên trạng ban đầu.
   - Thông báo Tổ trưởng cho công nhân tiếp tục thao tác bình thường.

---

## 🔒 MA TRẬN PHÂN ĐỊNH TRÁCH NHIỆM (RACI MATRIX)

| Hoạt Động Triển Khai | AI Copilot (Antigravity) | IT Operator (Kỹ Sư Đức) | Quản Đốc / Tổ Trưởng Xưởng |
| :--- | :---: | :---: | :---: |
| **Tiếp nhận & Chẩn đoán lỗi** | Thực hiện (Trace 360°, Phân tích Root Cause) | Giám sát & Phê duyệt | Cung cấp mã Lot, màn hình lỗi |
| **Soạn mã Hotfix / Script** | Thực hiện (Theo chuẩn 4 pha, Author 'vanduc') | Kiểm tra cú pháp & Logic | Không can thiệp |
| **Tiền kiểm định & Snapshot** | Tự động hóa (`validate_sql`, `Snapshot`) | Xác nhận kết quả Lint | Không can thiệp |
| **Bấm lệnh Triển khai (Deploy)** | Đề xuất câu lệnh CLI hoàn chỉnh | **Quyết định & Thực thi** (`ops deploy`) | Không can thiệp |
| **Nghiệm thu sau triển khai** | Tự động trace xác nhận dữ liệu DB | Xác nhận hoàn thành | Thao tác thử trên WinForm / Kiosk |
| **Kích hoạt Hoàn tác (Rollback)** | Tự động trích xuất file Undo | **Quyết định & Thực thi** (`ops rollback -Deploy`) | Báo dừng chuyền nếu có lỗi |
| **Lưu trữ tri thức (`/learn`)** | Đề xuất bài học & Ghi nhận vào L1 Cache | Duyệt nội dung bài học | Không can thiệp |
