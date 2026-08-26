# GW_02 — Luồng Mua Hàng (Purchase Flow)

> **Màn hình liên quan:** Electronic Document → Purchase
> **MES liên quan:** F330 (Nhập kho NVL), C220 (IQC), B310, B450
> ← [Về INDEX](GW_INDEX.md)

---

## 🗺️ Tổng Quan Luồng Mua Hàng

```
[1] Expense Report Document      ← Yêu cầu mua hàng (Local: auto VAT / Overseas: lock VAT + Currency Conversion)
           ↓
[2] Purchase Order Registration  ← Tạo đơn đặt hàng (liên kết từ Expense Report)
           ↓ (Sau khi duyệt → tự đẩy vào ERP)
[3] Arrival Confirmation         ← Khai báo hàng về đến công ty
           ↓
[MES] F330                       ← Thủ kho nhận hàng, in tem NVL
           ↓
[MES] C220 (IQC)                 ← QC kiểm tra chất lượng → PASS
           ↓
[4] Receiving Confirmation       ← Xác nhận nhập kho chính thức (ERP + MES cập nhật tồn kho)
           ↓
[5] Purchase Resolution          ← Đóng sổ, thanh toán Vendor

[Phụ] Return Product Document    ← Nếu cần trả hàng
[Phụ] PO Delete Document         ← Nếu PO sai cần xóa
```


---

## 1. 📝 Đề Xuất Chi Phí & Yêu Cầu Mua Hàng (Expense Report vs. Purchase Request)

Tùy thuộc vào loại hình mua sắm, nhân sự sẽ sử dụng một trong hai biểu mẫu sau trên Groupware:

### 1.1 Expense Report Document (Đơn Đề Xuất Chi Phí / Yêu Cầu Mua Sắm)
**Vào:** Electronic Document → Cost → Expense Report Document

- **Mục đích:** Đăng ký yêu cầu mua sắm hoặc đề xuất chi phí tự do từ các bộ phận trước khi tạo đơn mua hàng chính thức.
- **Tuyến phê duyệt mặc định:** **22205010-Nguyễn Thị Thúy_V6** → **21910034-Trần Quang Thỏa** (Final Approval).
- **Các bước thực hiện:**
  1. **Bước 1: Chọn đường line phê duyệt:** Chọn line có sẵn hoặc tự chỉ định người duyệt. Cho phép upload một hoặc nhiều file đính kèm.
  2. **Bước 2: Điền thông tin cơ bản:** Nhập tiêu đề form. Nếu làm form hộ người khác, gõ tên người đó vào trường **"Thay đổi người sử dụng"** (nếu không chọn, mặc định lấy người đăng nhập).
  3. **Bước 3: Chọn loại hình thanh toán/mua hàng:**
     - **Trường hợp 1 (Mua hàng trong nước - Local):** Bắt buộc nhập VAT, không cần chọn phần đổi ngoại tệ (tính theo VNĐ).
     - **Trường hợp 2 (Mua hàng nước ngoài - Overseas):** Không cần nhập VAT, bắt buộc chọn chuyển đổi ngoại tệ. Hệ thống tự động tính tỷ giá hối đoái tại thời điểm làm form.
     - *Lưu ý:* Cả hai trường hợp đều phải nhập số tiền chính xác của nhà cung cấp.
  4. **Bước 4: Mô tả chi tiết:** Soạn thảo nội dung ở khung Rich-text. Cho phép chèn video, hình ảnh, link, tạo bảng và chỉnh font chữ.
  5. **Bước 5: Gửi đi duyệt hoặc lưu tạm:** Sử dụng các nút dưới chân trang (Gửi đi, Lưu trữ tạm thời, Xóa nhớ tạm, Xem trước, Reset).

### 1.2 Purchase Request Document (Đơn Yêu Cầu Mua Hàng - Phân Loại Vật Tư)
**Vào:** Electronic Document → Purchase → Purchase Request Document

- **Mục đích:** Đăng ký yêu cầu mua vật tư chính thức theo từng phân loại chuyên biệt (Nguyên vật liệu, Vật tư phụ, Thiết bị/Nhà xưởng, IT).
- **Tuyến phê duyệt & Tiếp nhận (Receipt/Reference) quy định chi tiết từ Excel:**

