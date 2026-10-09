# 🧠 VINATECH LEARNED PRODUCTION PATTERNS & INCIDENT PLAYBOOKS (02_learned_patterns.md)

> **Mục đích:** Nơi lưu trữ tự động và bền vững các bài học vận hành, tiền lệ xử lý sự cố thực tế được đúc kết từ lệnh `/learn` và kinh nghiệm thực chiến của kỹ sư IT (Author: `vanduc`).
> **Quy tắc cập nhật:** Khi kỹ sư nhắc nhở, sửa lỗi hoặc dùng `/learn`, Agent sẽ bổ sung trực tiếp mẫu hình mới vào tệp này kèm ngày tháng và giải pháp.

---

## 📌 DANH MỤC TIỀN LỆ VẬN HÀNH ĐÃ XÁC THỰC (VERIFIED PLAYBOOKS)

### 1. Sự Cố Đổi Máy Nhầm Kiosk POP (Dual-Table Atomic Update)
- **Triệu chứng:** Công nhân bấm nhầm mã máy trên Kiosk POP (ví dụ chọn M01 thay vì M02), dẫn đến dữ liệu không khớp giữa Web POP và Core MES.
- **Root Cause:** POP Web đọc qua bảng trung gian `MongoToMesPerformance`, trong khi Core MES đọc từ `STB_ProdRouteHist`. Nếu chỉ update 1 bảng thì 1 bên sẽ bị lệch.
- **Giải pháp:** Bắt buộc UPDATE đồng thời cả 2 bảng trong cùng một Transaction:
  ```powershell
  mes swap-machine -Lots "<LotID>" -Machine "<TargetMachine>"
  ```

### 2. Sự Cố "Already Completed in MES" Khi Chốt Công Đoạn POP
- **Triệu chứng:** POP Kiosk báo lỗi *"Already completed in MES"* và từ chối cho công nhân quét Lot.
- **Root Cause:** Màn hình WinForm Core MES tự động sinh trước một bản ghi kế tiếp trong `STB_ProdRouteHist` với `CompleteRoute = 1` nhưng chưa có dữ liệu sản xuất thật.
- **Giải pháp:** Xóa bản ghi thừa tự sinh trong `STB_ProdRouteHist` và `STB_ProdRouteWorkerHist` có `CompleteRoute IS NULL` hoặc dùng lệnh:
  ```powershell
  mes fix-pop-clone -Lots "<LotID>"
  ```

### 3. Sự Cố Nút "Cắt Điện Cực" Bị Mờ Không Bấm Được
- **Triệu chứng:** Giao diện cắt điện cực khóa nút chức năng, công nhân không thể hoàn tất thao tác.
- **Root Cause:** Logic kiểm tra độ dày vật tư `MaterialThickness < 100` trong bảng `STB_MaterialMaster`. Nếu NVL khai báo độ dày nhỏ hơn ngưỡng 100 µm, nút bị vô hiệu hóa để bảo vệ dao cắt.
- **Giải pháp:** Kiểm tra thông số cuộn trong `STB_MaterialMaster`. Nếu là cuộn mỏng đặc thù cần bypass, cập nhật tạm thông số hoặc liên hệ QA/PE.

### 4. Giới Hạn Số Cuộn BTP Nạp Vào Máy Cắt
- **Triệu chứng:** Báo lỗi vượt quá định mức khi nạp cuộn vào máy cắt.
- **Tiền lệ chuẩn:** Hệ thống đã được nâng cấp chính thức từ định mức cũ (2 LOTNO) lên tối đa **3 LOTNO** cho 1 mã cắt.

### 5. Máy Kiosk Bị Kẹt Trạng Thái ACTIVE Không Cho Lot Mới Vào
- **Triệu chứng:** Máy hiển thị đang bận, công nhân khác không thể đăng nhập hoặc nạp Lot mới.
- **Giải pháp:**
  ```powershell
  pop unlock "<MachineID>" -Deploy
  # Hoặc giải phóng hàng loạt theo chuyền:
  pop release-machines -Force
  ```

### 6. Kiểm Soát File Excel Nạp Sản Lượng Chống Lệch Cột (F330 / B598)
- **Triệu chứng:** Khi import Excel vào MES, mã khay hoặc mã barcode bị đẩy nhầm vào cột `StartPeriod` gây lỗi dữ liệu.
- **Giải pháp:** Chạy kiểm toán Pre-flight trước khi nạp:
  ```powershell
  mes validate-excel "<PathToExcel.xlsx>" -Route F330
  ```

