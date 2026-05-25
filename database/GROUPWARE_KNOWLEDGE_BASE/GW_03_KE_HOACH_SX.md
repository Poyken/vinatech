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

**Sửa:** Click vào dòng PO → Điền lý do sửa → Lưu kế hoạch → Chọn "Điều chỉnh"

**Xóa:** Nhấn "Xóa kế hoạch" → Chọn dòng (chuyển đỏ) → "Xóa đối tượng đã chọn"
> ⚠️ Chỉ xóa được khi PO **chưa xác nhận** (trạng thái "Không được tạo" / "Không làm")

---

## 5. ✅ Chốt PO & Tạo Kế Hoạch Ngày

### Bước 1 – Chốt PO
- Chọn PO → **"Xác nhận lô hàng"** → PO tự động chuyển trạng thái từ **"Không được tạo"** sang **"Sản xuất"** (cấm xóa).
- PO xuất hiện trên **MES B310** (Màn hình giám sát PO cấp xưởng).

### Bước 2 – Xác nhận và tạo kế hoạch ngày
1. Click **"Vui lòng tạo lệnh sản xuất PO"**
2. Chọn BOM **version 2001** → **"Sản xuất"** → **"Đã xác nhận"**
3. Điền kế hoạch ngày, cấu hình rõ: **"Nơi làm việc"** (Nhà máy), **"Cell Line"** và **"Ca Làm Việc"** (Ca).
4. Thiết lập số lượng tổng (Yêu cầu: **Số lượng kế hoạch ngày phải <= Lượng PO gốc**).
5. Chọn các dòng (màu xanh) → **"Mục tiêu lựa chọn Đã xác nhận"** → Áp dụng.

### Bước 3 – Tạo Lô (LOT) & In Tem Mã
- Nhấn **"Chi tiết"** → **"Lot Sản xuất"** (hoặc nút **Tạo Lô (LOT)**).
- Nhập giới hạn số lượng nhỏ nhất cho 1 Lot (Ví dụ: nhập **5000**).
- Hệ thống sẽ lấy Tổng Kế Hoạch (ví dụ: **50.000**) chia cho số lượng 1 Lot (5000) để **tự động cắm Cờ IN RA 10 LÔ TEM MÃ** trực tiếp trên trạm **B450** của MES.

---

## 6. ❌ Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| PO không hiện trên B310 | Chưa "Xác nhận lô hàng" | Xác nhận lô hàng trên GW |
| Không tạo được Lot | BOM version ≠ 2001 | Đổi BOM về 2001 |
| Kế hoạch không hiện B450 | Chưa xác nhận kế hoạch ngày | Thực hiện bước xác nhận kế hoạch |

---

*Cập nhật: 2026-05-25 | Nguồn: Hướng dẫn tạo PO và Kế hoạch ngày trên Groupware.pptx + Comprehensive_Groupware_Report.md*
