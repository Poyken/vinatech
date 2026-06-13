# GW_08 — Luồng Bán Hàng & Xuất Khẩu (Sales & Shipment Flow)

> **Màn hình liên quan:** Electronic Document → Sales / Cost
> **ERP/MES liên quan:** Đồng bộ đơn bán hàng (Suju), Cập nhật tồn kho thành phẩm MES
> ← [Về INDEX](GW_INDEX.md)

---

## 🗺️ Tổng Quan Luồng Bán Hàng (Sales Flow)

Quy trình bán hàng trên Groupware được thiết kế liên thông chặt chẽ với hệ thống ERP và MES để quản lý từ khâu nhận đơn hàng đến giao hàng và ghi nhận doanh thu:

```
[1] Sales Order Request (Suju)   ← Đăng ký đơn bán hàng (Duyệt → Tự động tạo PO tháng & đăng ký ERP)
           ↓
[2] Shipment Request (출하요청)   ← Yêu cầu xuất hàng (Duyệt → Bắn Barcode Packing ID → Trừ tồn kho MES)
           ↓
[3] Shipment Confirmation (출하확인) ← Xác nhận xuất hàng (Duyệt → Đăng ký Doanh thu/Thông quan ERP)
           ↓
[4] Sales Resolution (매출결의)   ← Quyết toán doanh thu (Duyệt tự động chuyển Kế toán duyệt sổ)
```

---

## 1. ✍️ Sales Order Request Document (Suju - Đăng Ký Đơn Bán Hàng)

**Vào:** Electronic Document → Sales → Sales Order Document

- **Mục đích:** Khai báo đơn đặt hàng từ đối tác/khách hàng.
- **Các bước thực hiện:**
  1. **Tuyến phê duyệt & Tham chiếu từ Excel:**
     - **Tuyến phê duyệt (Approval):** **11804002-Lê Thị Vân Anh** → **Kim Kyeong Cheol** (CEO).
     - **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.
  2. Chọn liên kết thông tin **Kế hoạch bán hàng (Sales Plan)** đã thiết lập từ trước.
  3. Nhập các thông tin chi tiết của đơn hàng (Khách hàng, mã hàng, số lượng, đơn giá, ngày giao hàng mong muốn). Các bước thao tác tương tự như đăng ký 수주 trực tiếp trên ERP trước đây.
- **Tác động hệ thống:** Sau khi được phê duyệt hoàn toàn:
  - Đơn hàng được **tự động đăng ký** vào hệ thống ERP dưới dạng Suju.
  - Đồng thời, hệ thống **tự động tạo** một kế hoạch sản xuất tháng tương ứng trên giao diện *Month Production Plan* (GW_03) của nhà máy phụ trách.

---

## 2. 🚛 Shipment Request Document (Yêu Cầu Xuất Hàng / Deliver Out)

**Vào:** Electronic Document → Sales → Deliver Out Document (Trên menu tiếng Hàn là 출하요청서)

- **Mục đích:** Yêu cầu bộ phận kho chuẩn bị và bốc xếp hàng để xuất đi.
- **Các bước thực hiện:**
  1. **Tuyến phê duyệt & Tiếp nhận/CC quy định từ Excel:**
     - **Tuyến phê duyệt (Approval):** **71903004-Nguyễn Thị Linh_V1** → **21910034-Trần Quang Thỏa** (Final Approval).
     - **Tuyến tiếp nhận (Receipt):** Nhóm Xuất nhập khẩu (*71903004-NGUYỄN THỊ LINH_V1*, *72310004-NGUYỄN THỊ THÚY_V7*, *72401002-VŨ THỊ MINH NGỌC*).
     - **Tuyến tham chiếu (Reference):** Nhân viên chất lượng, Trưởng nhóm chất lượng (Quality Team Member/Leader).
  2. Chọn liên kết đến đơn bán hàng **Suju** đã được duyệt trước đó.
  3. Nhập số lượng yêu cầu xuất hàng (의뢰수량).
  4. **Đối với đơn hàng xuất khẩu (Ngoại thương):** Tiến hành nhập thông tin hóa đơn xuất khẩu (Invoice) liên kết từ phân hệ SFA.
  5. Trình duyệt biểu mẫu. Người lập form (người trình) sẽ được hệ thống **tự động duyệt** qua bước của mình (Auto-approved).
- **Tác động hệ thống:**
  - ERP ghi nhận trạng thái yêu cầu xuất hàng (Đăng ký 의뢰) và đăng ký hóa đơn xuất khẩu (Đăng ký Invoice).
  - Tự động kết nối với MES để truy xuất dữ liệu tồn kho sản phẩm thực tế.
  - Thủ kho thực hiện quét mã vạch **Packing ID** trên MES. Hệ thống sẽ **tự động trừ tồn kho thành phẩm** trên MES và đăng ký xuất hàng trên ERP.

---

## 3. ✅ Shipment Confirmation Document (Xác Nhận Xuất Hàng)

**Vào:** Electronic Document → Sales → Shipment Confirmation Document (출하확인서)

