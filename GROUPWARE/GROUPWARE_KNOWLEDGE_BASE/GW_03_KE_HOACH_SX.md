# GW_03 — Kế Hoạch Sản Xuất (PO & Production Plan)

> **Màn hình:** Home → Production Management → Month Production Plan
> **MES liên quan:** B310, B450
> ← [Về INDEX](GW_INDEX.md)

---

## 🗺️ Tổng Quan

```
Groupware: Month Production Plan → xác nhận
        ↓
MES: B310 (PO xuất hiện)
        ↓
Groupware: Tạo kế hoạch ngày
        ↓
MES: B450 (Kế hoạch ngày, tạo Lot, in tem)
```

> ⚠️ **BOM phải chọn phiên bản 2001** (mã BOM của Việt Nam)

---

## 1. 📅 Phân Biệt 3 Loại PO Trên Màn Hình

| Loại | Ý nghĩa |
|------|---------|
| **MES** | PO đăng ký trực tiếp trên MES |
| **Kế hoạch bán hàng** | Đơn hàng do Sales HQ/VN tạo |
| **Phần mềm nhóm** | PO tạo thủ công trên Groupware ← **Đây là loại cần tạo** |

---

---

## 1. 📅 Cơ Chế Liên Thông Dữ Liệu Tự Động (Suju → Production Plan)

Hệ thống Groupware thiết lập cơ chế đồng bộ tự động để tránh nhập liệu thủ công trùng lặp:

- **Tự động đăng ký kế hoạch:** Khi một biểu mẫu **Yêu cầu đặt hàng / Đơn bán hàng (Suju / Sales Order Request Document)** được phê duyệt hoàn toàn bởi cấp có thẩm quyền, hệ thống sẽ **tự động** tạo một dòng kế hoạch sản xuất tương ứng trong màn hình *Month Production Plan*.
- **Phân loại theo thị trường (영업그룹):** Dựa trên nhóm kinh doanh/영업그룹 ghi nhận trên Suju, hệ thống tự động định tuyến đăng ký kế hoạch sản xuất tại nhà máy (사업장) tương thích:
  - **SC (Seoul Factory):** Dành cho thị trường nội địa Hàn Quốc/văn phòng chính.
  - **FC (Foreign Factory - VVT):** Dành cho nhà máy Vinatech Việt Nam (Bắc Ninh/Bắc Giang/Hà Nam).
- **Xem trước 3 tháng:** Màn hình mặc định hiển thị danh sách kế hoạch sản xuất trong vòng 3 tháng tính từ tháng hiện hành để người lập kế hoạch tiện theo dõi.

---

## 2. ➕ Tạo / Sao Chép PO Tháng Thủ Công

Trong trường hợp cần tạo bổ sung hoặc sao chép kế hoạch:

### 2.1 Tạo PO mới:
1. Nhấn **"Thêm kế hoạch"** → Kéo xuống cuối trang.
2. Nhấn **"Yêu cầu mặt hàng"** (Item Request) → Cửa sổ pop-up hiển thị danh sách mã BOM, tích chọn một hoặc nhiều model cần sản xuất → Nhấn **"Áp dụng mục đã chọn"**.
3. Điền thông tin chi tiết trên lưới:
   - **Tháng:** Chọn tháng lập PO.
   - **Số lượng:** Điền tổng số lượng sản xuất mục tiêu trong tháng.
   - **Kiểu PO:** 
     - **Sản xuất:** PO sẽ được lưu chính thức, cấm xóa (khi đã xác nhận).
     - **Không làm:** PO nháp/chờ, có thể sửa đổi hoặc hủy bỏ.
   - **Phiên bản BOM:** ⚠️ **BẮT BUỘC chọn đúng phiên bản 2001** (mã BOM Việt Nam).
4. Nhấn **"Đăng ký gói"** → **"Sự đăng ký"** để lưu lại.

### 2.2 Sao chép PO từ tháng trước (Copy Plan):
- Nhấn **"Sao chép kế hoạch sản xuất"** → Chọn tháng nguồn cần sao chép.
- Hệ thống tự động copy toàn bộ danh mục sản phẩm (BOM) và cấu hình của tháng đó sang tháng mới. Người dùng chỉ cần chỉnh sửa lại Số lượng của từng con hàng và nhấn Đăng ký. Giúp tránh nhập thủ công hàng trăm mã hàng.

---

## 3. 📦 Tính Toán Nguyên Vật Liệu (Raw Material Sourcing)

Sau khi đăng ký kế hoạch sản xuất tháng thành công:

- **Bản kê nguyên vật liệu (BOM):** Hệ thống tự động truy xuất cấu trúc cây sản phẩm dựa trên cơ sở dữ liệu **ERP BOM** để hiển thị bảng phân rã **Nhu cầu nguyên vật liệu (Raw Material Requirements / 자재소요량)**.
- **Liên thông mua hàng (Purchase Request):** Trên lưới hiển thị nhu cầu vật tư, người lập kế hoạch có thể click trực tiếp vào nút **"Yêu cầu mua hàng" (Purchase Request)**. Hệ thống sẽ tự động chuyển hướng và điền trước thông tin vật tư thiếu hụt sang biểu mẫu **Yêu cầu mua hàng (Expense Report Document)** tại phân hệ Mua hàng của Groupware.

---

## 4. ✏️ Sửa / Xóa PO & Lịch Sử Thay Đổi

