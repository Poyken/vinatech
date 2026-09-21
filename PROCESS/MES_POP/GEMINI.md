# 🛡️ VINATECH MES WORKSPACE RULES (MES_POP)

> **Single Source of Truth:** `.agents/rules/00_vinatech_rules.md`

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0:** CẤM chạy `SELECT` trước khi tra cứu `.\mes.ps1 find "<Keyword>"` hoặc KB modules.
- **RULE 14 (TỐC ĐỘ):** Tối đa 1-2 tool calls/câu hỏi. Lấy xong data là DỪNG NGAY và trả lời (<5-10s). CẤM chạy chuỗi 10-30 tool dò dẫm.
- **RULE 15 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix hay lập plan khi User chỉ yêu cầu kiểm tra/hỏi nguyên nhân.

## ⚡ CLI HUB: `.\mes.ps1`
- `find "<Keyword>"` — Tra cứu L1 Cache + 78+ file KB
- `trace "<LotID>"` — Golden Query 360°
- `screen "<ScreenID>"` — Debug màn hình
- `health` / `audit` — Sức khỏe & kiểm toán
- `new-fix` / `deploy` — Hotfix workflow
