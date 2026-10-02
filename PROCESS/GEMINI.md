# 🛡️ VINATECH ENTERPRISE PROCESS WORKSPACE (MASTER RULES)

> **Single Source of Truth:** `.agents/rules/00_vinatech_master_rules.md`
> **Primary Command Hubs:** `.\pop.ps1` (POP Kiosk), `.\mes.ps1` (Core MES), `.\gw.ps1` (Groupware), `.\db.ps1` (15 Databases), `.\ksys.ps1` (K-System)

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
1. **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):** CẤM chạy `SELECT` trước khi tra cứu L1 Cache (`.\pop.ps1 find`, `.\mes.ps1 find`, `.\gw.ps1 find`, `.\db.ps1 find`) hoặc tài liệu KB tương ứng.
2. **RULE 1 (SELECT-ONLY ON PRODUCTION):** Tuyệt đối chỉ đọc dữ liệu trên Production CSDL. Cấm chạy `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE` trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và được triển khai qua `deploy_tool.ps1` hoặc `.\mes.ps1 deploy`.
3. **RULE 6 (GOLDEN QUERY 360° FIRST):** Dùng Golden Query trong lần kiểm tra đầu tiên:
   - Truy vết POP Kiosk & NVL BOM: `.\pop.ps1 trace "<Keyword>"` hoặc `.\pop.ps1 nvl "<Lot/PO>"`
   - Truy vết Sản xuất MES & Vòng đời Lot: `.\mes.ps1 trace "<LotID>"`
   - Truy vết PO / Chứng từ Groupware: `.\gw.ps1 trace "<PO/DocCode>"`
   - Truy vết huyết mạch dữ liệu liên hệ thống: `.\mes.ps1 lineage "<Lot/PO>"` hoặc `.\db.ps1 lineage -Type <T> -Value <V>`
4. **RULE 4 (SURGICAL RETRIEVAL):** Ưu tiên L1 Cache JSON (<0.001s, ~150 tokens) trước khi đọc cả file Markdown lớn.
5. **RULE 14 (TỐC ĐỘ PHẢN HỒI):** Tối đa 1-2 tool calls trúng đích/câu hỏi. Lấy xong thông tin cốt lõi DỪNG NGAY và trả lời (<5-10s).
6. **RULE 15 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix hay plan khi User chỉ yêu cầu kiểm tra/tra cứu.
7. **RULE 20 (CẨM NANG VẬN HÀNH POP 26 CA BỆNH — EA PLAYBOOK [POP_KB_07]):** Mọi sự cố/báo lỗi từ người dùng chuyển tiếp cho AI phải đối chiếu xử lý theo đúng [POP_KB_07_POP_FAULT_HANDLING_PLAYBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_07_POP_FAULT_HANDLING_PLAYBOOK.md) (Hải Triều & Đức Nguyễn). 8 Nguyên tắc vàng: (1) Đổi máy nhầm Kiosk UPDATE đồng thời cả 2 bảng `STB_ProdRouteHist` & `MongoToMesPerformance`. (2) "Already completed": Check `CompleteRoute IS NULL` trước (NULL là POP đã xong chỉ reload), nếu MES sinh sẵn dòng kế tiếp (`CompleteRoute=1`) thì xóa dòng thừa `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist`. (3) Nút Cắt điện cực mờ do `MaterialThickness < 100`. (4) Cuộn BTP tối đa 2-3 LOTNO. (5) Kẹt máy ACTIVE giải phóng qua `.\pop.ps1 unlock <Machine> -Deploy` hoặc `.\pop.ps1 release-machines -Force`. (6) Force Slitting Stock 3 bước (Base Lot ➔ `STB_SerialRule` & `STB_MaterialLotInfo` ➔ Check `ModalVisible='Y'`). (7) Hết tồn NVL/dung dịch/tape: Đối soát tiêu hao BOM vs `STB_RawMaterialInputHist` và cân bằng lại tồn kho. (8) Grade Model 35105 nối qua `STB_MaterialDocLotInfo`.
8. **RULE 21 (BẮT BUỘC LUÔN DÙNG TOOL CHUYÊN DỤNG - TUYỆT ĐỐI CẤM QUERY DÒ DẪM):** BẮT BUỘC dùng Tool CLI Hubs (`.\mes.ps1`, `.\pop.ps1`, `.\gw.ps1`, `.\ksys.ps1`) cho mọi tác vụ tra cứu, phân tích, truy vết. Tuyệt đối CẤM dùng `.\db.ps1 query` để mò mẫm cấu trúc bảng, tên menu hay thử sai liên tục (0 blind SQL looping). Muốn biết bảng/menu/trường ➔ Tra cứu L1 Cache (`POP_MATRIX.json`, `QUICK_MATRIX.json`, `KSYSTEM_MATRIX.json`, `GW_FORM_MATRIX.json`) hoặc `find`. Giới hạn cứng tối đa 1-2 tool calls.
9. **RULE 22 (ĐỊNH DANH SỰ CỐ & PHÂN LOẠI ISSUE — POP BẮT BUỘC GHI POP, KHÔNG GHI MES):** Mọi sự cố/issue/task/báo cáo tuần IT/báo cáo khắc phục sự cố liên quan đến POP (Kiosk xưởng, Web POP, nạp NVL Kiosk, kẹt máy Kiosk, sync MongoToMesPerformance) BẮT BUỘC ghi phân loại/remark/hệ thống là **POP**, TUYỆT ĐỐI KHÔNG ghi là **MES** nữa. MES chỉ dành riêng cho Core MES Sản Xuất WinForm & CSDL lõi.
10. **RULE 23 (TIER-0 ENTERPRISE MASTER ORCHESTRATION — ops.ps1 FIRST):** Khi nhận mã bất kỳ chưa rõ nguồn gốc hoặc bắt đầu ca sáng: BẮT BUỘC gọi `.\ops.ps1 health` hoặc `.\ops.ps1 trace <ID>` đầu tiên để Universal Auto-Router tự động phân luồng.
11. **RULE 24 (ZERO IRREVERSIBLE HOTFIX — SNAPSHOT & UNDO BẮT BUỘC):** Mọi lệnh UPDATE/DELETE Production bắt buộc chạy qua cơ chế Pre-flight Snapshot tự động sinh `undo_<Target>.sql`. Khi OP báo nhầm, hoàn tác bằng `.\ops.ps1 rollback -Target <ID> -Deploy`.
12. **RULE 25 (WORKSPACE MODULARITY & ZERO ROOT POLLUTION):** Cấm lưu file SQL, dump, scratch lẻ tại root `PROCESS/`. Mọi module phụ phải nằm trong folder riêng (`ATTENDANCE_CMS/`, `tools/shared/`).
13. **RULE 26 (ACTIVE KNOWLEDGE RETENTION & ANTI-DRIFT):** Nghiệm thu xong bug mới bắt buộc cập nhật vào L1 Cache JSON & `hotfix_audit.jsonl`. Định kỳ chạy `.\ops.ps1 audit-kb` đối soát live schema.
14. **RULE 27 (MULTI-ROOT WORKSPACE SYNCHRONIZATION):** Luôn mở IDE qua `vinatech-enterprise.code-workspace` và bảo đảm script có Universal Root Detection.



