# 🛡️ VINATECH MASTER AGENT WORKSPACE RULE DEFINITIONS (V3.1)

## QUY TẮC BẮT BUỘC KHÔNG THỂ BỎ QUA:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (BẤT BIẾN):**
   - Luôn tra cứu L1 Cache qua `.\pop.ps1 find "<Keyword>"`, `.\mes.ps1 find "<Keyword>"`, `.\gw.ps1 find "<Keyword>"`, hoặc `.\db.ps1 find "<Keyword>"` trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION:**
   - Cấm thực thi DML/DDL trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và triển khai qua `deploy_tool.ps1` hoặc `.\mes.ps1 deploy <file.sql>`.

3. **RULE 4 - SURGICAL RETRIEVAL & L1 CACHE FIRST:**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Tuyệt đối không đọc tràn lan cả file Markdown >50KB gây nghẽn Context.

4. **RULE 6 - GOLDEN QUERY 360° FIRST:**
   - Truy vết POP Kiosk & NVL BOM: `.\pop.ps1 trace "<Keyword>"` hoặc `.\pop.ps1 nvl "<Lot/PO>"`
   - Truy vết sản xuất MES: `.\mes.ps1 trace "<LotID>"`
   - Truy vết Groupware: `.\gw.ps1 trace "<PO/DocCode>"`
   - Truy vết Lineage: `.\mes.ps1 lineage "<Lot/PO>"` hoặc `.\db.ps1 lineage -Type <T> -Value <V>`

5. **RULE 10 - STANDARD TOOLING & ZERO JUNK FILES (BẢO VỆ WORKSPACE):**
   - Tuyệt đối CẤM tạo các file script `.ps1` rời rạc trực tiếp tại thư mục gốc.
   - BẮT BUỘC sử dụng đúng 5 CLI Hub: `.\pop.ps1`, `.\mes.ps1`, `.\gw.ps1`, `.\db.ps1`, `.\ksys.ps1`.
   - Nếu bắt buộc tạo scratch script: BẮT BUỘC đặt trong `tools/scratch/` hoặc subfolder `scratch/`.

6. **RULE 11 - CẤM ĐỘNG VÀO STB_SetInfo KHI ROLLBACK SẢN XUẤT:**
   - Khi rollback sản xuất (B530/B782): CHỈ thao tác trên `STB_DefectRepairInfo` và `STB_ProdRouteHist`.
   - TUYỆT ĐỐI CẤM UPDATE hoặc DELETE trên `STB_SetInfo`.

7. **RULE 12 - BẢO MẬT CREDENTIAL & TÁCH BIỆT TOKEN (ZERO KEY LEAKAGE):**
   - File cấu hình chỉ chứa placeholder mẫu. Mọi token/key thật lưu vào file `.local.json` được `.gitignore` bảo vệ.

8. **RULE 13 - ĐỒNG BỘ HAI CHIỀU POP KIOSK & NAIS MES (DUAL-SYNC INTEGRITY):**
   - Kiosk POP Web đọc tiến độ từ bảng trung gian `MongoToMesPerformance`.
   - Khi kiểm tra hoặc hủy chốt: BẮT BUỘC kiểm tra cả `MongoToMesPerformance` và `STB_ProdRouteHist`.

9. **RULE 14 - 1-SHOT SURGICAL TOOLING & TỐC ĐỘ PHẢN HỒI (<5-10s):**
   - Tối đa 1-2 tool calls trúng đích/câu hỏi. Lấy xong data là DỪNG NGAY và phản hồi trực tiếp cho người dùng.

10. **RULE 15 - CẤM TỰ Ý TẠO HOTFIX / PLAN KHI CHƯA ĐƯỢC YÊU CẦU:**
    - Khi User hỏi "check", "tại sao", "xem giúp": CHỈ phân tích nguyên nhân và báo cáo hiện trạng.

11. **RULE 20 - 5 NGUYÊN TẮC BẤT BIẾN VẬN HÀNH POP (MASTER PLAYBOOK EA TEAM):**
    - Sửa mã máy kép: UPDATE đồng thời cả `STB_ProdRouteHist` VÀ `MongoToMesPerformance`.
    - Xung đột WinForm vs POP: WinForm sinh sẵn dòng kế tiếp (`CompleteRoute = 1`), xóa dòng thừa trong `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist`.
    - Khóa độ dày Cắt điện cực: Nút Cắt mờ do `MaterialThickness < 100` trong `STB_MaterialMaster`.
    - Nạp cuộn BTP: Tối đa 3 LOTNO cho 1 mã cắt (Đã nâng cấp từ định mức cũ 2 LOTNO).
    - Giải phóng máy POP kẹt ACTIVE: Qua `.\pop.ps1 unlock <Machine> -Deploy` hoặc `.\pop.ps1 release-machines -Force` (`VINA_EQUIPMENT_MAPPING.MAPPING_STATUS = 'RELEASED'`).

