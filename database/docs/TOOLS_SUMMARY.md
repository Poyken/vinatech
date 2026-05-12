# 🛠️ TOOLS SUMMARY - CÔNG CỤ SẴN SÀNG CHO MES/Groupware

> **Mục đích:** Tổng hợp tất cả công cụ có sẵn để làm việc hiệu quả
> **Cập nhật:** 2026-05-12

---

## 📚 DOCUMENTATION

### Core Guides
- **MES_QUICK_START_GUIDE.md** - Hướng dẫn nhanh cho AI assistant khi nhận yêu cầu
- **AGENTS.md** - Hướng dẫn AI debug lỗi Vinatech MES
- **REQUEST_TEMPLATES.md** - Template chuẩn cho các loại yêu cầu

### Knowledge Base (MES_MASTER_KNOWLEDGE_BASE/)
- **KB_INDEX.md** - Index tra cứu KB theo triệu chứng
- **KB_01_UI_PHAN_QUYEN.md** - UI/Đăng nhập/Phân quyền/Stage Prices
- **KB_02_KHO_WMS.md** - Kho nguyên vật liệu
- **KB_03_SAN_XUAT.md** - Sản xuất & Lịch sử Routing
- **KB_04_DONG_GOI_IN_TEM.md** - Đóng gói & In tem
- **KB_05_QC_ELECTRODE.md** - Kiểm tra chất lượng & Điện cực
- **KB_06_MASTER_DATA_TOOLS.md** - Master Data, SQL Tools
- **KB_07_GROUPWARE_INTEGRATION.md** - Groupware & MES Integration
- **KB_05_TRACE_BUG_METHODOLOGY.md** - Phương pháp trace bug 5 bước
- **Vinatech_MES_Complete_DataFlow.md** - Tổng quan kiến trúc MES (4000+ dòng)
- **ZALO_MES_MASTER_TASKS.md** - Danh sách nhiệm vụ từ Zalo

### Groupware Documentation (GROUPWARE/)
- **extracted_text.txt** - Nội dung extract từ 14 PPTX files
- Các file PPTX gốc: Draft Document, Finished Good warehouse, Form tuyển dụng, Form nghỉ việc, đi công tác, đăng ký nhà thầu, Yêu cầu mua, thanh toán, sửa BOM, tạo PO, đăng ký code, Purchase Manual

---

## 🔧 AUTOMATION SCRIPTS

### Database Scripts
- **debug_queries.sql** - 20+ SQL template debug thông dụng
- **fetch_sp.ps1** - Fetch Stored Procedure từ database
- **auto_debug_barcode.ps1** - Tự động debug barcode
- **auto_check_common_issues.ps1** - Tự động kiểm tra lỗi thường gặp

### Groupware Scripts
- **extract_pptx.ps1** - Extract text từ PPTX files

---

## 🎯 CÁCH SỬ DỤNG CÔNG CỤ

### Khi nhận yêu cầu Bug MES:
1. **Gửi REQUEST_TEMPLATES.md → Template 1** cho user điền
2. **Chạy auto_debug_barcode.ps1** với barcode
3. **Chạy auto_check_common_issues.ps1** kiểm tra nhanh
4. **Tra KB_INDEX.md** theo triệu chứng
5. **Dùng debug_queries.sql** template phù hợp
6. **Theo MES_QUICK_START_GUIDE.md** quy trình 5 bước

### Khi nhận yêu cầu SQL Query:
1. **Gửi REQUEST_TEMPLATES.md → Template 2** cho user điền
2. **Dùng debug_queries.sql** template tương ứng
3. **Chạy query** để kiểm tra kết quả
4. **Đề xuất script** cho user tự chạy

### Khi nhận yêu cầu Documentation:
1. **Gửi REQUEST_TEMPLATES.md → Template 3** cho user điền
2. **Tra KB** xem có tài liệu tương tự chưa
3. **Tạo tài liệu mới** dựa trên template
4. **Cập nhật KB** nếu cần

### Khi nhận yêu cầu Groupware:
1. **Gửi REQUEST_TEMPLATES.md → Template 4** cho user điền
2. **Tra KB_07_GROUPWARE_INTEGRATION.md**
3. **Check extracted_text.txt** trong GROUPWARE/
4. **Đề xuất giải pháp** theo quy trình

### Khi nhận yêu cầu Data Fix:
1. **Gửi REQUEST_TEMPLATES.md → Template 5** cho user điền
2. **Backup dữ liệu** trước khi sửa
3. **Viết script SQL** an toàn
4. **Đề xuất user tự chạy** qua SSMS

---

## 📋 QUICK REFERENCE

### Database Connection
```bash
sqlcmd -S "dbserver.hycap.co.kr,5398" -d "SmartFactoryV2" -U "vinaadmin" -P "vina1234%6&8" -C
```

### Auto Debug Barcode
```powershell
.\auto_debug_barcode.ps1 -Barcode "VE260506-001"
```

### Auto Check Common Issues
```powershell
.\auto_check_common_issues.ps1 -Barcode "VE260506-001" -PONo "260428000011"
```

### Fetch SP
```powershell
.\fetch_sp.ps1 -SPName "usp_DoProcessProdRouteHist"
```

### Extract PPTX
```powershell
.\extract_pptx.ps1
```

---

## ⚠️ QUY TẮC QUAN TRỌNG

1. **NO DIRECT UID** - Không tự ý run UPDATE/INSERT/DELETE
2. **SELECT TRƯỚC** - Luôn kiểm tra dữ liệu trước khi sửa
3. **KNOWLEDGE FIRST** - Tra KB trước khi suy đoán
4. **FETCH SP MỚI** - Lấy SP mới nhất trước khi phân tích
5. **HỎI ĐẦY ĐỦ** - Thu thập đủ thông tin trước khi làm
6. **TEMPLATE CHUẨN** - Sử dụng template để giảm back-and-forth

---

## 🎯 TRIỆU CHỨNG → KB

| Triệu chứng | KB | Tool |
|-------------|----|------|
| Không đăng nhập | KB_01 | auto_check_common_issues.ps1 |
| Sửa JobDate | KB_03 | debug_queries.sql #3 |
| Kho sai | KB_02 | debug_queries.sql #9 |
| Lot không in tem | KB_04 | debug_queries.sql #11 |
| B597 lỗi điện cực | KB_05 | debug_queries.sql #7 |
| Model mới không Vol/Farad | KB_06 | auto_check_common_issues.ps1 |
| Groupware integration | KB_07 | extracted_text.txt |

---

## 📞 KHI CẦN HỖ TRỢ

Nếu không tìm thấy giải pháp:
1. **Debug database** với debug_queries.sql
2. **Trace theo KB_05_TRACE_BUG_METHODOLOGY**
3. **Phân tích SP logic** nếu cần
4. **Đề xuất giải pháp** cho user duyệt

---

**Tất cả công cụ đã sẵn sàng! Sử dụng hiệu quả để làm việc nhanh hơn.**