| Loại vật tư | Đường line phê duyệt (Approval) | Bộ phận tiếp nhận (Receipt) | Người tham chiếu (Reference) |
|-------------|---------------------------------|-----------------------------|------------------------------|
| **Nguyên vật liệu** (Raw materials) | 71908026-Đào Thị Phiên → 21910034-Trần Quang Thỏa | Nhân viên mua hàng → Trưởng phòng mua hàng (Final Receipt) | 21910034-Trần Quang Thỏa |
| **Vật tư phụ** (Subsidiary materials) | 71908026-Đào Thị Phiên → 21910034-Trần Quang Thỏa | Nhân viên mua hàng → Trưởng phòng mua hàng (Final Receipt) | 21910034-Trần Quang Thỏa |
| **Tài sản IT** (IT assets) | 92005006-Nguyễn Văn Nha → 11910035-Nguyễn Thành Phi | Nhóm kỹ thuật IT (92005006-Nguyễn Văn Nha, 92404003-Nguyễn Văn Thuần, 92209001-Trần Quang Duy, 92011009-Đỗ Xuân Đồng) → 92005006-Nguyễn Văn Nha (Final Receipt - CC: Nhóm nhận Kế toán*) | 92005006-Nguyễn Văn Nha |
| **Thiết bị/Nhà xưởng** (Facility) | 71908026-Đào Thị Phiên → 21910034-Trần Quang Thỏa → CEO | Nhóm kỹ thuật (72112005-Nguyễn Thị Minh Hiền, 72311001-Nguyễn Thị Hậu) → 71908026-Đào Thị Phiên (CC: Nhóm nhận Kế toán*) | 21910034-Trần Quang Thỏa |

*\*Nhóm nhận Kế toán (Receipt CC) bao gồm các nhân sự: 22205010-NGUYỄN THỊ THÚY_V6, 22205011-NGUYỄN THỊ PHƯƠNG LINH, 22308006-NGÔ PHƯƠNG ANH, 22312004-LÊ THỊ TRANG, 22404015-NGUYỄN THỊ HỒNG_V3.*

---

## 2. 📋 Purchase Order Registration (Tạo Đơn Mua Hàng)

**Vào:** Electronic Document → Purchase → Purchase Order Registration Document

### Bước 1: Chọn đường line phê duyệt & Tiếp nhận (Receipt)
- **Tuyến phê duyệt (Approval):** **71908026-Đào Thị Phiên** → **21910034-Trần Quang Thỏa** (hoặc chọn đường line đã cài sẵn trên hệ thống: *Team Leader -> Group Leader -> Lee Sang Hun -> Kim Kyeong Cheol (CEO)*).
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*), **71908026-Đào Thị Phiên** (Final Receipt: Nhóm nhận Kế toán*).
- **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.
- Có thể đính kèm một hoặc nhiều file cùng lúc.

### Bước 2: Điền thông tin đơn hàng (Các trường dữ liệu chính từ giao diện thực tế)
- **Phân loại Tài liệu (documentSaveApprovalTarget):** Dropdown phân cấp luồng gồm:
  - `Nguyên liệu thô` (`STATIC_DATA_000174`)
  - `Hàng nhập của pháp nhân` (`STATIC_DATA_000460`)
  - `Chất khử mùi` (`STATIC_DATA_000803`)
  - `Hàng nguy hiểm` (`STATIC_DATA_000685`)
  - `Phân phối` (`STATIC_DATA_000577`)
- **Đối tác (Vendor / cdPartner):** Nhấn tìm kiếm để chọn nhà cung cấp.
  * *Lưu ý nhập từ HQ:* Khi vendor là HQ (Mã đối tác: `13000`), đơn hàng sẽ tự động liên kết tạo sales order bên HQ.
- **Kết nối tài liệu:** Nhấn chọn định dạng tài liệu muốn kết nối → Chọn biểu mẫu **Expense Report Document** đã duyệt trước đó.
- **Ngày Đặt hàng (dtPo):** Trường chọn ngày thực tế mua hàng.
- **Loại Đặt hàng (cdTppo):** Chọn loại hình giao dịch tương ứng:
  - `Trong nướcMua hàng(Domestic Order (VAT 10))` (Mã `1100`)
  - `Nhập khẩu-L/C(Import Order-Master L/C)` (Mã `1120`)
  - `Nhập khẩu-T/T(Import Order-T/T)` (Mã `1130`)
  - `Nội địaĐơn đặt hàng(5%)(Domestic Order (VAT 5))` (Mã `1160`)
  - `Nội địaĐơn đặt hàng(영세)(Domestic Order (VAT 0))` (Mã `1170`)
  - `Nội địaĐơn đặt hàng(8%)(Domestic Order (VAT 8))` (Mã `1180`)
  - `Nước ngoàiĐơn đặt hàng-LOCAL(Import Order-Outsourcing)` (Mã `1200`)
  - `3Thương mạiNhập kho(3-party Trade Receipt)` (Mã `1300`)
