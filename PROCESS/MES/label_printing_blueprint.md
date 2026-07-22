# Cẩm Nang Phát Triển Màn Hình In Tem Nhãn & Đề Bài Thực Hành (B890 - Hela Label)

Tài liệu này mô phỏng một **yêu cầu thực tế (User Story dưới dạng Email yêu cầu)** từ đối tác Hela (Đức), bản vẽ thiết kế (mockup) tem nhãn, các điểm chung của hệ thống in tem nhãn khách hàng trên hệ thống NAIS MES của Vinatech, và hướng dẫn triển khai chi tiết màn hình **`B890`**.

---

## 1. 📧 Email Yêu Cầu Thực Tế (Simulated Request Email)

Dưới đây là chuỗi email yêu cầu triển khai được chuyển tiếp từ đối tác đến phòng IT Vinatech:

```
From: Le Quang Tai (IT Manager) <tai.lq@vinatech.com.vn>
Sent: Wednesday, July 22, 2026 10:15 AM
To: Nguyen Van Duc (MES Developer) <duc.nv@vinatech.com.vn>
Subject: Fwd: REQ: Phát triển màn hình in tem nhãn mới cho đối tác Hela (Đức) - TCode: B890

Đức ơi, 

Bên phòng Kế hoạch (Mrs. Xuân) và OQC vừa họp xong với đối tác Hela (Đức). Họ yêu cầu thiết lập riêng một màn hình in tem cho dòng sản phẩm xuất khẩu Châu Âu để dán thùng gỗ (Outer) và hộp carton nhỏ (Inner). 

Anh gửi thông tin chi tiết email yêu cầu từ Klaus (QA Hela) bên dưới. 
Em lên kế hoạch tạo màn hình B890 và viết SP xử lý nhé. Hạn chót test trên Staging là ngày kia (24/07) để bàn giao cho OQC chạy thử.

Thanks,
Tài.

---------- Forwarded message ----------
From: Klaus Hoffman <klaus.hoffman@hela-gmbh.de>
Date: Tue, Jul 21, 2026 at 4:32 PM
Subject: Labeling Requirements for Vinatech EDLC Shipments (Project HELA-2026)
To: Xuan Nguyen <xuan.nt@vinatech.com.vn>, Tai Le <tai.lq@vinatech.com.vn>

Dear Vinatech Team,

Following our technical alignment meeting yesterday, we would like to formalize the custom labeling requirements for our incoming EDLC shipments starting next month. 

Please configure your MES system to generate and print labels according to the specifications below:

1. Packaging Specification:
   - 1 Wooden Crate (Outer Box) = 4 Carton Boxes (Inner Boxes).
   - Outer Label must be attached to the crate; Inner Labels must be attached to each carton box.

2. Quality Gate Verification:
   - Labels must only be generated for Lots that have completed the packaging process in MES (B523) and successfully passed OQC Inspection (OQC Decision = PASS). 
   - Print client should throw an error and block printing if these conditions are not met.

3. Serialization Logic (Hela Serial Number):
   - Format: HELA-YYWW-XXXXX
     * YYWW: Year and ISO Week of the packaging date (e.g., Week 29, 2026 -> 2629).
     * XXXXX: 5-digit sequential counter, starting at 00001 and resetting back to 00001 at the beginning of each ISO week.
   - Inner Box Serial: Unique sequential numbers (e.g., HELA-2629-00001, HELA-2629-00002...).
   - Outer Box Serial: Must concatenate the 4 Inner Box serials inside it, separated by hyphens.
     * Example: HELA-2629-00001-00002-00003-00004

4. 2D Barcode (QR Code) Content:
   - The QR code on both Inner and Outer labels must encode the following data:
     [Material Code] | [Quantity] | [PO Number] | [OQC Inspector Name - ASCII only] | [Box Serial No]
   - Use pipe character '|' as field separator. The inspector name must have all Vietnamese diacritics removed to prevent scanning errors.

5. Dimension & Layout:
   - Label dimension is 80mm x 50mm (Landscape orientation). 
   - Please refer to the attached mockup for the visual design.

Best regards,

Klaus Hoffman
Quality Assurance Manager
Hela GmbH
```

---

## 2. 🎨 Thiết Kế Tem Nhãn & Mockup (Visual & Layout Design)

