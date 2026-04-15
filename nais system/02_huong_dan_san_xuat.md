# NAIS MES - Hướng Dẫn Sản Xuất (B screens)

> Nguồn: "HuongDanHehongSanxuat" - Một số màn hình sản xuất trên hệ thống MES

## Flow tổng quan sản xuất

```
B310 (Tạo PO theo tháng)
  │
  ▼
B450 (Kế hoạch lắp ráp theo ngày → FixDayPlan)
  │
  ▼
B540 (Nhập thẻ công đoạn)
  ├── Sấy hàng → In barcode
  ├── Kiểm tra thường xuyên (thông số + bắn NVL)
  └── Nhập số lượng SX (nhập lỗi → hoàn thành)
  │
  ▼
B598 (Báo phế NVL hỏng)
```

---

## B310 - Tạo PO (Production Order)

### Mục đích
Tạo lệnh sản xuất theo **tháng** cho từng sản phẩm.

### Quy trình
1. Vào B310 → Ấn **"Tạo PO thủ công"**
2. Popup hiện lên → điền thông tin:
   - Chọn sản phẩm cần sản xuất
   - **BOM Version**: bắt buộc = **99**
   - **ProQty**: số lượng cả **THÁNG** (không phải theo ngày)
3. Ấn **OK** để tạo PO
4. Tích chọn bản ghi vừa thêm → Ấn **"Chốt"** để xác nhận
5. Kiểm tra các tab bên dưới → xem công đoạn đã đúng chưa

### Lưu ý
- **POCancel**: xóa PO vừa tạo
- Phải **Chốt** thì PO mới có hiệu lực
- Kiểm tra tab công đoạn bên dưới trước khi chốt

---

## B450 - Kế hoạch lắp ráp theo ngày

### Mục đích
Chia PO tháng thành **kế hoạch sản xuất hàng ngày** cho từng line.

### Quy trình
1. Vào B450 → Ấn **"POSelectDialog"**
2. Popup hiện → nhập số PO (từ B310) → tìm kiếm → tích chọn → **OK**
3. Điền **4 cột bắt buộc** (có màu đậm):

| Cột | Nội dung |
|-----|----------|
| Mã line | Line sản xuất |
| Ngày theo kế hoạch | Ngày SX cụ thể |
| PlanShiftCode | **1** = Ca ngày, **2** = Ca đêm |
| Số lượng kế hoạch | Số lượng SX trong ngày đó |

4. Ấn **Lưu** để lưu lại
5. Ấn **"FixDayPlan"** → sản xuất mới có thể tạo lot

### Lưu ý quan trọng
- ⚠️ **Chưa ấn FixDayPlan = SX không tạo lot được**
- 💡 Có thể tạo PO trước, đến ngày SX mới ấn FixDayPlan

---

## B540 - Nhập thẻ công đoạn

### Mục đích
Màn hình chính để **theo dõi hàng qua từng công đoạn**: sấy, kiểm tra, nhập lỗi.

### Chức năng 1: Sấy hàng
1. Click **"Sấy hàng"** → màn hình sấy hiện lên
2. Chọn **máy sấy** → Ấn **"Tìm kiếm"**
3. Ấn **Lưu** (⚠️ lưu xong không thay đổi được)
4. Điền **4 cột bôi đậm** → phải nhập đủ mới in được barcode
   - Nếu thiếu → in barcode sẽ **báo lỗi**

### Chức năng 2: Kiểm tra thường xuyên (Việt Nam)
1. Click **"Việt Nam_Kiểm tra thường xuyên"** → màn hình mới
2. **Khung A** (bên trái): Nhập thông số kiểm tra
   - Kiểm tra sau sấy
   - Ngoại quan, đo đạc thực tế
   - Nhập xong → **Lưu**
3. **Khung B**: Nhập mã nguyên vật liệu
   - Bắn/scan mã NVL dùng để tạo con hàng
   - ⚠️ NVL phải **order từ kho** → kho xuất ra → mới bắn được lên hệ thống
   - Nhập xong → **Lưu**

### Chức năng 3: Nhập số lượng sản xuất (Nhập lỗi)
1. Click **"Nhập slg sản xuất"** → màn hình nhập lỗi
2. Ấn **nút thêm** → thêm 1 dòng lỗi mới
3. Chọn **loại lỗi** phù hợp
4. Nhập **DefectQty** (số lượng hàng lỗi)
5. Ấn **"Nhập lỗi"** → Yes để xác nhận
6. Lặp lại cho đến khi nhập hết các loại lỗi
7. Ấn **"Hoàn thành kết quả sản xuất"** → Yes xác nhận
8. Ra màn hình ngoài → kiểm tra:
   - Số lượng lỗi đã đúng chưa
   - Số lượng đầu vào công đoạn tiếp theo

---

## B598 - Báo phế sản xuất

### Mục đích
Báo phế **NVL bị hỏng** trong quá trình sản xuất.

### Quy trình
1. Vào B598
2. Ấn **nút thêm** → thêm dòng dữ liệu mới
3. Điền thông tin cần thiết (loại NVL, số lượng phế...)
4. Ấn **Lưu** để lưu báo phế

---

## Mối liên hệ giữa các màn hình

```
B310 ──creates──→ PO (lệnh SX tháng)
  │
  └──referenced by──→ B450 (chia PO → kế hoạch ngày)
                         │
                         └──FixDayPlan──→ Cho phép SX tạo Lot
                                           │
                                           ▼
                                        B540 (xử lý từng công đoạn)
                                         ├── Sấy → In barcode
                                         ├── Kiểm tra → Scan NVL (NVL phải order từ kho trước)
                                         └── Nhập lỗi → Hoàn thành → Chuyển công đoạn tiếp
                                           │
                                           ▼
                                        B598 (NVL hỏng → báo phế)
```

## Câu hỏi còn thiếu

- [ ] B530 (Nhập thực tế SX) - được đề cập trong tổng quan nhưng chưa có hướng dẫn chi tiết
- [ ] B523 (Đóng gói, gộp box) - chưa có hướng dẫn
- [ ] B597 (Kiểm tra NVL theo công đoạn) - chưa rõ khác gì chức năng "Kiểm tra thường xuyên" trong B540
- [ ] Mối liên hệ giữa B540 "Kiểm tra thường xuyên - Khung B" (scan NVL) và B597

---
*Cập nhật: 2026-03-07 | Phần 2/N*
