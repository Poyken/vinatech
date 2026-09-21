# 🔥 GW_11 — Sổ Tay Cứu Hộ & Xử Lý Sự Cố Groupware (Troubleshooting Playbook)

> **Mục tiêu:** Cung cấp hướng dẫn chẩn đoán và khắc phục 20+ sự cố phổ biến nhất trên Groupware Vinatech, bao gồm lỗi kẹt duyệt, lỗi đồng bộ ERP, lỗi màn hình MES liên quan, và lỗi xác thực SSO.

---

## ⚡ 1. Bảng Tra Cứu Sự Cố Nhanh (Quick Diagnostic Matrix)

| Mã Lỗi | Hiện Tượng / Triệu Chứng | Nguyên Nhân Cốt Lõi | Cách Xử Lý Nhanh |
| :---: | :--- | :--- | :--- |
| **GW-ERR-01** | Phiếu kẹt ở trạng thái `002` (Approving) quá lâu | Người duyệt vắng mặt hoặc chưa cài đặt ủy quyền ký thay | Cài đặt Proxy Approval hoặc nhờ Admin can thiệp |
| **GW-ERR-02** | PO đã duyệt hoàn tất nhưng không hiện trên ERP `NEOE.PU_PO` | Lỗi đồng bộ Trigger/Job hoặc mã đối tác/vật tư chưa mở trên ERP | Kiểm tra bảng log sync, chạy SP đồng bộ thủ công |
| **GW-ERR-03** | Đã làm Arrival Confirmation nhưng MES `F330` không hiện hàng | Trạng thái Arrival chưa sang `008` hoặc lệch mã kho nhập | Kiểm tra `VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` |
| **GW-ERR-04** | QC đã PASS trên `C220` nhưng GW không cho làm Receiving | Trạng thái QC chưa cập nhật vào MES bảng kết quả hoặc sai số PO | Soạn lại Receiving từ link Arrival tương ứng |
| **GW-ERR-05** | Báo lỗi tỷ giá hối đoái khi tạo đơn mua hàng nước ngoài (Overseas) | Bảng tỷ giá ngày chưa được Kế toán cập nhật trên Bizbox | Cập nhật tỷ giá hối đoái ngày trên Groupware/ERP |
| **GW-ERR-06** | Đăng ký mã NVL mới nhưng MES `A230` không tìm thấy | Mã mới chưa được phân loại hoặc chưa sync từ ERP sang MES | Đăng ký Item trên ERP ➔ Chạy sync Master Data |
| **GW-ERR-07** | PO sản xuất tháng duyệt xong nhưng MES `B310`/`B450` không thấy | Kế hoạch ngày `STB_DayProdPlan` chưa được phát hành từ Month Plan | Mở màn hình B240/B310 để phân rã Lot sản xuất |
| **GW-ERR-08** | Lỗi không xuất được kho thành phẩm trên `FG01` | Lệch thông tin giữa phiếu `Shipment Request` và mã Packing ID | Kiểm tra tồn kho vật lý và trạng thái OQC của Box |
| **GW-ERR-09** | Tự động bị văng đăng nhập khi bấm sang MES Web Portal | SSO Token trong `VINATECH_RESTFUL` hết hạn hoặc lệch Client IP | Đăng nhập lại qua cổng Portal trung tâm |
| **GW-ERR-10** | Tài khoản MES không phân quyền được theo nhân sự ERP | Trường `Appendix8` (ERPUserID) trong `STB_UserInfo` bị trống | Update `Appendix8 = NO_EMP` trên CSDL SmartFramework |

---

## 🛠️ 2. Chi Tiết Các Sự Cố & Câu Truy Vấn Khắc Phục (Detailed Runbooks)

### 2.1 GW-ERR-01: Văn Bản Kẹt Trạng Thái Trình Duyệt (`002`)
- **Triệu chứng:** Phiếu đề xuất mua sắm hoặc nghỉ phép gửi đi nhiều ngày nhưng không chuyển trạng thái, người duyệt phản ánh không thấy trong hòm thư duyệt.
- **Truy vấn kiểm tra:**
  ```sql
  -- Kiểm tra ai đang giữ phiếu và bước duyệt hiện tại
  SELECT 
      S.DOCUMENT_SAVE_CODE,
      S.DOCUMENT_SAVE_SUBJECT,
      S.DOCUMENT_SAVE_STATE,
      S.NO_EMP_WRITER,
      S.DOCUMENT_SAVE_REG_DATE
  FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE S WITH (NOLOCK)
  WHERE S.DOCUMENT_SAVE_CODE = 'MÃ_VĂN_BẢN';
  ```