### 2.1 Bản vẽ Mockup trực quan (Image Artifact)
Dưới đây là hình ảnh thiết kế mẫu tem được bộ phận OQC phê duyệt:

![Hela Label Mockup](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/05b0b703-81bb-4e41-aa39-56938ce13a1c/hela_label_mockup_1784691996123.png)

### 2.2 Layout chi tiết (ASCII representation)

#### Mẫu A: Nhãn Hộp Trong (Inner Box Label)
```
+--------------------------------------------------------------------------+
|  HELA GERMANY                                  +-------------------+     |
|  PART NO: HELA-ECVT30-368                      |   QR CODE FIELD   |     |
|  DESC: CAP, 3.0V 360F                          |  (Scan to verify) |     |
|                                                +-------------------+     |
|  LOT NO:  260722-001 (1D BARCODE)                                        |
|  ||||||||||||||||||||||||||||||||||||||||||||||||||||||                  |
|                                                                          |
|  QTY: 1000 PCS             OQC: PASS            DATE: 2026-07-22         |
|  OQC INSP: LE VAN DUC      PO NO: PO-2026-0089                           |
|                                                                          |
|  S/N: HELA-2629-00001                                  [ Inner Box ]     |
+--------------------------------------------------------------------------+
```

#### Mẫu B: Nhãn Thùng Ngoài (Outer Box Label)
```
+--------------------------------------------------------------------------+
|  HELA GERMANY                                  +-------------------+     |
|  PART NO: HELA-ECVT30-368                      |   QR CODE FIELD   |     |
|  DESC: CAP, 3.0V 360F                          | (Contains 4 Inner |     |
|                                                |    Serials)       |     |
|  LOT NO:  260722-001 (1D BARCODE)              +-------------------+     |
|  ||||||||||||||||||||||||||||||||||||||||||||||||||||||                  |
|                                                                          |
|  QTY: 4000 PCS             OQC: PASS            DATE: 2026-07-22         |
|  OQC INSP: LE VAN DUC      PO NO: PO-2026-0089                           |
|                                                                          |
|  S/N: HELA-2629-00001-00002-00003-00004                [ Outer Crate ]   |
+--------------------------------------------------------------------------+
```

---

## 3. 📐 Kiến Trúc In Tem Hệ Thống Vinatech MES (Điểm chung các màn hình)

Hệ thống in tem nhãn khách hàng hoạt động theo mô hình 3 lớp tách biệt:

1. **Z530 (Label Info) — Thư viện mẫu thiết kế:**
   * Nơi lưu trữ cấu trúc XML của file report thiết kế bằng DevExpress XtraReports trong bảng `SmartFramework.dbo.STB_LabelInfo.Format`.
2. **A460 (Model Label Info) — Ánh xạ (Mapping):**
   * Liên kết mã sản phẩm (`ModelCode`) + Loại tem (`LabelType` = `HelaLabel`) với Tên mẫu (`FormatName` = `Hela_Label_v1`).
3. **Màn hình in tem B890 (TCode) — Giao diện thực thi:**
   * Khi người dùng nhập PO, LotNo và bấm in, hệ thống chạy Stored Procedure lấy dữ liệu (Data Source), sau đó lấy template XML tương ứng từ Z530 thông qua mapping ở A460 để render lệnh in ra máy in Zebra.

---

## 4. 🛠️ Đề Bài Thực Hành Chi Tiết (Practice Challenge)

Nhiệm vụ của bạn là hiện thực hóa yêu cầu trên bằng cách viết các mã nguồn SQL và thiết kế cấu trúc dữ liệu mô phỏng.

### Nhiệm vụ 1: Tạo cấu trúc bảng lịch sử in tem (`STB_HelaLabelPrintHist`)
Hãy viết câu lệnh SQL tạo bảng để lưu trữ lịch sử in tem. Bảng này dùng để đối soát sản lượng đã in và làm căn cứ sinh số serial tự tăng tiếp theo.
* **Yêu cầu:** Thiết kế khóa chính tự tăng, lưu mã sản phẩm, Lot gốc, số PO, số lượng, tên người kiểm định OQC, ngày giờ in, tài khoản in, và mã Serial in trên tem (lưu ý trường này cần có độ rộng `VARCHAR(100)` để chứa chuỗi ghép của Outer Box).

