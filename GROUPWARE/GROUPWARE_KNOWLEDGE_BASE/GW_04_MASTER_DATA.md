# GW_04 — Master Data (Mã Code, BOM, Nhà Thầu)

> **Màn hình:** Electronic Document → Item / Basic / Production-Development
> **MES kiểm tra:** A230 (Code), A310 (BOM), B310 (PO)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 📦 Đăng Ký Mã Vật Tư Mới (Item Registration)

**Vào:** Electronic Document → Item → Item Registration Document

> ⚠️ **Bối cảnh:** Trước đây dùng màn A230 trên MES. Hiện nay EA HQ yêu cầu đăng ký trên Groupware thay thế.

### Bước 1: Chọn thông tin phê duyệt
1. Chọn người duyệt.
2. Ghi tiêu đề biểu mẫu.
3. Tải file đính kèm (nếu có).
4. Chọn người làm form hộ (nếu cần) - sử dụng khi làm thay cho người khác.

### Bước 2: Chọn kiểu code và phân loại tài liệu
Chọn đúng phân loại tài liệu (**documentSaveApprovalTarget**) tương thích chính xác với tuyến phê duyệt:
- `Nguyên liệu thô` (`STATIC_DATA_000174`)
- `Cell đơn` (`STATIC_DATA_000508`)
- `Mô-đun` (`STATIC_DATA_000509`)
- `F/C 탄소Công nghệ원` (`STATIC_DATA_000529`)
- `F/C MEA` (`STATIC_DATA_000517`)
- `S/C Điện cực` (`STATIC_DATA_000601`)
- `상품` (`STATIC_DATA_000596`)

### Bước 3: Điền thông tin code (Các nút chức năng trên lưới tab)
- **Add:** Thêm một tab mới để đăng ký đồng thời một mã code khác.
- **Copy:** Sao chép nguyên vẹn nội dung của tab trước đó. Đây là tính năng **"Copy thông số cũ sửa lại"** giúp quản lý khai báo nhanh chóng.
- **Delete:** Xóa tab hiện hành nếu không cần thiết.

### Bước 4: Khai báo chi tiết thuộc tính vật tư (Detail Technical Fields)
Cần điền đầy đủ các thuộc tính kỹ thuật sau trên giao diện biểu mẫu:
1. **Loại vật tư Chọn (clsItem - Item Class):**
   - `raw materials` (Mã `001`) | `subsidiary materials` (Mã `002`) | `semi-finished products` (Mã `004`) | `goods` (Mã `005`) | `expendables` (Mã `006`) | `service` (Mã `007`) | `construction` (Mã `008`) | `stored goods` (Mã `009`) | `expenses` (Mã `010`)
2. **Tên vật tư (nmItem):** Nhập tên sản phẩm (Tiếng Việt/Tiếng Hàn).
3. **Tên tiếng Anh (enItem):** Nhập tên Tiếng Anh của vật tư.
4. **Quy cách (stndItem):** Quy cách kỹ thuật sản phẩm.
5. **Quy cách chi tiết (stndDetailItem):** Chi tiết bổ sung cho quy cách.
6. **Phát triển/Loại sản xuất (itemType):** Chọn `Phát triển` (`STATIC_DATA_000510`) hoặc `Sản xuất hàng loạt` (`STATIC_DATA_000511`).
7. **Tên đối tác kinh doanh chính (salesPartner):** Tên Vendor chính cung cấp/thụ hưởng.
8. **Ứng dụng (application):** Ứng dụng thực tế của sản phẩm.
9. **EAU (eau):** Lượng sử dụng ước tính hàng năm.
10. **expectedDate (expectedDate):** Ngày mong muốn hoàn thành khai báo/đặt hàng.
11. **Đơn vị Chọn (unitIm - UoM):** `EA`, `BOX`, `G`, `KG`, `L`, `M`, `M2 (SQM)`, `MET`, `KP`.
12. **Phân loại Lớn (clsL - Large Class):**
    - `[L01] SC-조립` | `[L02] FC-MEA` | `[L03] 환경Bộ lọc` | `[L04] 상품` | `[L05] 하이브리드커패시터` | `[L06] PS` | `[L07] SC-Điện cực` | `[L08] FC-Bộ phận hỗ trợ` | `[L09] ENS`
13. **Phân loại Vừa (clsM - Medium Class):**
    - `[M01] Lead Type` | `[M02] Snap Type` | `[M03] Lug Type` | `[M04] Hoạt động탄` | `[M05] 도전제` | `[M06] 집Tất cả` | `[M07] Vách ngăn` | `[M08] Chất điện phân` | `[M09] Vỏ`
