# 🤖 AI CONFIGURATION - RULES FOR OPTIMAL PERFORMANCE

> **Mục đích:** Cấu hình AI để làm việc hiệu quả nhất với structure mới
> **Cập nhật:** 2026-05-12
> **Quy tắc cốt lõi:** NO DIRECT UID, Database là nguồn sự thật duy nhất

---

## 📁 STRUCTURE RULES

### 1. File Access Priority
```
Priority 1: README.md (Entry point)
Priority 2: docs/OPTIMIZED_QUICK_REFERENCE.md (Quick access)
Priority 3: docs/MASTER_DECISION_TREE.md (Decision routing)
Priority 4: docs/TOP_10_COMMON_ERRORS.md (Common errors)
Priority 5: scripts/ (Automation)
Priority 6: sql/debug_queries.sql (SQL templates)
Priority 7: MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md (KB lookup)
Priority 8: GROUPWARE/extracted_text.txt (Groupware docs)
```

### 2. File Location Rules
- **Documentation:** Luôn nằm trong `docs/`
- **Scripts:** Luôn nằm trong `scripts/`
- **SQL:** Luôn nằm trong `sql/`
- **KB:** Luôn nằm trong `MES_MASTER_KNOWLEDGE_BASE/`
- **Groupware:** Luôn nằm trong `GROUPWARE/`

---

## 🎯 WORKFLOW RULES

### Step 1: Receive Request
```
INPUT: User request
ACTION: 
1. Đọc README.md để hiểu structure
2. Đọc docs/OPTIMIZED_QUICK_REFERENCE.md cho quick access
3. Sử dụng docs/MASTER_DECISION_TREE.md để định tuyến
```

### Step 2: Route Request
```
ACTION:
1. Sử dụng docs/INTELLIGENT_ROUTING.md để auto-detect
2. Xác định route: BUG_MES / SQL_QUERY / GROUPWARE / DOCUMENTATION / DATA_FIX
3. Chọn tools tương ứng
```

### Step 3: Execute
```
BUG_MES:
- Chạy scripts/auto_debug_barcode.ps1
- Chạy scripts/auto_check_common_issues.ps1
- Tra MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md
- Dùng sql/debug_queries.sql template

SQL_QUERY:
- Dùng sql/debug_queries.sql template
- Chạy query kiểm tra kết quả

GROUPWARE:
- Đọc MES_MASTER_KNOWLEDGE_BASE/KB_07_GROUPWARE_INTEGRATION.md
- Check GROUPWARE/extracted_text.txt

DOCUMENTATION:
- Tra MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md
- Đọc docs/ tương ứng

DATA_FIX:
- Gửi docs/REQUEST_TEMPLATES.md → Template 5
- TUÂN THỦ NO DIRECT UID
```

### Step 4: Propose Solution
```
ACTION:
1. Viết script SQL (SELECT trước)
2. Đề xuất user tự chạy qua SSMS
3. TUÂN THỦ NO DIRECT UID
```

---

## ⚡ PERFORMANCE RULES

### Time Limits
- **Route identification:** < 1 second
- **Bug MES debugging:** < 3 minutes
- **SQL query:** < 2 minutes
- **Groupware issue:** < 3 minutes
- **Top 10 errors:** < 2 minutes

### Accuracy Requirements
- **Route detection accuracy:** > 95%
- **SQL query correctness:** 100% (verify với database)
- **KB lookup accuracy:** > 90%

### Optimization Rules
1. Luôn dùng scripts/ automation trước khi manual
2. Luôn tra docs/TOP_10_COMMON_ERRORS.md trước khi deep dive
3. Luôn dùng sql/debug_queries.sql template trước khi viết mới
4. Luôn backup bằng SELECT trước UPDATE/DELETE

---

## 🔒 SAFETY RULES

### NO DIRECT UID (CRITICAL)
```
TUYỆT ĐỐI KHÔNG:
- Chạy UPDATE/INSERT/DELETE trực tiếp
- Tự ý thay đổi dữ liệu production

CHỈ ĐƯỢC:
- Tìm phương án giải quyết
- Viết script (Fix script)
- Đề xuất cho User
- User tự quyết định và chạy tay qua SSMS
```

### Database Rules
```
1. Database là nguồn sự thật duy nhất
2. Mọi kết luận phải verify bằng SELECT
3. Luôn backup bằng SELECT trước UPDATE/DELETE
4. Luôn tra KB trước khi suy đoán
```

---

## 📚 KNOWLEDGE RULES

### KB Lookup Rules
```
1. Luôn tra MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md trước
2. Sử dụng triệu chứng để tìm KB tương ứng
3. Đọc KB file đầy đủ trước khi đề xuất giải pháp
4. Nếu không tìm thấy → Debug database với sql/debug_queries.sql
```

### Documentation Rules
```
1. Luôn đọc docs/MES_QUICK_START_GUIDE.md khi nhận yêu cầu mới
2. Sử dụng docs/OPTIMIZED_QUICK_REFERENCE.md cho quick access
3. Tra docs/MASTER_DECISION_TREE.md cho decision routing
4. Check docs/TOP_10_COMMON_ERRORS.md cho common errors
```

---

## 🛠️ TOOL USAGE RULES

