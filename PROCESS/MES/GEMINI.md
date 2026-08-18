<!--
AI-READY METADATA
Purpose: Auto-Context & Entry Point cho Antigravity / Gemini AI Agent tại Vinatech MES Workspace
Scope: Workspace Root Context
Single Source of Truth: GEMINI.md & AI_AGENT_CONFIG/RULES.md
Related Files:
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/RULES.md)
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
-->

# ⚡ GEMINI.md — Auto-Context cho Vinatech MES Workspace

> **Mục đích:** File này được AI tự đọc khi mở workspace. Chứa context tối thiểu để vận hành an toàn.
> **Chi tiết đầy đủ:** Đọc [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)

---

## 🛡️ Quy Tắc Cốt Lõi

> [!CAUTION]
> **1. SELECT-ONLY** — KHÔNG INSERT/UPDATE/DELETE/ALTER/DROP trực tiếp trên production DB.
> **2. Script → User chạy** — Viết SQL fix bọc `BEGIN TRAN...ROLLBACK` → user tự chạy qua SSMS hoặc `deploy_tool.ps1`.
> **3. KNOWLEDGE-FIRST HARD STOP** — CẤM CHẠY SQL QUERY KHI CHƯA TRA KB! Khi có lỗi, bắt buộc tra `KB_09_SCREEN_BUG_FIXBOOK.md` hoặc KI `vinatech_bug_fix_patterns` trước. (1) Tra tài liệu RA ➔ Trình bày căn cứ KB & SELECT verify tài liệu. (2) Tra tài liệu KHÔNG RA ➔ Báo cáo rõ đã tra KB nhưng chưa có & đề xuất SELECT khảo sát DB.
> **4. TOKEN OPTIMIZATION** — Không load full file >50KB hoặc `SELECT *`. Chỉ dùng `grep_search` / line-range, SELECT 3-5 cột chính, phản hồi ngắn gọn 3 khối.
> **5. Hỏi trước khi làm** — Thiếu thông tin hoặc nghi ngờ → dừng hỏi user ngay.
> **6. GOLDEN QUERY FIRST** — BẮT BUỘC DÙNG GOLDEN QUERY TRUY VẾT 360° NGAY LẦN SELECT ĐẦU TIÊN! Khi user đưa mã Barcode/LotNo bất kỳ (Cell, Module, Cuộn cực Slitting, NVL kho), CẤM SELECT đơn lẻ tẻ từng bảng. Bắt buộc dùng Golden Query (Mẫu 1/2/3/4 trong KNOWLEDGE.md §4) ngay ở câu SELECT đầu tiên để quét sạch 100% PO, Routing, Kho, Slitting Stock, Packing trong 1 lần duy nhất!
> **7. IMMEDIATE SCREEN & SP MAPPING** — CẤM CẮM ĐẦU ĐI TÌM LẠI TỪ ĐẦU! Khi user gửi ảnh thiết kế màn hình hoặc nhập Screen ID (VD: B523, B530, B351, B597, F330, C530...), AI BẮT BUỘC tra cứu ngay lập tức từ `screen_id_reference` / `KB_09` để xác định ngay 100%: (1) Tên & Phân hệ màn hình, (2) Search SP (`_get`), (3) Execute SP (`_iud`), (4) Bảng DB chính & UI Grid layout. Cấm tìm kiếm mơ hồ hay hỏi lại thông tin đã có trong KB!
> **8. CẤM CHÈN BẢN GHI GIẢ LẬP (DUMMY)** — CẤM TỰ Ý INSERT/UPDATE dữ liệu suy đoán vào DB sản xuất khi chưa tra cứu chuẩn kiến trúc SoT (`KB_04_01_CORE_PACKAGING.md`). Mọi thao tác fix dữ liệu phải tuân thủ 100% quy trình từ tài liệu SoT!
> **9. CẤM CẮM ĐẦU VÀO SELECT DATABASE** — CẤM CẮM ĐẦU VÀO SELECT DATABASE NGAY KHI NHẬN YÊU CẦU! AI BẮT BUỘC phải đọc và tra cứu tài liệu KB / SoT trước: Nếu tra RA ➔ Trình bày căn cứ KB rồi mới SELECT verify tài liệu; Nếu tra KHÔNG RA ➔ Báo cáo đã tra các tài liệu nào nhưng chưa có, sau đó mới đề xuất hoặc thực thi SELECT khảo sát DB.
> **10. CẤM TẠO FILE DƯ THỪA & BẮT BUỘC DÙNG FILE CÓ SẴN** — CẤM tự ý tạo các file script test tạm, file SQL rác hay file rác dư thừa trong workspace. BẮT BUỘC chỉ sử dụng các file/công cụ sẵn có trong hệ thống (`run_query.ps1`, `deploy_tool.ps1`, `check_db.ps1`...). Dọn dẹp sạch sẽ nguyên trạng ngay sau khi hoàn thành công việc.


> Chi tiết đầy đủ → [RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/RULES.md)

---

## 🔌 Kết Nối DB

> [!NOTE]
> Thông tin kết nối chi tiết xem tại [db_config.json](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/db_config.json)  
> - **DB chính:** `SmartFactoryV2`  
> - **DB framework:** `SmartFramework`

---

## 🛠️ Tools & Workflow

→ Xem [BOOTSTRAP.md § KẾT NỐI & TOOLS](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md#2--kết-nối--tools)

---

## 🧭 Tra Cứu Nhanh

- **Tri thức tích hợp chéo (Groupware/MES) →** [Master Index](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) (VOL_01: Kiến trúc, VOL_02: Nghiệp vụ, VOL_03: Troubleshooting)
- **Bug theo màn hình →** [KB_09 (Bug Fixbook)](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)
- **Bài học & Tối ưu vận hành →** [LESSONS_LEARNED.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/LESSONS_LEARNED.md)
- **Config files →** Thư mục [AI_AGENT_CONFIG/](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/README.md) ([BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md), [RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/RULES.md), [KNOWLEDGE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/KNOWLEDGE.md), [SKILLS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/SKILLS.md))
- **KB chuyên sâu →** [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
- **Knowledge Items →** screen_id_reference, deep_system_map, kb_verification


