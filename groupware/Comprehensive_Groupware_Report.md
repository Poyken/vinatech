# BÁO CÁO TOÀN DIỆN VÀ CHI TIẾT VẬN HÀNH HỆ THỐNG GROUPWARE VINATECH

**Đơn vị sử dụng:** VINATech VINA Co.,Ltd.
**Hệ thống mục tiêu:** Groupware System (gw.vinatech.com) và Giao thức liên thông MES/ERP.
**Mục đích tài liệu:** Báo cáo chi tiết đến cấp độ trường dữ liệu (Field-level) dựa trên tài liệu hướng dẫn đào tạo và kết quả đã khảo sát, mô phỏng trực tiếp từ hệ thống sống (Live System).

---

## PHẦN I. TỔNG QUAN VÀ KHẢO SÁT THỰC TRẠNG GIAO DIỆN HỆ THỐNG (UI/UX)
Sau quá trình truy cập tài khoản *92603003 (NGUYỄN VĂN ĐỨC_V3)*, hệ thống làm việc của nhân sự tại VINATech phản ánh thực tế sự đồng bộ cực cao với đào tạo:

1. **Khảo sát Nền tảng:** Giao diện hỗ trợ song ngữ linh hoạt. Thiết kế chia Sidebar Menu điều hướng rõ ràng, phân nhóm theo phòng ban (Nhân sự, Kế toán, Mua bán, Sản xuất, Hành chính).
2. **Dashboard Trung tâm (Hệ thống điều khiển nhanh):**
   * Kết nối nhanh tệp công việc "Pending Approval" (Việc cần bạn duyệt) và "My expense document" (Việc của bạn đang chờ người khác duyệt).
   * Tương tác cổng "Vina Daily Insight" cung cấp tổng quan trực quan và kết xuất nhanh thư nội bộ hoặc VinaOneQ.
3. **Cải tiến Đột phá ở Trình Thu thập Nâng cao:** 
   * Trình Rich-text Editor đã vượt qua ranh giới biểu mẫu tĩnh. Đặc biệt phát hiện: Quá trình viết Ghi chú / Trình nội dung có nút hỗ trợ **"✨ AI Tinh Chỉnh"**. Điều này cho phép Nhân sự các cấp có thể tự động rà soát từ vựng tài liệu chuyên nghiệp thông qua Trí tuệ Nhân tạo (Gemini/ChatGPT Tích hợp).
4. **Quy chuẩn Duyệt Toàn Hệ Thống (Standardized Approval Line System):** Bất kể nghiệp vụ nào đều tuân thủ nguyên tắc chọn người ký. Phân rõ vai trò: Người duyệt (Approver) - Người Đồng ý (Agreement) - Người Tham chiếu (Reference). Các biểu mẫu sau khi đẩy đi, nếu bị vướng mắc, người quản lý cấp trên được quyền "Đặt Câu hỏi trực tiếp" và người khởi tạo vào "Trả lời" (Dạng log tin nhắn) ngay trên tờ trình thay vì bị huỷ/reject ngay tức khắc.

---

## PHẦN II. PHÂN TÍCH CHUYÊN SÂU NHÓM NGHIỆP VỤ NHÂN SỰ & HÀNH CHÍNH (HUMAN RESOURCE & ADMIN)

### 1. Phê Duyệt Văn Bản Dạng Mở (Draft Document)
  * **Vị trí Tab:** Electronic Document -> Basic -> Draft Document
  * **Hoạt động:** Phục vụ cho các hoạt động không làm Form cố định. Có thể chèn File đính kèm, sửa Đổi người trình biểu mẫu (Làm hộ ai đó). Gửi đi có thể Hủy (nếu cấp trên chưa ký), sau khi hủy sẽ vào Temporary Storage (lưu trữ tạm thời).

### 2. Tuyển Dụng (Emp Request)
  * **Vị trí Tab:** Electronic Document -> Human Sources -> Emp Request
  * **Các trường dữ liệu bắt buộc:** 
    * *Phân loại tuyển:* Tuyển mới / Thay thế / Bổ sung.
    * *Cơ cấu hợp đồng:* Nhân viên chính thức / Thử việc / Công nhân thời vụ.
    * *Chi tiết cá nhân & Nghề nghiệp:* Số lượng tuyển, Giới tính ưu tiên, Kinh nghiệm, Trình độ học vấn, Chuyên ngành được đào tạo và **Ngày đến hạn kết thúc phê duyệt / tuyển dụng**.