### 4.1 Quy trình sửa đổi PO & Ghi nhận lịch sử (Change Logs):
1. Click chọn trực tiếp vào dòng PO cần sửa đổi trên bảng.
2. Điền đầy đủ lý do sửa đổi vào ô nhập liệu (yêu cầu bắt buộc).
3. Sửa đổi số lượng kế hoạch → Kéo chuột lên đầu trang nhấn **"Lưu kế hoạch"** → Chọn **"Điều chỉnh"** để xác nhận.
- 💡 **Theo dõi lịch sử:** Mọi thao tác thay đổi số lượng kế hoạch đều được hệ thống ghi nhận vào lịch sử thay đổi (**생산계획 변경이력**) kèm theo chi tiết số lượng cũ, số lượng mới, người sửa và lý do. Lịch sử này có thể xem lại tại trang chi tiết kế hoạch sản xuất.

### 4.2 Quy trình xóa PO:
1. Nhấn nút **"Xóa kế hoạch"** → Click chọn các dòng PO muốn xóa (dòng được chọn sẽ **chuyển sang màu đỏ**).
2. Nhấn nút **"Xóa đối tượng đã chọn"** → Xác nhận **"Xóa"** để hoàn tất.
- ⚠️ **Điều kiện xóa:** Chỉ cho phép xóa PO khi PO ở trạng thái chưa xác nhận (Không được tạo hoặc Không làm) và **chưa phát sinh lệnh chỉ thị sản xuất (PO/작업지시)**. Nếu đã phát sinh PO trên MES, hệ thống sẽ báo lỗi và cấm xóa.

---

## 5. ✅ Chốt PO & Tạo Kế Hoạch Ngày

### Bước 1 – Chốt PO (Xác nhận lô hàng)
- Chọn PO cần chốt → Nhấn nút **"Xác nhận lô hàng"**.
- Trạng thái PO chuyển từ "Không được tạo" sang **"Sản xuất"** (trạng thái khóa cứng, cấm sửa/xóa).
- PO tự động đồng bộ sang màn hình quản lý xưởng **MES B310**.

### Bước 2 – Xác nhận và tạo kế hoạch ngày
1. Click dòng thông báo **"Vui lòng tạo lệnh sản xuất PO"**.
2. Chọn phiên bản BOM **2001** → Chọn kiểu **"Sản xuất"** → Click chọn **"Đã xác nhận"**.
3. Tại phần lưới kế hoạch ngày bên dưới, click **"+"** để tạo dòng mới:
   - **Nơi làm việc:** Chọn nhà máy sản xuất (VVT_F1, VVT_F2, VVT_F3).
   - **Ngày lập kế hoạch:** Chọn ngày chạy máy thực tế.
   - **Cell Line:** Chọn dây chuyền sản xuất tương ứng.
   - **Ca làm việc:** Chọn ca làm việc (ca A, B, v.v.).
   - **Số lượng:** Điền số lượng sản xuất chi tiết.
   * ⚠️ **Quy tắc:** Tổng số lượng kế hoạch ngày cộng lại **phải nhỏ hơn hoặc bằng** số lượng PO tháng gốc.
4. Tích chọn các dòng kế hoạch ngày vừa tạo (dòng được chọn sẽ **chuyển sang màu xanh**).
5. Nhấn **"Mục tiêu lựa chọn Đã xác nhận"** → Chọn **"Áp dụng"** để chốt kế hoạch ngày, dữ liệu tự đồng bộ sang **MES B450**.
- ⚠️ **Hủy kế hoạch ngày:** Một khi kế hoạch ngày đã ở trạng thái **Xác nhận (확정)** hoặc **Đã chốt/Mở ca (마감)**, người dùng **không thể** thực hiện lệnh hủy kế hoạch ngày.

### Bước 3 – Tạo Lô (LOT) & In Tem Mã
1. Nhấn nút **"Chi tiết"** của kế hoạch ngày → Nhấn nút **"Lot Sản xuất"** (hoặc **Tạo Lô (LOT)**).
2. Nhập số lượng giới hạn của mỗi Lot (Ví dụ: `5000` sản phẩm/Lot).
3. Hệ thống tự động chia Lot (Ví dụ: Kế hoạch ngày là 50.000 sản phẩm / 5.000 = 10 Lot) và truyền cờ lệnh in tem trực tiếp xuống trạm **MES B450**.
- ⚠️ **Ràng buộc xóa LOT:** Nếu Lot đó đã được quét ghi nhận sản lượng thực tế tại xưởng (실적등록 완료), người dùng **không thể** thực hiện thao tác xóa Lot trên hệ thống.

---

## 6. ❌ Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| PO không hiện trên B310 | Chưa nhấn "Xác nhận lô hàng" trên Groupware | Thực hiện bước Xác nhận lô hàng để chuyển PO sang trạng thái "Sản xuất" |
| Không tạo được Lot sản xuất | BOM version khác 2001 | Sửa lại BOM version thành 2001 |
| Kế hoạch không hiện B450 | Chưa xác nhận kế hoạch ngày | Tích chọn dòng kế hoạch ngày và nhấn "Mục tiêu lựa chọn Đã xác nhận" |
| Không xóa được kế hoạch sản xuất | Đã phát sinh PO (Lệnh sản xuất) trên MES | Không được phép xóa, phải tiến hành đóng/kết thúc kế hoạch |
| Không xóa được LOT | Lot đã phát sinh dữ liệu sản lượng thực tế (Thực hiện chạy máy) | Không thể xóa Lot |

---

*Cập nhật: 2026-06-12 | Nguồn: Hướng dẫn tạo PO và Kế hoạch ngày trên Groupware.pptx + GROUPWARE PURCHASE, SALES FUNCTION MANUAL.pptx + Comprehensive_Groupware_Report.md*