### 7. Tờ Trình Groupware Bị Từ Chối Mở Phiếu Nhận Hàng (Receiving Confirmation)
- **Triệu chứng:** OP không tạo được phiếu trên Groupware.
- **Root Cause:** Thiếu chốt chặn IQC PASS trên màn hình MES `C220`.
- **Giải pháp:** Kiểm tra kết quả kiểm định IQC trên `C220`. Khi QC bấm Confirm PASS (`QcResult = 'PASS'`), Groupware mới cho phép lập phiếu.

### 8. Định Mức BOM Phiên Bản Việt Nam (Lock Version 2001/2002)
- **Tiền lệ:** MES `B310`/`B450` chỉ chấp nhận BOM phiên bản **2001** (Việt Nam) hoặc **2002** (Dây chuyền Cell mới). Mọi phiên bản khác đều bị từ chối phát hành Lot.

### 9. Chuyển Ngày Chốt Sản Lượng B782 (B782 Move Job Date)
- **Triệu chứng:** Công nhân chốt sản lượng ca đêm sau 00:00 nhưng thuộc ca ngày hôm trước, dẫn đến báo cáo ca bị lệch ngày.
- **Giải pháp:** Chuyển ngày chốt về đúng 10h00 AM ca làm việc chuẩn:
  ```powershell
  mes fix-movedate -Lots "<LotID>" -TargetDate "yyyy-MM-dd"
  ```

### 10. Cấp Cứu Thùng Dung Dịch Điện Giải 150kg (Electrolyte Solution Recovery)
- **Triệu chứng:** Thùng dung dịch điện giải 150kg bị trừ nhầm hoặc kẹt không cấp phát được tiếp cho các line nạp dung dịch.
- **Giải pháp:**
  ```powershell
  mes fix-solution -Lots "<SolutionLot>"
  ```

### 11. Xóa Mẻ Trộn / Cuộn Slitting B552 & Reset IsLineInput
- **Triệu chứng:** Cuộn điện cực hoặc mẻ trộn B552 bị kẹt `IsLineInput = 1`, không cho nạp tiếp hoặc cần hủy lượt chốt.
- **Giải pháp:**
  ```powershell
  mes fix-electrode -Lots "<LotID>" [-Type Slitting|Mixing]
  ```

### 12. Mất Cột Lỗi NG Trên Lưới B782 (RepairQty IS NULL)
- **Triệu chứng:** Màn hình B782 không hiển thị cột NG hoặc tính tổng phế bị sai do `RepairQty` mang giá trị `NULL`.
- **Root Cause:** Biểu thức tính phế trong WinForm: `DefectQty - RepairQty`. Nếu `RepairQty` là NULL, toàn bộ kết quả trở thành NULL.
- **Giải pháp:** Chuẩn hóa `RepairQty = 0` bằng lệnh:
  ```powershell
  mes fix-defect-null -Lots "<LotID>"
  ```

### 13. Hủy Lẻ Box Đóng Gói (B523 / HN523 Single Box Cancel)
- **Triệu chứng:** Công nhân đóng nhầm 1 Box trong thùng Carton hoặc Pallet, cần rã lẻ 1 Box mà không muốn hủy toàn bộ Pallet lớn.
- **Giải pháp:**
  ```powershell
  mes fix-cancel-pack -Target "<LotID>" -BoxId "<BoxId>"
  ```

### 14. Giao Thức Bảo Vệ 3 Bảng Khổng Lồ (Monster Tables Guard - Rule 15)
- **`STB_VVT_ESRDATA` (423 Triệu dòng, 64.8 GB):** CẤM câu lệnh `SELECT` không có `WHERE id > ...`. Bảng chỉ có 1 Clustered Index trên `id`. Quét theo ngày sẽ gây Clustered Index Scan làm tê liệt hệ thống.
- **`STB_ProductStockInfo` (69 Triệu dòng, 13.1 GB):** BẮT BUỘC luôn lọc theo `WHERE BaseDate = '...'`.
- **`STB_SetInfo` (789K dòng, HEAP):** Luôn tìm kiếm theo `Barcode`, `LotNumber`, `DayPlanNo`. Tránh tìm kiếm theo cột tự do không có chỉ mục.

