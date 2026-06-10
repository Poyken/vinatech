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
├── AI_AGENT_CONFIG/           ← BẠN ĐANG ĐÂY — Config cho AI agent
│   ├── README.md              ← File này — Entry point
│   ├── RULES.md               ← Quy tắc bắt buộc (SELECT-only, safety, surgical changes)
│   ├── KNOWLEDGE.md           ← Cheat sheet bảng/SP/factory matrix
│   └── SKILLS.md              ← SQL/PS templates + lessons learned
├── MES_MASTER_KNOWLEDGE_BASE/  ← 29 KB files chi tiết (đọc khi cần)
│   ├── KB_INDEX.md            ← Mục lục tra cứu nhanh
│   └── KB_01 → KB_30          ← Tài liệu chuyên sâu từng phân hệ
├── sql/                       ← Thư mục chứa mã nguồn CSDL
│   ├── procedures/            ← Các Stored Procedure (đã bỏ _ORIGINAL)
│   ├── hotfixes/              ← 5 SQL hotfix scripts đã deploy
│   └── scripts/               ← Các script tiện ích
├── db_sync_tool.ps1           ← Công cụ tải SP từ DB
├── deploy_tool.ps1            ← Công cụ triển khai SQL lên DB
└── README.md                  ← Tổng quan dự án
```

## FAQ

**Q: Tôi có nên đọc các file KB không?**
A: Chỉ đọc khi RULES + KNOWLEDGE + SKILLS chưa đủ thông tin hoặc khi được chỉ định rõ bởi KB_INDEX.md.

**Q: Token budget thấp, tôi nên ưu tiên đọc file nào?**
A: Đọc RULES.md — đây là file bắt buộc chứa toàn bộ quy tắc an toàn CSDL.
