# 🚀 AI Agent Config — Vinatech MES

> **Bạn là AI agent đang làm việc trên dự án MES Vinatech.**
> **Mỗi session mới: User sẽ nói "Đọc BOOTSTRAP.md" → AI đọc 1 file và sẵn sàng ngay.**

## ⚡ Thứ tự đọc file

| # | File | Khi nào đọc | Nội dung | Token ~est |
|---|------|-------------|----------|-----------|
| **0** | **[BOOTSTRAP.md](BOOTSTRAP.md)** | **LUÔN LUÔN — Mỗi session mới** | **All-in-one: rules + DB + tools + bẫy + trạng thái dự án** | **~1500** |
| 1 | [RULES.md](RULES.md) | Khi cần chi tiết quy tắc | Quy tắc an toàn DB, workflow bug fix | ~500 |
| 2 | [KNOWLEDGE.md](KNOWLEDGE.md) | Khi cần tra cứu bảng/SP/KB | Cheat sheet bảng/SP/factory matrix | ~800 |
| 3 | [SKILLS.md](SKILLS.md) | Khi cần SQL template cụ thể | SQL/PS templates + debug recipes | ~600 |

### Quy trình đề xuất:
1. **Session mới** → Đọc `BOOTSTRAP.md` (đã đủ 90% context)
2. **Cần thêm chi tiết** → Đọc `RULES.md` / `KNOWLEDGE.md` / `SKILLS.md` tùy nhu cầu
3. **Cần KB chuyên sâu** → Tra `KB_INDEX.md` → đọc đúng 1 KB file

## Cấu trúc dự án

```
MES/
├── AI_AGENT_CONFIG/           ← Config cho AI agent
│   ├── BOOTSTRAP.md           ← ⚡ FILE DUY NHẤT CẦN ĐỌC mỗi session mới
│   ├── README.md              ← File này — Hướng dẫn sử dụng
│   ├── RULES.md               ← Quy tắc chi tiết (tham chiếu bổ sung)
│   ├── KNOWLEDGE.md           ← Cheat sheet bảng/SP (tham chiếu bổ sung)
│   └── SKILLS.md              ← SQL/PS templates (tham chiếu bổ sung)
├── MES_MASTER_KNOWLEDGE_BASE/  ← 30 KB files chi tiết (đọc khi cần)
│   ├── KB_INDEX.md            ← Mục lục tra cứu nhanh
│   └── KB_01 → KB_30          ← Tài liệu chuyên sâu từng phân hệ
├── sql/hotfixes/               ← 17 SQL hotfix scripts đã triển khai (lịch sử)
├── run_query.ps1               ← Query DB nhanh
├── validate_sql.ps1            ← Validate SQL trước deploy
├── deploy_tool.ps1             ← Deploy SQL lên production
├── db_sync_tool.ps1            ← Tải/xóa SP tạm từ DB
└── README.md                   ← Tổng quan dự án
```

## FAQ

**Q: Tôi có nên đọc tất cả 4 file config không?**
A: Không — chỉ cần đọc `BOOTSTRAP.md` là đủ. Các file `RULES`, `KNOWLEDGE`, `SKILLS` là tham chiếu chi tiết khi cần.

**Q: Token budget thấp, tôi nên ưu tiên đọc file nào?**
A: Đọc `BOOTSTRAP.md` — file này chứa tất cả quy tắc, kết nối DB, bẫy đã gặp, và trạng thái dự án.

**Q: Khi nào cần đọc KB files?**
A: Chỉ khi BOOTSTRAP chưa đủ. Tra `KB_INDEX.md` theo triệu chứng → đọc đúng 1 KB file liên quan.
