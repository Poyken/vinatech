# 🛡️ VINATECH MES AGENT WORKSPACE RULE DEFINITIONS (V2.2)

## QUY TẮC BẮT BUỘC KHÔNG THỂ BỎ QUA:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (BẤT BIẾN):**
   - Luôn tra cứu L1 qua `.\pop.ps1 find "<Keyword>"` (POP Kiosk) hoặc `.\mes.ps1 find "<Keyword>"` (MES Core) trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION:**
   - Cấm thực thi DML/DDL trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và triển khai qua `.\mes.ps1 deploy <file.sql>`.

3. **RULE 4 - SURGICAL RETRIEVAL & L1 CACHE FIRST:**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Tuyệt đối không đọc tràn lan cả file Markdown >50KB gây nghẽn Context.

4. **RULE 6 - GOLDEN QUERY 360° FIRST:**
   - Khi điều tra sự cố POP Kiosk & NVL BOM: Dùng `.\pop.ps1 trace "<Target>"` hoặc `.\pop.ps1 nvl "<Lot/PO>"`.
   - Khi điều tra sự cố sản xuất MES: Dùng `.\mes.ps1 trace "<LotID>"` (quét sạch 4 bảng trong 1 lần duy nhất).

5. **RULE 7 - GIAO THỨC XỬ LÝ KHI USER CUNG CẤP THIẾU THÔNG TIN (UNDERSPECIFIED INPUT):**
   - **Trường hợp User chỉ gõ "check" / "kiểm tra hệ thống":** Tự động kích hoạt `.\mes.ps1 health -Detail` (quét Lot HOLD, WIP 24h, DB Lock) và đưa ra 4 tùy chọn tra cứu nhanh (Trace Lot / Debug Screen / Audit Schema / Inventory). CẤM chạy SELECT mò mẫm tự do.
   - **Trường hợp User chỉ gửi mã Lot nhưng không nêu hiện tượng lỗi:** Chạy ngay `.\mes.ps1 trace "<LotID>"`, xuất bảng tóm tắt 4 trạng thái cốt lõi và hỏi rõ hành động mong muốn (Mở HOLD, Hủy sản lượng, Đổi Model, hay In tem).
   - **Trường hợp User hỏi về phân hệ mở rộng (POP, Sorting, Kế hoạch):** Tự động điều hướng đúng Database Profile (`POP`, `Groupware`, `AndonDB`, `ERP`) qua tham số `-Profile`.

6. **RULE 10 - STANDARD TOOLING & ZERO JUNK FILES (BẢO VỆ WORKSPACE):**
   - Tuyệt đối CẤM tạo các file script `.ps1` rời rạc (`check_*.ps1`, `find_*.ps1`, `inspect_*.ps1`...) trực tiếp tại thư mục gốc hoặc trong `tools/`.
   - BẮT BUỘC sử dụng đúng CLI Hub: `.\pop.ps1` (Kiosk POP tại xưởng) và `.\mes.ps1` (Lõi MES sản xuất & Hotfix).
   - Nếu trong trường hợp đặc biệt bắt buộc phải tạo scratch script để test: BẮT BUỘC đặt trong `tools/scratch/` (thư mục này đã được `.gitignore` bảo vệ) và phải dọn dẹp sau ca làm việc.

7. **RULE 11 - CẤM ĐỘNG VÀO STB_SetInfo KHI ROLLBACK SẢN XUẤT:**
   - Khi rollback / hủy chốt sản lượng các công đoạn sản xuất (Winding, Riveting, Curling... B530/B782): CHỈ thao tác trên `STB_DefectRepairInfo` (xóa phế NG) và `STB_ProdRouteHist` (xóa downstream, update `CompleteRoute = NULL` công đoạn cần chốt lại).
   - TUYỆT ĐỐI CẤM UPDATE hoặc DELETE trên `STB_SetInfo` (để bảo toàn định danh Lot, mã vạch Barcode và dữ liệu khởi tạo chuyền ban đầu).

8. **RULE 12 - BẢO MẬT CREDENTIAL & TÁCH BIỆT TOKEN (ZERO KEY LEAKAGE):**
   - Tuyệt đối CẤM lưu API key, database credentials thật vào các file mã nguồn hoặc file mẫu công khai.
   - Mọi API Key thật của Production BẮT BUỘC lưu vào các file `*.local.json` hoặc `.env.local` (được bảo vệ bởi `.gitignore`). Tuyệt đối CẤM commit key thật lên GitHub repository.