### 3. Nghỉ Việc & Thu Hồi Quyền Hành (Employee Retire Document)
  * **Các bước thao tác chi tiết:**
    * Nếu làm hộ (Ví dụ quản lý làm cho công nhân) -> Chọn User được áp dụng. Nếu không hệ thống mặc định lấy người đang gửi.
    * Điền chính xác **"Ngày làm việc cuối cùng"**, "Ngày chính thức nghỉ" và người tiếp nhận bàn giao ("Người đảm nhiệm công việc thay thế").
    * Điền thông tin liên lạc / Địa chỉ nhân sự dùng để xuất các loại giấy tờ bưu điện chốt BHXH sau khi nghỉ.

### 4. Công Tác (Business Trip)
Quy trình được hệ thống chia rất triệt để thành 3 pha xử lý:
  * **Pha 1: Xin Phép Đi Công Tác (Business Trip Document):**
    * Chọn điểm đến (Trong nước Việt Nam / Hoặc danh sách Quốc gia khác).
    * Thiết lập Định lượng tài chính dự trù: Phụ cấp chức vụ (Mặc định lấy từ cấp HR), Phụ cấp ăn uống từng ngày, Tổng ngày, Khai báo tổng số bữa ăn thực tế (để nhân hệ số dự trù). Đính kèm hình ảnh mô tả lộ trình.
  * **Pha 2: Thay đổi Thông tin (Trip Change Document):**
    * Khi lịch trình có biến động so với Pha 1 (Đổi chuyến bay, đi trễ, gia hạn), hệ thống cung cấp "Liên kết tài liệu" để gọi lại form đã duyệt của chuyến đi đó -> Thay đổi Ghi chú -> Trình duyệt lại lịch mới.
  * **Pha 3: Báo cáo & Quyết toán (Business Trip Report):**
    * Khi trở về, gọi form "Report". Bắt buộc khai báo Hãng Hàng Không đã chuyên chở. 
    * Upload **Cuống máy bay/ Vé Tàu** và Report File dưới dạng hình ảnh, PDF. Kế toán sẽ nhìn vào phần chi phí chênh lệch thực tế để làm thanh toán / thu hồi. Bộ phận chịu chi phí phân rã sẽ được cài đặt ngay tại bước này.

### 5. Quản Lý Ngày Cán Bộ Đi Làm Lễ/Ngày Nghỉ (Holiday Work Request)
  * Cản nguyên: Khắc phục tình trạng nhân sự tăng ca cuối tuần không khai báo trước.
  * **Quy trình Thực thi:** 
    1. Đăng ký nhân viên, số giờ dự kiến, ngày chọn đi làm.
    2. Sau khi đi làm xong -> Liên kết tài liệu mở **Holiday Work Report**: Cập nhật lại "Thời gian vào" (Check-in start) và "Kết thúc" (Check-out end), kèm đính kèm Báo cáo làm gì ngày lễ đó (Tuỳ chọn).
  * **Quy trình Quản lý Dòng chạy (Tính năng cho HR/Kế Toán):**
    * Menu `Management -> Holiday Work Management -> Holiday Work Ledger`: dành riêng cho Admin nhân sự. Giám sát toàn cục ai đang thực đi làm ngày lễ, có thể Export dữ liệu ra Excel phục vụ Audit.
    * Kế toán vào giao diện `Holiday Work Calculate Management` để chạy lệnh duyệt thanh toán/làm phiếu lương thêm ngày công.

---

## PHẦN III. KẾ TOÁN & MUA HÀNG (FINANCE & PURCHASE LOGIS)

### 1. Khai báo Hồ sơ Vệ sinh (Vendor/Partner Management)
Việc chuẩn hoá Mã nhà cung cấp/khách hàng được làm siêu chặt chẽ ở bước này trước khi đưa vào giao dịch trên ERP.
  * **Trường dữ liệu bắt buộc khi đăng ký vendor mới:** Tên Đăng ký DKKD, Tên Giám đốc đại diện, Quốc gia, Địa chỉ thực, Email công ty, **Mã số Thuế**.
  * **Định tuyến Kế tóan Ngầm:** Xác định định dạng hóa đơn phát hành. Phân loại hình "Customer Business" (Khách Mua / Khách Bán / Thẻ tín dụng tổ chức / Ngân hàng thụ hưởng).
  * Khai báo chính xác số thẻ Tài Khoản Ngân hàng, Trạng thái kích hoạt: Đặt cờ trạng thái "USE" (Lưu lên hệ thống cho mọi người dùng) chứ không dùng "For mass use" (Bản nháp thụ động).