14. **Nhóm vật tư Chọn (grpItem - Small Class / Item Group):**
    - `계면Hoạt động제` (`001`) | `Đầu nối cao su` (`002`) | `Khác` (`003`) | `Tấm đầu cực` (`004`) | `도전제` (`005`) | `Cho Module Vật liệu chip` (`006`) | `Cho Module HARNESS` (`007`) | `Cho Module PCB` (`008`) | `Cho Module WIRE` (`009`)
15. **Nhà sản xuất (nmMaker):** Tên hãng sản xuất.
16. **Hạn sử dụng (dyValid):** Số ngày hiệu lực sử dụng (Mặc định: `0` nếu không giới hạn).
17. **SIZE Chọn (grpMfg - Size):** `0612` (`052`), `0813` (`001`), `0816` (`051`), `0816L` (`057`), `0820` (`002`), `0820C` (`003`), `0820L` (`058`), `0825` (`004`), `0830` (`005`), v.v.
18. **Loại thu mua Chọn (tpProc - Procurement Type):** `purchased product` (`P`) | `Product` (`M`) | `outsourced product` (`S`).
19. **Loại vật tư (tpItem - Item Type):** `General product` (`SIN`) | `The aging property item` (`VAL`) | `FAS item` (`FAS`) | `GENERIC ARTICLE` (`GEN`) | `SET bosom` (`SET`).
20. **내Nước ngoài Loại (tpPart - Local/Foreign):** `Make` (`P` - Trong nước) | `Foreign language` (`V` - Nước ngoài).
21. **화학물 여부 (chemicalYn - Chemical Y/N):** `Y` hoặc `N`.
22. **casNo (CAS Number):** Nhập mã đăng ký CAS nếu là hóa chất.
23. **Cell đơn/Mô-đun Loại (moduleCellDivision):** `CELL` (`C`) hoặc `MODULE` (`M`).
24. **moduleCellQty:** Số lượng cell đơn bên trong module.
25. **Chiều dài Chọn (length):** `12` (`021`), `13` (`001`), `16` (`020`), `20` (`002`), `25` (`003`), `30` (`004`), `107` (`023`), `138` (`026`), `159` (`019`), v.v.
26. **Điện áp Chọn (volt):** `2.3` (`001`), `2.5` (`002`), `2.7` (`003`), `3` (`004`), `3.8` (`005`), `4.0` (`015`), `12` (`010`), `16` (`011`), `16.2` (`012`).
27. **Đường kính Chọn (sizeW):** `10` (`002`), `13` (`003`), `16` (`004`), `18` (`005`), `22` (`006`), `25` (`007`), `27` (`008`), `29` (`013`), `30` (`009`), v.v.
28. **Dung lượng / Thể tích (volume):** Giá trị điện dung Faraday (Ví dụ: `3.5`).
29. **Nhóm sản phẩm Chọn (productionGrpItem):**
    - `EDLC` (`100`) | `VPC` (`110`) | `VET` (`120`) | `Support` (`200`) | `Catalyst` (`210`) | `MEA` (`220`) | `LIC` (`300`)
30. **Thông số QC đặc thù (nếu có):** `acEsr` (AC-ESR), `dcEsr` (DC-ESR), `maximumCurrent` (Dòng cực đại), `leakageCurrent` (Dòng rò).
31. **Điện cực (electrod):** Chọn cực tính `+` hoặc `-`.

### ⚙️ Cơ chế đồng bộ dữ liệu tự động (Auto-Sync Flow):
- **Cố định đường line phê duyệt:** Tuyến phê duyệt (Approval Line) được hệ thống tự động khóa/cố định sẵn dựa trên loại vật tư (zách hóa/자재유형) được đăng ký.
- **Quy tắc điền thông tin tại bước Tiếp nhận (Receipt Stage):**
  - **Với Nguyên vật liệu (Raw material):** Tại bước tiếp nhận phê duyệt, bắt buộc phải điền mã vật tư và các thông tin chi tiết của vật tư.
  - **Với Thành phẩm / Bán thành phẩm (Product / Semi-finished):** Phải khai báo đầy đủ các thông số sản phẩm, quy cách kỹ thuật và thông tin phụ trợ.
- **Tiến trình đồng bộ:** Sau khi phê duyệt hoàn tất:
  1. Dữ liệu mã code mới sẽ tự động đăng ký vào hệ thống **ERP Việt Nam**.
  2. Hệ thống đồng bộ mã vật tư đó sang **ERP Hàn Quốc (HQ)**.
  3. Dữ liệu nạp tự động xuống màn hình thiết bị **MES A230** để sẵn sàng sử dụng.

---

## 2. ✏️ Cập Nhật Thông Tin Mã Code (Item Change)

