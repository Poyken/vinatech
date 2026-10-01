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

---

## 📝 NHẬT KÝ BÀI HỌC MỚI (LEARNED ENTRIES SINK)
*(Các bài học mới qua lệnh `/learn` sẽ được ghi nối tiếp vào đây)*