### 2. Yêu Cầu Mua Hàng (Expense Report Document)
  * Nếu mua hàng nội địa (Local Vendor): Người khởi tạo bắt buộc nhập trường Giá trị tiền cộng cơ chế tự nhảy Thuế Giá Trị Gia Tăng (VAT).
  * Nếu mua hàng nước ngoài (Overseas Vendor): Hệ thống khóa trường VAT nhưng cho kích hoạt bảng chuyển đổi "Tỷ giá hối đoái ngoại tệ" (Currency Conversion). Hệ thống tự nội suy tỷ giá thực tại khoảnh khắc bấm nút tạo form.

### 3. Yêu Cầu Thanh Toán (Disbursement Document)  
Đây là bước đóng dấu xác nhận chi tiền:
  * **Cơ chế kéo chuỗi:** Bắt buộc sử dụng nút "Tín dụng" và "Liên kết tài liệu" để gom các Đơn kêu gọi Mua sắm (đã được duyệt ở Bước 2) ghim lên form (có thể gom nhiều form Mua thành 1 lệnh Thanh toán).
  * **Dẫn chứng giao dịch:** Điểm mấu chốt, người dùng ở đây sử dụng mục Đính kèm (Attachment) tải lên phiếu hoá đơn hoặc vận đơn. **Ví dụ cụ thể:** Hồ sơ tài liệu PDF mang tên `Bee Logistics_Vina tech_By_Air_Inv-2925431946.pdf` (phiếu vận tải bằng đường hàng không) mà người dùng đệ trình sẽ được đẩy lên làm cơ sở xác thực số tiền cước phí cho Phòng Kế toàn.
  * **Tài khoản và Bút toán Phân kỳ Cost:** User tự chọn mã tài khoản thanh toán tiền, loại hoá đơn. Kế toán sẽ Fix sẵn Ngày rải ngân thanh toán hàng tháng (ví dụ: ngày 15, ngày 30), nếu User muốn ấn định ngày khác phải thỏa thuận.

---

## PHẦN IV. LÕI HỆ THỐNG SẢN XUẤT VÀ TÍCH HỢP QUẢN LÝ NHÀ MÁY (MES & PRODUCTION / WAREHOUSE)

Groupware ở Vinatech không chỉ làm về hồ sơ mà ăn cực kỳ sâu vào hệ thống Nhà máy sản xuất thông qua chức năng chuyển nhượng quyền khởi tạo từ MES A230 sang Groupware.

### 1. Đăng Ký Item Code Sinh Mã (Thay thế Tờ cài đặt MES A230)
Trước đây, bộ phận quản lý thiết lập BOM Cell/Module/Nhựa... trên hệ thống cơ sở. Nay dùng **Item Registration Document**. Trình Cấu hình rất chi tiết: 
*   Chia luồng: `[Cell] -> Single Cell`, `[Module] -> Module`, `[Raw Materials] -> Điện cực/Màng lọc/Hoá chất...`.
*   Tab tính năng "Add" - "Copy thông số cũ sửa lại" - "Delete": giúp quản lý khai báo không cần nhập lại từ đầu cùng 1 loại sản phẩm tương đương.
*   Trường thông số kỹ thuật (Spec Values) phải bao gồm: Điện áp cấu hình (Ví dụ: `12- 3.0 C035`), Tiêu chuẩn tiết diện/kích cỡ Điện dung Faraday (Ví dụ `3.5 mm`). Khai báo Nhóm bộ phận hưởng lượng kinh phí khi làm ra mặt hàng này, Sản xuất chạy Test thử (Dev) hay Sản xuất hàng loạt (Mass Production). Khai báo dự kiến đơn hàng bao giờ Order.

