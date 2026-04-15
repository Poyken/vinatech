# NAIS MES - Hướng Dẫn QC (C screens)

> Nguồn: "HuongDanHehongQC" + "Hướng dẫn tổng quan quy trình QC"

## Flow tổng quan 3 nhóm QC

### IQC - Kiểm tra đầu vào NVL
```
C121 (Tạo nhóm + hạng mục kiểm tra chung) ─── Dùng chung cho IQC & OQC
  ↓
C122 (Gán hạng mục cho từng mã NVL)
  ↓
C220 (Thực hiện kiểm tra NVL đầu vào)
```

### OQC - Kiểm tra thành phẩm xuất xưởng
```
C121 (Nhóm + hạng mục chung) ─── Dùng chung cho IQC & OQC
  ↓
C151 (Hạng mục kiểm tra riêng cho từng MODEL)
  ↓
C512 (Tạo lot kiểm tra theo model - cần barcode từ SX)
  ↓
C530 (Kiểm tra OQC theo từng mẫu)
  ↓
C540 (Lịch sử kiểm tra - xem lại từ C530)
```

### PQC - Kiểm tra trong quá trình SX
```
C141 (Tạo nhóm + hạng mục kiểm tra chung PQC)
  ↓
C143 (Hạng mục riêng cho từng MODEL)
  │    ├── Mã TEST ────→ B597 (SX nhập thông số kiểm tra thường xuyên)
  │    └── Mã QUALITY ─→ C443 (QC kiểm tra PQC)
  ↓
C443 (Kiểm tra PQC - ngoài line)
  ↓
C430 (Lịch sử kiểm tra PQC)
```

> ⚠️ **Quan trọng**: Trong C143, phân biệt rõ:
> - **Mã TEST** = Hạng mục do **sản xuất** tự kiểm tra → nhập trên **B597**
> - **Mã QUALITY** = Hạng mục do **QC** kiểm tra → nhập trên **C443**

---

## Chi tiết thiết lập cơ bản (Config 1 lần)

### C111 - Hằng số thống kê cơ bản
- Giá trị cố định theo số lượng mẫu - **không cần thay đổi**

### C112 - Tiêu chuẩn AQL
- Ô **màu xanh đậm** bắt buộc nhập

### C113 - Thông tin cơ bản kiểm tra mẫu

---

## Chi tiết thiết lập IQC/OQC

### C121 - Quản lý hạng mục kiểm tra (IQC + OQC)
1. Ấn **(+)** → thêm nhóm kiểm tra
2. Điền thông tin → ⚠️ **tích "Sử dụng"** → Save
3. Thêm hạng mục chi tiết → điền **cột tiêu đề đậm** → Save

### C122 - Gán hạng mục cho từng NVL
1. Tìm NVL → nếu trống → ấn **"Chọn trong nhóm/Hạng mục kiểm tra"**
2. Popup → tìm nhóm (từ C121) → tích **Test1** → OK → Save
3. ⚠️ NVL không config ở C122 → **C220 sẽ trống**

### C220 - Kiểm tra NVL đầu vào (IQC)
- Hiển thị hạng mục đã gán ở C122 → QC thực hiện kiểm tra

### C151 - Hạng mục riêng cho từng model (OQC)
- Tương tự C122 nhưng cho **sản phẩm thành phẩm** thay vì NVL

### C512 - Tạo lot kiểm tra (OQC)
- Sau khi SX cung cấp **barcode** → tạo lot kiểm tra

### C530 - Kiểm tra OQC theo mẫu
- QC kiểm tra từng mẫu trong lot

### C540 - Lịch sử kiểm tra OQC
- Xem lại kết quả kiểm tra từ C530

---

## Chi tiết thiết lập PQC

### C141 - Hạng mục kiểm tra chung PQC
- Tạo nhóm + hạng mục kiểm tra dùng cho PQC

### C143 - Hạng mục riêng cho từng model (PQC)
- Chọn thông số từ C141
- **Mã TEST** → SX kiểm tra trên **B597**
- **Mã QUALITY** → QC kiểm tra trên **C443**

### C443 - Kiểm tra PQC (ngoài line)
- QC thực hiện kiểm tra công đoạn

### C430 - Lịch sử kiểm tra PQC

---

## Màn hình lỗi & Báo cáo bất thường

### C131 - Nhóm lỗi
- Tạo nhóm mã lỗi phù hợp công đoạn → liên kết với SX

### C132 - Chi tiết lỗi
- Thêm/sửa/xóa lỗi trong nhóm → hiển thị khi SX nhập lỗi tại **B530**

### B530 - Nhập lỗi trên từng công đoạn
- SX chọn lỗi (từ C132) và nhập số lượng

### C385 - Báo cáo bất thường ⚡ MỚI
- Nhập báo cáo lỗi bất thường → **gửi email tự động**

### C390 - Xem báo cáo bất thường ⚡ MỚI
- Xem lại các báo cáo đã tạo từ C385

---

## Tổng hợp liên kết QC ↔ Kho ↔ Sản xuất

```
KHO NVL                    QC                         SẢN XUẤT
────────                   ──                         ────────
F312 (ghi chú NVL)
  ↓
F330 (nhập kho)
  ↓
               ←── C220 (IQC kiểm tra NVL) ←── C122 ←── C121
  ↓
F430 (xuất NVL)  ──────────────────────────→  B540 (nhập thẻ công đoạn)
                                                ↓
                   C443 (PQC kiểm tra) ←──── B597 (SX nhập thông số)
                   C430 (lịch sử PQC)          ↓
                                              B530 (nhập lỗi) ←── C132 (mã lỗi)
                                                ↓
                                              B523 (đóng gói)
                                                ↓
                   C512 (tạo lot OQC) ←── barcode từ SX
                   C530 (kiểm tra OQC)
                   C540 (lịch sử OQC)
                                                ↓
                                              FG01/FG00 (kho thành phẩm)
```

---
*Cập nhật: 2026-03-07 | Phần 4/N - Đã merge 2 file QC*