9. **RULE 13 - ĐỒNG BỘ HAI CHIỀU POP KIOSK & NAIS MES (DUAL-SYNC INTEGRITY):**
   - Kiosk POP Web (`pop.vinatech.com/pop/screen`) đọc tiến độ và trạng thái hoàn thành từ bảng trung gian `SmartFactoryV2.dbo.MongoToMesPerformance`, không đọc trực tiếp từ `STB_ProdRouteHist`.
   - Khi kiểm tra, hủy chốt hoặc mở khóa công đoạn cho Kiosk: BẮT BUỘC kiểm tra và xử lý đồng thời cả `MongoToMesPerformance` và `STB_ProdRouteHist`.
   - Khi khai báo hoặc gán thiết bị cho Kế hoạch mới: BẮT BUỘC kiểm tra `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` để đảm bảo máy không bị kẹt trạng thái `ACTIVE` từ các DayPlan cũ.

10. **RULE 14 - 1-SHOT SURGICAL TOOLING & TỐC ĐỘ PHẢN HỒI (<5-10s):**
   - CẤM chạy chuỗi 10-30 tool calls tuần tự cho một câu hỏi tra cứu/kiểm tra.
   - Mỗi câu hỏi: CHỈ ĐƯỢC PHÉP gọi tối đa 1-2 công cụ trúng đích (`.\mes.ps1 trace` cho Lot, `.\mes.ps1 find` cho lỗi/màn hình).
   - Lấy xong thông tin cốt lõi là DỪNG NGAY LẬP TỨC và phản hồi trực tiếp cho người dùng.

11. **RULE 15 - CẤM TỰ Ý TẠO HOTFIX / PLAN KHI CHƯA ĐƯỢC YÊU CẦU:**
   - Khi User hỏi "check", "tại sao", "xem giúp": CHỈ phân tích nguyên nhân và báo cáo hiện trạng.
   - TUYỆT ĐỐI CẤM tự ý tạo file `.sql` hotfix, tự ý tạo plan hay sửa đổi CSDL khi người dùng chưa yêu cầu sửa lỗi.

12. **RULE 16 - CHUẨN VẬN HÀNH CONSOLE CLI & WEB PORTAL (CLI HUBS & WEB PORTAL):**
   - Toàn bộ vận hành hệ thống tập trung qua 2 kênh chính thống: Console CLI Hubs (`.\mes.ps1`, `.\pop.ps1`, `.\gw.ps1`, `.\ksys.ps1`, `.\db.ps1`) và Web Operations Portal (`MES_POP/web` Next.js kết nối bảo mật qua Cloudflare Tunnel & API Relay).
   - Đã khai tử hoàn toàn Telegram Bot để triệt tiêu triệt để nguy cơ rò rỉ dữ liệu CSDL ra bên ngoài.

13. **RULE 17 - CẤM OVER-ENGINEERING & LÀM ĐÚNG PHẠM VI YÊU CẦU:**
   - Tuyệt đối chỉ làm đúng nội dung công việc được người dùng yêu cầu.
   - CẤM tự ý tạo thêm plan, tạo file mới, tạo web app, hoặc sửa các phần không liên quan. Làm đúng việc được giao và dừng lại trả lời ngay.

14. **RULE 18 - ĐỊNH DANH KỸ SƯ IT & CHUẨN AUTHOR/CHANGEUSERID 'vanduc':**
   - Người dùng là Kỹ sư IT (Nguyen Van Duc - EA Team), chịu trách nhiệm vận hành hệ thống MES, POP, CSDL, mạng và thiết bị IT.
   - Mọi can thiệp CSDL, Hotfix, Stored Procedure, Script hay comment BẮT BUỘC dùng `Author = 'vanduc'` và `ChangeUserID = 'vanduc'`. Tuyệt đối CẤM dùng `Antigravity` hay `it_hotfix`.

15. **RULE 19 - TRIỆT TIÊU LỖI FONT TIẾNG VIỆT & MA TRẬN TIỀN LỆ L1:**
   - Mọi file `.ps1`, `.sql`, `.json` bắt buộc lưu với định dạng UTF-8 with BOM trên Windows.
   - Tuyệt đối không để xảy ra lỗi font chữ tiếng Việt trên Console và Web Portal.
   - Luôn tra cứu tiền lệ trong L1 Cache (`historical_precedents` & `RULE_CATALOG`) trước khi chẩn đoán, không chạy truy vấn mò mẫm vào CSDL.

