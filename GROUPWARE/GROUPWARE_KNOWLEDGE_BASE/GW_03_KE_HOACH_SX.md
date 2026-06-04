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

## 2. ➕ Tạo PO Mới

1. Nhấn **"Thêm kế hoạch"** → Kéo xuống cuối trang
2. Nhấn **"Yêu cầu mặt hàng"** → Tìm và chọn model (nhiều model cùng lúc được)
3. Điền thông tin:

| Trường | Mô tả |
|--------|-------|
| Tháng | Tháng sẽ làm PO |
| Số lượng | Tổng SL trong tháng |
| Kiểu PO | **Sản xuất** (Trạng thái cấm xóa, cố định đơn) hoặc **Không làm** (Trạng thái nháp, có thể hủy) |
| Phiên bản BOM | ⚠️ **PHẢI chọn 2001** |

4. Nhấn **"Đăng ký gói"** → **"Sự đăng ký"** → Xác nhận

---

## 3. 📋 Sao Chép PO Từ Tháng Trước

- Nhấn **"Sao chép kế hoạch sản xuất"** → Chọn tháng cần copy
- Hệ thống copy toàn bộ BOM → Chỉnh sửa SL → Đăng ký gói
- 💡 **Ưu điểm:** Sao chép nhanh Kế hoạch tổng PO của các tháng trước bê y nguyên sang tháng sau. Tránh việc phải nhập thủ công hàng nghìn mã BOM Code.

---

## 4. ✏️ Sửa / Xóa PO

### 4.1 Quy trình sửa đổi thông tin PO:
1. Click chọn trực tiếp vào dòng PO cần sửa đổi (1).
2. Điền đầy đủ lý do sửa đổi vào ô nhập liệu (2).
3. (Nếu muốn hủy bỏ thao tác sửa → ấn nút **"Hủy bỏ"** (3)).
4. Kéo chuột lên đầu trang, nhấn nút **"Lưu kế hoạch"** (4).
5. Hộp thoại hiện ra → chọn **"Điều chỉnh"** (5) để xác nhận cập nhật dữ liệu.

### 4.2 Quy trình xóa PO:
1. Nhấn nút **"Xóa kế hoạch"** (1).
2. Click chọn dòng PO muốn xóa trong danh sách.
   * 💡 **Nhận diện:** Dòng PO được chọn sẽ tự động **chuyển sang màu đỏ**.
3. Nhấn nút **"Xóa đối tượng đã chọn"** (3).
4. Hộp thoại xác nhận hiện ra → nhấn **"Xóa"** (4) để hoàn tất.
5. (Nếu muốn hủy bỏ thao tác xóa → ấn nút **"Hủy bỏ"** (5)).

> ⚠️ **Quy tắc:** Chỉ có thể xóa hoặc sửa đổi PO khi PO đang ở trạng thái **chưa xác nhận** (trạng thái hiển thị là "Không được tạo" hoặc "Không làm"). Một khi đã xác nhận lô hàng, PO sẽ bị khóa cứng.


---

## 5. ✅ Chốt PO & Tạo Kế Hoạch Ngày

### Bước 1 – Chốt PO
- Chọn PO cần chốt trong danh sách.
- Nhấn nút **"Xác nhận lô hàng"** → PO tự động chuyển trạng thái từ **"Không được tạo"** (hoặc "Không làm") sang **"Sản xuất"** (trạng thái khóa cứng, cấm xóa).
- PO lúc này sẽ tự động xuất hiện trên màn hình **MES B310** (Màn hình giám sát PO cấp xưởng).

### Bước 2 – Xác nhận và tạo kế hoạch ngày
1. Click chọn dòng thông báo **"Vui lòng tạo lệnh sản xuất PO"**.
2. Tại đây, chọn đúng phiên bản BOM **2001** (mã BOM Việt Nam) → Chọn **"Sản xuất"** → Click chọn **"Đã xác nhận"**.
3. Phần nhập liệu bên dưới sẽ xuất hiện để tạo kế hoạch ngày. Cấu hình rõ:
   - **Nơi làm việc:** Chọn nhà máy sản xuất tương ứng.
   - **Ngày lập kế hoạch:** Chọn ngày chạy máy thực tế.
   - **Cell Line:** Chọn dây chuyền sản xuất.
   - **Ca làm việc:** Chọn ca làm việc (ca A, B, v.v.).
   - **Số lượng:** Điền số lượng sản xuất chi tiết.
   * 💡 **Thao tác nhanh:** Có thể nhấn nút **"+"** để tạo thêm dòng kế hoạch ngày mới, hoặc nhấn nút **"-"** để xóa dòng.
   * ⚠️ **Quy tắc:** Tổng số lượng sản xuất của toàn bộ kế hoạch ngày cộng lại **phải nhỏ hơn hoặc bằng** tổng số lượng của PO gốc.
4. Sau khi điền đầy đủ, click chọn các dòng kế hoạch ngày cần xác nhận.
   * 💡 **Nhận diện:** Dòng được chọn thành công sẽ tự động **chuyển sang màu xanh**.
5. Nhấn nút **"Mục tiêu lựa chọn Đã xác nhận"** → Chọn **"Áp dụng"**. Hệ thống sẽ thông báo thao tác thành công.

### Bước 3 – Tạo Lô (LOT) & In Tem Mã
- Nhấn nút **"Chi tiết"** của kế hoạch ngày cần tạo Lot.
- Nhấn tiếp nút **"Lot Sản xuất"** (hoặc nút **Tạo Lô (LOT)**) → Một ô nhập liệu nhỏ sẽ hiển thị.
- Nhập giới hạn số lượng của **mỗi Lot** (Ví dụ: nhập **5000**).
- Hệ thống tự động chia lô: lấy Tổng số lượng kế hoạch ngày (ví dụ: **50.000**) chia cho số lượng mỗi lot (5000) để **tự động cắm Cờ IN RA 10 LÔ TEM MÃ** (50.000 / 5000 = 10 Lot) trực tiếp trên trạm **MES B450**.


---

## 6. ❌ Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| PO không hiện trên B310 | Chưa "Xác nhận lô hàng" | Xác nhận lô hàng trên GW |
| Không tạo được Lot | BOM version ≠ 2001 | Đổi BOM về 2001 |
| Kế hoạch không hiện B450 | Chưa xác nhận kế hoạch ngày | Thực hiện bước xác nhận kế hoạch |

---

*Cập nhật: 2026-06-04 | Nguồn: Hướng dẫn tạo PO và Kế hoạch ngày trên Groupware.pptx + Comprehensive_Groupware_Report.md*
