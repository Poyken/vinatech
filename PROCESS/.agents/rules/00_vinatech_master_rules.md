# 🛡️ VINATECH MASTER AGENT WORKSPACE RULE DEFINITIONS (V3.0)

## QUY TẮC BẮT BUỘC KHÔNG THỂ BỎ QUA:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (BẤT BIẾN):**
   - Luôn tra cứu L1 Cache qua `.\mes.ps1 find "<Keyword>"`, `.\gw.ps1 find "<Keyword>"`, hoặc `.\db.ps1 find "<Keyword>"` trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION:**
   - Cấm thực thi DML/DDL trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và triển khai qua `deploy_tool.ps1` hoặc `.\mes.ps1 deploy <file.sql>`.

3. **RULE 4 - SURGICAL RETRIEVAL & L1 CACHE FIRST:**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Tuyệt đối không đọc tràn lan cả file Markdown >50KB gây nghẽn Context.

4. **RULE 6 - GOLDEN QUERY 360° FIRST:**
   - Truy vết sản xuất: `.\mes.ps1 trace "<LotID>"`
   - Truy vết POP Kiosk: `.\mes.ps1 pop-trace "<Keyword>"`
   - Truy vết Groupware: `.\gw.ps1 trace "<PO/DocCode>"`
   - Truy vết Lineage: `.\db.ps1 lineage -Type <T> -Value <V>`

5. **RULE 10 - STANDARD TOOLING & ZERO JUNK FILES (BẢO VỆ WORKSPACE):**
   - Tuyệt đối CẤM tạo các file script `.ps1` rời rạc trực tiếp tại thư mục gốc.
   - BẮT BUỘC sử dụng các CLI Hub: `.\mes.ps1`, `.\gw.ps1`, `.\db.ps1`.
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