16. **RULE 20 - 5 NGUYÊN TẮC BẤT BIẾN VẬN HÀNH POP (MASTER PLAYBOOK EA TEAM):**
   - **(1) Sửa mã máy kép:** Khi đổi máy gán nhầm trên POP Kiosk, BẮT BUỘC UPDATE đồng thời ở **CẢ 2 BẢNG**: `SmartFactoryV2.dbo.STB_ProdRouteHist` VÀ bảng đệm `SmartFactoryV2.dbo.MongoToMesPerformance`. Tuyệt đối CẤM chỉ sửa 1 bảng vì Background Worker của POP sẽ ghi đè ngược lại mã cũ.
   - **(2) Xung đột sinh sớm công đoạn (MES WinForm vs Web POP):** MES WinForm khi chốt tự động sinh sẵn dòng ở công đoạn tiếp theo (`CompleteRoute = 1`), trong khi Web POP chỉ sinh 1 dòng cho công đoạn vừa chốt (`CompleteRoute = NULL`). Khi Kiosk báo *"This route is already completed in MES"*, BẮT BUỘC xóa dòng sinh sớm thừa trong `STB_ProdRouteWorkerHist` và `STB_ProdRouteHist`.
   - **(3) Khóa liên động độ dày Cắt điện cực:** Nút "Cắt điện cực" trên Kiosk bị mờ / vô hiệu hóa nếu độ dày màng `MaterialThickness < 100` trong `STB_MaterialMaster`. BẮT BUỘC kiểm tra độ dày trước khi nghi ngờ lỗi phần mềm.
   - **(4) Giới hạn nạp cuộn BTP tối đa 3 LOTNO:** Một mã cắt cuộn BTP chỉ cho phép nạp tối đa vào 3 LOTNO sản phẩm để kiểm soát phế và chống âm kho (Đã nâng cấp từ định mức cũ 2 LOTNO). CẤM quét ép vào LOT thứ 4.
   - **(5) Cơ chế giải phóng máy kẹt (Exclusive Lock):** Bảng `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` quản trị phiên gắn máy theo DayPlan. Khi OP quên bấm Hủy gán làm máy kẹt `ACTIVE` (POP-ERR-20, POP-ERR-27), BẮT BUỘC chuyển sang `MAPPING_STATUS = 'RELEASED'` (dùng lệnh `.\pop.ps1 unlock <Machine> -Deploy` hoặc `.\pop.ps1 release-machines -Force`).

17. **RULE 21 - BẮT BUỘC LUÔN DÙNG TOOL CHUYÊN DỤNG (CLI HUBS & L1 CACHE) — TUYỆT ĐỐI CẤM QUERY DÒ DẪM (ZERO BLIND SQL EXPLORATION):**
    - **ƯU TIÊN TUYỆT ĐỐI CÁC TOOL CLI ĐÃ ĐÓNG GÓI:**
      * POP Kiosk / NVL BOM / Tồn kho: `.\pop.ps1 trace "<Target>"`, `.\pop.ps1 nvl "<Lot/PO>"`, `.\pop.ps1 unlock "<Machine>"`, `.\pop.ps1 sync`
      * MES Core Sản xuất / Lot Lifecycle / Màn hình / Lỗi: `.\mes.ps1 trace "<LotID>"`, `.\mes.ps1 diagnose "<Text>"`, `.\mes.ps1 screen "<ScreenID>"`, `.\mes.ps1 sp "<SP_Name>"`, `.\mes.ps1 lineage "<Lot/PO>"`
      * Groupware / Tờ trình / Phê duyệt: `.\gw.ps1 trace "<PO/DocCode>"`, `.\gw.ps1 form "<Form>"`, `.\gw.ps1 find "<Keyword>"`
      * Hợp nhất ERP K-System Ace: `.\ksys.ps1 find "<Keyword>"`, `.\ksys.ps1 trace "<Lot/PO>"`, `.\ksys.ps1 module "<ModuleID>"`
      * Tra cứu từ khóa / mã lỗi: `.\pop.ps1 find "<Keyword>"`, `.\mes.ps1 find "<Keyword>"`, `.\ksys.ps1 find "<Keyword>"`.
    - **CẤM TUYỆT ĐỐI LẠM DỤNG `.\db.ps1 query` ĐỂ THỬ SAI (0 BLIND SQL LOOPING):**
      * CẤM chạy chuỗi `SELECT` thăm dò (SELECT *, SELECT TOP...) để đoán cấu trúc bảng, tên menu ERP hay tìm kiếm logic nghiệp vụ.
      * Muốn biết thông tin bảng, menu, quy trình: BẮT BUỘC tra cứu L1 Cache (`POP_MATRIX.json`, `QUICK_MATRIX.json`, `KSYSTEM_MATRIX.json`, `GW_FORM_MATRIX.json`) hoặc đọc SP gốc (`.\mes.ps1 sp`).
      * Lệnh `.\db.ps1 query` CHỈ ĐƯỢC PHÉP dùng khi CLI Hub chưa hỗ trợ VÀ đã biết đích xác 100% bảng + 3-5 cột từ tài liệu/KB/SP, có `WITH (NOLOCK)`. CẤM chạy quá 1-2 query.
    - **KỶ LUẬT HARD CEILING 1-2 TOOL CALLS:** Lấy xong dữ liệu từ CLI Hub là DỪNG NGAY và trả lời theo chuẩn 4 Dòng Vàng. Cấm gọi thêm tool để verify lan man.