**Vào:** Electronic Document → Item → Item Change Document

1. Nhấn nút **"Tìm kiếm mặt hàng"** → Một cửa sổ popup hiện ra.
2. Tìm kiếm và chọn mã code cần cập nhật thông tin → Nhấn **"Áp dụng lựa chọn"**. Hệ thống sẽ tự động hiển thị mã code và các thông tin đi kèm.
3. Cập nhật lại các trường thông tin cần thiết:
   - **Kiểu loại mua hàng** (Purchase Type)
   - **Kho đưa vào** (Incoming Warehouse)
   - **Kho đưa ra** (Outgoing Warehouse)
   - **Bộ phận chịu cost** (Cost Center)
4. Nhập nội dung giải thích lý do cần cập nhật (6).
5. Thực hiện các thao tác ở chân trang:
   - **Gửi đi (1):** Gửi tới người duyệt.
   - **Lưu tạm thời (2):** Lưu nháp vào Temporary Storage để chỉnh sửa/gửi sau.
   - **Xóa (3):** Xóa biểu mẫu hiện tại.
   - **Xem trước (4):** Review tổng thể form trước khi gửi.
   - **Reset (5):** Xóa hết dữ liệu nhập lại từ đầu.


---

## 3. 🧩 Tạo / Sửa BOM

### 3.1 Tạo BOM trên ERP (EBOM)

**Vào:** ERP → Tìm kiếm "EBOM" trên thanh công cụ

1. Chọn mã code thành phẩm/bán thành phẩm
2. Nhấn Tìm kiếm
3. Nhập phiên bản BOM:
   > [!WARNING]
   > **CẢNH BÁO BẮT BUỘC:** Mọi nhân sự/công nhân Việt Nam khi đăng ký phiên bản BOM trên hệ thống bắt buộc phải chọn hoặc nhập đúng mã BOM version code chuẩn mực của Việt Nam là **2001**. Tuyệt đối không chọn hoặc nhập version khác.
4. Thêm dòng dữ liệu
5. Chọn mã nguyên vật liệu
6. Chọn số lượng NVL
7. Lưu lại

**Cập nhật BOM đã có:**
1. Tìm mã code thành phẩm
2. Nhấn Tìm kiếm → chọn phiên bản cần sửa (chọn bản **2001**)
3. Thay đổi thông tin → Lưu

### 3.2 Phê Duyệt BOM trên Groupware

**Vào:** Electronic Document → Production/Development → BOM Addition And Update Document (Mã biểu mẫu: `bomAdditionDocument`)

| Bước | Thao tác |
|------|----------|
| 1 | Chọn line phê duyệt |
| 2 | Đặt tên form |
| 3 | Đính kèm file |
| 4 | Thêm mục / tìm kiếm code → Hệ thống tự sinh các mã đi kèm |
| 5 | Ghi chú / giải thích lý do thay đổi (chèn Note giải thích rõ ràng lý do thay đổi để trình Approve) |
| 6 | Gửi đi duyệt |

### 3.3 Kiểm Tra BOM Sau Khi Duyệt & Đồng Bộ MES

Tiến trình đồng bộ BOM từ ERP/Groupware sang MES sẽ tự động chạy sau khi được duyệt:
- **A310 (Màn Quản Trị MES):** Sử dụng để kiểm tra BOM đã đồng bộ chính xác chưa.
- **B310 (Màn Giám Sát PO cấp xưởng MES):** Xem khi làm PO xem BOM đã được áp dụng.
- **A230 (Màn Thiết Lập MES):** Xem lại mã code.

---

## 4. 🏢 Đăng Ký Nhà Thầu / Khách Hàng (Partner Management)

**Vào:** Electronic Document → Basic → Partner Management

