# GW_02 — Luồng Mua Hàng (Purchase Flow)

> **Màn hình liên quan:** Electronic Document → Purchase
> **MES liên quan:** F330 (Nhập kho NVL), C220 (IQC), B310, B450
> ← [Về INDEX](GW_INDEX.md)

---

## 🗺️ Tổng Quan Luồng Mua Hàng

```
[1] Purchase Order Registration  ← Tạo đơn đặt hàng
           ↓ (Sau khi duyệt → tự đẩy vào ERP)
[2] Arrival Confirmation         ← Khai báo hàng về đến công ty
           ↓
[MES] F330                       ← Thủ kho nhận hàng, in tem NVL
           ↓
[MES] C220 (IQC)                 ← QC kiểm tra chất lượng → PASS
           ↓
[3] Receiving Confirmation       ← Xác nhận nhập kho chính thức (ERP + MES cập nhật tồn kho)
           ↓
[4] Purchase Resolution          ← Đóng sổ, thanh toán Vendor

[Phụ] Return Product Document    ← Nếu cần trả hàng
[Phụ] PO Delete Document         ← Nếu PO sai cần xóa
```

---

## 1. 📋 Purchase Order Registration (Tạo Đơn Mua Hàng)

**Vào:** Electronic Document → Purchase → Purchase Order Registration Document

### Bước 1: Chọn đường line phê duyệt
- Chọn đường line đã cài đặt trong hệ thống, hoặc tự chọn người duyệt thủ công

### Bước 2: Điền thông tin đơn hàng
- **Đối tác (Vendor):** Chọn nhà cung cấp
- **Kết nối tài liệu:** Nếu có form yêu cầu mua trước → chọn để link vào
- **Mặt hàng:** Chọn từng item cần mua
- **Cho mỗi item:** Nhập đơn giá, số lượng, VAT, ngày giao hàng, kho, trung tâm chi phí
  - Khi nhập số lượng + đơn giá → Giá trị và VAT **tự tính toán**

> ⚠️ Sau khi duyệt xong → Dữ liệu **tự động đăng ký vào ERP**

> ⚠️ **Giao dịch phân phối:** Nếu mua để phân phối (không nhập kho) → tích chọn "Giao dịch phân phối" → Hệ thống **KHÔNG** xử lý nhập kho MES.

> ⚠️ **Import trực tiếp từ HQ:** Khi vendor là HQ → chọn mã nhà cung cấp HQ. Đơn hàng tự tạo ở HQ.

---

## 2. 📦 Arrival Confirmation (Xác Nhận Hàng Về)

**Vào:** Electronic Document → Purchase → Arrival Confirmation Document

### Bước 1: Chọn đơn đặt hàng đã tạo trước đó
- Tải danh sách PO đã approved

### Bước 2: Điền thông tin hàng về
| Trường | Mô tả |
|--------|-------|
| Ngày hàng về | Ngày thực tế hàng đến công ty |
| Bộ phận mua hàng | Chọn phòng ban |
| Ngày thanh toán | Ngày user chọn (khác ngày tự động tính) |

### Bước 3 (Nếu hàng nhập khẩu): Điền thông tin B/L
| Trường | Mô tả |
|--------|-------|
| Số B/L | Mã vận đơn |
| Ngày thanh toán | Ngày trả tiền cho đối tác |
| Điều kiện TT | T/T, D/P, D/A... |
| Incoterms | FOB, CIF... |
| Tỷ giá B/L | Tỷ giá ghi trong B/L |
| Thông tin thông quan | Số thông quan, số hóa đơn, ngày khai báo, tỷ giá |

> 💡 Đối với **giao dịch trong nước**: Phần B/L và thông quan **không hiển thị** → không cần điền.

### Bước 4: Điền thông tin MES Label (Thủ kho làm)
Tại phần liên quan đến MES F330:
- **Số lượng lot mỗi bao bì**
- **Số lượng nhãn**
- Khi nhập đủ → Dữ liệu tự điền vào F330 (màn hình nhập kho MES)
- Khi hoàn tất mà **không nhấn** "Tạo nhãn thủ công" → Nhãn tạo **tự động**

> ⚠️ Sau khi Arrival Confirmation hoàn tất:
> - Email thông báo gửi đến đội **QC (C220)**
> - Sau khi C220 Pass → Email xác nhận gửi đến tất cả người tiếp nhận

---

## 3. ✅ Receiving Confirmation (Xác Nhận Nhập Kho)

**Vào:** Electronic Document → Purchase → Receiving Confirmation Document

> ⚠️ **ĐIỀU KIỆN:** Chỉ có thể làm sau khi **C220 (IQC) đã PASS**. Chỉ mặt hàng đã Pass IQC mới hiển thị để chọn.

