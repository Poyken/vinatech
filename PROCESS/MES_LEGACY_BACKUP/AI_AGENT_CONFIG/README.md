<!--
AI-READY METADATA
Purpose: Hướng dẫn tổng quan cấu trúc thư mục AI_AGENT_CONFIG tinh gọn
Scope: Config Directory Documentation
Single Source of Truth: AI_AGENT_CONFIG/README.md
-->

# 🚀 AI Agent Config — Vinatech MES (Lean v2.1)

> Thư mục chứa cấu hình và bộ nhớ dài hạn tinh gọn cho AI Agent vận hành hệ thống MES Vinatech.

## 📂 Cấu Trúc Thư Mục

| File / Thư mục | Chức năng | Cơ chế sử dụng |
|---|---|---|
| **`QUICK_MATRIX.json`** | **L1 Cache (95 màn hình MES)** | Truy xuất siêu tốc (<0.001s) qua `.\mes.ps1 find "<TCode>"` hoặc `.\mes.ps1 screen "<TCode>"` |
| **`HOTFIX_LOG.md`** | **Nhật ký Hotfix (Active 30 ngày)** | Lưu vết các sự cố & SQL patch gần nhất. Script `record_hotfix.ps1` tự động tăng ID từ file này |
| **`LESSONS_LEARNED.md`** | **Bài học kinh nghiệm vận hành** | Tổng hợp các bẫy, nguyên nhân gốc rễ và quy chuẩn thao tác an toàn từ các phiên trước |
| **`archive/`** | **Kho lưu trữ Hotfix cũ** | Chứa các hotfix cũ hơn 30 ngày (Tháng 07-08/2026...) để giữ file active luôn nhẹ và nhanh |

## ⚡ Nguyên Tắc Vận Hành Nhanh
1. **Không nạp toàn bộ file:** Dùng `.\mes.ps1 find` để tra cứu theo nhu cầu thay vì đọc toàn bộ file cấu hình.
2. **Hotfix Registry:** Khi ghi nhận lỗi mới qua `record_hotfix.ps1`, mã ID tự động sinh dựa trên max ID hiện tại.
3. **Single Source of Truth:**
   - Quy tắc ứng xử: `.agents/rules/00_vinatech_rules.md`
   - Điều phối lệnh: `.\mes.ps1`