- **Điều khoản giá (condPrice):** Chọn điều kiện Incoterms:
  - `C&F` (`002`), `CIF` (`001`), `FOB` (`003`), `EXW` (`EXW`), `DDP` (`DDP`), `DAP` (`DAP`), `FAS` (`FAS`), `CIP` (`CIP`), `CPT` (`CPT`).
- **Nhóm mua hàng (cdPurgrp):** Phân nhóm phòng ban mua:
  - `Material Purchase Group` (`1000`)
  - `Outsourcing Purchase Group` (`2000`)
  - `Export Return Group` (`3000`)
- **Loại Thanh Toán (fgPayment):** Chọn phương thức thanh toán:
  - `Bill` (`000`), `Allotment` (`002`), `Within the cash 3 Months` (`001`), `Cash for Vietnam` (`004`), `T/T for Vietnam` (`003`).
- **Loại Đơn Giá (fgUm):** Chọn `Normal price` (`001`) hoặc `Discount` (`002`).
- **Loại thuế (fgTax):** Lựa chọn loại thuế áp dụng:
  - `Taxation(VAT 5)` (Mã `22` hoặc `70`)
  - `Taxation (VAT 10)` (Mã `21`)
  - `Taxation(VAT 8)` (Mã `71`)
  - `Tax exemption` (Mã `26`)
  - `Zero tax` (Mã `23`)
  - `Receipt` (Mã `99`)
- **Loại tiền tệ (cdExch):** Lựa chọn đồng tiền thanh toán (UI hiển thị dạng `:: Loại tiền tệLoại ::`): `KRW`, `USD`, `JPY`, `EUR`, `CNY`, etc.
- **Tỷ giá hối đoái (rtExch):** Nhập tỷ giá thực tế nếu dùng ngoại tệ.
- **Giao dịch phân phối (tích chọn):** Nếu mua để phân phối trực tiếp (không qua kho MES) → Tích chọn giao dịch phân phối để bỏ qua bước nhập kho MES.
- **문서 내용(비고) (documentSaveContent):** Nhập nội dung mô tả hoặc ghi chú của tài liệu.

### Bước 3: Đăng ký danh sách mặt hàng (Grid Table chi tiết)
Bảng nhập liệu chi tiết của mặt hàng bao gồm các cột sau:
1. `No`
2. `Có/Không mẫu ( Đăng ký hàng loạt )` (Check box chọn hàng mẫu)
3. `Mục` (Mã và tên vật tư)
4. `Revision` (Phiên bản BOM, bắt buộc chọn **2001** cho Việt Nam)
5. `Đơn giá` (Unit Price)
6. `Số lượng Đơn hàng` (Order Qty)
7. `Số tiền(Ngoại tệ)` (Amount in Foreign Currency)
8. `Số tiền` (Amount in Local Currency)
9. `VAT`
10. `Tổng số tiền`
11. `Loại thuế`
12. `Bao gồm VAT ( Đăng ký hàng loạt )`
13. `Ngày Giao Hàng ( Đăng ký hàng loạt )`
14. `Kho nhập ( Đăng ký hàng loạt )` (Chọn mã kho thực tế, xem bảng tra cứu ở GW_07)
15. `Trung tâm Chi phí ( Đăng ký hàng loạt )` (Chọn Cost Center của bộ phận)
16. `Xóa`

> ⚠️ Sau khi duyệt xong → Dữ liệu **tự động đăng ký vào ERP**.
> ⚠️ **Import trực tiếp từ HQ:** Khi vendor là HQ → chọn mã nhà cung cấp HQ (Mã `13000`). Đơn hàng tự tạo ở HQ.


---

## 3. 📦 Arrival Confirmation (Xác Nhận Hàng Về)

**Vào:** Electronic Document → Purchase → Arrival Confirmation Document

### Bước 1: Chọn đơn đặt hàng đã tạo trước đó & Tuyến phê duyệt/Tiếp nhận
- Nhấn tải danh sách PO đã approved để liên kết vào form.
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).
- **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.