12. **RULE 21 - BẮT BUỘC LUÔN DÙNG TOOL CHUYÊN DỤNG (CLI HUBS & L1 CACHE) — TUYỆT ĐỐI CẤM QUERY DÒ DẪM (ZERO BLIND SQL EXPLORATION):**
    - **ƯU TIÊN TUYỆT ĐỐI CÁC TOOL CLI ĐÃ ĐÓNG GÓI:**
      * POP Kiosk / NVL BOM / Tồn kho: `.\pop.ps1 trace "<Target>"`, `.\pop.ps1 nvl "<Lot/PO>"`, `.\pop.ps1 unlock "<Machine>"`, `.\pop.ps1 sync`
      * MES Core Sản xuất / Lot Lifecycle / Màn hình / Lỗi: `.\mes.ps1 trace "<LotID>"`, `.\mes.ps1 diagnose "<Text>"`, `.\mes.ps1 screen "<ScreenID>"`, `.\mes.ps1 sp "<SP_Name>"`, `.\mes.ps1 lineage "<Lot/PO>"`
      * Groupware / Tờ trình / Phê duyệt: `.\gw.ps1 trace "<PO/DocCode>"`, `.\gw.ps1 form "<Form>"`, `.\gw.ps1 find "<Keyword>"`
      * Hợp nhất ERP K-System Ace: `.\ksys.ps1 find "<Keyword>"`, `.\ksys.ps1 trace "<Lot/PO>"`, `.\ksys.ps1 module "<ModuleID>"`
      * Quản trị 15 DB Multi-Engine: `.\db.ps1 find "<Keyword>"`, `.\db.ps1 lineage`, `.\db.ps1 sp`, `.\db.ps1 locks`
    - **CẤM TUYỆT ĐỐI LẠM DỤNG `.\db.ps1 query` ĐỂ THỬ SAI (0 BLIND SQL LOOPING):**
      * CẤM chạy chuỗi `SELECT` thăm dò (SELECT *, SELECT TOP...) để đoán cấu trúc bảng, tên menu ERP hay tìm kiếm logic nghiệp vụ.
      * Muốn biết thông tin bảng, menu, quy trình: BẮT BUỘC tra cứu L1 Cache (`POP_MATRIX.json`, `QUICK_MATRIX.json`, `KSYSTEM_MATRIX.json`, `DATABASE_MATRIX.json`, `GW_FORM_MATRIX.json`) hoặc đọc SP gốc (`.\mes.ps1 sp`).
      * Lệnh `.\db.ps1 query` CHỈ ĐƯỢC PHÉP dùng khi CLI Hub chưa hỗ trợ VÀ đã biết đích xác 100% bảng + 3-5 cột từ tài liệu/KB/SP, có `WITH (NOLOCK)`. CẤM chạy quá 1-2 query.
    - **KỶ LUẬT HARD CEILING 1-2 TOOL CALLS:** Lấy xong dữ liệu từ CLI Hub là DỪNG NGAY và trả lời. Cấm gọi thêm tool để verify lan man.

13. **RULE 22 - QUY TẮC ĐỊNH DANH SỰ CỐ & PHÂN LOẠI ISSUE (POP BẮT BUỘC GHI LÀ POP, KHÔNG GHI MES):**
    - Mọi issue, sự cố phát sinh, task hỗ trợ, ticket, báo cáo tuần IT, báo cáo khắc phục sự cố... liên quan đến POP (Kiosk xưởng, Web POP, nạp NVL Kiosk, kẹt máy Kiosk, sync MongoToMesPerformance) **BẮT BUỘC ghi phân loại/remark/hệ thống là `POP`**, **TUYỆT ĐỐI KHÔNG ghi là `MES` nữa**.
    - **Tách bạch rõ ràng:** `POP` (Toàn bộ Kiosk xưởng & Web POP) vs `MES` (Chỉ dành riêng cho Core MES Sản Xuất WinForm & CSDL lõi).

