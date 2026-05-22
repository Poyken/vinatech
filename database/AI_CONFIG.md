# 🤖 AI CONFIGURATION - VINATECH MES & GROUPWARE

> **Mục đích:** Quy tắc vận hành AI để làm việc hiệu quả nhất
> **Cập nhật:** 2026-05-22
> **Quy tắc cốt lõi:** NO DIRECT UID — Database là nguồn sự thật duy nhất

---

## 📁 THỨ TỰ ƯU TIÊN ĐỌC FILE

```
1. README.md                                    → Entry point, hiểu structure
2. MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md        → Tra theo triệu chứng lỗi
3. MES_MASTER_KNOWLEDGE_BASE/KB_0X_...md        → File chuyên biệt theo nhóm
4. sql/debug_queries.sql                        → SQL templates debug
5. scripts/auto_debug_barcode.ps1               → Automation có barcode
6. scripts/auto_check_common_issues.ps1         → Automation check nhanh
7. GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md         → Khi liên quan Groupware
8. GROUPWARE/extracted_text_utf8.txt            → Raw text PPTX đào tạo
```

---

## 🎯 WORKFLOW XỬ LÝ YÊU CẦU

### Bước 1: Phân loại yêu cầu
| Loại | Dấu hiệu | Action |
|------|----------|--------|
| **BUG_MES** | Barcode, màn hình BX/CX/FX/HNX, lỗi in tem | → KB_INDEX + scripts |
| **SQL_QUERY** | Cần truy vấn, xem dữ liệu, báo cáo | → sql/debug_queries.sql |
| **DATA_FIX** | Sửa dữ liệu sai, xóa record | → SELECT trước, đề xuất IUD script |
| **GROUPWARE** | Mua hàng, kế hoạch, hành chính, thanh toán | → GW_INDEX |
| **MASTER_DATA** | Thêm model, cell, line, user | → KB_06 |

### Bước 2: Thực thi
```
BUG_MES:
  → scripts/auto_debug_barcode.ps1 -Barcode "xxx"
  → scripts/auto_check_common_issues.ps1 -Barcode "xxx"
  → MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md (tra theo triệu chứng)
  → sql/debug_queries.sql (template phù hợp)

SQL_QUERY:
  → sql/debug_queries.sql (chọn template)
  → Viết query, verify kết quả

DATA_FIX:
  → SELECT để đếm rows bị ảnh hưởng
  → Viết script với BEGIN TRAN ... ROLLBACK để xem trước
  → Đề xuất user tự chạy qua SSMS
  → TUÂN THỦ NO DIRECT UID

GROUPWARE:
  → GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md
  → Đọc GW_0X file chuyên biệt

MASTER_DATA:
  → KB_06_MASTER_DATA_TOOLS.md
```

### Bước 3: Đề xuất giải pháp
```
1. Viết script SQL rõ ràng (SELECT trước → IUD sau)
2. Dùng BEGIN TRAN / ROLLBACK để xem trước kết quả
3. Đề xuất user tự chạy qua SSMS
4. KHÔNG tự ý execute UPDATE/INSERT/DELETE
```

---

## 🔒 SAFETY RULES (BẮT BUỘC)

### NO DIRECT UID (CRITICAL)
```
TUYỆT ĐỐI KHÔNG:
  ❌ Chạy UPDATE/INSERT/DELETE trực tiếp
  ❌ Tự ý thay đổi dữ liệu production

CHỈ ĐƯỢC:
  ✅ Viết Fix Script và đề xuất
  ✅ Chạy SELECT để kiểm tra
  ✅ User tự quyết định và chạy qua SSMS
```

### Database Rules
```
1. Luôn SELECT trước → đếm rows bị ảnh hưởng
2. Dùng BEGIN TRAN ... ROLLBACK/COMMIT (xem kết quả trước)
3. Luôn dùng PK (ID cụ thể) trong WHERE
4. Sửa đồng bộ đủ bảng → thiếu 1 bảng gây lệch dữ liệu
5. Ghi log tất cả thay đổi để audit
```

---

## ⚡ PERFORMANCE TARGETS

| Task | Target |
|------|--------|
| Phân loại yêu cầu | < 1 giây |
| Debug Bug MES | < 3 phút |
| Viết SQL query | < 2 phút |
| Xử lý Groupware | < 3 phút |

---

## 🔧 THÔNG TIN HỆ THỐNG

| Thông tin | Giá trị |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database** | `SmartFactoryV2` |
| **Framework DB** | `SmartFramework` |
| **Username** | `vinaadmin` |
| **Platform** | NAIS / SmartFramework by Awoo |
| **Nhà máy** | VVT_F1=Bắc Ninh, VVT_F2=Bắc Giang, VVT_F3=Hà Nam, VVT_F4=Bắc Giang 2 |

---

## 🛠️ KHI BỊ KẸT

```
1. Tra MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md theo triệu chứng
2. Chạy scripts/auto_debug_barcode.ps1
3. Dùng sql/debug_queries.sql Golden Query (#1) để full trace
4. Đọc sp_output/ SP liên quan để hiểu logic
5. Hỏi user clarification nếu vẫn chưa rõ
```

---

## 📊 CÁC QUERY THƯỜNG DÙNG

```sql
-- 1. Full Trace theo Barcode (Golden Query)
--    → Template #1 trong sql/debug_queries.sql

-- 2. Check HOLD / Hạn dùng
--    → Template #3 trong sql/debug_queries.sql

-- 3. Check FIFO (Lot nào đang chặn)
--    → Template #4 trong sql/debug_queries.sql

-- 4. Check NVL scan tại V-23/V-24
--    → Template #5 trong sql/debug_queries.sql

-- 5. Check QC status B597
--    → Template #6 trong sql/debug_queries.sql
```
