# 🚀 MES QUICK START GUIDE - CHO AI ASSISTANT

> **Mục đích:** Hướng dẫn nhanh cho AI khi nhận yêu cầu từ user về MES/Groupware
> **Cập nhật:** 2026-05-12

---

## 🎯 QUY TRÌNH CHUẨN KHI NHẬN YÊU CẦU

### BƯỚC 1: PHÂN LOẠI YÊU CẦU
```
User gửi yêu cầu → Xác định loại:
├─ Bug MES (lỗi hệ thống)
├─ SQL Query (cần truy vấn dữ liệu)
├─ Documentation (cần tài liệu)
├─ Groupware (quy trình phê duyệt)
└─ Other (khác)
```

### BƯỚC 2: THU THẬP THÔNG TIN
**Thông tin cần có:**
- Màn hình/TCode (nếu có)
- Barcode/ControlNo/LotID/PONo
- Thời gian xảy ra
- Thông báo lỗi (nếu có)
- Mục tiêu yêu cầu

### BƯỚC 3: TRA CỨU KB
```
Theo triệu chứng → KB tương ứng:
├─ Login/Phân quyền → KB_01
├─ Kho/WMS → KB_02
├─ Sản xuất → KB_03
├─ Đóng gói → KB_04
├─ QC/Điện cực → KB_05
├─ Master Data → KB_06
└─ Groupware → KB_07
```

### BƯỚC 4: DEBUG DATABASE
```sql
-- Sử dụng template từ debug_queries.sql
-- Golden Query #1: Trace barcode
-- Template #2: Check SetInfo
-- Template #3: Check Holding
-- Template #4: Check FIFO
-- Template #5: Check NVL scan
-- Template #6: Check QC
```

### BƯỚC 5: ĐỀ XUẤT GIẢI PHÁP
- Viết script SQL (SELECT trước, IUD sau)
- Đề xuất user tự chạy qua SSMS
- TUÂN THỦ QUY TẮC NO DIRECT UID

---

## 🔧 CÔNG CỤ SẴN SÀNG

### Database Connection
```bash
sqlcmd -S "dbserver.hycap.co.kr,5398" -d "SmartFactoryV2" -U "vinaadmin" -P "vina1234%6&8" -C
```

### Debug Scripts
- `debug_queries.sql` - 20+ SQL template
- `fetch_sp.ps1` - Fetch SP từ DB

### Knowledge Base
- `MES_MASTER_KNOWLEDGE_BASE/` - 7 KB files
- `KB_05_TRACE_BUG_METHODOLOGY.md` - Quy trình trace 5 bước

---

## 📋 TEMPLATE YÊU CẦU CHUẨN

### Bug MES Template
```
1. Màn hình/TCode: [B597/B523/F330...]
2. Thao tác: [scan/lưu/gộp box...]
3. Mã đối tượng: [Barcode/ControlNo/LotID/PONo]
4. Thời điểm: [ngày/giờ]
5. Thông báo lỗi: [text hoặc ảnh]
6. Môi trường: [production/test]
```

### SQL Query Template
```
1. Mục tiêu: [cần truy vấn gì]
2. Bảng liên quan: [tên bảng]
3. Điều kiện lọc: [where clause]
4. Kết quả mong muốn: [format output]
```

---

## ⚠️ QUY TẮC BẮT BUỘC

1. **NO DIRECT UID** - Không tự ý run UPDATE/INSERT/DELETE
2. **SELECT TRƯỚC** - Luôn kiểm tra dữ liệu trước khi sửa
3. **KNOWLEDGE FIRST** - Tra KB trước khi suy đoán
4. **FETCH SP MỚI** - Lấy SP mới nhất trước khi phân tích
5. **HỎI ĐẦY ĐỦ** - Thu thập đủ thông tin trước khi làm

---

## 🎯 QUICK REFERENCE

### Triệu chứng → KB
| Triệu chứng | KB |
|-------------|----|
| Không đăng nhập | KB_01 |
| Sửa JobDate | KB_03 |
| Kho sai | KB_02 |
| Lot không in tem | KB_04 |
| B597 lỗi điện cực | KB_05 |
| Model mới không Vol/Farad | KB_06 |
| Groupware integration | KB_07 |

### Database Tables Quan Trọng
- `STB_SetInfo` - Barcode/Lot gốc
- `STB_ProdRouteHist` - Lịch sử công đoạn
- `STB_MaterialLotInfo` - Thông tin gộp Lot
- `STB_ProcedureLog` - Log hệ thống
- `STB_CommInspDocHistory` - QC history

---

## 📞 KHI CẦN HỖ TRỢ

Nếu không tìm thấy giải pháp trong KB:
1. Debug database với debug_queries.sql
2. Trace theo KB_05_TRACE_BUG_METHODOLOGY
3. Phân tích SP logic nếu cần
4. Đề xuất giải pháp cho user duyệt

---

**Hệ thống sẵn sàng làm việc với yêu cầu MES/Groupware!**
