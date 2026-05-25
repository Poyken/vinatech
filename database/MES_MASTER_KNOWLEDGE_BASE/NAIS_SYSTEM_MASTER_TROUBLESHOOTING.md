# 📘 NAIS SYSTEM MASTER TROUBLESHOOTING

> Tài liệu tổng hợp các lỗi thực tế đã xử lý, kèm phương pháp trace và script fix.
> Mọi chi tiết fix bug đã được chuẩn hóa thành 1 nguồn duy nhất tại các file KB_0x tương ứng để tránh trùng lặp.

---

## 1. LỖI THIẾU THIẾT LẬP VỎ NHÔM (B597)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_05_QC_ELECTRODE.md § 7.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md)

---

## 2. LỖI GỘP TÚI BÓNG QTY = 0 (HN544)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

## 3. LỖI VENDOR LOT (F330 — Nhập kho NVL)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_02_KHO_WMS.md § 4.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md)

---

## 4. LỖI TRACE KẾ HOẠCH SAI LINE (B450)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_03_SAN_XUAT.md § 5.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md)

---

## 5. LỖI POPUP TRỐNG (B270)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md)

---

## 6. LỖI KHÔNG ĐĂNG NHẬP ĐƯỢC MES
👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md)

---

## 7. LỖI B597 — CHECKLIST ĐẦY ĐỦ
👉 **Checklist B597:** Xem tại [KB_05_QC_ELECTRODE.md § 8.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md)
👉 **Kiểm tra và Bypass hạn sử dụng NVL:** Xem tại [KB_02_KHO_WMS.md § 4.10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md) và [§ 4.9](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md)

---

## 💡 NGUYÊN TẮC VÀNG KHI TỰ SỬA

1. **Luôn SELECT trước khi UPDATE** — đảm bảo WHERE chỉ tác động đúng dòng cần sửa
2. **Dùng BEGIN TRAN ... ROLLBACK/COMMIT** khi sửa dữ liệu quan trọng
3. **Sửa đủ bảng** — thiếu 1 bảng gây lệch dữ liệu (VD: F330 cần sửa 3 bảng)
4. **Ghi log thao tác** — để audit sau

*Cập nhật: 2026-05-25*
