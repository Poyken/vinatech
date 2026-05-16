# 🗂️ NAIS MES — Knowledge Base Index

> **Cập nhật:** 2026-05-17 | **Tổng hợp từ:** Lỗi thực tế + Docx gốc (đã extract toàn bộ)
> **Cách dùng:** Đọc file INDEX này trước, sau đó mở file KB chuyên biệt theo nhóm lỗi.

---

## 📋 Danh sách file KB chuyên biệt

| File | Nội dung | Màn hình liên quan |
|------|----------|-------------------|
| [KB_01_UI_PHAN_QUYEN.md](KB_01_UI_PHAN_QUYEN.md) | Login, cài đặt, phân quyền User, Stage Prices | Login, A460, Z410, Z220, Z330, B682, B781 |
| [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) | Kho NVL: F330 sai kho, F312, F430, FIFO, Holding, Hạn dùng | F330, F312, F430, F110, F721, C220 |
| [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md) | Sửa JobDate, Chuyển Line, VV→VJ, Xóa PO, NG, Andon | B782, B781, B598, B726, B791, B310, B450 |
| [KB_04_DONG_GOI_IN_TEM.md](KB_04_DONG_GOI_IN_TEM.md) | Tiêu chuẩn đóng gói, fix B523 không gộp, sửa mã Lot, Qty=0 | B523, B789, B781, B351, A419 |
| [KB_05_QC_ELECTRODE.md](KB_05_QC_ELECTRODE.md) | QC B597/C443/C512, Điện cực Slitting B552, Lỗi chuỗi độ dày | B597, C443, C512, B552 |
| [KB_05_TRACE_BUG_METHODOLOGY.md](KB_05_TRACE_BUG_METHODOLOGY.md) | Phương pháp trace bug 5 bước, Log hệ thống, Bảng quan trọng | Toàn bộ |
| [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md) | Model mới, Vol/Farad, Thêm Cell/Line, SQL Utilities, Bypass | A410, B250, B270, SQL tools |
| [KB_07_GROUPWARE_INTEGRATION.md](KB_07_GROUPWARE_INTEGRATION.md) | Tích hợp Groupware: Mua hàng, Kế hoạch SX, Master Data | Groupware, F330, C220, B310, B450 |
| [KB_08_KHO_THANH_PHAM_HN.md](KB_08_KHO_THANH_PHAM_HN.md) | Kho TP Hà Nam: Xuất HN551, Tồn HN866, Hủy F330, Xóa sản lượng | HN551, HN866, HN544, FG00 |
| [KB_09_IN_TEM_LABEL.md](KB_09_IN_TEM_LABEL.md) | Các loại tem đặc biệt, lỗi sai mẫu, in tem khẩn | B450, B756, B767, B790, A460 |
| [NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md](NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md) | Cẩm nang xử lý lỗi NAIS tổng hợp từ Docx & Hình ảnh | Toàn bộ |

---

## ⚡ Tra cứu nhanh theo triệu chứng

