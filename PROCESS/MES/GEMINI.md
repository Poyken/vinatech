# GEMINI.md — Auto-Context cho Vinatech MES Workspace

> **Mục đích:** File này được AI tự đọc khi mở workspace. Chứa context tối thiểu.
> **Chi tiết đầy đủ:** Đọc `AI_AGENT_CONFIG/BOOTSTRAP.md`

## Quy Tắc Bắt Buộc

1. **SELECT-ONLY** — KHÔNG INSERT/UPDATE/DELETE trực tiếp trên production DB
2. **Script → User chạy** — Viết SQL fix bọc `BEGIN TRAN...ROLLBACK` → user tự chạy SSMS
3. **Fetch trước khi sửa** — Query SP mới nhất từ `sys.sql_modules`
4. **WITH(NOLOCK)** trên bảng giao dịch lớn
5. **Hỏi trước khi làm** — Thiếu thông tin → dừng hỏi user
6. **Tra cứu KB trước** — Đọc gợi ý tự động từ `run_query.ps1` / `db_sync_tool.ps1` hoặc chạy `.\search_kb.ps1` tìm tài liệu trước khi truy vấn DB.
7. **Ghi nhận & Tự vá** — Sau khi fix lỗi, bắt buộc chạy `.\record_hotfix.ps1` để tự động hóa cập nhật `HOTFIX_LOG.md` và `KB_31`. Chạy `.\self_improve.ps1` để audit lại workspace trước khi hoàn thành.

## Kết Nối DB

- **Server:** `dbserver.hycap.co.kr,5398`
- **DB:** `SmartFactoryV2` (chính), `SmartFramework` (UI/config)
- **User:** `vinaadmin`

## Tools (chạy từ MES/)

```
.\search_kb.ps1 -Query "keyword"         # Tìm kiếm tài liệu cục bộ
.\run_query.ps1 -Query "SELECT ..."     # Query nhanh (tự động gợi ý KB liên quan)
.\validate_sql.ps1 <file.sql>            # Validate trước deploy  
.\deploy_tool.ps1 <file.sql>             # Deploy SQL
.\db_sync_tool.ps1 -SPName "usp_xxx"     # Tải SP tạm (tự động gợi ý KB liên quan)
.\db_sync_tool.ps1 -Clean                # Xóa SP tạm
.\record_hotfix.ps1 -TCode "B523" -Symptom "..." -Cause "..." -SQLPatch "..." # Tự động hóa ghi chép lỗi
.\self_improve.ps1                       # Tự đánh giá audit workspace
.\debug_screen.ps1 -TCode "B523"         # Chẩn đoán màn hình (Menu, SP, Grid)
.\debug_screen.ps1 -ErrorMsg "loi"       # Tìm SP ném lỗi qua chuỗi dịch nghĩa
```

## Tra Cứu

- **Bug theo màn hình →** KB_31 (Bug Fixbook)
- **Config files →** `AI_AGENT_CONFIG/` (BOOTSTRAP.md, RULES.md, KNOWLEDGE.md, SKILLS.md)
- **KB chuyên sâu →** `MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md`
- **Knowledge Items →** screen_id_reference, deep_system_map, kb_verification