### Bước 2: Điền thông tin hàng về (Các trường trên UI thực tế)
- **Phân loại Tài liệu (documentSaveApprovalTarget):** Dropdown phân cấp:
  - `Nguyên liệu thô` (`STATIC_DATA_000174`)
  - `Trong nước` (`STATIC_DATA_000260`)
  - `Quốc tế` (`STATIC_DATA_000261`)
  - `Chất khử mùi` (`STATIC_DATA_000803`)
  - `탈취Bộ lọc` (`STATIC_DATA_000723`)
  - `Phân phối` (`STATIC_DATA_000577`)
- **Ngày hàng về (dtArrival):** Chọn ngày thực tế hàng về.
- **Loại hình mua hàng (paymentType):** Lựa chọn kiểu thanh toán:
  - `Payment in VND` (`STATIC_DATA_000697`)
  - `Advance Payment (VND)` (`STATIC_DATA_000699`)
- **Số Phiếu Giao Nhận Nguyên Vật Liệu (materialDocNo):** Mã số phiếu nguyên vật liệu từ hệ thống MES (được nạp tự động).

### Bước 3: Kiểm tra thông tin liên kết PO (Bảng thông tin PO)
Bảng thông tin đơn hàng (Table 1 / Index 1) hiển thị các thông tin:
- `Tên Đối tác` | `Số Đơn đặt hàng` | `Ngày Đặt hàng` | `Loại Đặt hàng` | `Nhóm mua hàng` | `Điều khoản thanh toán` | `Loại thuế` | `Loại tiền tệ` | `Tỷ giá hối đoái`

### Bước 4: Danh mục hàng về thực tế (Grid Table chi tiết)
Bảng nhập liệu chi tiết hàng về (Table 2 / Index 2) bao gồm các cột:
1. `No`
2. `Có/Không mẫu`
3. `Số Đơn đặt hàng`
4. `Mục` (Mã và tên vật tư)
5. `Revision` (Phiên bản BOM)
6. `Đơn giá`
7. `Số lượng Đơn hàng` (Số lượng đặt mua gốc)
8. `Số lượng Nhập kho` (Số lượng hàng về thực tế ở bước này)
9. `Số tiền(Ngoại tệ)`
10. `Số tiền`
11. `VAT`
12. `Tổng số tiền`
13. `Trung tâm Chi phí`
14. `Loại thuế`
15. `Kho nhập ( Đăng ký hàng loạt )`
16. `Xóa`

### Bước 3 (Nếu hàng nhập khẩu): Điền thông tin B/L & Thông Quan
> 💡 Đối với **giao dịch trong nước**: Phần B/L, chi phí phụ và thông quan **không hiển thị** → không cần nhập.

| Thông tin B/L | Mô tả |
|---------------|-------|
| **Số B/L** | Nhập số vận đơn đường biển/đường hàng không |
| **Ngày thanh toán** | Ngày thanh toán tiền cho đối tác |
| **Điều kiện TT** | T/T, D/P, D/A, v.v. |
| **Incoterms** | FOB, CIF, EXW, v.v. |
| **Tỷ giá B/L** | Tỷ giá ghi nhận trên B/L |
| **Ngày phát hành B/L** | Ngày phát hành tài liệu B/L = Ngày ghi sổ |

| Thông tin Thông quan & Chi phí phụ | Mô tả |
|-------------------------------------|-------|
| **Chi phí phụ B/L** | Nhập các chi phí phát sinh đi kèm B/L |
| **Số thông quan** | Số tờ khai thông quan hàng nhập khẩu |
| **Số hóa đơn** | Số Invoice của lô hàng |
| **Ngày khai báo** | Ngày ghi trong tờ khai nhập khẩu |
| **Tỷ giá hải quan** | Tỷ giá ghi trong chứng nhận khai báo nhập khẩu |

> ⚠️ Với đơn nhập khẩu, sau khi duyệt hoàn tất, dữ liệu sẽ **tự động đồng bộ** vào ERP B/L, chi phí phụ B/L và thông tin thông quan.

### Bước 4: Điền thông tin MES Label (Thủ kho/Nhân viên kho làm)
Tại phần liên quan đến MES F330:
- Chọn mặt hàng xuất kho, nhập các thông số phát hành nhãn:
  - **Số lượng lot mỗi bao bì**
  - **Số lượng nhãn**