### 15. Mismatch Quy Cách NVL Thay Thế POP Kiosk (DelegateMaterialCode Sync Overwrite)
- **Triệu chứng:** Kiosk POP ép công nhân nạp cuộn thay thế sai quy cách (ví dụ Tape 10mm thay vì 5mm). Quét cuộn chuẩn theo PO bị chặn.
- **Root Cause:** Cột `DelegateMaterialCode` trong `STB_MaterialMaster` dùng chung cho toàn bộ nhà máy. Khi Groupware duyệt một tờ trình của model khác dùng chung mã vật tư cơ sở, tiến trình sync ghi đè lên mã thay thế của model hiện tại.
- **Giải pháp:** Cập nhật lại `DelegateMaterialCode` theo đúng quy cách của PO trong `STB_MaterialMaster` (Author: `vanduc`):
  ```sql
  BEGIN TRAN;
  UPDATE SmartFactoryV2.dbo.STB_MaterialMaster
  SET DelegateMaterialCode = 'GBRBPL-002', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
  WHERE MaterialCode = 'GBTPPL-001';
  COMMIT;
  ```

### 16. Chuẩn Hóa Ánh Xạ Thiết Bị Toàn Diện Cho Lot Liên Xưởng (Bắc Ninh -> Hưng Yên & Cụm Máy Hạ Nguồn)
- **Triệu chứng:** Khi chuyển Lot từ Bắc Ninh xuống Hưng Yên, hoặc công nhân chạy máy giữa các chuyền, Kiosk POP không hiển thị tên máy cần thiết (như Curling DR1/DR2 BN, Riveting BN, Curling C#1..C#10, Sleeving C#1..C#10) khiến công nhân không thể chốt được sản lượng.
- **Root Cause & Đặc thù liên xưởng:**
  1. Các máy Bắc Ninh chuyển xuống (`Curling DR1/DR2 BN`, `Riveting DR1/DR2 BN`, `Bọc vỏ BN`) trước đây chỉ được map vào duy nhất `VVHYC-01` với Route `_HY`, trong khi Lot Bắc Ninh có thể chạy ở Line khác (Line 2, 4, 8, `BN_HY`, `TCX1`, `TCX2`) hoặc mang mã Route gốc Bắc Ninh (`_BG` hoặc không có hậu tố).
  2. Tuyến điều chuyển `BN_HY` có 0 bản ghi mapping trong `STB_ProductMachine`.
- **Giải pháp dứt điểm (Full Visibility Hotfix):**
  1. Mở toàn bộ thiết bị Hưng Yên và Bắc Ninh trên toàn bộ các Line (`VVHYC-01..10`, `BN_HY`, `TCX1`, `TCX2`).
  2. Đa hình hóa RouteCode: Khai báo đồng thời cả 3 hệ mã Route: `_HY` (`V-22_HY..V-25_HY`), `_BG` (`V-22_BG..V-25_BG`) và Route tiêu chuẩn (`V-22..V-25`).
  3. File Hotfix chuẩn: `hotfix_20261008_ENABLE_FULL_MACHINE_VISIBILITY_FOR_ALL_LINES.sql`.
  4. Kết quả: 100% OP ở bất kỳ Line nào, chạy Lot Hưng Yên hay Lot Bắc Ninh chuyển xuống, đều luôn luôn nhìn thấy máy mình cần và chốt được sản lượng ngay lập tức.

### 17. Quy Ước Định Danh CSDL CMS: CMS = CMS_VINA (Chấm Công Vân Tay)
- **Quy ước người dùng:** Khi người dùng đề cập đến **CMS** hoặc **Database CMS**, mặc định 100% hiểu là CSDL **`CMS_VINA`** (Hệ thống Quản lý Chấm công & Vân tay - `ATTENDANCE_CMS`), TUYỆT ĐỐI KHÔNG hiểu sang `WCMS_Standard` / FirmBanking ngân hàng trừ khi người dùng nói rõ "WCMS" hoặc "FirmBanking".
- **Thông tin kỹ thuật cốt lõi:**
  - CSDL: `CMS_VINA` (và `CMS_HN` cho Hà Nam).
  - Vị trí vật lý: Máy chủ `110.11.27.5\MESTESTDB,8080`.
  - Cổng truy vấn từ MES: Linked Server `[CMS_VINA_LINK]`.
  - Lưu ý truy cập máy trạm: Kết nối trực tiếp cần đúng port `,8080`, instance `\MESTESTDB`, và tài khoản có quyền (như `sa` qua Linked Server, tránh dùng `vinaadmin` vì chưa map user).

---

## 📝 NHẬT KÝ BÀI HỌC MỚI (LEARNED ENTRIES SINK)
*(Các bài học mới qua lệnh `/learn` sẽ được ghi nối tiếp vào đây)*