- **Khắc phục:**
  1. Nếu người duyệt đang vắng mặt: Hướng dẫn người duyệt đăng nhập từ xa qua điện thoại hoặc thiết lập Ủy quyền (Delegation) cho cấp phó.
  2. Nếu người duyệt đã nghỉ việc: Yêu cầu Quản trị viên HR/IT điều chuyển văn bản sang người kế nhiệm.

---

### 2.2 GW-ERR-02: PO Đã Duyệt Hoàn Tất Nhưng Không Đồng Bộ Sang ERP
- **Triệu chứng:** Phiếu Purchase Order đã có trạng thái `008` trên Groupware nhưng khi phòng Mua hàng mở ERP Douzone (NEOE) kiểm tra thì mã đơn hàng `NO_PO` không tồn tại.
- **Nguyên nhân:**
  1. Mã nhà cung cấp (`CD_PARTNER`) chưa được kích hoạt hoặc bị khóa giao dịch trên ERP.
  2. Một trong các mã vật tư (`CD_ITEM`) trong danh sách chi tiết bị sai mã đơn vị tính hoặc chưa được duyệt trên Master Data ERP.
- **Truy vấn kiểm tra:**
  ```sql
  -- 1. Kiểm tra chi tiết PO trên Groupware
  SELECT H.NO_PO, H.CD_PARTNER, H.CD_EXCH, L.CD_ITEM, L.QT_PO, L.UM_EX_PO
  FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH H WITH (NOLOCK)
  INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_POL L WITH (NOLOCK)
      ON H.DOCUMENT_SAVE_CODE = L.DOCUMENT_SAVE_CODE
  WHERE H.NO_PO = 'MÃ_PO_CẦN_CHECK';

  -- 2. Kiểm tra xem PO đã sang ERP chưa
  SELECT NO_PO, CD_PARTNER, DT_PO, YN_SU
  FROM NEOE_ERP.dbo.PU_PO WITH (NOLOCK)
  WHERE NO_PO = 'MÃ_PO_CẦN_CHECK';
  ```
- **Khắc phục:**
  - Kiểm tra tính hợp lệ của mã đối tác và mã vật tư trên ERP.
  - Chạy thủ tục tái đồng bộ PO từ Groupware sang ERP.

---

### 2.3 GW-ERR-03: Arrival Confirmation Đã Duyệt Nhưng MES F330 Không Hiện
- **Triệu chứng:** Nhà cung cấp đã giao hàng đến xưởng, nhân sự đã làm xong phiếu Khai báo hàng về (Arrival) trên Groupware nhưng thủ kho mở màn hình **MES F330** để quét barcode và in tem thì lưới dữ liệu trống trơn.
- **Nguyên nhân:**
  - Phiếu Arrival chưa chuyển sang trạng thái `008` (vẫn còn nằm ở cấp duyệt trung gian).
  - Lệch mã kho tiếp nhận (`CD_SL`): Mã kho trên Arrival không khớp với danh mục kho được phân quyền của thủ kho đang đăng nhập trên MES.
- **Truy vấn kiểm tra:**
  ```sql
  SELECT 
      H.DOCUMENT_SAVE_CODE,
      H.NO_PO,
      H.CD_COMPANY,
      H.CD_SL,
      S.DOCUMENT_SAVE_STATE
  FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H H WITH (NOLOCK)
  INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE S WITH (NOLOCK)
      ON H.DOCUMENT_SAVE_CODE = S.DOCUMENT_SAVE_CODE
  WHERE H.NO_PO = 'MÃ_PO';
  ```
- **Khắc phục:**
  - Kiểm tra đảm bảo `DOCUMENT_SAVE_STATE = '008'`.
  - Đối chiếu mã kho `CD_SL` với danh sách mã kho chuẩn tại [Code_Warehouse_In_VietNam.xlsx](attachments/Code_Warehouse_In_VietNam.xlsx).

---

### 2.4 GW-ERR-04: Đã Kiểm Tra IQC PASS Nhưng Không Cho Làm Receiving
- **Triệu chứng:** Hàng đã về xưởng, QC đã kiểm tra và dán tem PASS trên màn hình **C220**, nhưng khi nhân viên Mua hàng bấm tạo form `Receiving Confirmation` trên Groupware thì hệ thống báo lỗi không lấy được số lượng PASS.
- **Nguyên nhân:**
  - Trên màn hình MES C220, kỹ thuật viên QC mới chỉ lưu tạm kết quả mà chưa nhấn nút **"Xác nhận hoàn thành (Confirm)"**.
- **Khắc phục:**
  - Liên hệ tổ QC mở lại màn hình **MES C220**, tìm mã lô hàng và nhấn xác nhận hoàn tất để hệ thống nhả cờ cho Groupware làm chứng từ nhập kho chính thức.
