# GW_07 — Kho Thành Phẩm (Finished Good Warehouse)

> **Màn hình MES liên quan:** FG01 (Xuất kho tạm), B750 (In tem pallet), B752 (Kiểm tra chi tiết)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 📤 Xuất Ra Kho Tạm / Trung Chuyển (FG01)

Chuỗi thao tác hiện trường tại kho vận sau khi hàng hóa ra lò từ trạm kế hoạch ngày:

### Bước 1: Vào menu "Xuất ra kho tạm" (FG01)

### Bước 2: Scan Packing ID
- Sử dụng súng bắn Barcode để quét dữ liệu thùng **Packing ID** của từng box cần xuất.

### Bước 3: Nhập khách hàng thực tế
- Tích hợp ID Khách mua hàng thực tế vào Container chứa lô hàng.

### Bước 4: Kiểm tra lại lần cuối → Nhấn **"Lưu dữ liệu"**
- Xác nhận luân chuyển trạng thái hàng sang "Xuất ra kho trung chuyển/ kho tạm".

---

## 2. 🏷️ In Tem Pallet (B750)

Sau khi lưu dữ liệu xuất ra kho tạm thành công trên FG01:

1. Di chuyển qua trạm **B750** trên MES.
2. Thực hiện lệnh: **In tem thông tin lô hàng**.
3. **Dán niêm phong lên cụm Pallet bốc xếp** đã bọc màng PE bảo vệ.

---

## 3. 🚛 Xuất Lên Xe / Container (Shipment)

- Nhấn vào menu lệnh **"Xuất lên công te lơ"** (hoặc Xe vận tải).
- Thực hiện bắn thẳng lệnh xuất theo kiện (Scan thùng/Pallet bốc lên xe) → Hệ thống tự động ghi nhận lượng xuất kho thực tế.

---

## 4. 🔍 Kiểm Tra Chi Tiết Pallet (B752)

- Khi bốc dỡ hàng lên xe hoàn tất, Kỹ sư/Thủ kho tiến hành kiểm kê tổng lượng Pallet trong lòng Container.
- Vào màn hình giám sát **B752** của MES để xem lưới chi tiết, đối chiếu số lượng thực tế bốc lên so với kế hoạch xuất kho.

---

## 5. 📋 Luồng Xuất Kho Thành Phẩm Đầy Đủ

```
[Kế hoạch ngày] Hàng hoàn tất đóng gói (B523)
     ↓
[FG01] Bắn Barcode scan Packing ID → Tích hợp ID Khách hàng → Lưu (Chuyển kho tạm/trung chuyển)
     ↓
[B750] In tem thông tin lô hàng → Dán Niêm Phong lên cụm Pallet
     ↓
[Xuất lên Container] Quét kiện xuất lên xe (Bắn thẳng lệnh xuất theo kiện)
     ↓
[B752] Giám sát chi tiết lưới Pallet thực xuất trong lòng Container
```

---

## 6. ❓ Lỗi Thường Gặp

| Tình huống | Nguyên nhân | Xử lý |
|-----------|-------------|-------|
| Không scan được Packing ID | Box chưa đóng gói hoàn chỉnh | Hoàn tất B523 trước |
| Không in được tem pallet | Chưa lưu FG01 thành công | Kiểm tra lại bước "Lưu dữ liệu" FG01 |
| Packing ID không xuất hiện | Box chưa vào kho tạm | Thực hiện FG01 trước |

---

*Cập nhật: 2026-05-25 | Nguồn: Hướng dẫn Finished Good warehouse.pptx + Comprehensive_Groupware_Report.md*
