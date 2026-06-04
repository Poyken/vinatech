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

## 8. LỖI KHÔNG GỘP ĐƯỢC BOX (B523) — 4 BƯỚC DEBUG CHUẨN
👉 **Chi tiết Trace & Fix (4 bước chuẩn):** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)
👉 **Demo case + Script SQL:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)

---

## 9. LỖI USER MUỐN HỦY KẾT QUẢ / HỦY CÔNG ĐOẠN
👉 **3 kịch bản (Hủy routing, Hủy QC, Hủy OQC):** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Xóa nhập sản lượng công đoạn:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md)

---

## 10. LỖI GỘP BOX 2 LẦN BỊ NHẦM / GỘP BOX SAI SỐ LƯỢNG
👉 **Hủy gộp box + Rã box + Khôi phục Qty:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Gộp túi bóng Qty=0 (HN544):** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)
👉 **Packing Qty âm:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

## 11. LỖI KHÔNG CHỐT ĐƯỢC CÔNG ĐOẠN (B530)
👉 **3 kịch bản (NVL chưa scan, công đoạn đảo thứ tự, Gate 20 phút):** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)

---

## 12. LỖI KHÔNG IN ĐƯỢC TEM (B450 / B523 / B756)
👉 **5 bước kiểm tra + Checklist đầy đủ:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Checklist 7 bước khi user báo không in được:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.12](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

## 13. LỖI MÀN HNC321 NHẬP PHẾ BÁO LỖI TIẾNG HÀN
👉 **Bypass nghiệp vụ + Bypass SQL (chèn lịch sử giả lập):** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Cũng có tại:** [KB_08_KHO_THANH_PHAM_HN.md § 4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md)

---

## 14. LỖI NHẢY BƯỚC CÂN ĐIỆN CỰC MIXING (electrode.weighing)
👉 **Nguyên nhân checkbox CA ĐÊM + Reset Lot kẹt:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)

---

## 16. LỖI SẢN LƯỢNG OUTPUT = 0 KHI GỘP BOX TÙY CHỈNH (HN523)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.13](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#613-phân-tích-nguyên-nhân-lỗi-gộp-box-tùy-chỉnh-trên-màn-hình-hn523-sản-lượng-hiển-thị--0--cảnh-báo-tiếng-hàn)

---

## 17. LỖI KHO THÀNH PHẨM HÀ NAM TỰ ĐỘNG ĐỔI MÃ HÀNG (STB_ChangeMaterialCode_HN)
👉 **Đăng ký thay đổi mã vật tư:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 3.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md#31-đăng-ký-thay-đổi-mã-vật-tư-thủ-công-qua-stb_changematerialcode_hn)

---

## 18. ĐĂNG KÝ MÃ VẬT TƯ MỚI VÀO MASTER DATA (STB_MaterialMaster)
👉 **Hướng dẫn chèn SQL thủ công:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 1.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#13-đăng-ký-mã-vật-tư-mới-vào-stb_materialmaster-a230-qua-sql)

---

## 19. TRA CỨU MẪU THIẾT KẾ VÀ MAPPING TEM IN CHO KHÁCH HÀNG MỚI (SANMINA)
👉 **SQL queries tìm mẫu tem & SP:** Xem tại [KB_09_IN_TEM_LABEL.md § 12](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_09_IN_TEM_LABEL.md#12-tra-cứu-sp-và-thiết-kế-tem-cho-khách-hàng-mới-ví-dụ-sanmina)

---

## 20. LỖI HỆ THỐNG TREO/CHẬM DO TRANH CHẤP DATABASE (BLOCK SESSION)
👉 **SQL query kiểm tra block session:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 5.D](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md#d-kiểm-tra-block-session-khóa-bảngdatabase-bị-treo)

---

## 💡 NGUYÊN TẮC VÀNG KHI TỰ SỬA

1. **Luôn SELECT trước khi UPDATE** — đảm bảo WHERE chỉ tác động đúng dòng cần sửa
2. **Dùng BEGIN TRAN ... ROLLBACK/COMMIT** khi sửa dữ liệu quan trọng
3. **Sửa đủ bảng** — thiếu 1 bảng gây lệch dữ liệu (VD: F330 cần sửa 3 bảng)
4. **Ghi log thao tác** — để audit sau

*Cập nhật: 2026-05-27*