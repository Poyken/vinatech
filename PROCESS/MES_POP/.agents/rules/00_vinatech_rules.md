# 🛡️ VINATECH MES AGENT WORKSPACE RULE DEFINITIONS (V2.1)

## QUY TẮC BẮT BUỘC KHÔNG THỂ BỎ QUA:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (BẤT BIẾN):**
   - Luôn tra cứu L1 `QUICK_MATRIX.json` qua `.\find_kb.ps1 "<Keyword>"` hoặc module KB trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION:**
   - Cấm thực thi DML/DDL trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và triển khai qua `.\mes.ps1 deploy <file.sql>`.

3. **RULE 4 - SURGICAL RETRIEVAL & L1 CACHE FIRST:**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Tuyệt đối không đọc tràn lan cả file Markdown >50KB gây nghẽn Context.

4. **RULE 6 - GOLDEN QUERY 360° FIRST:**
   - Dùng `.\mes.ps1 trace "<LotID>"` trong lần kiểm tra đầu tiên khi truy vết Lot/Barcode (quét sạch 4 bảng trong 1 lần duy nhất).

5. **RULE 7 - GIAO THỨC XỬ LÝ KHI USER CUNG CẤP THIẾU THÔNG TIN (UNDERSPECIFIED INPUT):**
   - **Trường hợp User chỉ gõ "check" / "kiểm tra hệ thống":** Tự động kích hoạt `.\mes.ps1 health -Detail` (quét Lot HOLD, WIP 24h, DB Lock) và đưa ra 4 tùy chọn tra cứu nhanh (Trace Lot / Debug Screen / Audit Schema / Inventory). CẤM chạy SELECT mò mẫm tự do.
   - **Trường hợp User chỉ gửi mã Lot nhưng không nêu hiện tượng lỗi:** Chạy ngay `.\mes.ps1 trace "<LotID>"`, xuất bảng tóm tắt 4 trạng thái cốt lõi và hỏi rõ hành động mong muốn (Mở HOLD, Hủy sản lượng, Đổi Model, hay In tem).
   - **Trường hợp User hỏi về phân hệ mở rộng (POP, Sorting, Kế hoạch):** Tự động điều hướng đúng Database Profile (`POP`, `Groupware`, `AndonDB`, `ERP`) qua tham số `-Profile`.

6. **RULE 10 - STANDARD TOOLING & ZERO JUNK FILES (BẢO VỆ WORKSPACE):**
   - Tuyệt đối CẤM tạo các file script `.ps1` rời rạc (`check_*.ps1`, `find_*.ps1`, `inspect_*.ps1`...) trực tiếp tại thư mục gốc hoặc trong `tools/`.
   - BẮT BUỘC sử dụng CLI Hub `.\mes.ps1` (`.\mes.ps1 query`, `.\mes.ps1 trace`, `.\mes.ps1 screen`, `.\mes.ps1 find`).
   - Nếu trong trường hợp đặc biệt bắt buộc phải tạo scratch script để test: BẮT BUỘC đặt trong `tools/scratch/` (thư mục này đã được `.gitignore` bảo vệ) và phải dọn dẹp sau ca làm việc.

7. **RULE 11 - CẤM ĐỘNG VÀO STB_SetInfo KHI ROLLBACK SẢN XUẤT:**
   - Khi rollback / hủy chốt sản lượng các công đoạn sản xuất (Winding, Riveting, Curling... B530/B782): CHỈ thao tác trên `STB_DefectRepairInfo` (xóa phế NG) và `STB_ProdRouteHist` (xóa downstream, update `CompleteRoute = NULL` công đoạn cần chốt lại).
   - TUYỆT ĐỐI CẤM UPDATE hoặc DELETE trên `STB_SetInfo` (để bảo toàn định danh Lot, mã vạch Barcode và dữ liệu khởi tạo chuyền ban đầu).

8. **RULE 12 - BẢO MẬT CREDENTIAL & TÁCH BIỆT TOKEN (ZERO KEY LEAKAGE):**
   - File `tools/telegram_config.json` chỉ được chứa giá trị PLACEHOLDER mẫu (`YOUR_TELEGRAM_BOT_TOKEN_HERE`, `YOUR_GEMINI_API_KEY_HERE`).
   - Mọi Token Telegram và API Key thật của Production BẮT BUỘC lưu vào `tools/telegram_config.local.json` (được bảo vệ bởi `.gitignore` qua `*.local.json`). Tuyệt đối CẤM commit key thật lên GitHub repository.

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

