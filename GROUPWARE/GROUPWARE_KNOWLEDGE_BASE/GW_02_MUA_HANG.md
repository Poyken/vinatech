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

### Bước 2: Điền thông tin đơn hàng (Các trường dữ liệu chính)
- **Đối tác (Vendor):** Chọn nhà cung cấp (trong trường hợp nhập trực tiếp từ HQ, chọn mã nhà cung cấp HQ để tự tạo sales order ở HQ).
- **Kết nối tài liệu:** Nhấn chọn định dạng tài liệu muốn kết nối → Chọn biểu mẫu **Yêu Cầu Mua Hàng (Expense Report Document)** đã duyệt trước đó.
- **Ngày đặt hàng:** Ngày thực tế mua hàng từ đối tác.
- **Hình thức đặt hàng:** Chọn loại giao dịch (trong nước, quốc tế, bao gồm thuế GTGT, v.v.). Cơ chế nhập kho, nhận hàng và quyết toán sẽ tự động điều phối theo lựa chọn này.
- **Phân loại mua hàng:** Chọn mua nguyên vật liệu hoặc mua gia công ngoài.
- **Loại hình thanh toán:** Chọn hình thức thanh toán phù hợp.
- **Phân loại đơn giá:** Chọn đơn giá mua bình thường hay giá giảm.
- **Thuế giá trị gia tăng (VAT):** Nhập tỷ lệ VAT nếu có.
- **Đơn vị tiền tệ, tỷ giá hối đoái:** Hệ thống tự động tra cứu tỷ giá hối đoái thực tế theo ngày đặt hàng.
- **Giao dịch phân phối:** Nếu mua để phân phối trực tiếp (không nhập kho) → tích chọn **"Giao dịch phân phối"**. Hệ thống sẽ **bỏ qua** toàn bộ quá trình nhập kho liên quan đến MES. Dữ liệu sau khi duyệt chỉ đăng ký vào ERP.
- **Mặt hàng:** Chọn từng item cần mua. Nhập đơn giá, số lượng, ngày giao hàng, kho nhận, trung tâm chi phí (Cost Center) cho từng mặt hàng. Giá trị và VAT sẽ tự động tính toán.

> ⚠️ Sau khi duyệt xong → Dữ liệu **tự động đăng ký vào ERP**.

> ⚠️ **Import trực tiếp từ HQ:** Khi vendor là HQ → chọn mã nhà cung cấp HQ. Đơn hàng tự tạo ở HQ (phục vụ khi HQ mua thiết bị, linh kiện, v.v.).


---

## 3. 📦 Arrival Confirmation (Xác Nhận Hàng Về)

**Vào:** Electronic Document → Purchase → Arrival Confirmation Document

### Bước 1: Chọn đơn đặt hàng đã tạo trước đó & Tuyến phê duyệt/Tiếp nhận
- Nhấn tải danh sách PO đã approved để liên kết vào form.
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).
- **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.

### Bước 2: Điền thông tin hàng về
- **Ngày hàng về:** Nhập ngày hàng hóa thực tế về tới công ty.
- **Bộ phận mua hàng:** Chọn phòng ban thực hiện mua hàng.
- **Ngày thanh toán:** 
  - *Ngày tự chọn:* Ngày do người dùng tự chọn (khác ngày tự động tính toán).
  - *Ngày quy định:* Ngày thanh toán định kỳ của công ty (Ví dụ: ngày 15 hàng tháng).
- **Tổng số tiền:** Nhập tổng số tiền thực tế.

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

> ⚠️ **ĐIỀU KIỆN:** Chỉ có thể làm sau khi **C220 (IQC) đã PASS**. Chỉ mặt hàng đã Pass IQC mới hiển thị để chọn.

### Bước 1: Tải danh sách PO đã tạo & Tuyến phê duyệt/Tiếp nhận
- Nhấn tải danh sách PO đã duyệt để bắt đầu liên kết.
- **Tuyến tiếp nhận (Receipt):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).
- **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.
### Bước 2: Thêm mặt hàng đã hoàn tất IQC
- Số lượng đạt và số tiền **tự động tính và hiển thị**
- Kho **tự động điền** theo kho đã nhập trong Arrival Confirmation

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

## 6. 🚫 Hủy / Đóng Đơn Đặt Hàng (Purchase Order Cancel & Closing)

Dùng khi thông tin đơn đặt hàng bị nhập sai hoặc khi giao dịch kết thúc giữa chừng cần hủy bỏ/kết thúc các dòng PO chưa nhập kho.

