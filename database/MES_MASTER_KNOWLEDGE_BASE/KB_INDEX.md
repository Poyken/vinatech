# 🗂️ NAIS MES — Knowledge Base Index

> **Cập nhật:** 2026-06-04 | **Tổng hợp từ:** Lỗi thực tế + Docx gốc (đã extract toàn bộ) + Xác minh DB trực tiếp + Phân tích 41 SP + Deep Core Analysis (2026-04-18) + DB Audit (2026-05-05) + Electrode Weighing (2026-05-26) + Consolidation (2026-06-04)
> **Cách dùng:** Đọc file INDEX này trước, sau đó mở file KB chuyên biệt theo nhóm lỗi.
> **Groupware KB:** Xem → [`../GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md`](../GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md)

---

## 📋 Danh sách file KB chuyên biệt

| File | Nội dung | Màn hình liên quan |
|------|----------|-------------------|
| [KB_01_UI_PHAN_QUYEN.md](KB_01_UI_PHAN_QUYEN.md) | Login, cài đặt, phân quyền User, Stage Prices | Login, A460, Z410, Z220, Z330, B682, B781 |
| [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) | Kho NVL: F330 sai kho, F312, F430, FIFO, Holding, Hạn dùng | F330, F312, F430, F110, F721, F741, C220 |
| [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md) | Sửa JobDate, Chuyển Line, VV→VJ, Xóa PO, NG, Andon, **Cell Line vận hành chi tiết B310→B882**, Module Line, B351/B528/B598/B717/B802, In tem PAC/Digi-Key, Spare Part H301-H305, K101/K109 | B782, B781, B598, B726, B791, B310, B450, B530, B540, B523, B525, B528, B717, B802, B351, B452, B754-B758, H301-H305, K101, K109 |
| [KB_04_DONG_GOI_IN_TEM.md](KB_04_DONG_GOI_IN_TEM.md) | Tiêu chuẩn đóng gói, fix B523 không gộp, sửa mã Lot, Qty=0 | B523, B789, B781, B351, A419 |
| [KB_05_QC_ELECTRODE.md](KB_05_QC_ELECTRODE.md) | QC B597/C443/C512/C486, Điện cực Slitting B552, Lỗi chuỗi độ dày, Rebuild bảng & Fix layout, **QC Flow đầy đủ IQC→PQC→OQC→Bending/Cutting**, Slitting Hà Nam F743-F748 | B597, C443, C512, C486, B552, C121-C564, F743-F748 |
| [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md) | Model mới, Vol/Farad, Thêm Cell/Line, SQL Utilities, Bypass, **Quick Start Checklist đầy đủ**, B210-B240 Line/Route, A418, B260, Địa chỉ hệ thống, Bảng tổng hợp màn hình MES (Mở rộng) | A410, B210-B240, B250, B260, B270, A418, A419, C131, C132, C430, C451, C560, F741 |
| [KB_07_GROUPWARE_INTEGRATION.md](KB_07_GROUPWARE_INTEGRATION.md) | Tích hợp Groupware: Mua hàng, Kế hoạch SX, Master Data | Groupware, F330, C220, B310, B450 |
| [KB_08_KHO_THANH_PHAM_HN.md](KB_08_KHO_THANH_PHAM_HN.md) | Kho TP Hà Nam: Xuất HN551, Tồn HN866, Hủy F330, Xóa sản lượng | HN551, HN866, HN544, FG00 |
| [KB_09_IN_TEM_LABEL.md](KB_09_IN_TEM_LABEL.md) | Các loại tem đặc biệt, lỗi sai mẫu, in tem khẩn | B450, B756, B767, B790, A460 |
| [KB_10_KIEN_TRUC_TONG_QUAN.md](KB_10_KIEN_TRUC_TONG_QUAN.md) | Kiến trúc tổng quan hệ thống NAIS, 3 Trụ cột, Vòng đời dữ liệu, Dictionary Bảng, Ma trận nhà máy | System |
| [KB_11_SP_DATAFLOW.md](KB_11_SP_DATAFLOW.md) | End-to-End Data Flow, Sơ đồ SP từng Phase (0-6), Dictionary SP, Key Identifiers | DB/SP |
| [KB_12_DEEP_CORE_ANALYSIS.md](KB_12_DEEP_CORE_ANALYSIS.md) | Phân tích sâu cốt lõi, 5 triết lý DNA, Bảng ẩn Custom Vietnam, Điểm nguy hiểm cho Dev | DB/SP |
| [KB_13_DB_AUDIT.md](KB_13_DB_AUDIT.md) | DB Audit Trail, 3 bugs thực tế, 7 sai lệch logic, Production Metrics | DB/Audit |
| [KB_14_TRACE_BUG_METHODOLOGY.md](KB_14_TRACE_BUG_METHODOLOGY.md) | Phương pháp trace bug 5 bước, Log hệ thống, Bảng quan trọng | Toàn bộ |
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
| Cột Note1 thừa trên Grid (C486) | KB_05 § 7.8 |
| Thêm cột mới giữ đúng thứ tự (Rebuild) | KB_05 § 7.8 |
| Lỗi "Chưa CONFIG Slitting" | KB_05 § 8.2 |
| Lỗi chiều rộng Slitting B552 | KB_05 § 8.1 |
| C546 FOQC OCV/ESR chỉ hiển thị 20ea thay vì 50ea | KB_05 § 9.6 |
| Model mới không hiện Vol/Farad | KB_06 § 1.2 |
| In tem khẩn không có Lot | KB_06 § 6, KB_09 § 4 |
| Thêm Cell/Line mới (B250/B270) | KB_06 § 7 |
| Hàng xuất HN551 nhưng HN866 vẫn còn | KB_08 § 1 |
| Lot bị đổi MaterialCode tự động | KB_08 § 2 |
| Màn HNC321 nhập phế lỗi | KB_08 § 3 |
| Không PO trên MES từ Groupware | KB_07 § 6 |
| Không nhập được F330 (chưa duyệt) | KB_07 § 2 |
| Trace lỗi không biết bắt đầu từ đâu | KB_14_TRACE_BUG_METHODOLOGY |
| **Không in được tem (nhiều mã)** | KB_14 § 4.5, KB_04 § 6.12 |
| **HNC321 nhập phế báo lỗi tiếng Hàn** | KB_14 § 4.6, KB_08 § 4 |
| **Nhảy bước cân điện cực Mixing (electrode.weighing)** | KB_14 § 4.7 |
| **Mã HCE lỗi không thao tác được** | KB_14 § 4.7 |
| **Sản xuất ra không ghi nhận trên hệ thống** | KB_14 § 4.7 |
| **Mã 3582-600F CY không tạo được tem** | KB_14 § 4.8 |
| **Hủy kết quả QC / Hủy công đoạn** | KB_14 § 4.2 |
| **Gộp box 2 lần bị nhầm / Rã box** | KB_14 § 4.3 |
| **Gộp box sai số lượng** | KB_14 § 4.3, KB_04 § 6.5 |
| **Không chốt được công đoạn B530** | KB_14 § 4.4 |
| **Cell Line vận hành chi tiết (B310→B882)** | KB_03 § 6 |
| B530 báo "Routing không có trong PO" | KB_03 § 6.3 |
| B530 báo "Đã hoàn thành thực tế rồi" | KB_03 § 6.3 |
| B530 Gate 20 phút không hoạt động (bug) | KB_05 § 11.3 |
| B540 Module hiển thị thông số Cell | KB_03 § 6.4 |
| B523 quy trình mới (in tem Box To trước chia box) | KB_03 § 6.5 |
| B717 nhập sai số lượng Bending/Tapping | KB_03 § 6.6 |
| B452 không đổi được Line | KB_03 § 6.7 |
| Module Line flow (MV-xx routes) | KB_03 § 6.8 |
| B351 chuyển đổi Lot/Material | KB_03 § 6.9 |
| B528 Barrel Barcode | KB_03 § 6.10 |
| B802 lịch sử SX điện cực | KB_03 § 6.11 |
| B598 báo phế NVL (sửa JobDate đặc biệt) | KB_03 § 6.12 |
| In tem PAC (B754-B756) / Digi-Key (B757-B758) | KB_03 § 6.16 |
| Spare Part H301-H305 | KB_03 § 6.15 |
| K101/K109 nhà máy BG2 | KB_03 § 6.14 |
| QC Flow đầy đủ IQC→PQC→OQC | KB_05 § 9 |
| C321 sửa chữa lỗi Cell Line | KB_05 § 9.5 |
| Slitting Hà Nam F743-F748 | KB_05 § 10 |
| Deep Core Analysis — DNA hệ thống | KB_12 § 1 |
| Bảng ẩn chứa logic quan trọng | KB_12 § 3 |
| Điểm nguy hiểm ẩn cho Developer | KB_12 § 4 |
| DB Audit Trail 2026-05-05 | KB_13 |
| End-to-End Data Flow | KB_11 § 1 |
| Kiến trúc tổng quan (3 Trụ cột) | KB_10 § 1 |
| Quick Start checklist model mới (đầy đủ 7 bước) | KB_06 § 9.1 |
| Checklist onboard user mới | KB_06 § 9.2 |
| Thiết lập Line/Route B210-B240 | KB_06 § 10 |
| A418 số lượng đóng gói theo Size | KB_06 § 11 |
| B260 nhân viên SX (WorkerGroupCode='VE-01') | KB_06 § 12 |
| Địa chỉ URL truy cập hệ thống | KB_06 § 13 |
| Bảng tổng hợp màn hình MES (Mở rộng) | KB_06 § 14 |
| Gộp box tùy chỉnh HN523 Qty = 0 (thiếu IsOutputRoute) | KB_04 § 6.13 |
| Đổi mã vật tư tự động (STB_ChangeMaterialCode_HN) | KB_08 § 3.1 |
| Đăng ký mã vật tư mới (STB_MaterialMaster) | KB_06 § 1.3 |
| Tra cứu SP in tem cho khách hàng mới (Sanmina) | KB_09 § 12 |
| Hệ thống chậm/treo do tranh chấp database (block session) | KB_14 § 5.D |
| Hủy/Rollback Slitting F742 (xóa F746 trước) | KB_05 § 10.1 |
| Giải mã quy tắc đặt tên Model Name (3562) | KB_06 § 1.4 |
| Kiến trúc in tem nhãn (Z530/A460) | KB_09 § 5.1 |
| Truy vết ký hiệu in phun (Marking Letter) | KB_03 § 5.19 |
| Quy trình 3 bước hủy công đoạn / NG nhầm | KB_03 § 5.18 |
| Lỗi cắt chuỗi danh sách tem nhỏ (B560 - 73/80 tem) | KB_04 § 6.14 |
| Cấu hình/Đồng bộ mã lỗi B530 Bắc Giang (BG) | KB_03 § 6.18 |
| Bắn nối nhiều cuộn nguyên liệu (Electrode & Case 3562/3582/35105) | KB_03 § 6.19, KB_05 § 8.7 |

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
| `STB_AluCaseMapping_VVT` | ⚠️ KHÔNG TỒN TẠI — Logic vỏ nhôm nằm trong SP | B597 |

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