18. **RULE 22 - QUY TẮC ĐỊNH DANH SỰ CỐ & PHÂN LOẠI ISSUE (POP BẮT BUỘC GHI LÀ POP, KHÔNG GHI MES):**
    - Từ nay, mọi issue (sự cố phát sinh, task hỗ trợ, ticket sự cố, báo cáo tuần IT, báo cáo khắc phục sự cố, Overtime report...) có liên quan đến hệ thống POP (POP Kiosk tại xưởng, giao diện Web POP `pop.vinatech.com`, nạp cuộn BTP/NVL BOM Kiosk, mở khóa máy kẹt `ACTIVE`, kiểm tra/sửa lỗi đồng bộ `MongoToMesPerformance` / `VINATECH_POP`, DayPlan Kiosk...) **BẮT BUỘC ghi phân loại/remark/hệ thống là `POP`**, **TUYỆT ĐỐI KHÔNG ghi là `MES` nữa**.
    - **Tách biệt rõ ràng 2 phân hệ độc lập:**
      * **`POP`:** Toàn bộ công việc, sự cố, hỗ trợ liên quan đến Kiosk xưởng & Web POP.
      * **`MES`:** Chỉ ghi cho các vấn đề thuộc về Core MES Sản xuất (WinForm NAIS MES, SmartFactoryV2 lõi, chốt sản lượng B530/B540/B552/B781/B782, in tem thùng, đóng gói B523, v.v.).

19. **RULE 23 - TIER-0 ENTERPRISE MASTER ORCHESTRATION (ops.ps1 FIRST):**
    - Khi nhận một mã bất kỳ chưa rõ nguồn gốc hoặc khi bắt đầu ca làm việc (Morning Patrol): **BẮT BUỘC sử dụng `ops.ps1` làm điểm tiếp nhận đầu tiên (`ops health` hoặc `ops trace <Mã>`)**.
    - Để Universal Smart Auto-Router tự động nhận diện 10 loại thực thể và điều phối sang sub-hub chuyên dụng.

20. **RULE 24 - ZERO IRREVERSIBLE HOTFIX (SNAPSHOT & 1-CLICK ROLLBACK BẮT BUỘC):**
    - Mọi can thiệp DML (`UPDATE`, `DELETE`) trên Production CSDL **BẮT BUỘC phải thực thi qua cơ chế Pre-flight Snapshot (`Create-SafePreflightSnapshot` hoặc `deploy_tool.ps1`)**.
    - Script triển khai phải tự động lưu bản chụp JSON các dòng bị ảnh hưởng tại `backups/snapshots/` và tự sinh tệp hoàn tác `backups/undo/undo_<Target>_<Timestamp>.sql`.
    - Khi có yêu cầu hoàn tác từ hiện trường, BẮT BUỘC thực thi qua lệnh chuẩn: `ops rollback -Target <LotID> -Deploy`.

21. **RULE 25 - WORKSPACE MODULARITY & ZERO ROOT POLLUTION (BẢO VỆ ĐỘ SẠCH GỐC):**
    - Thư mục gốc `PROCESS/` là **Khu Vực Bất Khả Xâm Phạm**: Chỉ được phép chứa 5 thư mục trụ cột chính, các thư mục module phụ (`ATTENDANCE_CMS`, `tools/shared`), và các tệp chuyển tiếp.
    - Tuyệt đối CẤM lưu các tệp script thử nghiệm, tệp dump SQL, tệp export dữ liệu hoặc tệp log tạm thời trực tiếp tại root `PROCESS/`.

22. **RULE 26 - ACTIVE KNOWLEDGE RETENTION & ANTI-DRIFT (TRIỆT TIÊU TRI THỨC MỒ CÔI):**
    - Khi phát hiện một triệu chứng lỗi mới hoặc giải pháp sửa lỗi mới được kiểm chứng thành công: **BẮT BUỘC phải ghi nhận ngay vào L1 Cache JSON (`historical_precedents`) và ghi log vào `hotfix_audit.jsonl`**.
    - Định kỳ hàng tuần hoặc sau mỗi đợt bảo trì CSDL, BẮT BUỘC chạy `ops audit-kb` để rà soát tự động 100% Stored Procedures và Tables giữa L1 Cache và Live DB (Anti-Drift).

23. **RULE 27 - MULTI-ROOT WORKSPACE SYNCHRONIZATION (ĐỒNG NHẤT MÔI TRƯỜNG LÀM VIỆC):**
    - Luôn ưu tiên mở IDE thông qua tệp `vinatech-enterprise.code-workspace` để nạp đầy đủ cả 5 phân hệ cùng lúc.
    - Mọi công cụ viết mới BẮT BUỘC phải tích hợp cơ chế Universal Root Detection.