- Nhấn **"Tạo nhãn thủ công"** (nếu muốn tự in), hoặc bỏ qua nút này để nhãn được **tạo tự động** khi hoàn tất tiếp nhận.
- Dữ liệu này tự động điền vào màn hình tiếp nhận nhãn **MES F330**.

> ⚠️ Sau khi Arrival Confirmation hoàn tất:
> - Email và thông báo tự động được gửi đến đội **QC (C220)**.
> - Sau khi đội QC hoàn tất kiểm tra nhập khẩu theo từng mẫu trên **MES C220** và cập nhật **PASS**, một email xác nhận hoàn tất sẽ tự động gửi tới tất cả người tiếp nhận.


---

## 4. ✅ Receiving Confirmation (Xác Nhận Nhập Kho)

**Vào:** Electronic Document → Purchase → Receiving Confirmation Document

> ⚠️ **Lưu ý giao diện UI:** Trên thanh menu và tiêu đề biểu mẫu của hệ thống, từ này bị viết sai chính tả thành **"Receiving Confirmation Doucment"** (chữ *Document* viết sai thành *Doucment*).

> ⚠️ **ĐIỀU KIỆN:** Chỉ có thể làm sau khi **C220 (IQC) đã PASS**. Chỉ mặt hàng đã Pass IQC mới hiển thị để chọn.

### Bước 1: Tải danh sách PO đã tạo & Tuyến phê duyệt/Tiếp nhận
- Nhấn tải danh sách PO đã duyệt để bắt đầu liên kết.
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).
- **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.

### Bước 2: Điền thông tin cơ bản
- **Phân loại Tài liệu (documentSaveApprovalTarget):**
  - `Trong nước` (`STATIC_DATA_000260`)
  - `Quốc tế` (`STATIC_DATA_000261`)
  - `Chất khử mùi` (`STATIC_DATA_000803`)
  - `탈취Bộ lọc` (`STATIC_DATA_000723`)
  - `Phân phối` (`STATIC_DATA_000577`)
- **Ngày nhập kho (dtIo):** Chọn ngày thực tế nhập kho chính thức.

### Bước 3: Kiểm tra bảng thông tin và sổ kế toán phụ
- **Bảng đối tác (Table 1 / Index 1):** Hiển thị `Tên Đối tác` | `Số Đơn đặt hàng` | `Ngày Đặt hàng` | `Loại Đặt hàng` | `Nhóm mua hàng` | `Điều khoản thanh toán` | `Loại thuế` | `Loại tiền tệ` | `Tỷ giá hối đoái`
- **Bảng đối chiếu tạm ứng (Table 2 / Index 2):** Hiển thị sổ phụ đối chiếu: `Số Chứng từ` | `Diễn giải` | `Tỷ giá hối đoái` | `Tạm ứng` | `Số tiền đã xử lý` | `Số dư trước` | `Số tiền đã xử lý ở trên` | `Số dư cuối cùng` | `Chứng từ đã xử lý`

### Bước 4: Danh mục nhập kho thực tế (Table 3 / Index 3)
Bao gồm các cột thông tin:
1. `No`
2. `Có/Không mẫu`
3. `Mục` (Mã và tên vật tư)
4. `Đơn giá`
5. `Số lượng Nhập kho` (Số lượng được QC Pass cho phép nhập)
6. `Số lượng nhập kho` (Số lượng thực tế đưa vào kho)
7. `Số tiền(Ngoại tệ)`
8. `Số tiền`
9. `VAT`
10. `Tổng cộng`
11. `Kho nhập` (Mã kho thực tế nhận hàng)
12. `Loại thuế`
13. `Xóa`

### Kết quả sau khi hoàn tất:
- ✅ Xử lý nhập kho trong **ERP**
- ✅ Cập nhật tồn kho trong **MES**
- ✅ Dữ liệu tồn kho chính thức được ghi nhận

---

## 5. 🔄 Return Product Document (Trả Hàng)

**Vào:** Electronic Document → Purchase → Return Product Document

### Bước 1: Chọn tài liệu nhập kho đã tạo trước đó & Tuyến phê duyệt/Tiếp nhận
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).
### Bước 2: Phân loại trả hàng
- Chọn phân biệt giữa: **Trả lại sản phẩm** (Product Return) hoặc **Trả lại nguyên vật liệu** (Raw Material Return).
- Chọn hình thức trả: trả sau khi mua nguyên vật liệu hay trả sau khi mua gia công ngoài.

