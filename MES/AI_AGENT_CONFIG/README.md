# 🚀 AI Agent Config — Vinatech MES

> **Bạn là AI agent đang làm việc trên dự án MES Vinatech.**
> **ĐỌC 3 FILE DƯỚI ĐÂY THEO THỨ TỰ khi bắt đầu phiên mới.**

## Thứ tự đọc file (tiết kiệm token tối đa)

| # | File | Khi nào đọc | Token ~est |
|---|------|-------------|-----------|
| 1 | [RULES.md](RULES.md) | **LUÔN LUÔN** — Mỗi phiên bắt đầu | ~500 |
| 2 | [KNOWLEDGE.md](KNOWLEDGE.md) | **Khi cần tra cứu** bảng/SP/KB | ~800 |
| 3 | [SKILLS.md](SKILLS.md) | **Khi cần chạy query** hoặc debug | ~600 |

## Khi nào đọc thêm KB files?

- **CHỈ** đọc KB file cụ thể khi RULES + KNOWLEDGE + SKILLS chưa đủ để trả lời
- Tra KB_INDEX.md theo triệu chứng → đọc đúng 1 KB file liên quan
- **KHÔNG** đọc hết 30 KB files — chỉ đọc file được KB_INDEX chỉ định

## Cấu trúc dự án

```
MES/
├── AI_AGENT_CONFIG/          ← BẠN ĐANG ĐÂY — Config cho AI agent
│   ├── README.md             ← File này — Entry point
│   ├── RULES.md              ← Quy tắc bắt buộc (SELECT-only, safety)
│   ├── KNOWLEDGE.md          ← Cheat sheet bảng/SP/factory matrix
│   └── SKILLS.md             ← SQL/PS templates + lessons learned
├── MES_MASTER_KNOWLEDGE_BASE/ ← 30 KB files chi tiết (đọc khi cần)
│   ├── KB_INDEX.md            ← Mục lục tra cứu nhanh
│   └── KB_01 → KB_30          ← Tài liệu chuyên sâu từng phân hệ
├── HOTFIX_SCRIPTS/            ← 5 SQL hotfix scripts (chưa deploy)
├── AI_CONFIG.md               ← Config cũ (legacy, tham khảo)
├── CLAUDE.md                  ← Coding rules cũ (legacy, tham khảo)
└── README.md                  ← Tổng quan dự án
```

## FAQ

**Q: Tôi có nên đọc AI_CONFIG.md và CLAUDE.md không?**
A: Không cần. Nội dung đã được tổng hợp và nén gọn vào RULES.md + SKILLS.md.

**Q: Token budget thấp, tôi chỉ đọc 1 file?**
A: Đọc RULES.md — đây là file quan trọng nhất.
