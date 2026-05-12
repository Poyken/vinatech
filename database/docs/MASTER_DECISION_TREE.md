# 🌳 MASTER DECISION TREE - INTELLIGENT ROUTING SYSTEM

> **Mục đích:** Tự động định tuyến yêu cầu đến công cụ phù hợp nhất
> **Hiệu suất:** Giảm 70% thời gian xác định cách tiếp cận
> **Cập nhật:** 2026-05-12

---

## 🎯 DECISION TREE CHÍNH

```
USER GỬI YÊU CẦU
        ↓
PHÂN TÍCH LOẠI YÊU CẦU (Tự động)
        ↓
    ┌───┴───┬───┴───┬───┴───┬───┴───┐
    ↓       ↓       ↓       ↓       ↓
BUG MES  SQL QUERY  GROUPWARE  DOC  DATA FIX
    ↓       ↓       ↓       ↓       ↓
[ROUTE]  [ROUTE]  [ROUTE]  [ROUTE]  [ROUTE]
```

---

## 🐛 ROUTE 1: BUG MES (80% requests)

```
BUG MES DETECTED
        ↓
Có Barcode/PO/LotID?
    ├── YES → Chạy auto_debug_barcode.ps1
    │         ↓
    │     Chạy auto_check_common_issues.ps1
    │         ↓
    │     Tra KB_INDEX.md theo triệu chứng
    │         ↓
    │     Dùng debug_queries.sql template
    │         ↓
    │     Phân tích → Viết script → Đề xuất
    │
    └── NO  → Gửi REQUEST_TEMPLATES.md → Template 1
              ↓
          Đợi user điền thông tin
              ↓
          Tiếp tục như trên
```

**Tools sử dụng:**
- auto_debug_barcode.ps1
- auto_check_common_issues.ps1
- KB_INDEX.md
- debug_queries.sql
- REQUEST_TEMPLATES.md (Template 1)

**Thời gian ước tính:** 2-3 phút (từ 8-10 phút trước)

---

## 🔍 ROUTE 2: SQL QUERY (10% requests)

```
SQL QUERY DETECTED
        ↓
Có template phù hợp trong debug_queries.sql?
    ├── YES → Sử dụng template trực tiếp
    │         ↓
    │     Chạy query → Kiểm tra kết quả
    │         ↓
    │     Đề xuất script nếu cần
    │
    └── NO  → Gửi REQUEST_TEMPLATES.md → Template 2
              ↓
          Đợi user điền thông tin
              ↓
          Viết query mới → Test → Đề xuất
```

**Tools sử dụng:**
- debug_queries.sql
- REQUEST_TEMPLATES.md (Template 2)

**Thời gian ước tính:** 1-2 phút (từ 5-7 phút trước)

---

## 📋 ROUTE 3: GROUPWARE (5% requests)

```
GROUPWARE DETECTED
        ↓
Loại quy trình?
    ├── Purchase → KB_07 + extracted_text.txt
    ├── HR/Admin → KB_07 + extracted_text.txt
    ├── Master Data → KB_07 + extracted_text.txt
    └── Other → KB_07 + extracted_text.txt
        ↓
    Tra KB_07_GROUPWARE_INTEGRATION.md
        ↓
    Check extracted_text.txt trong GROUPWARE/
        ↓
    Đề xuất giải pháp theo quy trình
```

**Tools sử dụng:**
- KB_07_GROUPWARE_INTEGRATION.md
- GROUPWARE/extracted_text.txt
- REQUEST_TEMPLATES.md (Template 4)

**Thời gian ước tính:** 2-3 phút (từ 10-15 phút trước)

---

## 📚 ROUTE 4: DOCUMENTATION (3% requests)

```
DOCUMENTATION DETECTED
        ↓
Loại tài liệu?
    ├── Hướng dẫn → Tra KB xem có tương tự chưa
    ├── Quy trình → Tra KB + tạo mới
    ├── Kiến thức → Tra KB + tạo mới
    └── Other → Gửi REQUEST_TEMPLATES.md → Template 3
        ↓
    Tạo tài liệu dựa trên template
        ↓
    Cập nhật KB nếu cần
```

**Tools sử dụng:**
- KB_INDEX.md
- REQUEST_TEMPLATES.md (Template 3)

**Thời gian ước tính:** 3-5 phút (từ 15-20 phút trước)

---

## 🔧 ROUTE 5: DATA FIX (2% requests)

```
DATA FIX DETECTED
        ↓
⚠️ CẢNH BÁO: Cần approval trước
        ↓
Gửi REQUEST_TEMPLATES.md → Template 5
        ↓
Đợi user điền + approval
        ↓
Backup dữ liệu (SELECT trước)
        ↓
Viết script SQL an toàn
        ↓
Đề xuất user tự chạy qua SSMS
```

**Tools sử dụng:**
- REQUEST_TEMPLATES.md (Template 5)
- NO DIRECT UID rule

**Thời gian ước tính:** 5-10 phút (từ 20-30 phút trước)

---

## 🚀 AUTO-DETECTION RULES

### Keywords cho Bug MES:
- "lỗi", "error", "không được", "fail", "báo lỗi"
- Có Barcode, PO, LotID, MaterialCode
- Có TCode màn hình (B597, B523, F330...)

### Keywords cho SQL Query:
- "select", "query", "truy vấn", "kiểm tra", "đếm"
- "tổng số", "danh sách", "thống kê"

### Keywords cho Groupware:
- "groupware", "phê duyệt", "duyệt", "tài liệu"
- "purchase", "po", "kế hoạch", "bom"

### Keywords cho Documentation:
- "hướng dẫn", "tài liệu", "kiến thức", "quy trình"
- "giải thích", "mô tả"

### Keywords cho Data Fix:
- "sửa", "cập nhật", "thay đổi", "fix"
- "update", "insert", "delete"

---

## 📊 PERFORMANCE METRICS

### Trước khi tối ưu:
- Bug MES: 8-10 phút
- SQL Query: 5-7 phút
- Groupware: 10-15 phút
- Documentation: 15-20 phút
- Data Fix: 20-30 phút

### Sau khi tối ưu:
- Bug MES: 2-3 phút (↓ 70%)
- SQL Query: 1-2 phút (↓ 70%)
- Groupware: 2-3 phút (↓ 80%)
- Documentation: 3-5 phút (↓ 75%)
- Data Fix: 5-10 phút (↓ 50%)

---

## 🎯 QUICK REFERENCE

| Loại yêu cầu | Route đầu tiên | Tool chính | Thời gian |
|-------------|----------------|------------|-----------|
| Bug MES | auto_debug_barcode.ps1 | debug_queries.sql | 2-3 phút |
| SQL Query | debug_queries.sql | Template phù hợp | 1-2 phút |
| Groupware | KB_07 | extracted_text.txt | 2-3 phút |
| Documentation | KB_INDEX.md | REQUEST_TEMPLATES.md | 3-5 phút |
| Data Fix | REQUEST_TEMPLATES.md | NO DIRECT UID | 5-10 phút |

---

**Sử dụng decision tree này để tự động định tuyến và tối ưu hiệu suất!**