**Vào:** Electronic Document → Purchase → Purchase Order Cancel Document (hoặc Purchase Order Closing Document)

- **Tuyến phê duyệt (Approval):** **71908026-Đào Thị Phiên** → **21910034-Trần Quang Thỏa** (Final Approval).
- **Tuyến tham chiếu (Reference):** Nhóm kỹ thuật thiết bị/nhà xưởng (*72112005-Nguyễn Thị Minh Hiền*, *72311001-Nguyễn Thị Hậu*, *71908026-Đào Thị Phiên*).

> [!WARNING]
> **ĐIỀU KIỆN:** Nếu đang tồn tại biểu mẫu *Receiving Confirmation* (Xác nhận nhập kho) ở trạng thái đang chờ duyệt liên quan đến PO này, hệ thống sẽ **khóa cứng**, cấm thực hiện thao tác Hủy hoặc Đóng PO.

### 6.1 Hủy đơn đặt hàng (Purchase Order Cancel Document):
- **Mục đích:** Xóa hoàn toàn dữ liệu PO.
- **Tác động:** Sau khi được phê duyệt, hệ thống sẽ tự động xóa sạch dữ liệu đăng ký nhập hàng (Arrival/Receiving) tương ứng trên cả hệ thống ERP và MES. Cụ thể, PO đã hủy sẽ **không thể** được lựa chọn trong form *Arrival Confirmation* nữa.

### 6.2 Đóng đơn đặt hàng (Purchase Order Closing Document):
- **Mục đích:** Đóng/Kết thúc các hạng mục (items) còn lại trong PO mà không xóa dữ liệu lịch sử PO gốc.
- **Tác động:** Giữ nguyên dữ liệu PO. Xóa dữ liệu kế hoạch nhập hàng liên quan của các item được chọn đóng trên ERP và MES. Các item đã đóng sẽ bị ẩn đi, không thể chọn trong màn hình *Arrival Confirmation*.
- **Quy tắc đóng một phần:** Nếu chỉ đóng một số item trong PO, hệ thống sẽ tự động tính toán lại tổng giá trị còn lại của PO và thực hiện đăng ký cập nhật lại trên ERP và MES.

---

## 7. 🗑️ Xóa Dữ Liệu Đơn Đặt Hàng (Purchase Order Data Delete Document)

**Vào:** Electronic Document → Purchase → Purchase Order Data Delete Document

- **Mục đích:** Xóa vĩnh viễn dữ liệu PO bị nhập sai.
- **Điều kiện:** PO **chưa từng được xử lý nhập kho**. Nếu đã nhập kho thực tế, nút xóa sẽ bị khóa (phải dùng *Return Product Document* để xuất trả).
- **Tác động:** Đối với các đơn hàng nhập khẩu, toàn bộ thông tin B/L và tờ khai thông quan đã đăng ký đi kèm với PO này cũng sẽ bị xóa sạch khỏi cơ sở dữ liệu. Cần kiểm tra kỹ lưỡng trước khi phê duyệt vì đây là thao tác xóa dữ liệu vật lý vĩnh viễn.

---

## 8. 💰 Purchase Resolution (Đóng Sổ Thanh Toán)

**Vào:** Electronic Document → Cost Management → Purchase Resolution Document

Dùng để hoàn tất công việc đóng sổ và ghi nhận công nợ thanh toán cho các đơn mua hàng.

### 8.1 Phân loại đóng sổ theo chứng từ gốc:
- **Arrival Confirmation Document:** Dùng khi cần thanh toán trước cho đối tác trước khi hoàn tất kiểm tra nhập khẩu (trước khi xử lý nhập kho thực tế).
- **Receiving Confirmation Document:** Dùng khi hàng đã nhập kho thực tế xong và tiến hành đóng sổ công nợ.
- **Return Product Document:** Dùng khi tiến hành đóng sổ giảm trừ cho đơn hàng đã xuất trả lại.

### 8.2 Các bước thao tác & Trường dữ liệu chi tiết:
1. **Giá trị ghi nợ và ghi có:** Giá trị cố định do hệ thống tự tính, không được sửa.
2. **Mô tả trên chứng từ:** Hệ thống tự động điền thông tin mô tả, người dùng không cần ghi riêng.
3. **Ngày thanh toán:**
   - *Ngày tự chọn (8-1):* Ngày do người dùng tự ấn định, bắt buộc phải thỏa thuận trước với phòng Kế toán.
   - *Ngày quy định (8-2):* Theo lịch giải ngân cố định của công ty (Ví dụ: **ngày 15** và **ngày 30** của tháng tiếp theo).
   - *Ngày phát hành chi phí phụ (8-3):* Ngày phát hành hóa đơn chi phí phụ liên quan.