### Bước 1: Tải danh sách PO đã tạo
### Bước 2: Thêm mặt hàng đã hoàn tất IQC
- Số lượng đạt và số tiền **tự động tính và hiển thị**
- Kho **tự động điền** theo kho đã nhập trong Arrival Confirmation

### Kết quả sau khi hoàn tất:
- ✅ Xử lý nhập kho trong **ERP**
- ✅ Cập nhật tồn kho trong **MES**
- ✅ Dữ liệu tồn kho chính thức được ghi nhận

---

## 4. 🔄 Return Product Document (Trả Hàng)

**Vào:** Electronic Document → Purchase → Return Product Document

### Bước 1: Chọn tài liệu nhập kho đã tạo
### Bước 2: Chọn mặt hàng và LOT muốn trả lại
- Chọn LOT cụ thể cần trả
- Điền: Ngày trả, Loại hình trả (sau mua NVL / sau gia công ngoài), Phân loại VAT, Tỷ giá

> ⚠️ LOT bị trả sẽ được **chuyển vào kho lỗi trong MES** tự động.
> ⚠️ Xử lý trả hàng trong ERP được **tự động đăng ký**.

---

## 5. 🗑️ Purchase Order Delete Document (Xóa PO Sai)

**Vào:** Electronic Document → Purchase → Purchase Order Data Delete Document

### Điều kiện để xóa:
- PO **chưa được xử lý nhập kho** → mới xóa được
- Nếu đã nhập kho → **KHÔNG THỂ xóa**

### Cách làm:
1. Chọn tài liệu đơn đặt hàng cần xóa
2. Chọn mặt hàng muốn xóa
3. Xác nhận xóa

> ⚠️ **Với đơn nhập khẩu:** Tất cả thông tin B/L và thông quan cũng bị xóa theo.
> ⚠️ Tài liệu này **xóa dữ liệu vĩnh viễn** → Cần thẩm định kỹ trước khi xóa.

---

## 6. 💰 Purchase Resolution (Đóng Sổ Thanh Toán)

**Vào:** Electronic Document → Cost Management → Purchase Resolution Document

Dùng để hoàn tất công việc đóng sổ cho các đơn mua hàng đã nhập kho xong.

### Lưu ý theo từng loại tài liệu:
| Tài liệu gốc | Khi nào làm Resolution |
|--------------|----------------------|
| Arrival Confirmation | Cần TT trước khi Pass IQC (chưa nhập kho) |
| Receiving Confirmation | Khi đã nhập kho thực tế xong |
| Return Product Document | Khi đóng sổ cho đơn trả hàng |

### Các trường quan trọng:
- **Giá trị ghi nợ/ghi có:** Cố định, tự động
- **Mô tả chứng từ:** Tự động điền, không cần ghi tay
- **Ngày thanh toán:** Chọn ngày user muốn (≠ ngày tự động tính) hoặc ngày theo quy định công ty (VD: ngày 15 tháng sau)
- **Chi phí phụ (nhập khẩu):** Vận chuyển, thông quan → Nhập thêm đối tác và số tiền
- **Bản ghi nợ:** Chọn mã tài khoản cho loại hàng cần thanh toán

> ✅ Khi kế toán tiếp nhận hoàn tất → Chứng từ ERP **xử lý tự động**.

---

## 7. 📊 Xem Tổng Hợp Đơn Mua Hàng (Purchase Total List)

**Vào:** Home → Purchase Management → Purchase Total List

| Chức năng | Cách dùng |
|-----------|-----------|
| Lọc và tìm kiếm | Dùng bộ lọc (1) theo nhiều điều kiện |
| Sửa thông tin PO | Nhấn nút thay đổi (2) — **Không sửa được nếu đang nhập kho** |
| In đơn hàng | Nhấn nút in (3), chỉnh sửa nội dung in nếu cần |
| Xem tiến độ | Cột (7) hiển thị trạng thái toàn bộ tài liệu theo PO |

---

## 8. ❓ Các Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| Không nhập được F330 | Arrival Confirmation chưa được duyệt | Bộ phận Mua hàng duyệt Arrival Confirmation trước |
| Không làm được Receiving Confirmation | C220 (IQC) chưa Pass | Đội QC làm C220 Pass trước |
| Không thấy mặt hàng trong Receiving | Mặt hàng chưa Pass IQC | Chỉ mặt hàng Pass IQC mới được chọn |
| Không xóa được PO | PO đã được xử lý nhập kho | Không thể xóa, cần làm Return Document thay |

---

*Cập nhật: 2026-05-18 | Nguồn: [GROUPWARE] Purchase Manual.pptx + extracted_text_utf8.txt*