| Triệu chứng | File & Mục |
|-------------|-----------|
| Không đăng nhập được MES | KB_01 § 1.1 |
| Không in được tem B450 | KB_01 § 1.2 |
| Popup B270 trống | KB_01 § 1.3, KB_06 § 7 |
| Thêm/xóa user, phân quyền | KB_01 § 2 |
| Giá lên B682/B781 bị trống | KB_01 § 3.1, KB_06 § 3 |
| Kho nhập sai Warehouse (F330) | KB_02 § 4.3 |
| Sửa số lượng F312 | KB_02 § 4.5 |
| Hàng hết hạn sử dụng | KB_02 § 4.10 |
| Chuyển từ kho Holding sang kho chính | KB_02 § 4.7 |
| Không tìm thấy Lot ở C512 | KB_02 § 4.2, KB_05 § 7.2 |
| Xóa phiếu nhập kho F330 đã Confirm | KB_08 § 5 |
| Sửa ngày JobDate B782 | KB_03 § 5.2 |
| Sửa ngày PrintTime B781 | KB_03 § 5.3 |
| Chuyển Line sản xuất | KB_03 § 5.9 |
| Xóa PO (B310/B450) | KB_03 § 5.7 |
| Sửa số lượng NG DefectQty | KB_03 § 5.8 |
| Đổi Barcode VV→VJ | KB_03 § 5.10 |
| Xóa nhập sản lượng 1 công đoạn | KB_08 § 4 |
| Lot không in tem được | KB_04 § 6.10 (checklist) |
| B523 không gộp Box | KB_04 § 6.4 |
| Packing Qty âm | KB_04 § 6.6 |
| Gộp túi bóng Qty = 0 (HN544) | KB_04 § 6.5 |
| In tem sai mẫu (5H1 → 6D1) | KB_09 § 3 |
| Không có Lot, muốn in tem khẩn | KB_09 § 4 |
| Tìm màn hình thiết kế/in tem | KB_09 § 5 |
| B597 lỗi hạng mục kiểm tra cũ | KB_05 § 7.1 |
| B597 lỗi hết hạn sử dụng | KB_02 § 4.10 |
| B597 lỗi Vỏ Nhôm | KB_05 § 7.4 |
| B597 lỗi Electrolyte không khớp | KB_05 § 7.5 |
| B597 lỗi chuỗi điện cực | KB_05 § 7.6 |
| Lỗi HOLDING | KB_05 § 7.7 |
| Lỗi "Chưa CONFIG Slitting" | KB_05 § 8.2 |
| Lỗi chiều rộng Slitting B552 | KB_05 § 8.1 |
| Model mới không hiện Vol/Farad | KB_06 § 1.2 |
| In tem khẩn không có Lot | KB_06 § 6, KB_09 § 4 |
| Thêm Cell/Line mới (B250/B270) | KB_06 § 7 |
| Hàng xuất HN551 nhưng HN866 vẫn còn | KB_08 § 1 |
| Lot bị đổi MaterialCode tự động | KB_08 § 2 |
| Màn HNC321 nhập phế lỗi | KB_08 § 3 |
| Không PO trên MES từ Groupware | KB_07 § 6 |
| Không nhập được F330 (chưa duyệt) | KB_07 § 2 |
| Trace lỗi không biết bắt đầu từ đâu | KB_05_TRACE_BUG_METHODOLOGY |

---

## 🔑 Bảng DB & SP Quan Trọng Nhất

| Bảng / SP | Chức năng | Màn hình |
|-----------|-----------|---------|
| `STB_SetInfo` | Thông tin Barcode/Lot gốc | B450, B530, B540 |
| `STB_ProdRouteHist` | Lịch sử công đoạn | B782, B530 |
| `STB_MaterialLotInfo` | Tồn kho & PackingID | B523, F721 |
| `STB_MachineMaster` | Master máy móc | B250 |
| `STB_ProductMachine` | Mapping máy-route | B270 |
| `STB_LineInfo` | Master Line sản xuất | B450 |
| `STB_ModelBasicInfo` | Thông số kỹ thuật model | A410, C512 |
| `STB_MaterialMaster` | Master vật tư | A230, F721 |
| `STB_DayProdPlan` | Kế hoạch ngày | B450 |
| `STB_CommInspDocHistory` | Lịch sử kiểm tra QC | B597, C443 |
| `STB_AluCaseMapping_VVT` | Mapping vỏ nhôm | B597 |
| `stb_slittinglocationconfig_vvt` | Config điện cực Slitting | B552, B597 |
| `STB_SavePackingTime_VVT` | Lịch sử đóng gói | B781, B789 |
| `STB_VVT_StagePrices` | Giá công đoạn Cell | B682, B781 |
| `STB_ProcessTerminalDataLog` | Log gói tin từ UI | Debug |
| `STB_ProcedureLog` | Log biến trong SP | Debug |
| `usp_Vietnam_RawMaterialInputHist_uid` | SP kiểm tra NVL (B597) | B597 |
| `usp_Vietnam_DoProcessProdPacking_VVT` | SP gộp Box | B523 |

---

## 🛡️ Nguyên Tắc Vàng Khi Sửa DB

1. **Luôn SELECT trước, IUD sau** — Đếm số dòng bị ảnh hưởng
2. **Dùng BEGIN TRAN ... ROLLBACK/COMMIT** — Xem kết quả trước khi commit
3. **Luôn dùng PK (ID cụ thể)** trong WHERE — Không dùng điều kiện mờ
4. **Sửa đồng bộ đủ bảng** — Thiếu 1 bảng gây lệch dữ liệu
5. **Ghi log tất cả thay đổi** — Để audit sau

*Cập nhật: 2026-05-17*