### Script Usage
```
scripts/auto_debug_barcode.ps1:
- Sử dụng khi có Barcode
- Chạy đầu tiên khi debug Bug MES

scripts/auto_check_common_issues.ps1:
- Sử dụng khi cần check nhanh
- Chạy sau auto_debug_barcode.ps1

scripts/PERFORMANCE_METRICS.ps1:
- Sử dụng khi cần track performance
- Chạy để optimize scripts

scripts/extract_pptx.ps1:
- Sử dụng khi cần extract PPTX
- Chạy khi có file PPTX mới

scripts/fetch_sp.ps1:
- Sử dụng khi cần xem SP code
- Chạy khi cần phân tích SP logic
```

### SQL Usage
```
sql/debug_queries.sql:
- Luôn dùng template trước khi viết mới
- Sử dụng Golden Query (#1) cho trace đầy đủ
- Sử dụng template tương ứng theo nhu cầu
```

---

## 🎯 DECISION RULES

### When to Use Which Tool
```
Có Barcode → scripts/auto_debug_barcode.ps1
Có PO/LotID → scripts/auto_check_common_issues.ps1
Cần SQL → sql/debug_queries.sql
Cần KB → MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md
Cần Groupware → GROUPWARE/extracted_text.txt
Cần quick access → docs/OPTIMIZED_QUICK_REFERENCE.md
Cần routing → docs/MASTER_DECISION_TREE.md
Common error → docs/TOP_10_COMMON_ERRORS.md
```

### When to Ask User
```
1. Thông tin không đầy đủ → Gửi docs/REQUEST_TEMPLATES.md
2. Yêu cầu Data Fix → Gửi docs/REQUEST_TEMPLATES.md → Template 5
3. Không tìm thấy giải pháp trong KB → Hỏi user thêm thông tin
4. Cần approval cho IUD → Yêu cầu user approval trước
```

---

## 📊 METRICS RULES

### Track Performance
```
1. Sử dụng scripts/PERFORMANCE_METRICS.ps1 để track
2. Monitor time cho từng task
3. Optimize nếu time > limit
```

### Report Performance
```
1. Report performance nếu > limit
2. Đề xuất optimization nếu cần
3. Update docs/OPTIMIZED_QUICK_REFERENCE.md với metrics mới
```

---

## 🔄 UPDATE RULES

### When to Update Files
```
1. Tìm bug mới → Cập nhật docs/TOP_10_COMMON_ERRORS.md
2. Tạo script mới → Thêm vào scripts/
3. Tạo SQL mới → Thêm vào sql/debug_queries.sql
4. Tạo KB mới → Thêm vào MES_MASTER_KNOWLEDGE_BASE/
5. Cải tiến workflow → Cập nhật docs/MASTER_DECISION_TREE.md
```

### Update Process
```
1. Đánh giá impact
2. Update file tương ứng
3. Cập nhật README.md nếu cần
4. Cập nhật docs/OPTIMIZED_QUICK_REFERENCE.md
```

---

## 🎯 SUCCESS CRITERIA

### Performance Criteria
- Route identification: < 1 second (85x faster than before)
- Bug MES debugging: < 3 minutes (70% faster)
- SQL query: < 2 minutes (70% faster)
- Groupware issue: < 3 minutes (80% faster)
- Top 10 errors: < 2 minutes (80% faster)

### Quality Criteria
- Route detection accuracy: > 95%
- SQL query correctness: 100%
- KB lookup accuracy: > 90%
- NO DIRECT UID compliance: 100%

---

## 🚀 EMERGENCY PROCEDURES

### When Stuck
```
1. Đọc docs/OPTIMIZED_QUICK_REFERENCE.md
2. Check docs/TOP_10_COMMON_ERRORS.md
3. Tra MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md
4. Chạy scripts/auto_debug_barcode.ps1
5. Hỏi user clarification
```

### When Error Occurs
```
1. Stop immediately
2. Report error to user
3. Propose alternative solution
4. TUÂN THỦ NO DIRECT UID
```

---

**AI đã cấu hình để hoạt động tối ưu với structure mới!**

---

## 🏢 THÔNG TIN HỆ THỐNG (SYSTEM INFO)

| Thông tin | Giá trị |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database** | `SmartFactoryV2` |
| **Framework DB** | `SmartFramework` |
| **Username** | `vinaadmin` |
| **Platform** | NAIS / SmartFramework by Awoo |
| **Nhà máy** | VVT_F1 = Bắc Ninh, VVT_F2 = Bắc Giang, VVT_F3 = Hà Nam, VVT_F4 = Bắc Giang 2 |

---

## ⚡ COMMON QUERIES SẴN SÀNG (TỪ AGENTS)

Khi cần debug nhanh:

```sql
-- 1. Golden Query - full traceability
-- → Dùng template #1 trong debug_queries.sql

-- 2. Check HOLD/Expiry
-- → Dùng template #3 trong debug_queries.sql

-- 3. Check FIFO (Lot nào đang chặn)
-- → Dùng template #4 trong debug_queries.sql

-- 4. Check NVL scan tại V-23/V-24
-- → Dùng template #5 trong debug_queries.sql

-- 5. Check QC status
-- → Dùng template #6 trong debug_queries.sql
```
