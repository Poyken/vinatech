# KB_07 — Groupware & MES Integration

> **Màn hình liên quan:** Groupware (gw.vinatech.com), F330, C220, B310, B450, A230, A310
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Hệ thống Groupware là nơi phê duyệt các quy trình **Mua Hàng**, **Kế Hoạch Sản Xuất** và **Master Data** trước khi dữ liệu được đồng bộ xuống MES và ERP.

---

## 2. Luồng Mua Hàng & Nhập Kho (Purchase Flow)

```
1. Purchase Order Registration (Groupware) → Khởi tạo đơn đặt hàng → đẩy xuống ERP
2. Arrival Confirmation (Groupware) → Khai báo hàng về đến công ty
   (Hàng nhập khẩu: khai báo B/L và thông tin hải quan)
3. F330 (MES) → Thủ kho nhận hàng thực tế + in tem nhãn
4. C220 (MES) → QC kiểm tra chất lượng → PASS IQC
5. Receiving Confirmation (Groupware) → Ghi nhận tồn kho vào ERP và MES
6. Purchase Resolution (Groupware) → Đóng sổ, thanh toán Vendor
```

**Debug nhanh:**
- Không nhập được F330 → Groupware chưa duyệt **Arrival Confirmation**?
- Không làm được Receiving Confirmation → C220 chưa PASS?

```sql
-- Kiểm tra trạng thái IQC của lô hàng
SELECT * FROM STB_MaterialQcInfo WHERE MaterialDocNo = 'Số_Tài_Liệu'
-- Nếu chưa có record hoặc QcResult != 'PASS' → QC chưa làm C220
```

---

## 3. Luồng Kế Hoạch Sản Xuất (PO & Production Plan)

```
Month Production Plan (Groupware)
    → Đăng ký PO theo tháng
    → BOM Version: 2001 (áp dụng cho Việt Nam)
    → Trạng thái: "Sản xuất" để xác nhận
    ↓
B310 (MES) → Thông tin PO được link xuống
    ↓
B450 (MES) → Kế hoạch theo ngày → Tạo LOT sản xuất + in tem
```

**Debug nhanh:**
- Không thấy PO trên MES (B310/B450) → Kiểm tra Groupware:
  - Đã "Xác nhận lô hàng" (chuyển sang Sản xuất) chưa?
  - BOM Version có đúng `2001` không?

```sql
-- Kiểm tra PO đã có trên MES chưa
SELECT PONo, MaterialCode, CompanyCode, PlanQty, CreateDateTime
FROM STB_ProductionOrderInfo
WHERE MaterialCode = 'Mã_Model' AND MONTH(CreateDateTime) = MONTH(GETDATE())
ORDER BY CreateDateTime DESC
```

---

## 4. Master Data (Đăng Ký Code & BOM)

**Luồng đăng ký mã vật tư mới:**
```
Item Registration Document (Groupware)
    → Loại: Cell / Module / Raw material
    → Sau khi duyệt → sync xuống A230 (STB_MaterialMaster)
    ↓
A230 (MES) → Kiểm tra mã đã sync chưa
A310 (MES) → Kiểm tra BOM đã sync chưa
```

**Đăng ký/cập nhật BOM:**
```
EBOM (ERP) → Khởi tạo BOM version, thêm NVL, định lượng
    ↓
BOM Addition & Update (Groupware) → Gửi duyệt thay đổi BOM
    → Sau khi duyệt → BOM có hiệu lực
    ↓
A310 (MES) → Kiểm tra BOM đã cập nhật chưa
```

```sql
-- Kiểm tra BOM của model trên MES
SELECT BH.BomHeaderNo, BH.MaterialCode, BH.BomVersion,
       BD.ChildMaterialCode, BD.Qty, BD.Unit, BD.RouteCode
FROM STB_BomHeader BH
JOIN STB_BomDetail BD ON BH.BomHeaderNo = BD.BomHeaderNo
WHERE BH.MaterialCode = 'Mã_Model'
ORDER BY BD.RouteCode, BD.ChildMaterialCode
```

---

## 5. Hành Chính & Nhân Sự

| Document | Mục đích | Lưu ý |
|----------|----------|-------|
| **Business Trip Document** | Đi công tác trong/ngoài nước | Phải làm **Business Trip Report** sau khi về để thanh toán |
| **Holiday Work Request** | Đăng ký đi làm ngày lễ/nghỉ | — |
| **Emp Request / Employee Retire** | Tuyển dụng / Nghỉ việc | — |
| **Draft Document** | Trình ký văn bản nội bộ | — |
| **Disbursement Document** | Yêu cầu thanh toán chi phí | Chọn đúng tài khoản VNĐ hoặc USD |
| **Partner Management** | Đăng ký Khách hàng / Nhà cung cấp mới | — |

---

## 6. Chỉ Định NCC ↔ NVL (F130 / F140)

**F130 — Từ 1 Nhà cung cấp, chỉ định được cung cấp những NVL nào:**
1. Tìm kiếm nhà cung cấp (trái) → Click chọn NCC
2. Bên phải hiển thị danh sách NVL
3. **Tick vào ô "Sử dụng"** cho từng NVL được phép → Lưu

**F140 — Từ 1 Vật liệu, chỉ định có thể mua từ những NCC nào:**
1. Tìm kiếm NVL (trái) → Click chọn NVL
2. Bên phải hiển thị danh sách NCC
3. **Tick vào ô "Sử dụng"** cho từng NCC được phép → Lưu

> **Tác động:** F130/F140 ảnh hưởng đến popup chọn NCC khi tạo tài liệu nhập kho ở F312.

```sql
-- Kiểm tra NCC nào được phép cung cấp NVL này
SELECT * FROM STB_MaterialVendorMapping
WHERE MaterialCode = 'Mã_NVL' AND IsUsed = 1

-- Thêm mapping mới (nếu cần)
INSERT INTO STB_MaterialVendorMapping (MaterialCode, VendorCode, IsUsed, CreateDateTime, CreateUserID)
VALUES ('Mã_NVL', 'Mã_NCC', 1, GETDATE(), 'vinaadmin')
```



## 7. Luồng Master Data Chi Tiết (A210, F130/F140)

**A210 — Đăng ký mã vật tư mới:**
```
Item Registration Document (Groupware)
    → Loại: Cell / Module / Raw material
    → Điền đầy đủ thông tin: MaterialCode, MaterialName, Unit, MaterialTypeCode
    → Sau khi duyệt → sync xuống A230 (STB_MaterialMaster)
    ↓
A230 (MES) — Kiểm tra mã đã sync chưa
    ↓
F130/F140 — Chỉ định NCC được phép cung cấp NVL này
    ↓
F110 — Cấu hình thuộc tính kho (IsLotUse, IsUseBarcode)
    ↓
A310 — Kiểm tra BOM đã có NVL này chưa
```

**Kiểm tra mã vật tư đã sync từ Groupware:**
```sql
-- Kiểm tra mã vật tư trong MES
SELECT MaterialCode, MaterialName, MaterialTypeCode, Unit, CreateDateTime
FROM STB_MaterialMaster
WHERE MaterialCode = 'Mã_NVL_Mới'
ORDER BY CreateDateTime DESC

-- Nếu chưa có → Kiểm tra Groupware đã duyệt chưa
-- Nếu đã duyệt nhưng chưa sync → Liên hệ IT kiểm tra job sync
```