14. **RULE 23 - TIER-0 ENTERPRISE MASTER ORCHESTRATION (ops.ps1 FIRST):**
    - Khi nhận một mã bất kỳ chưa rõ nguồn gốc hoặc khi bắt đầu ca làm việc (Morning Patrol): **BẮT BUỘC sử dụng `ops.ps1` làm điểm tiếp nhận đầu tiên (`ops health` hoặc `ops trace <Mã>`)**.
    - Để Universal Smart Auto-Router tự động nhận diện 10 loại thực thể và điều phối sang sub-hub chuyên dụng. Tuyệt đối không phán đoán thủ công rồi gọi nhầm sub-hub.
    - Mọi sub-workspace (`MES_POP`, `GROUPWARE`, `DATABASE`, `FINAL`) bắt buộc phải duy trì tệp shim `ops.ps1` để người dùng có thể gõ lệnh từ bất kỳ đâu.

15. **RULE 24 - ZERO IRREVERSIBLE HOTFIX (SNAPSHOT & 1-CLICK ROLLBACK BẮT BUỘC):**
    - Mọi can thiệp DML (`UPDATE`, `DELETE`) trên Production CSDL **BẮT BUỘC phải thực thi qua cơ chế Pre-flight Snapshot (`Create-SafePreflightSnapshot` hoặc `deploy_tool.ps1`)**.
    - Script triển khai phải tự động lưu bản chụp JSON các dòng bị ảnh hưởng tại `backups/snapshots/` và tự sinh tệp hoàn tác `backups/undo/undo_<Target>_<Timestamp>.sql`.
    - Khi có yêu cầu hoàn tác từ hiện trường, BẮT BUỘC thực thi qua lệnh chuẩn: `ops rollback -Target <LotID> -Deploy`. Tuyệt đối CẤM viết tay câu UPDATE ngược lại trong lúc hoảng loạn.

16. **RULE 25 - WORKSPACE MODULARITY & ZERO ROOT POLLUTION (BẢO VỆ ĐỘ SẠCH GỐC):**
    - Thư mục gốc `PROCESS/` là **Khu Vực Bất Khả Xâm Phạm**: Chỉ được phép chứa 5 thư mục trụ cột chính (`MES_POP`, `GROUPWARE`, `DATABASE`, `FINAL`, `.agents`), các thư mục module phụ đã được đóng gói (`ATTENDANCE_CMS`, `tools/shared`), và các tệp chuyển tiếp (`ops.ps1`, `mes.ps1`, `gw.ps1`, `db.ps1`, `ksys.ps1`, `README.md`, `GEMINI.md`).
    - Tuyệt đối CẤM lưu các tệp script thử nghiệm, tệp dump SQL, tệp export dữ liệu hoặc tệp log tạm thời trực tiếp tại root `PROCESS/`. Mọi tệp tạm phải nằm trong `scratch/` hoặc `logs/` và phải được dọn dẹp bằng `ops clean`.

17. **RULE 26 - ACTIVE KNOWLEDGE RETENTION & ANTI-DRIFT (TRIỆT TIÊU TRI THỨC MỒ CÔI):**
    - Khi phát hiện một triệu chứng lỗi mới hoặc một giải pháp sửa lỗi mới được kiểm chứng thành công: **BẮT BUỘC phải ghi nhận ngay vào L1 Cache JSON (`historical_precedents` trong `POP_MATRIX.json` hoặc `QUICK_MATRIX.json`) và ghi log vào `hotfix_audit.jsonl`**.
    - Định kỳ hàng tuần hoặc sau mỗi đợt bảo trì CSDL, BẮT BUỘC chạy `ops audit-kb` để rà soát tự động 100% Stored Procedures và Tables giữa L1 Cache và Live DB, phát hiện ngay các bảng/SP bị lệch tên hoặc mất định nghĩa (Anti-Drift).

18. **RULE 27 - MULTI-ROOT WORKSPACE SYNCHRONIZATION (ĐỒNG NHẤT MÔI TRƯỜNG LÀM VIỆC):**
    - Luôn ưu tiên mở IDE thông qua tệp `vinatech-enterprise.code-workspace` để nạp đầy đủ cả 5 phân hệ cùng lúc.
    - Mọi công cụ, script PowerShell và Node.js viết mới BẮT BUỘC phải tích hợp cơ chế Universal Root Detection (tự động dò tìm đường dẫn gốc `PROCESS`), đảm bảo script chạy đúng dù người dùng đang đứng ở bất kỳ ổ đĩa hay thư mục con nào.


