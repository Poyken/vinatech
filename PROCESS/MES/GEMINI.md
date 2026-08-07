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
> **3. KNOWLEDGE-FIRST HARD STOP** — CẤM CHẠY SQL QUERY KHI CHƯA TRA KB! Khi có lỗi, bắt buộc tra `KB_09_SCREEN_BUG_FIXBOOK.md` hoặc KI `vinatech_bug_fix_patterns` để đọc Root Cause + SP + Bảng trước. Chỉ SELECT sau khi đã nắm rõ trong KB.
> **4. TOKEN OPTIMIZATION** — Không load full file >50KB hoặc `SELECT *`. Chỉ dùng `grep_search` / line-range, SELECT 3-5 cột chính, phản hồi ngắn gọn 3 khối.
> **5. Hỏi trước khi làm** — Thiếu thông tin hoặc nghi ngờ → dừng hỏi user ngay.
> **6. GOLDEN QUERY FIRST** — BẮT BUỘC DÙNG GOLDEN QUERY TRUY VẾT 360° NGAY LẦN SELECT ĐẦU TIÊN! Khi user đưa mã Barcode/LotNo bất kỳ (Cell, Module, Cuộn cực Slitting, NVL kho), CẤM SELECT đơn lẻ tẻ từng bảng. Bắt buộc dùng Golden Query (Mẫu 1/2/3/4 trong KNOWLEDGE.md §4) ngay ở câu SELECT đầu tiên để quét sạch 100% PO, Routing, Kho, Slitting Stock, Packing trong 1 lần duy nhất!
> **7. IMMEDIATE SCREEN & SP MAPPING** — CẤM CẮM ĐẦU ĐI TÌM LẠI TỪ ĐẦU! Khi user gửi ảnh thiết kế màn hình hoặc nhập Screen ID (VD: B523, B530, B351, B597, F330, C530...), AI BẮT BUỘC tra cứu ngay lập tức từ `screen_id_reference` / `KB_09` để xác định ngay 100%: (1) Tên & Phân hệ màn hình, (2) Search SP (`_get`), (3) Execute SP (`_iud`), (4) Bảng DB chính & UI Grid layout. Cấm tìm kiếm mơ hồ hay hỏi lại thông tin đã có trong KB!


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