### Bước 3: Chọn mặt hàng và LOT muốn trả lại
- Tìm kiếm mã hàng và chọn đúng **LOT** cụ thể cần trả về nhà cung cấp.
- Điền các thông tin:
  - **Ngày trả lại:** Ngày thực tế xuất trả hàng.
  - **Phân loại VAT:** Chọn loại VAT tương ứng.
  - **Tỷ giá:** Đối với đơn vị tiền tệ ngoại tệ, tỷ giá áp dụng bắt buộc phải là **tỷ giá gốc khi mua hàng** (lấy từ lịch sử đơn hàng).

> ⚠️ LOT bị trả sẽ được **tự động chuyển vào kho lỗi trong MES**.
> ⚠️ Giao dịch trả hàng trong ERP sẽ được **tự động đăng ký**.


---

## 6. 🚫 Hủy (Xóa) / Đóng Đơn Đặt Hàng (Purchase Order Data Delete & Closing Document)

Dùng khi thông tin đơn đặt hàng bị nhập sai hoặc khi giao dịch kết thúc giữa chừng cần hủy bỏ/kết thúc các dòng PO chưa nhập kho.

### 6.1 Hủy/Xóa đơn đặt hàng (Purchase Order Data Delete Document)
**Vào:** Electronic Document → Purchase → Purchase Order Data Delete Document (Mã biểu mẫu: `purchaseOrderCancelDocument`)
- **Mục đích:** Hủy hoặc xóa hoàn toàn dữ liệu PO.
- **Điều kiện:** PO **chưa từng được xử lý nhập kho**. Nếu đã nhập kho thực tế, hệ thống sẽ khóa và cấm thực hiện (phải dùng *Return Product Document* để xuất trả).
- **Tác động:** Sau khi được phê duyệt, hệ thống sẽ tự động xóa sạch dữ liệu đăng ký nhập hàng (Arrival/Receiving) tương ứng trên cả hệ thống ERP và MES. Cụ thể, PO đã hủy sẽ **không thể** được lựa chọn trong form *Arrival Confirmation* nữa. Đối với các đơn hàng nhập khẩu, toàn bộ thông tin B/L và tờ khai thông quan đã đăng ký đi kèm với PO này cũng sẽ bị xóa sạch khỏi cơ sở dữ liệu.

### 6.2 Đóng đơn đặt hàng (Purchase Order Closing Document)
**Vào:** Electronic Document → Purchase → Purchase Order Closing Document (Mã biểu mẫu: `purchaseOrderClosingDocument`)
- **Mục đích:** Đóng/Kết thúc các hạng mục (items) còn lại trong PO mà không xóa dữ liệu lịch sử PO gốc.
- **Tác động:** Giữ nguyên dữ liệu PO. Xóa dữ liệu kế hoạch nhập hàng liên quan của các item được chọn đóng trên ERP và MES. Các item đã đóng sẽ bị ẩn đi, không thể chọn trong màn hình *Arrival Confirmation*.
- **Quy tắc đóng một phần:** Nếu chỉ đóng một số item trong PO, hệ thống sẽ tự động tính toán lại tổng giá trị còn lại của PO và thực hiện đăng ký cập nhật lại trên ERP và MES.

- **Tuyến phê duyệt (Approval):** **71908026-Đào Thị Phiên** → **21910034-Trần Quang Thỏa** (Final Approval).
- **Tuyến tham chiếu (Reference):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).

> [!WARNING]
> **ĐIỀU KIỆN RÀN BUỘC:** Nếu đang tồn tại biểu mẫu *Receiving Confirmation* (Xác nhận nhập kho) ở trạng thái đang chờ duyệt liên quan đến PO này, hệ thống sẽ **khóa cứng**, cấm thực hiện thao tác Hủy hoặc Đóng PO.

---

## 7. 💰 Purchase Resolution (Đóng Sổ Thanh Toán)

**Vào:** Electronic Document → Cost Management → Purchase Resolution Document

Dùng để hoàn tất công việc đóng sổ và ghi nhận công nợ thanh toán cho các đơn mua hàng.