### Nhiệm vụ 2: Viết Stored Procedure ghi lịch sử (`usp_HelaLabelPrintHist_iud`)
Viết Stored Procedure nhận các tham số in từ client và thực hiện `INSERT` ghi nhận lịch sử in thành công.

### Nhiệm vụ 3: Viết Stored Procedure lấy dữ liệu in tem (`usp_HelaLabelPrint_get`)
Đây là phần cốt lõi của bài thực hành. Bạn cần viết SP nhận vào các tham số:
* `@pProcessUserID` (Tài khoản in)
* `@pPONumber` (Số PO nhập vào)
* `@pLotNo` (Mã Lot quét vào)
* `@pTotalBox` (Tổng số thùng gỗ Outer cần in)

**Yêu cầu xử lý trong SP:**
1. **Validation Gate (Cổng chặn):**
   * Truy vấn bảng `STB_SetInfo` (hoặc `STB_MaterialLotInfo`) kiểm tra: cờ `IsProdFinish` của Lot phải bằng 1 (Đã hoàn thành đóng gói B523) và `LotDecisionResult` phải bằng `'PASS'` (QC Đã duyệt). Nếu không thỏa mãn, ném lỗi ra màn hình (`RAISERROR`).
2. **Tính toán Năm - Tuần (YYWW):**
   * Lấy ngày đóng gói từ lịch sử (`STB_SavePackingTime_VVT`), sử dụng hàm `DATEPART(ISO_WEEK, ...)` để tính tuần hiện tại và ghép với 2 số cuối của năm đóng gói.
3. **Chuẩn hóa chữ không dấu:**
   * Lấy tên nhân viên OQC thực hiện kiểm định lô hàng đó từ bảng nhân sự. Thực hiện loại bỏ toàn bộ ký tự tiếng Việt có dấu sang dạng chữ ASCII không dấu.
4. **Sinh Serial tự tăng:**
   * Tìm kiếm trong bảng lịch sử `STB_HelaLabelPrintHist` để lấy số serial lớn nhất của tuần hiện tại có dạng `HELA-YYWW-%`.
   * Tách lấy số tự tăng 5 chữ số cuối và xác định số serial xuất phát cho lượt in mới.
5. **Nhân bản dòng dữ liệu (Row Multiplication):**
   * Dựa trên số lượng thùng Outer cần in (`@pTotalBox`), thực hiện nhân dòng dữ liệu. 
   * Cứ mỗi 1 thùng Outer (`LabelClass = 'Outer'`), hệ thống phải sinh ra thêm 4 dòng dữ liệu Inner tương ứng (`LabelClass = 'Inner'`).
   * Gán số serial tuần tự cho các dòng Inner: `HELA-2629-00001`, `HELA-2629-00002`...
   * Gộp 4 số serial Inner tương ứng dán vào dòng Outer: `HELA-2629-00001-00002-00003-00004`.
6. **Ghép chuỗi QR Code:**
   * Ghép chuỗi theo đúng quy chuẩn: `Mã linh kiện | Số lượng | Số PO | Tên OQC không dấu | Serial`.
7. Trả về kết quả đầu ra là Grid Dataset.

#### Gợi ý cấu trúc phân dòng trong SP:
```sql
-- Ví dụ kỹ thuật nhân dòng dùng bảng tạm kết hợp ROW_NUMBER()
SELECT 
    #tmp.ModelCode,
    #tmp.PONumber,
    LType.LabelClass,
    CASE 
        WHEN LType.LabelClass = 'Inner' THEN @SerialGenerated
        ELSE @OuterSerialMerged
    END AS BoxSerialNo,
    -- ... các trường khác
FROM #tmpData #tmp
CROSS JOIN (
    SELECT 'Outer' AS LabelClass, 1 AS Seq
    UNION ALL SELECT 'Inner', 2
    UNION ALL SELECT 'Inner', 3
    UNION ALL SELECT 'Inner', 4
    UNION ALL SELECT 'Inner', 5
) LType
```

---

*Tài liệu này được biên soạn để làm tài liệu chuẩn (Blueprint) hướng dẫn thiết kế & phát triển các loại tem nhãn khách hàng mới trên hệ thống MES Vinatech.*