### 2. Thiết lập & Thay đổi E-BOM Định Mức (BOM Addition and Update)
Bản thể EBOM ban đầu phải được điền qua thiết bị gốc (ERP). Trình tự đồng bộ là:
* Lập thư thay đổi BOM trên Groupware. 
* Search tìm mã Code (Từ Bước 1) nó sẽ xổ ra dữ liệu cấp bậc các vật tư con nằm trong phái sinh. 
* Lựa chọn phiên bản BOM (Version Management) -> Cảnh báo Đỏ trong Tài liệu quy định mọi công nhân Việt Nam bắt buộc lấy BOM version code chuẩn mực là **2001**.
* Xác nhận xong, cập nhật thay đổi cho hệ thống bằng việc chèn Note giải thích trình Approve.
Tiến trình này được đánh dấu đồng bộ xong qua màn hình Audit MES: A310 (Màn Quản Trị) hoặc B310 (Màn Giám Sát PO cấp xưởng).

### 3. Quy trình Lên PO Lệnh Xuất và Kế Hoạch Ngày (Month Production Plan -> Daily Plan)
Đây là sự nâng cấp đột phá, thay vì tự chia khối lượng trên phần mềm sản xuất MES (B450).
1.  **Quản trị Lệnh Tạo mới (Add Plan):** Sao chép nhanh Kế hoạch tổng PO của các tháng trước bê y nguyên sang tháng sau. Tránh việc phải Add hàng nghìn BOM Code.
2.  **Cơ chế Chốt PO:** Lựa chọn Kiểu xử lý ("Sản Xuất" – Trạng thái cấm xoá, "Không làm" – Có thể huỷ). Sau khi tạo lệnh -> Click **"Xác nhận Lô Hàng"** thì PO sẽ tự di chuyển trạng thái *"Không được tạo"* vọt  sang *"Sản Xuất"*.
3.  **Chia rã chi tiết Kế hoạch Ngày & Định lượng Lô (LOT Breakdown):**
    * Sau khi đã bấm lệnh cho sản xuất, hệ thống đi xuống cấp "Ngày lập kế hoạch". Cấu hình rõ: "Nơi làm việc", "Cell Line" và "Ca Làm Việc".
    * User thiết lập số lượng tổng (Phải <= Lượng PO gốc).
    * Click nút **Tạo Lô (LOT)** -> Tại đây chỉ nhập giới hạn số lượng Lô nhỏ nhất (Ví dụ nhập 5000), hệ thống sẽ lấy Tổng Kế Hoạch 50.000 / 5000 để tự động cắm Cờ IN RA 10 LÔ TEM MÃ.

### 4. Quá trình Vận Hành Kho Thành Phẩm (Warehouse Management FG01)
Chuỗi thao tác hiện trường tại kho vận sau khi Hàng ra lò (Kết thúc ở trạm kế hoạch ngày):
*   Bắn Barcode để scan dữ liệu thùng `Packing ID`.
*   Luân chuyển trạng thái "Xuất ra kho trung chuyển/ kho tạm". Tích hợp ID Khách mua hàng thực tế vào Container chứa lô.
*   Thông qua trạm B750: **In tem thông tin lô hàng -> Dán Niêm Phong lên Cụm Pallet bốc xếp.**
*   Nhấn menu lệnh (Xuất lên Container): Bắn thẳng lệnh xuất theo kiện. Kỹ sư/Kho kiểm kê màn lưới chi tiết tổng lượng Pallet trong lòng Container tại giám sát B752 của MES.

## KẾT LUẬN & ĐÁNH GIÁ CẤP QUẢN TRỊ 

1. **Hiệu suất Liên kết:** Cấu trúc tổ chức của Vinatech đã xử lý rất tốt việc xoá bỏ độ trễ của các form thủ tục tay bằng điện tử hoá 100%. Đặc biệt phần Module quản lý kho & Tạo lot kế hoạch chạy máy, giúp công nhân chỉ thao tác quét, nhấn, xác nhận mà không cần tự nhập liệu gây chênh lệch.
2. **Khuyến nghị Bổ sung Tài liệu:** Như quan sát thấy công cụ **AI Tinh Chỉnh** trên màn Web thật mà slide đào tạo chưa có, cần đẩy mạnh tập huấn nhân sự dùng tính năng này để viết Request trong sáng, súc tích hơn trước khi trình Sếp ngoại quốc/Quản lý cấp trên.
3. **Tiêu Biểu Hoá Đơn Liên Thông:** Về việc hoàn thiện chứng từ thanh toán (Kéo hoá đơn Bee Logistics Air Freight), việc tích hợp này minh định mạnh tính khả dụng khi Kế toán không cần hỏi lại chứng thư file cứng, chỉ nhìn vào Lịch sử Liên Kết Tài Liệu Kéo thả trong tab Cost để kiểm Audit bất cứ lúc nào.