4. **Thông tin liên thông (lấy từ form trước):** Số tờ khai thông quan, số B/L tự động hiển thị (nếu là hàng nhập khẩu).
5. **Đăng ký Chi phí phụ & Chi phí thông quan (Hàng nhập khẩu):**
   - Click chọn đối tác (vendor) phụ trách vận chuyển, thông quan.
   - Nhập số tiền chi phí phụ (phí vận chuyển đường biển/đường không, cước tàu, v.v.).
   - Nếu có nhiều mục chi phí phụ cho cùng một đối tác → bấm nút thêm dòng chi phí phụ.
   - Chọn phòng ban phụ trách chịu cost chi phí phụ này (Mặc định: **Nhóm mua hàng**).
   - Hệ thống tự động phát hành bảng kê giao dịch điện tử (cố định).
6. **Mặt hàng thanh toán:** Hiển thị số lượng, đơn giá đã nhập kho và số tiền thanh toán dựa trên tỷ lệ thuế nhập khẩu.
7. **Bản ghi nợ:** Click chọn nút **"Bản ghi nợ"** để mở cửa sổ danh sách mã tài khoản kế toán, chọn đúng mã tài khoản tương ứng với chủng loại hàng cần thanh toán (Bút toán phân kỳ Cost).
8. **Chọn loại thuế và VAT:** Nhập loại hình thuế và tiền thuế VAT tương ứng.

> ✅ Khi phòng Kế toán tiếp nhận và phê duyệt hoàn tất → Chứng từ kế toán ERP sẽ được **xử lý tự động**.

---

## 9. 🏢 Luồng Mua Hàng Giữa Các Pháp Nhân (Inter-company PO & Receiving)

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

## 10. 📊 Xem Tổng Hợp Đơn Mua Hàng (Purchase Total List)

**Vào:** Home → Purchase Management → Purchase Total List

| Chức năng | Cách dùng & Quy tắc hệ thống |
|-----------|------------------------------|
| **Lọc và tìm kiếm** | Sử dụng bộ lọc (1) với nhiều tiêu chí (ngày tháng, vendor, mã hàng, trạng thái...) |
| **Sửa đổi thông tin PO** | - Nhấn nút **Thay đổi** (2) để điều chỉnh thông tin PO.<br>- ⚠️ **Quy tắc:** Nếu PO đang trong quá trình nhập kho hoặc đã nhập kho thực tế, hệ thống **khóa chức năng sửa**.<br>- Khi nhấn nút thay đổi, hệ thống sẽ tự động tạo một đơn yêu cầu thay đổi thông tin PO. |
| **In đơn đặt hàng** | - Nhấn nút **In** (3) để kết xuất bản in.<br>- Người dùng có thể chỉnh sửa thủ công nội dung cần hiển thị trên bản in (trừ các thông tin cốt lõi liên quan đến mã hàng/item). |
| **Tên tài liệu PO** | Click trực tiếp vào tên tài liệu PO để mở trực tiếp bản in chi tiết. |
| **Theo dõi tiến độ** | Cột (7) hiển thị trực quan toàn bộ trạng thái tiến trình các tài liệu liên quan đến PO (đã duyệt, đang chờ duyệt, hay chưa tạo). |

---

## 11. ❓ Các Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| Không nhập được F330 | Arrival Confirmation chưa được duyệt | Bộ phận Mua hàng duyệt Arrival Confirmation trước |
| Không làm được Receiving Confirmation | C220 (IQC) chưa Pass | Đội QC làm C220 Pass trước |
| Không thấy mặt hàng trong Receiving | Mặt hàng chưa Pass IQC | Chỉ mặt hàng Pass IQC mới được chọn |
| Không xóa được PO | PO đã được xử lý nhập kho | Không thể xóa, cần làm Return Document thay |
| Không hủy/đóng được PO | Đang có form Receiving Confirmation chờ duyệt | Cần duyệt xong hoặc từ chối form Receiving Confirmation trước khi hủy/đóng PO |

---

*Cập nhật: 2026-06-12 | Nguồn: [GROUPWARE] Purchase Manual.pptx + GROUPWARE PURCHASE, SALES FUNCTION MANUAL.pptx + Comprehensive_Groupware_Report.md*
