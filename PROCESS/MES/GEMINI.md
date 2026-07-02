# GEMINI.md — Auto-Context cho Vinatech MES Workspace

> **Mục đích:** File này được AI tự đọc khi mở workspace. Chứa context tối thiểu.
> **Chi tiết đầy đủ:** Đọc `AI_AGENT_CONFIG/BOOTSTRAP.md`

## Quy Tắc Cốt Lõi

1. **SELECT-ONLY** — KHÔNG INSERT/UPDATE/DELETE trực tiếp trên production DB
2. **Script → User chạy** — Viết SQL fix bọc `BEGIN TRAN...ROLLBACK` → user tự chạy SSMS
3. **Hỏi trước khi làm** — Thiếu thông tin → dừng hỏi user

> Chi tiết đầy đủ → [RULES.md](AI_AGENT_CONFIG/RULES.md)

## Kết Nối DB

→ Xem [`db_config.json`](db_config.json) | DB chính: `SmartFactoryV2`, DB framework: `SmartFramework`

## Tools & Workflow

→ Xem [`BOOTSTRAP.md`](AI_AGENT_CONFIG/BOOTSTRAP.md) § KẾT NỐI & TOOLS

## Tra Cứu

- **Tri thức tích hợp chéo (Groupware/MES) →** [Master Index](../SYSTEM_MASTER_KNOWLEDGE_BASE/README.md) (VOL_01: Kiến trúc, VOL_02: Nghiệp vụ, VOL_03: Troubleshooting)
- **Bug theo màn hình →** KB_31 (Bug Fixbook)
- **Config files →** `AI_AGENT_CONFIG/` (BOOTSTRAP.md, RULES.md, KNOWLEDGE.md, SKILLS.md)
- **KB chuyên sâu →** `MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md`
- **Knowledge Items →** screen_id_reference, deep_system_map, kb_verification
