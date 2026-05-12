# AGENTS.md - Hướng Dẫn Cho AI Khi Debug Lỗi Vinatech MES

## 🏢 Thông Tin Hệ Thống

| Thông tin | Giá trị |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database** | `SmartFactoryV2` |
| **Framework DB** | `SmartFramework` |
| **Username** | `vinaadmin` |
| **Platform** | NAIS / SmartFramework by Awoo |
| **Nhà máy** | VVT (Bắc Giang), VNT (Bắc Ninh), HN (Hà Nam) |

---

## 🎯 Mục Tiêu Khi Nhận Bug Từ User

Khi User gửi bug report, thực hiện theo quy trình sau:

### Bước 1: Tiếp Nhận & Phân Loại
- [ ] Xác định màn hình/TCode (B597, B523, F330, HN523...)
- [ ] Xác định thao tác gây lỗi (scan, save, gộp box, in tem...)
- [ ] Thu thập: Barcode/ControlNo, LotID, MaterialDocNo, PONo
- [ ] Xác định thời điểm xảy ra (ngày/giờ để lọc log)

### Bước 2: Tra Cứu KB
- [ ] **Ưu tiên tra KB_INDEX.md trước** - tìm KB phù hợp theo triệu chứng
- [ ] Nếu chưa có trong KB → dùng DataFlow.md để hiểu flow
- [ ] Kiểm tra KB_05_TRACE_BUG_METHODOLOGY.md cho methodology

### Bước 3: Phân Tích & Query
- [ ] Viết SQL query để xác minh trạng thái dữ liệu
- [ ] **Luôn SELECT trước** khi đề xuất UPDATE/DELETE
- [ ] Sử dụng template trong `debug_queries.sql` khi phù hợp

### Bước 4: Đề Xuất Giải Pháp
- [ ] Đưa ra script SQL đề xuất (User tự chạy)
- [ ] Không bao giờ tự ý chạy I/U/D trên production
- [ ] Ghi rõ: WHERE clause, backup trước khi sửa

### Bước 5: Cập Nhật KB (nếu cần)
- [ ] Nếu bug mới → note lại vào KB phù hợp
- [ ] Cập nhật ZALO_MES_MASTER_TASKS.md nếu là task từ Zalo

---

## 🔴 Quy Tắc Vàng (BẮT BUỘC)

1. **KHÔNG bao giờ chạy INSERT/UPDATE/DELETE trực tiếp** trên production database
2. **LUÔN SELECT trước** để xem dữ liệu hiện tại
3. **Backup bằng SELECT** trước khi đề xuất sửa
4. **Knowledge First** - tra KB trước khi suy đoán
5. **Fetch SP mới nhất** bằng `fetch_sp.ps1` trước khi phân tích code SP
6. **Hỏi đầy đủ thông tin** nếu user không cung cấp đủ (Barcode, TCode, thời gian)

---

## 📋 Template Bug Report Chuẩn

Khi User gửi bug, cần có:

```
1. Màn hình/TCode: [B597/B523/F330/HN523...]
2. Thao tác: [bấm nút gì / scan gì / lưu gì]
3. Mã đối tượng: [Barcode / ControlNo / LotID / MaterialDocNo / PONo]
4. Thời điểm: [ngày/giờ xảy ra]
5. Thông báo lỗi: [copy text hoặc ảnh chụp]
6. Môi trường: [production / test]
```

---

## 🗂️ Quick Reference - Triệu Chứng → KB

| Triệu chứng | Đọc KB |
|-------------|--------|
| Không đăng nhập được | KB_01 |
| Sửa ngày JobDate | KB_03 |
| Kho nhập sai Warehouse | KB_02 |
| Lot không in tem được / Part No sai | KB_04 |
| B597 báo lỗi chuỗi điện cực | KB_05 |
| Model mới không hiện Vol/Farad | KB_06 |
| Cần in tem khẩn không có Lot | KB_06 |
| Không tìm thấy Lot ở C512 | KB_05 |
| Giá lên B682/B781 | KB_01 |
| Slitting chiều rộng B552 | KB_05 |

---

## 🔧 Công Cụ Có Sẵn

| File | Mục đích |
|------|----------|
| `debug_queries.sql` | 20+ SQL template debug thông dụng |
| `fetch_sp.ps1` | Lấy source code SP từ DB |
| `Vinatech_MES_Complete_DataFlow.md` | Toàn bộ kiến trúc & data flow |
| `KB_05_TRACE_BUG_METHODOLOGY.md` | Quy trình trace 5 bước |
| `SOLO_CONTEXT_OVERVIEW.md` | Map tổng quan |

---

## ⚡ Common Queries Sẵn Sàng

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

---

## 📞 Khi Cần Fetch SP Mới

Nếu cần xem source code của SP:

```powershell
# Cách 1: Fetch 1 SP cụ thể
.\fetch_sp.ps1 -SPName "usp_DoProcessProdRouteHist"

# Cách 2: Fetch nhiều SP cùng lúc
# Sửa $SPList trong script rồi chạy
.\fetch_sp.ps1
```

---

## 📝 Ghi Chú Quan Trọng

- [ ] **STB_BaseCode, STB_ConstCodeInfo, STB_MaterialHoldInfo** không tồn tại trong SmartFactoryV2
- [ ] HOLD logic dùng `MaterialWarehouseCode = 'HOLDING%'` thay vì bảng riêng
- [ ] FIFO validation nằm trong SP, không phải cột trong MaterialMaster
- [ ] Route prefix: VNT = E-xx, VVT = V-xx, HN = VE-xx

---

**Cập nhật:** 2026-05-12
**Mục đích:** Hướng dẫn AI debug hiệu quả với Vinatech MES