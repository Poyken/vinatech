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
| Kiểu PO | **Sản xuất** = Đã fix | **Không được tạo** = Còn sửa được |
| Phiên bản BOM | ⚠️ **PHẢI chọn 2001** |

4. Nhấn **"Đăng ký gói"** → **"Sự đăng ký"** → Xác nhận

---

## 3. 📋 Sao Chép PO Từ Tháng Trước

- Nhấn **"Sao chép kế hoạch sản xuất"** → Chọn tháng cần copy
- Hệ thống copy toàn bộ BOM → Chỉnh sửa SL → Đăng ký gói

---

## 4. ✏️ Sửa / Xóa PO

**Sửa:** Click vào dòng PO → Điền lý do sửa → Lưu kế hoạch → Chọn "Điều chỉnh"

**Xóa:** Nhấn "Xóa kế hoạch" → Chọn dòng (chuyển đỏ) → "Xóa đối tượng đã chọn"
> ⚠️ Chỉ xóa được khi PO **chưa xác nhận**

---

## 5. ✅ Chốt PO & Tạo Kế Hoạch Ngày

### Bước 1 – Chốt PO
- Chọn PO → **"Xác nhận lô hàng"** → PO chuyển sang **"Sản xuất"**
- PO xuất hiện trên **MES B310**

### Bước 2 – Xác nhận và tạo kế hoạch ngày
1. Click "Vui lòng tạo lệnh sản xuất PO"
2. Chọn BOM **version 2001** → "Sản xuất" → "Đã xác nhận"
3. Điền kế hoạch ngày: Nhà máy, Ngày, Cell Line, Ca, Số lượng
4. Chọn các dòng (màu xanh) → "Mục tiêu lựa chọn Đã xác nhận" → Áp dụng

### Bước 3 – Tạo Lot
- Nhấn "Chi tiết" → "Lot Sản xuất" → Nhập số lượng/Lot → Áp dụng
- Ví dụ: Kế hoạch 50,000 | Mỗi Lot 5,000 → Tạo **10 Lot**

---

## 6. ❌ Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| PO không hiện trên B310 | Chưa "Xác nhận lô hàng" | Xác nhận lô hàng trên GW |
| Không tạo được Lot | BOM version ≠ 2001 | Đổi BOM về 2001 |
| Kế hoạch không hiện B450 | Chưa xác nhận kế hoạch ngày | Thực hiện bước xác nhận kế hoạch |

---

*Cập nhật: 2026-05-18 | Nguồn: Hướng dẫn tạo PO và Kế hoạch ngày trên Groupware.pptx*