12. **RULE 16 - CẤM TRÌNH DUYỆT & KHÔNG DÙNG HTML (NO BROWSER / ZERO HTML):**
   - Môi trường vận hành nhà máy không thể mở file `.html` hoặc khởi chạy trình duyệt Web.
   - 100% vận hành qua Console CLI (`mes.ps1`), REPL Shell, Terminal, Python và Telegram Bot.

13. **RULE 17 - CẤM OVER-ENGINEERING & LÀM ĐÚNG PHẠM VI YÊU CẦU:**
   - Tuyệt đối chỉ làm đúng nội dung công việc được người dùng yêu cầu.
   - CẤM tự ý tạo thêm plan, tạo file mới, tạo web app, hoặc sửa các phần không liên quan. Làm đúng việc được giao và dừng lại trả lời ngay.

14. **RULE 18 - ĐỊNH DANH KỸ SƯ IT & CHUẨN AUTHOR/CHANGEUSERID 'vanduc':**
   - Người dùng là Kỹ sư IT (Nguyen Van Duc - EA Team), chịu trách nhiệm vận hành hệ thống MES, POP, CSDL, mạng và thiết bị IT.
   - Mọi can thiệp CSDL, Hotfix, Stored Procedure, Script hay comment BẮT BUỘC dùng `Author = 'vanduc'` và `ChangeUserID = 'vanduc'`. Tuyệt đối CẤM dùng `Antigravity` hay `it_hotfix`.

15. **RULE 19 - TRIỆT TIÊU LỖI FONT TIẾNG VIỆT & MA TRẬN TIỀN LỆ L1:**
   - Mọi file `.ps1`, `.sql`, `.json` bắt buộc lưu với định dạng UTF-8 with BOM trên Windows.
   - Tuyệt đối không để xảy ra lỗi font chữ tiếng Việt hay lỗi parsing ký tự HTML trên Telegram Bot.
   - Luôn tra cứu tiền lệ trong L1 Cache (`historical_precedents` & `RULE_CATALOG`) trước khi chẩn đoán, không chạy truy vấn mò mẫm vào CSDL.

16. **RULE 20 - 5 NGUYÊN TẮC BẤT BIẾN VẬN HÀNH POP (MASTER PLAYBOOK EA TEAM):**
   - **(1) Sửa mã máy kép:** Khi đổi máy gán nhầm trên POP Kiosk, BẮT BUỘC UPDATE đồng thời ở **CẢ 2 BẢNG**: `SmartFactoryV2.dbo.STB_ProdRouteHist` VÀ bảng đệm `SmartFactoryV2.dbo.MongoToMesPerformance`. Tuyệt đối CẤM chỉ sửa 1 bảng vì Background Worker của POP sẽ ghi đè ngược lại mã cũ.
   - **(2) Xung đột sinh sớm công đoạn (MES WinForm vs Web POP):** MES WinForm khi chốt tự động sinh sẵn dòng ở công đoạn tiếp theo (`CompleteRoute = 1`), trong khi Web POP chỉ sinh 1 dòng cho công đoạn vừa chốt (`CompleteRoute = NULL`). Khi Kiosk báo *"This route is already completed in MES"*, BẮT BUỘC xóa dòng sinh sớm thừa trong `STB_ProdRouteWorkerHist` và `STB_ProdRouteHist`.
   - **(3) Khóa liên động độ dày Cắt điện cực:** Nút "Cắt điện cực" trên Kiosk bị mờ / vô hiệu hóa nếu độ dày màng `MaterialThickness < 100` trong `STB_MaterialMaster`. BẮT BUỘC kiểm tra độ dày trước khi nghi ngờ lỗi phần mềm.
   - **(4) Giới hạn nạp cuộn BTP tối đa 2 LOTNO:** Một mã cắt cuộn BTP chỉ cho phép nạp tối đa vào 2 LOTNO sản phẩm để kiểm soát phế và chống âm kho. CẤM quét ép vào LOT thứ 3.
   - **(5) Cơ chế giải phóng máy kẹt (Exclusive Lock):** Bảng `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` quản trị phiên gắn máy theo DayPlan. Khi OP quên bấm Hủy gán làm máy kẹt `ACTIVE` (POP-ERR-20, POP-ERR-27), BẮT BUỘC chuyển sang `MAPPING_STATUS = 'RELEASED'` (dùng lệnh `.\mes.ps1 release-machines -Force` hoặc SQL Hotfix).