- **Mục đích:** Chốt thực tế hàng đã rời nhà máy để vận chuyển đến khách hàng hoặc xếp lên tàu/máy bay.
- **Các bước thực hiện:**
  1. **Tuyến tiếp nhận & Tham chiếu từ Excel:**
     - **Tuyến tiếp nhận (Receipt):**
       - **[Trong nước - Domestic]:** Nhóm Kinh doanh nội địa (*10220201-Nguyễn Trường Sa, 12310002-Nguyễn Trà Linh, 12402002-Đào Thị Bích Ngọc, 12404029-Nguyễn Văn Hoàng, 12404030-Nguyễn Thị Thảo, 12406011-Ngô Hồng Nhung, 12407002-NGUYỄN THỊ THẢO_V3, 12408006-ĐẶNG THANH LÂM*).
       - **[Xuất khẩu - Overseas]:** Nhóm Xuất nhập khẩu (*71903004-NGUYỄN THỊ LINH_V1, 72310004-NGUYỄN THỊ THÚY_V7, 72401002-VŨ THỊ MINH NGỌC*).
     - **Tuyến tham chiếu (Reference):** Nhóm nhận Kế toán*.
  2. Chọn liên kết đến biểu mẫu **Shipment Request** đã hoàn tất ở bước 2.
  3. Khai báo thông tin bán hàng tùy theo loại hình giao dịch:
     - **Đối với giao dịch trong nước (Domestic):** Nhập thông tin doanh thu/매출 (giống hệt cách đăng ký doanh thu trên ERP).
     - **Đối với giao dịch xuất khẩu (Overseas):** Nhập thông tin khai báo Hải quan (Customs) và ngày tàu chạy/선적 (giống cách đăng ký thông quan/선적 trên ERP).
  4. Gửi duyệt biểu mẫu.
- **Tác động hệ thống:** Sau khi duyệt hoàn tất:
  - ERP ghi nhận doanh thu chính thức (국내 매출 등록) hoặc đăng ký thông tin hải quan và vận đơn xuất khẩu (해외 통관, 선적 등록).
  - Hệ thống tự động phát hành chứng từ kế toán/phiếu toán chi phí (전표 발행).

---

## 4. 💰 Sales Resolution Document (Quyết Toán Doanh Thu)

- **Cơ chế hoạt động:** Ngay sau khi *Shipment Confirmation Document* được phê duyệt hoàn tất, hệ thống Groupware sẽ **tự động khởi tạo và trình duyệt** biểu mẫu Quyết toán doanh thu:
  - **국내매출결의서** (Đơn quyết toán doanh thu trong nước).
  - **해외매출결의서** (Đơn quyết toán doanh thu xuất khẩu).
- **Phê duyệt:** Biểu mẫu này sẽ được tự động chuyển đến phòng Kế toán (Accounting Team). Kế toán viên kiểm tra đối chiếu và thực hiện phê duyệt bút toán kế toán tạm hoãn (미결전표 승인처리) để ghi nhận doanh thu chính thức vào sổ sách tài chính.

---

## 5. 🚫 Hủy / Đóng Đơn Bán Hàng (Sales Order Cancel & Closing)

Khi đơn hàng bị thay đổi thỏa thuận hoặc hủy bỏ từ phía khách hàng:

**Vào:** Electronic Document → Sales → Sales Order Cancel/Closing Document (수주데이터삭제/종결신청서)

- **Tuyến phê duyệt (Approval):** **11804002-Lê Thị Vân Anh** (Final Approval).
- **수주데이터삭제신청서 (Hủy Suju):** Xóa dữ liệu Suju khỏi hệ thống.
  - *Điều kiện:* PO yêu cầu xuất hàng (출하의뢰) liên kết với Suju này **chưa được đăng ký**. Nếu đã có yêu cầu xuất hàng, hệ thống cấm xóa.
- **수주종결신청서 (Đóng Suju):** Đóng/kết thúc đơn hàng đối với các phần sản lượng chưa giao.
  - *Điều kiện:* Yêu cầu xuất hàng (출하의뢰) liên quan **không được ở trạng thái đang xử lý** (đang chờ duyệt).

---

## 6. 🗑️ Xóa Dữ Liệu Xuất Hàng (Shipment Data Delete Document)

Dùng khi thủ kho hoặc nhân viên logistics nhập sai thông tin xuất hàng cần thu hồi dữ liệu.

**Vào:** Electronic Document → Sales → Shipment Data Delete Document (출하데이터삭제신청서)

- **Điều kiện:** Phiếu toán kế toán liên quan **chưa được phê duyệt** (미결전표 상태). Nếu kế toán đã phê duyệt chốt sổ, hệ thống sẽ **khóa chức năng xóa**.
- **Tác động:** Khi được duyệt xóa, hệ thống sẽ đồng thời hủy bỏ toàn bộ chuỗi dữ liệu liên quan trên ERP bao gồm: Yêu cầu xuất hàng (의뢰), Hóa đơn (송장), Thực xuất (출하), Doanh thu (매출) và Phiếu toán (전표).

---

## 📊 Xem Tổng Hợp Đơn Bán Hàng (Sales Total List)

**Vào:** Home → Sales Management → Sales Total List

Màn hình quản trị cho phép theo dõi toàn bộ trạng thái đơn hàng:
- Cung cấp bộ lọc tra cứu theo ngày, khách hàng, mã hàng.
- Xem chi tiết tiến độ giao hàng của từng đơn Suju (số lượng đặt, số lượng yêu cầu xuất, số lượng thực xuất).
- Theo dõi trạng thái của các tài liệu liên thông (Suju -> Shipment Request -> Shipment Confirmation).

---

*Cập nhật: 2026-06-12 | Nguồn: GROUPWARE PURCHASE, SALES FUNCTION MANUAL.pptx + Comprehensive_Groupware_Report.md*
