# GEMINI.md — Auto-Context cho Vinatech MES Workspace

> **Mục đích:** File này được AI tự đọc khi mở workspace. Chứa context tối thiểu.
> **Chi tiết đầy đủ:** Đọc `AI_AGENT_CONFIG/BOOTSTRAP.md`

## Quy Tắc Bắt Buộc

1. **SELECT-ONLY** — KHÔNG INSERT/UPDATE/DELETE trực tiếp trên production DB
2. **Script → User chạy** — Viết SQL fix bọc `BEGIN TRAN...ROLLBACK` → user tự chạy SSMS
3. **Fetch trước khi sửa** — Query SP mới nhất từ `sys.sql_modules`
4. **WITH(NOLOCK)** trên bảng giao dịch lớn
5. **Hỏi trước khi làm** — Thiếu thông tin → dừng hỏi user
6. **Tra cứu KB trước** — Bắt buộc chạy `.\search_kb.ps1` tìm mã lỗi/màn hình trước khi truy vấn DB

## Kết Nối DB

- **Server:** `dbserver.hycap.co.kr,5398`
- **DB:** `SmartFactoryV2` (chính), `SmartFramework` (UI/config)
- **User:** `vinaadmin`

## Tools (chạy từ MES/)

```
.\search_kb.ps1 -Query "keyword"         # Tìm kiếm tài liệu cục bộ
.\run_query.ps1 -Query "SELECT ..."     # Query nhanh
.\validate_sql.ps1 <file.sql>            # Validate trước deploy  
.\deploy_tool.ps1 <file.sql>             # Deploy SQL
.\db_sync_tool.ps1 -SPName "usp_xxx"     # Tải SP tạm
.\db_sync_tool.ps1 -Clean                # Xóa SP tạm
```

## Tra Cứu

- **Bug theo màn hình →** KB_31 (Bug Fixbook)
- **Config files →** `AI_AGENT_CONFIG/` (BOOTSTRAP.md, RULES.md, KNOWLEDGE.md, SKILLS.md)
- **KB chuyên sâu →** `MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md`
- **Knowledge Items →** screen_id_reference, deep_system_map, kb_verification