### 4.1 Quy trình đăng ký mới:
1. **Chọn line phê duyệt:** Chọn line có sẵn hoặc thiết lập người duyệt.
2. **Điền thông tin cơ bản:** Tiêu đề, đính kèm tài liệu doanh nghiệp, điền người làm hộ (nếu đăng ký giúp người khác - hệ thống mặc định lấy tên người đăng nhập).
3. **Các trường thông tin bắt buộc:**
   - **Quốc gia:** Nước đặt trụ sở đối tác.
   - **Tên công ty:** Tên đăng ký doanh nghiệp (DKKD) đầy đủ.
   - **Người đại diện:** Tên Giám đốc đại diện pháp lý.
   - **Email:** Email liên hệ giao dịch chính.
   - **Mã số thuế:** ⚠️ **Bắt buộc nhập chính xác tuyệt đối**.
   - **Danh mục thuế:** Thường chọn **"Người nộp thuế chung"** (do doanh nghiệp thường có cả hoạt động mua và bán).
   - **Công ty chính/con:** Thường chọn **N** (Không phải công ty con).
   - **Định dạng hóa đơn:** Chọn định dạng hóa đơn phát hành của đối tác.
   - **Mục đích:** Phân loại định tuyến ngầm (Khách hàng bán hàng/Khách Bán, Khách hàng mua hàng/Khách Mua, Công ty thẻ tín dụng, Đối tác ngân hàng).
   - **Phân loại:** Mua, Bán, hoặc Khác.
   - **Loại hình & Lĩnh vực kinh doanh:** Điền ngành nghề, lĩnh vực đối tác hoạt động.
   - **Địa chỉ chi tiết:** Nhập địa chỉ chi tiết (thường nhập cả địa chỉ tiếng Anh/Hàn và tiếng Việt vào 2 trường địa chỉ tương ứng).
   - **Trạng thái:** Còn hoạt động hay không.
   - **Sử dụng:** Chọn **Use** để kích hoạt sử dụng ngay trên toàn hệ thống cho mọi người dùng, **không chọn** *For mass use* (trạng thái nháp, thụ động chưa sử dụng).
4. **Thông tin ngân hàng giao dịch:**
   - Chọn ngân hàng giao dịch của đối tác.
   - Nhập chính xác số tài khoản và tên tài khoản/số thẻ thụ hưởng của đối tác.
5. **Thực hiện gửi duyệt:**
   - Viết ghi chú chi tiết về đối tác (ở khung nội dung).
   - Nhấn **"Gửi đi"** (1) để trình duyệt, hoặc **"Lưu trữ tạm thời"** (2) để nháp, hoặc **"Xem trước"** (4) để review lại form, hoặc **"Reset"** (5) để làm lại mới hoàn toàn.

### 4.2 Cập nhật thông tin đối tác:
**Vào:** Electronic Document → Basic → Modify Partner Management

1. Chọn line phê duyệt cho form cập nhật.
2. Đặt tiêu đề và đính kèm tệp tin liên quan (ví dụ: DKKD mới, thay đổi thông tin tài khoản ngân hàng).
3. Nhấp chọn mục **"Chọn nhà thầu/vendor/khách hàng cần thay đổi thông tin"** → Tìm kiếm và click chọn đối tác tương ứng.
4. Tại form thông tin hiển thị, trực tiếp nhập đè dữ liệu mới vào các textbox hoặc chọn lại combo box cần thay đổi.
5. Ghi rõ lý do thay đổi ở phần nội dung và nhấn **"Gửi đi"** / **"Lưu trữ tạm thời"** / **"Xem trước"**.

---

## 5. 💰 Đăng Ký / Thay Đổi Đơn Giá (Item Price Addition & Change)

**Vào:** Electronic Document → Item → Item Price Addition Document (hoặc Item Price Change Document)

### 5.1 Tuyến phê duyệt quy định từ Excel:
- **Tuyến phê duyệt (Approval):** **71908026-Đào Thị Phiên** → **21910034-Trần Quang Thỏa** (Final Approval).
- **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.

### 5.2 Nghiệp vụ & Ràng buộc:
- **Phân loại đơn giá:**
  - **Đơn giá [Bán] (Sales Price):** Quản lý giá bán chi tiết theo từng đối tượng khách hàng.
  - **Đơn giá [Mua] (Purchase Price):** Quản lý giá mua chi tiết theo từng nhà cung cấp (vendor).
- **Ràng buộc:** Bắt buộc mặt hàng phải được tạo mã code thành công trước khi đăng ký đơn giá (nếu chưa có mã code, phải làm đơn *Item Registration Document* trước).
- **Đồng bộ ERP & Lưu lịch sử thay đổi:**
  - Đơn giá sau khi hoàn tất phê duyệt trên Groupware sẽ tự động cập nhật xuống hệ thống **ERP**.
  - Hệ thống tự động ghi nhận lịch sử thay đổi đơn giá (đơn giá cũ, đơn giá mới) và theo dõi hiệu lực theo mốc thời gian: **Ngày bắt đầu hiệu lực (Start Date)** và **Ngày kết thúc hiệu lực (End Date)**.

---

*Cập nhật: 2026-06-12 | Nguồn: Hướng dẫn đăng ký các loại code.pptx + Hướng dẫn sửa đổi BOM trên ERP và Groupware.pptx + Hướng dẫn Groupware_Form đăng ký nhà thầu_khách hàng.pptx + GROUPWARE PURCHASE, SALES FUNCTION MANUAL.pptx + Vietnam Corporation Approval Setting List.xlsx + Comprehensive_Groupware_Report.md*