## ⚡ HỆ THỐNG CLI HUBS TẠI WORKSPACE ROOT
- `.\ops.ps1 [health|trace|clean|rollback|audit-kb|weekly-report]` ➔ 🌟 **ENTERPRISE MASTER OPERATIONS HUB (TỔNG HÀNH DINH ĐIỀU HÀNH v4.0)**:
  * Morning 360 Patrol quét song song 15 DB, POP Kiosk, Core MES, Groupware, K-System (<3s)
  * Universal Smart Auto-Router tự nhận diện 10 loại mã (Lot, PO, Machine, Screen, SP, Table, K-System)
  * Deep Workspace Purge & Zombie process killer dọn dẹp rác máy trạm
  * 1-Click Undo / Rollback an toàn tuyệt đối với snapshot khôi phục tự động
  * Tổng hợp Báo Cáo Tuần IT chuẩn Rule 22 (tách bạch rõ ràng POP vs MES)
- `.\mes.ps1` ➔ 🏭 **MES & POP MASTER HUB**: Tích hợp đầy đủ phân hệ sản xuất hiện trường:
  * Smart Auto-Router tự nhận diện Lot/PO/Screen/Machine/Lỗi (<0.01s)
  * Trace 360° siêu tốc tích hợp tiến độ đóng gói POP (`VINA_PACKING_REMAIN_QTY`), BOM NVL, Tồn kho xưởng, Thiết bị, PQC (<2s)
  * Kiểm toán Pre-flight file Excel `.\mes.ps1 validate-excel <File.xlsx> -Route <F330|B598>` chống lệch cột (E04/E05 vào StartPeriod) (<1s)
  * Tra cứu nhanh đơn giá & tỷ lệ cân hardcode B598 `.\mes.ps1 b598-price [-Target <Code>]` (<1s)
  * Soi real-time khóa blocking & deadlock trên 15 CSDL `.\mes.ps1 locks [-Profile <Name>]` (<2s)
  * Dọn dẹp & tiêu diệt zombie process ngầm chống quá tải CPU / rú quạt `.\mes.ps1 clean`
  * Chẩn đoán 4 Dòng Vàng, BOM NVL & Tồn kho, Groupware & ERP, Toàn bộ Hotfixes bọc Transaction.
- `.\pop.ps1 [trace|nvl|unlock|release-machines|sync|readiness|audit|find]` ➔ **Kiosk POP tại xưởng (NVL BOM, Tồn kho ROUTE_VN_WH, Mở khóa máy, Sync)**
- `.\gw.ps1 [trace|form|find|routine|chain|health|check|query|audit]` ➔ **Groupware Bizbox & Duyệt Chứng Từ ERP NEOE**
- `.\db.ps1 [list|health|stats|sp|schema|query|find|jobs|triggers|index|crossdb|lineage|auditkb]` ➔ **Quản Trị 15 CSDL Multi-DB Engine**
- `.\ksys.ps1 [trace|find|module|schema|bridge|health]` ➔ **Hợp Nhất ERP K-System Ace**

## 🧭 CÁC LỆNH SLASH COMMANDS CHUYÊN BIỆT (/plan, /learn, /grill-me, /goal)
- `/plan`: Lập kế hoạch thực thi chi tiết, yêu cầu người dùng duyệt `Proceed` trước khi triển khai các thay đổi lớn.
- `/learn`: Dạy bài học mới cho AI khi xử lý xong một sự cố thực địa, tự động lưu vĩnh viễn vào `.agents/rules/02_learned_patterns.md`.
- `/grill-me`: Phỏng vấn làm sáng tỏ các quyết định kỹ thuật/nghiệp vụ trước khi bắt tay vào code.
- `/goal`: Tác chiến bền bỉ cho các nhiệm vụ dài hạn không dừng giữa chừng.
- Chi tiết tham khảo toàn diện tại: [Sổ Tay Vận Hành AI Copilot](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/OPERATOR_COPILOT_GUIDE.md).