*Cập nhật: 2026-05-30 | Đã kiểm chứng bằng SELECT trực tiếp từ SmartFactoryV2 | Bổ sung: Cell Line chi tiết, Module Line, QC Flow đầy đủ, Deep Core Analysis, DB Audit Trail, Mở rộng Bảng tổng hợp màn hình MES*


Add giá B682, B781, B789, B791 ➔ Đã match vào KB_06 (§3)
Xóa/sửa số lượng B789 / B523 ➔ Đã match vào KB_04 (§6.6)
Lỗi popup trống B270 (setup B230) ➔ Đã match vào KB_01 (§1.3)
Sửa hạng mục kiểm tra B597 & C443 (STB_CommInspDocHistory) ➔ Đã match vào KB_05 (§1.1)
Không tìm thấy lot ở C512 (A410, VE02) ➔ Đã match vào KB_05 (§7.2)
Lỗi không in được tem B450 (Màn A460) ➔ Đã match vào KB_01 (§1.2)
Chuyển JobDate màn B782 (Routing) ➔ Đã match vào KB_03 (§5.2)
Chuyển JobDate màn B781 (Packing) ➔ Đã match vào KB_03 (§5.3)
Chuyển tháng kho thành phẩm FG00 ➔ Đã match vào KB_08 (§8)
Sửa số lượng kho F312 (Kho chị Xuân) ➔ Đã match vào KB_02 (§4.5)
Chuyển jobdate màn B598 (Báo phế) ➔ Đã match vào KB_03 (§5.4)
Chuyển lại kho nhập sai ở màn F330 ➔ Đã match vào KB_02 (§4.3)
Chuyển JobDate B726 (STB_VN_SCRAP_AFTERPRODUCTIONS) ➔ Đã match vào KB_03 (§5.5)
Xóa PO ở 2 màn B450 và B310 ➔ Đã match vào KB_03 (§5.7)
Sửa số lượng NG DefectQty màn B791 ➔ Đã match vào KB_03 (§5.8)
Bỏ in VV thành VJ theo mã NVL ➔ Đã match vào KB_04 (§6.7)
Tiêu chuẩn đóng gói B523 (Sửa A419) ➔ Đã match vào KB_06 (§11)
Không lưu được NVL trên B597 (Vỏ nhôm) ➔ Đã match vào KB_05 (§7.4)
Chỉnh số dòng hiển thị Andon ➔ Đã match vào KB_03 (§7)
Chỉnh chiều rộng slitting B552 ➔ Đã match vào KB_05 (§8.1 & 8.2)
Không lưu được Lot F330 đặc tính 10 ➔ Đã match vào KB_02 (§4.11)
Sửa ngày xuất F430 ➔ Đã match vào KB_02 (§4.6)
Chỉnh sửa từ kho holding ra ngoài ➔ Đã match vào KB_02 (§4.8)
Chỉnh Location (LotAttr09) ➔ Đã match vào KB_02 (§4.15)
FIFO Kho NVL ➔ Đã match vào KB_11 & KB_02 (§2.1)
Chỉnh Code NVL nhập sai màn F312 ➔ Đã match vào KB_02 (§4.4)
Chỉnh LotNo, Vol, Farad (Thêm ModelBasicInfo) ➔ Đã match vào KB_06 (§1.1 & 1.2)
NVL mới không gộp box được (Tích F110) ➔ Đã match vào KB_06 (§2.1)
FIFO Kho thành phẩm xuất Excel ➔ Đã match vào KB_01 (§5.3)
Sửa tên Lot sau B351 ➔ Đã match vào KB_04 (§6.2)
Lấy Part No từ hàm xử lý chuỗi ➔ Đã match vào KB_06 (§5.2)
Tra ModelName & ModelSize cho B597 ➔ Đã match vào KB_03 (§6.10)
Lỗi chuỗi điện cực (MaterialThickness số nguyên) ➔ Đã match vào KB_05 (§7.6)