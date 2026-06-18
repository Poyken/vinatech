# 🗂️ NAIS MES — Knowledge Base Index

> **Cập nhật:** 2026-06-12 | **Tổng hợp từ:** Lỗi thực tế + Docx gốc (đã extract toàn bộ) + Xác minh DB trực tiếp + Phân tích 41 SP + Deep Core Analysis (2026-04-18) + DB Audit (2026-05-05) + Electrode Weighing (2026-05-26) + Consolidation (2026-06-04) + **System Discovery & Gap Analysis (2026-06-10)**
> **Cách dùng:** 
> 1. Đọc file INDEX này trước để có cái nhìn tổng quan.
> 2. **Tìm kiếm siêu tốc theo màn hình:** Nhấn `Ctrl + Shift + F` nhập `## Mã_Màn_Hình` (Ví dụ: `## C512`, `## B597`) để chuyển trực tiếp đến cẩm nang sửa lỗi theo Screen ID.
> **Groupware KB:** Xem → [GW_INDEX.md](../../GROUPWARE/GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md)

---

## 📋 Danh sách file KB chuyên biệt

| File | Nội dung | Màn hình liên quan |
|------|----------|-------------------|
| [MES_DAILY_PLAYBOOK.md](MES_DAILY_PLAYBOOK.md) | **Cẩm nang giám sát sức khỏe hệ thống hằng ngày (Check block, lag ERP, jobs...)** | Giám sát / DBA / AI |
| [MES_OPERATIONAL_LOG.md](MES_OPERATIONAL_LOG.md) | **Nhật ký tích hợp ghi nhận và xử lý sự cố tại xưởng của User và AI** | Sự cố phát sinh |
| [MES_SCRIPT_GUIDE.md](MES_SCRIPT_GUIDE.md) | **Hướng dẫn sử dụng chi tiết 4 script PowerShell bổ trợ trong dự án** | Script / Tool bổ trợ |
| [KB_01_UI_PHAN_QUYEN.md](KB_01_UI_PHAN_QUYEN.md) | Login, cài đặt, phân quyền User, Stage Prices, và cẩm nang sửa lỗi Screen ID tương ứng | Login, A460, Z410, Z220, Z330, B682, B781 |
| [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) | Kho NVL và Kho Thành phẩm Hà Nam/Bắc Giang, FIFO, Holding, Hạn dùng, lỗi gộp túi bóng HN544, và cẩm nang lỗi Screen ID tương ứng | F330, F312, F430, F110, F721, F741, C220, HN551, HN866, HN544, FG00 |
| [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md) | Sửa JobDate, Chuyển Line, VV→VJ, Xóa PO, NG, Andon, Cell Line vận hành chi tiết B310→B882, Module Line, thiết bị phụ trợ (Lò sấy, Gá Doping, Slitting), Spare Parts H301-H305 & K101/K109, đối soát Lot Size, và cẩm nang lỗi Screen ID tương ứng | B782, B781, B598, B726, B791, B310, B450, B530, B540, B523, B525, B528, B717, B802, B351, B452, H301-H305, K101, K109, B250, B270, B260, B882, V-22, Doping |
| **B353 chuyển đổi lot nhưng B523 vẫn in lot cũ (VJ/VV mismatch)** | KB_04 § 6.18, KB_14 § 7.1 |
| **C531 sửa cấp OQC chọn nhầm (VVT_OQC_REFER)** | KB_04 § 6.19 |
| **B442 không hiển thị độ dày Electrode (MaterialThickness rỗng)** | KB_04 § 6.20 |
| [KB_04_DONG_GOI_IN_TEM.md](KB_04_DONG_GOI_IN_TEM.md) | Tiêu chuẩn đóng gói, fix B523 không gộp, sửa mã Lot, Qty=0, in tem nhãn và cẩm nang lỗi Screen ID tương ứng | B523, B789, B781, B351, A419 |
| [KB_05_QC_ELECTRODE.md](KB_05_QC_ELECTRODE.md) | QC B597/C443/C512/C486, Điện cực Slitting B552, QC Flow đầy đủ IQC→PQC→OQC→Bending/Cutting, Slitting Hà Nam F743-F748, 4M Change, CAPA, Reliability Test, và cẩm nang lỗi Screen ID tương ứng | B597, C443, C512, C486, B552, C121-C564, F743-F748, RTM, 4M Change, CAPA |
| [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md) | Model mới, Vol/Farad, Thêm Cell/Line, SQL Utilities, Bypass, Quick Start Checklist đầy đủ, Line/Route B210-B240, A418, B260, và cẩm nang lỗi Screen ID tương ứng | A410, B210-B240, B250, B260, B270, A418, A419, C131, C132, C430, C451, C560, F741 |
| [KB_07_GROUPWARE_INTEGRATION.md](KB_07_GROUPWARE_INTEGRATION.md) | Tích hợp Groupware: Mua hàng, Kế hoạch SX, Master Data, ESM Bridge Tables (18 bảng), BOM Management, Danh sách 100+ kho active | Groupware, F330, C220, B310, B450, F110, F130, F140 |
| [KB_10_KIEN_TRUC_VA_DATAFLOW.md](KB_10_KIEN_TRUC_VA_DATAFLOW.md) | Kiến trúc tổng quan MES, 3 Trụ cột, Sơ đồ End-to-End, Phân tích SP, Ma trận nhà máy, Dịch nghĩa bình dân luồng MES, và Cẩm nang nhập môn liên thông hệ thống dành cho người mới (GW ↔ CSDL ↔ MES) | System |
| [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md) | Phân tích sâu cốt lõi, 5 triết lý DNA, Bảng ẩn, Điểm nguy hiểm cho Dev, Kết quả DB Audit & Bugs | DB/Audit |
| [KB_14_TRACE_BUG_METHODOLOGY.md](KB_14_TRACE_BUG_METHODOLOGY.md) | Phương pháp trace bug 5 bước, Log hệ thống, Bảng quan trọng | Toàn bộ |
| [KB_15_EA_MES_CASE_STUDY_XUONG_MAY.md](KB_15_EA_MES_CASE_STUDY_XUONG_MAY.md) | Tổng hợp các Case Study thực tế dành cho kỹ sư EA/MES khi xuống xưởng | Vận hành/Hỗ trợ |
| [KB_19_ALL_DATABASES_MAP.md](KB_19_ALL_DATABASES_MAP.md) | Bản đồ chi tiết 13 cơ sở dữ liệu hệ thống, cơ chế liên thông, truy vấn mẫu, và Bảng tra cứu cột quan trọng + Sơ đồ ERD cốt lõi | DB/Integration |
| [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md) | Phân hệ VinaEnesol, đóng gói & in nhãn (Inner/Outer Box), khớp box (Box Matching), Vận hành Hưng Yên, và cẩm nang lỗi Screen ID tương ứng | D000, D051, D100, D110, HungYenFactory |
| [KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md) | Liên kết WMS-Sản xuất-QC-Xuất hàng, Cơ chế trừ kho Trigger, Tác vụ ngầm & Agent Jobs, cấu hình DB Mail, phân hệ SCM, Rework, Trả hàng, Kiểm kê F750, và tự động tách lô chất mang | B597, B530, C443, C512, C530, C546, HN551, FG00, F750, B618 |
| [KB_29_SUPER_DEEP_SYSTEM_DISCOVERY_PROMPT.md](KB_29_SUPER_DEEP_SYSTEM_DISCOVERY_PROMPT.md) | Siêu Prompt (Meta-Prompt) tự học, đào sâu bản chất màn hình & liên kết nghiệp vụ | Hướng dẫn phân tích ngược |

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
| Xóa phiếu nhập kho F330 đã Confirm | KB_02 § 5 |
| Sửa ngày JobDate B782 | KB_03 § 5.2 |
| Sửa ngày PrintTime B781 | KB_03 § 5.3 |
| Chuyển Line sản xuất | KB_03 § 5.9 |
| Xóa PO (B310/B450) | KB_03 § 5.7 |
| Sửa số lượng NG DefectQty | KB_03 § 5.8 |
| Đổi Barcode VV→VJ | KB_03 § 5.10 |
| Xóa nhập sản lượng 1 công đoạn | KB_02 § 4 |
| Lot không in tem được | KB_04 § 6.10 (checklist) |
| B523 không gộp Box | KB_04 § 6.4 |
| Packing Qty âm | KB_04 § 6.6 |
| Gộp túi bóng Qty = 0 (HN544) | KB_04 § 6.5 |
| In tem sai mẫu (5H1 → 6D1) | KB_04 § 6.3 |
| Không có Lot, muốn in tem khẩn | KB_04 § 6.15 |
| Tìm màn hình thiết kế/in tem | KB_04 § 6.16 |
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
| In tem khẩn không có Lot | KB_06 § 6, KB_04 § 6.15 |
| Thêm Cell/Line mới (B250/B270) | KB_06 § 7 |
| Hàng xuất HN551 nhưng HN866 vẫn còn | KB_02 § 1 |
| Lot bị đổi MaterialCode tự động | KB_02 § 2 |
| Màn HNC321 nhập phế lỗi | KB_14 § 4.6, KB_02 § 4 |
| Không PO trên MES từ Groupware | KB_07 § 6 |
| Không nhập được F330 (chưa duyệt) | KB_07 § 2 |
| Trace lỗi không biết bắt đầu từ đâu | KB_14_TRACE_BUG_METHODOLOGY |
| **Không in được tem (nhiều mã)** | KB_14 § 4.5, KB_04 § 6.12 |
| **HNC321 nhập phế báo lỗi tiếng Hàn** | KB_14 § 4.6, KB_02 § 4 |
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
| Deep Core Analysis — DNA hệ thống | KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 1 |
| Bảng ẩn chứa logic quan trọng | KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 4 |
| Điểm nguy hiểm ẩn cho Developer | KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 5 |
| DB Audit Trail 2026-05-05 | KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 2 |
| End-to-End Data Flow | KB_10_KIEN_TRUC_VA_DATAFLOW.md § 2.1 |
| Kiến trúc tổng quan (3 Trụ cột) | KB_10_KIEN_TRUC_VA_DATAFLOW.md § 1.1 |
| Quick Start checklist model mới (đầy đủ 7 bước) | KB_06 § 9.1 |
| Checklist onboard user mới | KB_06 § 9.2 |
| Thiết lập Line/Route B210-B240 | KB_06 § 10 |
| A418 số lượng đóng gói theo Size | KB_06 § 11 |
| B260 nhân viên SX (WorkerGroupCode='VE-01') | KB_06 § 12 |
| Địa chỉ URL truy cập hệ thống | KB_06 § 13 |
| Bảng tổng hợp màn hình MES (Mở rộng) | KB_06 § 14 |
| Gộp box tùy chỉnh HN523 Qty = 0 (thiếu IsOutputRoute) | KB_04 § 6.13 |
| Gộp box lỗi do PO có công đoạn hậu đóng gói B523 (thiếu lịch sử V-28_BG) | KB_04 § 6.13.2 |
| Đổi mã vật tư tự động (STB_ChangeMaterialCode_HN) | KB_02 § 3.1 |
| Đăng ký mã vật tư mới (STB_MaterialMaster) | KB_06 § 1.3 |
| Tra cứu SP in tem cho khách hàng mới (Sanmina) | KB_04 § 6.9.3 |
| Hệ thống chậm/treo do tranh chấp database (block session) | KB_14 § 5.D |
| Hủy/Rollback Slitting F742 (xóa F746 trước) | KB_05 § 10.1 |
| Giải mã quy tắc đặt tên Model Name (3562) | KB_06 § 1.4 |
| Kiến trúc in tem nhãn (Z530/A460) | KB_04 § 6.0 |
| Truy vết ký hiệu in phun (Marking Letter) | KB_03 § 5.19 |
| Quy trình 3 bước hủy công đoạn / NG nhầm | KB_03 § 5.18 |
| Lỗi cắt chuỗi danh sách tem nhỏ (B560 - 73/80 tem) | KB_04 § 6.14 |
| Cấu hình/Đồng bộ mã lỗi B530 Bắc Giang (BG) | KB_03 § 6.18 |
| Bắn nối nhiều cuộn nguyên liệu (Electrode & Case 3562/3582/35105) | KB_03 § 6.19, KB_05 § 8.7 |
| **Máy hỏng / Lịch sử sửa chữa** | KB_03 § 6.21.2 |
| **Hiệu chuẩn thiết bị đo** | KB_03 § 6.21.3 |
| **Spare Part tồn kho / xuất nhập** | KB_03 § 6.21.4 |
| **Giao ca (Takeover) giữa các ca** | KB_03 § 6.22.3 |
| **Ai xử lý viên tụ nào (Worker tracking)** | KB_03 § 6.22.4 |
| **Dashboard sản lượng / UPH** | KB_03 § 6.20.1, 6.20.3 |
| **Andon hiển thị** | KB_03 § 6.20.2 |
| **4M Change (Man/Machine/Material/Method)** | KB_05 § 11.1 |
| **CAPA (hành động khắc phục)** | KB_05 § 11.2 |
| **Phân loại mã lỗi / Defect Code** | KB_05 § 11.4 |
| **ESM sync MES ↔ ERP (Douzone)** | KB_07 § 8 |
| **BOM Management chi tiết** | KB_07 § 9 |
| **Danh sách kho đầy đủ (100+ kho)** | KB_07 § 10 |
| **Kiểm tra độ tin cậy (Reliability Test)** | KB_05 § 12 |
| **Đóng gói & In tem VinaEnesol** | KB_25 |
| **Gộp/Khớp hộp lớn, hộp nhỏ (Box Matching) Enesol** | KB_25 § 4.3 |
| **Quy tắc sinh Lot No Enesol** | KB_25 § 4.1 |
| **Chặn sản lượng do PQC chưa nhập lỗi (lô đạt)** | KB_26 § 3.1 |
| **Không đổi được trạng thái Reject sang Pass ở QC Audit** | KB_26 § 3.2 |
| **Trống hàng QC Audit ở kho Hà Nam/Hưng Yên** | KB_26 § 3.3 |
| **Cơ chế trừ kho tự động (WMS ↔ Sản xuất Triggers)** | KB_26 § 2 |
| **Lỗi phân quyền màn hình Rework (B618)** | KB_26 § 2 |
| **Lỗi quét barcode trả hàng không thành công (Customer Return)** | KB_26 § 3 |
| **Quy trình tự động cân bằng kho (Kiểm kê F750)** | KB_26 § 4 |
| **Quy trình chia lô tự động chất mang/substrate** | KB_26 § 5 |
| **🚦 Tổng hợp 12 nhóm Validation Gates (Cổng chặn)** | KB_14 § 6 |
| **Yêu cầu giả định KH: Chặn NVL B597 (7 gates)** | KB_14 § 6.3 Nhóm 1 |
| **Yêu cầu giả định KH: Chặn chốt B530 (7 gates)** | KB_14 § 6.3 Nhóm 2 |
| **Yêu cầu giả định KH: Chặn đóng gói B523** | KB_14 § 6.3 Nhóm 3 |
| **Yêu cầu giả định KH: Chặn phân quyền B452/B618** | KB_14 § 6.3 Nhóm 4-5 |
| **Yêu cầu giả định KH: Chặn QC Audit/Returns** | KB_14 § 6.3 Nhóm 7-8 |
| **Yêu cầu giả định KH: Chặn Lò Sấy/Dao Slitting** | KB_14 § 6.3 Nhóm 9-10 |
| **Yêu cầu giả định KH: Chặn IQC nhập kho/Electrode** | KB_14 § 6.3 Nhóm 11-12 |
| **4 Pattern thiết kế Validation Gate (A/B/C/D)** | KB_14 § 6.2 |
| **Checklist thêm Gate chặn mới** | KB_14 § 6.4 |
| **Case Study: B353/B523 VJ/VV prefix mismatch (truy vết 6 bước)** | KB_14 § 7.1 |


---

---

> 📌 **Bảng DB & SP quan trọng:** Xem chi tiết tại [KNOWLEDGE.md](../AI_AGENT_CONFIG/KNOWLEDGE.md) §1-2 và [KB_19_ALL_DATABASES_MAP.md](KB_19_ALL_DATABASES_MAP.md).
> 🛡️ **Nguyên tắc sửa DB:** Xem tại [RULES.md](../AI_AGENT_CONFIG/RULES.md).

*Cập nhật: 2026-06-14 | Tái cấu trúc tinh gọn tài liệu: Gộp toàn bộ 9 tệp tin trùng lặp nội dung*