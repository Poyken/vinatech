# 📖 Hướng Dẫn Vận Hành (SOP) — Thiết Lập Lô Xuất & In Tem Poka-Yoke Sanmina (B767_M & B767)

> **Mục đích:** Hướng dẫn vận hành 2 màn hình liên kết [B767_M] (Dành cho Quản lý / Leader) và [B767] (Dành cho Công nhân / OP) nhằm loại bỏ 100% lỗi nhầm lẫn thông tin tem xuất khẩu Sanmina.

---

## 🎯 1. Nguyên Tắc Vận Hành Hai Lớp

```
[B767_M: Thiết Lập Lô Xuất] (Leader/Admin)
       │ (1. Đăng ký PO, PartNo tùy biến, TotalBox -> Bấm KÍCH HOẠT)
       ▼
[STB_SanminaShipmentPlan] (Status = 'ACTIVE')
       │ (2. Tự động nạp thông tin & tính số thứ tự thùng)
       ▼
[B767: In Tem Sanmina] (Công nhân / OP)
       │ (3. Chỉ quét Barcode Lot -> Bấm In tem 1 chạm)
       ▼
[Tự động cập nhật tiến độ in] -> (Đủ số thùng -> Tự động COMPLETED)
```

---

## 👨‍💼 2. Hướng Dẫn Dành Cho Leader / Kế Hoạch (Màn hình [B767_M])

### Bước 1: Mở màn hình [B767_M]
- Đường dẫn menu: **Sản xuất (Production)** $\rightarrow$ **[B767_M] Thiết lập kế hoạch xuất Sanmina** (`VVT_SanminaShipmentPlan`).

### Bước 2: Tạo mới Lô xuất (Thêm kế hoạch)
1. Bấm nút **Thêm mới (New)**.
2. Nhập các thông tin lô xuất:
   * **PO Number:** Mã PO khách hàng Sanmina (VD: `PO-SANMINA-20260819-01`).
   * **Part Number:** Nhập hoặc chọn mã Part Number (Hệ thống hỗ trợ nhập tự do, không fix cứng; ví dụ `LFIBLM164855`, `LFIBE164855` hoặc bất kỳ mã linh kiện mới nào theo PO).
   * **Total Box (Tổng số thùng):** Số lượng thùng của lô (VD: `20`).
   * **Qty Per Box (SL/Thùng):** Mặc định 200 pcs (hoặc tùy biến theo quy cách đóng thùng).
   * **Ghi chú (Remark):** Tùy chọn.
3. Bấm **Lưu (Save)**. Kế hoạch được tạo với trạng thái `PENDING` (Chờ in).

### Bước 3: Kích hoạt Lô xuất đang in
- Chọn dòng Lô xuất vừa tạo $\rightarrow$ Bấm nút **Kích Hoạt (Activate)**.
- Trạng thái chuyển sang **`ACTIVE`** (Hệ thống tự động chuyển các lô active khác về `PENDING` để đảm bảo xưởng luôn in đúng 1 lô đang chỉ định).

---

## 👷 3. Hướng Dẫn Dành Cho Công Nhân / OP (Màn hình [B767])

### Bước 1: Mở màn hình [B767]
- Mở màn hình **[B767] In tem KH Sanmina India**.

### Bước 2: Quét mã và In tem (Zero Input / 1 Chạm)
1. Đặt con trỏ vào ô **Lot No (Barcode)**.
2. Dùng súng bắn mã vạch quét Barcode Lot thành phẩm đã đóng gói từ B523.
3. **Hệ thống tự động hoàn toàn:**
   * Tự nạp `PO Number` từ Lô xuất đang ACTIVE.
   * Tự nạp `Part Number` chính xác 100%.
   * Tự nhảy số thùng `CartonBoxNo` theo tiến độ thực tế (VD: `01/20`, `02/20`, `03/20`...).
4. Bấm **In Tem**: Máy in Zebra tự động in ra bộ nhãn gồm **1 tem Outer + 2 tem Inner** với mã QR Code và Serial tự tăng liên tục.
5. Tiến độ thùng tự động cộng dồn. Khi in đến thùng cuối cùng (`20/20`), hệ thống tự động hoàn tất Lô xuất.

---

## 🔄 4. Khả Năng Tương Thích & Tùy Biến (Dynamic & Backward Compatibility)

* **Không cố định mã linh kiện (Dynamic Part Number):** Người dùng có thể nhập bất kỳ mã Part Number hoặc PO Number nào mà không bị hệ thống chặn cứng.
* **Chế độ in tự do (Manual Mode):** Nếu xưởng có đơn hàng đặc thù không tạo Plan, OP vẫn có thể nhập tay PO Number và Part Number trực tiếp trên màn [B767] như quy trình truyền thống.

---

## 🛠️ 5. Bảng Stored Procedure & Database Map

| Đối tượng | Loại | Chức năng |
|---|---|---|
| `STB_SanminaShipmentPlan` | Bảng CSDL | Lưu trữ Master Lô xuất Sanmina |
| `STB_SanminaShipmentPlanLot` | Bảng CSDL | Lưu vết chi tiết từng thùng đã in theo Plan |
| `usp_SanminaShipmentPlan_get` | Stored Procedure | Tìm kiếm và hiển thị tiến độ trên [B767_M] |
| `usp_SanminaShipmentPlan_iud` | Stored Procedure | Thêm / Sửa / Kích hoạt / Đóng Lô xuất trên [B767_M] |
| `usp_SanminaLabelPrint_get_Vietnam` | Stored Procedure | Truy vấn và nạp tự động thông tin in tem trên [B767] |
| `usp_SanminaIndiaLabelPrintHist_iud` | Stored Procedure | Ghi log in tem và cập nhật tiến độ Lô xuất |