### 8.1 Phân loại đóng sổ theo chứng từ gốc:
- **Arrival Confirmation Document:** Dùng khi cần thanh toán trước cho đối tác trước khi hoàn tất kiểm tra nhập khẩu (trước khi xử lý nhập kho thực tế).
- **Receiving Confirmation Document:** Dùng khi hàng đã nhập kho thực tế xong và tiến hành đóng sổ công nợ.
- **Return Product Document:** Dùng khi tiến hành đóng sổ giảm trừ cho đơn hàng đã xuất trả lại.

### 8.2 Các bước thao tác & Trường dữ liệu chi tiết:
- **Phân loại Tài liệu (documentSaveApprovalTarget):** Dropdown phân luồng kế toán:
  - `Trong nước` (`STATIC_DATA_000260`)
  - `Quốc tế` (`STATIC_DATA_000261`)
  - `Phân phối` (`STATIC_DATA_000577`)
- **Giá trị ghi nợ và ghi có:** Giá trị cố định do hệ thống tự tính, không được sửa.
- **Mô tả trên chứng từ:** Hệ thống tự động điền thông tin mô tả, người dùng không cần ghi riêng.
- **Ngày thanh toán:**
   - *Ngày tự chọn (8-1):* Ngày do người dùng tự ấn định, bắt buộc phải thỏa thuận trước với phòng Kế toán.
   - *Ngày quy định (8-2):* Theo lịch giải ngân cố định của công ty (Ví dụ: **ngày 15** và **ngày 30** của tháng tiếp theo).
   - *Ngày phát hành chi phí phụ (8-3):* Ngày phát hành hóa đơn chi phí phụ liên quan.
- **Thông tin liên thông (lấy từ form trước):** Số tờ khai thông quan, số B/L tự động hiển thị (nếu là hàng nhập khẩu).
- **Đăng ký Chi phí phụ & Chi phí thông quan (Hàng nhập khẩu):**
   - Click chọn đối tác (vendor) phụ trách vận chuyển, thông quan.
   - Nhập số tiền chi phí phụ (phí vận chuyển đường biển/đường không, cước tàu, v.v.).
   - Nếu có nhiều mục chi phí phụ cho cùng một đối tác → bấm nút thêm dòng chi phí phụ.
   - Chọn phòng ban phụ trách chịu cost chi phí phụ này (Mặc định: **Nhóm mua hàng**).
   - Hệ thống tự động phát hành bảng kê giao dịch điện tử (cố định).
- **Mặt hàng thanh toán:** Hiển thị số lượng, đơn giá đã nhập kho và số tiền thanh toán dựa trên tỷ lệ thuế nhập khẩu.
- **Bản ghi nợ:** Click chọn nút **"Bản ghi nợ"** để mở cửa sổ danh sách mã tài khoản kế toán, chọn đúng mã tài khoản tương ứng với chủng loại hàng cần thanh toán (Bút toán phân kỳ Cost).
- **Chọn loại thuế và VAT:** Nhập loại hình thuế và tiền thuế VAT tương ứng.

### 8.3 Cơ chế kiểm tra chênh lệch (System Change Check Flags):
Hệ thống tự động sử dụng các cờ kiểm tra (API check flags) để xác định xem thông tin đóng sổ thanh toán có sai lệch so với đơn đặt hàng gốc (PO) hay không:
- `changeDistribuCheck`: Kiểm tra thay đổi về tỷ lệ phân phối chi phí.
- `changeRequestDateCheck`: Kiểm tra thay đổi ngày yêu cầu thanh toán.
- `changeCostCdCcCheck`: Kiểm tra thay đổi mã trung tâm chi phí (Cost Center).
- `changeCondPriceCheck`: Kiểm tra thay đổi về điều kiện giá mua (Incoterms).
- `changeInvoiceNoCheck`: Kiểm tra thay đổi về số hóa đơn (Invoice Number).
- `purchaseResolutionExchChangeYn`: Cờ quy định xem có cho phép thay đổi tỷ giá hối đoái so với PO gốc hay không (`Y`/`N`).

> ✅ Khi phòng Kế toán tiếp nhận và phê duyệt hoàn tất → Chứng từ kế toán ERP sẽ được **xử lý tự động**.

---

## 8. 🏢 Luồng Mua Hàng Giữa Các Pháp Nhân (Inter-company PO & Receiving)

Quy trình áp dụng khi Vinatech Việt Nam mua hàng trực tiếp từ Công ty mẹ Vinatech Hàn Quốc (HQ):

