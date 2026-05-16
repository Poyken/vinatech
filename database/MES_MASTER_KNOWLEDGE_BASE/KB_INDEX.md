# 🗂️ NAIS MES — Knowledge Base Index

> **Cập nhật:** 2026-05-06 | **Tổng hợp từ:** Lỗi thực tế + Docx gốc (đã extract toàn bộ)
> **Cách dùng:** Đọc file INDEX này trước, sau đó mở file KB chuyên biệt theo nhóm lỗi.

---

## 📋 Danh sách file KB chuyên biệt

| File | Nội dung | Màn hình liên quan |
|------|----------|--------------------|
| [KB_01_UI_PHAN_QUYEN.md](KB_01_UI_PHAN_QUYEN.md) | Login, cài đặt, phân quyền User, giá Stage Prices | Login, A460, Z410, Z220, B682, B781 |
| [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) | Kho NVL: F330 sai kho, F312 sửa code, F430 ngày xuất, FIFO, Holding | F330, F312, F430, F110, F721 |
| [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md) | Sửa JobDate, Chuyển Line, VV→VJ, Xóa PO, NG DefectQty, Andon | B782, B781, B598, B726, B791, B310, B450 |
| [KB_04_DONG_GOI_IN_TEM.md](KB_04_DONG_GOI_IN_TEM.md) | Tiêu chuẩn đóng gói, fix PartNo in tem, sửa mã Lot B523 | B523, B789, B351, A419 |
| [KB_05_QC_ELECTRODE.md](KB_05_QC_ELECTRODE.md) | QC B597/C443/C512, Điện cực Slitting B552, Lỗi chuỗi độ dày | B597, C443, C512, B552 |
| [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md) | Model mới, Vol/Farad, SQL Utilities, Manual Bypass in tem khẩn | A410, STB_ModelBasicInfo, SQL tools |
| [KB_07_GROUPWARE_INTEGRATION.md](KB_07_GROUPWARE_INTEGRATION.md) | Tích hợp Groupware: Mua hàng, Kế hoạch Sản Xuất, Đăng ký Code | Groupware, F330, C220, B310, B450 |
| [NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md](NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md) | **[MỚI]** Cẩm nang xử lý lỗi NAIS tổng hợp từ Docx & Hình ảnh | Toàn bộ hệ thống |

---

## ⚡ Tra cứu nhanh theo triệu chứng

| Triệu chứng | File cần đọc |
|-------------|-------------|
| Không đăng nhập được MES | KB_01 |
| Sửa ngày JobDate / PrintTime | KB_03 |
| Kho nhập sai Warehouse | KB_02 |
| Lot không in tem được / Part No sai | KB_04 |
| B597 báo lỗi chuỗi điện cực | KB_05 |
| Model mới không hiện Vol/Farad | KB_06 |
| Cần in tem khẩn không có Lot trên hệ thống | KB_06 |
| Không tìm thấy Lot ở C512 | KB_05 |
| Giá lên B682/B781 | KB_06 |
| Slitting chiều rộng B552 | KB_05 |
| Groupware: Lỗi duyệt PO, sai BOM, hàng nhập chưa có QC | KB_07 |
| **Gộp túi bóng bị mất số lượng (Qty = 0)** | **KB_04** |
| **Lỗi "Chưa CONFIG trong STB_SLITTINGLOCATIONCONFIG_VVT"** | **KB_05** |
| **Lỗi "Không tồn tại thiết lập Vỏ Nhôm"** | **KB_06** |
| **TRA CỨU TỔNG HỢP (ẢNH + SQL)** | **NAIS_SYSTEM_MASTER_TROUBLESHOOTING** |