### Bước 1: Khởi tạo đơn đặt hàng HQ (Corporate PO)
- Khi tạo PO mới, nếu người dùng chọn đối tác (Vendor) là Công ty mẹ HQ (Mã đối tác: **13000**).
- Sau khi PO này được duyệt hoàn toàn trên hệ thống Groupware Việt Nam, hệ thống sẽ tự động tạo một biểu mẫu **Yêu cầu nhận đơn hàng (Suju / Sales Order Document)** tại Groupware của Công ty mẹ HQ.

### Bước 2: Thực hiện xuất hàng phía Hàn Quốc
- Bộ phận nghiệp vụ phía HQ sẽ thực hiện các bước xử lý Suju trên hệ thống của họ: `Suju (Nhận đơn) -> 출하요청 (Shipment Request) -> 출하확인 (Shipment Confirmation)`.
- Khi phía HQ hoàn thành việc duyệt biểu mẫu *Shipment Request* (출하요청서 접수완료), thông tin lô hàng sẽ lập tức hiển thị trên hệ thống Groupware Việt Nam.

### Bước 3: Xác nhận nhận hàng liên công ty (Corporate Receiving Confirmation)
- **Vào:** Electronic Document → Purchase → Corporate Receiving Confirmation Document (Tài liệu nhập kho pháp nhân).
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).
- **Thao tác:**
  1. Nhấn bắt đầu xác nhận thông tin hàng nhập liên công ty.
  2. Dùng máy quét quét mã vạch **Packing ID** trên các thùng hàng thực tế nhận được.
  3. Hệ thống sẽ đối chiếu mã Packing ID và số lượng thực quét với thông tin phiếu xuất của HQ.
  - *Lưu ý:* Khi quét mã vạch lần đầu tiên, lưới danh mục toàn bộ các mặt hàng được khai báo trong phiếu xuất của HQ sẽ tự động hiển thị để thủ kho Việt Nam đối chiếu.

---

## 9. 📊 Xem Tổng Hợp Đơn Mua Hàng (Purchase Total List)

**Vào:** Home → Purchase Management → Purchase Total List

| Chức năng | Cách dùng & Quy tắc hệ thống |
|-----------|------------------------------|
| **Lọc và tìm kiếm** | Sử dụng bộ lọc (1) với nhiều tiêu chí (ngày tháng, vendor, mã hàng, trạng thái...) |
| **Sửa đổi thông tin PO** | - Nhấn nút **Thay đổi** (2) để điều chỉnh thông tin PO.<br>- ⚠️ **Quy tắc:** Nếu PO đang trong quá trình nhập kho hoặc đã nhập kho thực tế, hệ thống **khóa chức năng sửa**.<br>- Khi nhấn nút thay đổi, hệ thống sẽ tự động tạo một đơn yêu cầu thay đổi thông tin PO. |
| **In đơn đặt hàng** | - Nhấn nút **In** (3) để kết xuất bản in.<br>- Người dùng có thể chỉnh sửa thủ công nội dung cần hiển thị trên bản in (trừ các thông tin cốt lõi liên quan đến mã hàng/item). |
| **Tên tài liệu PO** | Click trực tiếp vào tên tài liệu PO để mở trực tiếp bản in chi tiết. |
| **Theo dõi tiến độ** | Cột (7) hiển thị trực quan toàn bộ trạng thái tiến trình các tài liệu liên quan đến PO (đã duyệt, đang chờ duyệt, hay chưa tạo). |

---

## 10. ❓ Các Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| Không nhập được F330 | Arrival Confirmation chưa được duyệt | Bộ phận Mua hàng duyệt Arrival Confirmation trước |
| Không làm được Receiving Confirmation | C220 (IQC) chưa Pass | Đội QC làm C220 Pass trước |
| Không thấy mặt hàng trong Receiving | Mặt hàng chưa Pass IQC | Chỉ mặt hàng Pass IQC mới được chọn |
| Không xóa được PO | PO đã được xử lý nhập kho | Không thể xóa, cần làm Return Document thay |
| Không hủy/đóng được PO | Đang có form Receiving Confirmation chờ duyệt | Cần duyệt xong hoặc từ chối form Receiving Confirmation trước khi hủy/đóng PO |

---

*Cập nhật: 2026-06-12 | Nguồn: [GROUPWARE] Purchase Manual.pptx + GROUPWARE PURCHASE, SALES FUNCTION MANUAL.pptx + Comprehensive_Groupware_Report.md*
