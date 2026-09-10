<!--
AI-READY METADATA
Purpose: Hướng dẫn chuyên sâu toàn diện về luồng vận hành (Process Flow), 4 vùng giao diện Kiosk, từng nút bấm/modal và tác động cơ sở dữ liệu ngầm của POP Web
Scope: Khai thác thực tế 100% giao diện pop.vinatech.com/pop/screen và pop.vinatech.com/pop/quality (Đồng bộ theo Bộ Slide Đào Tạo Chuẩn 2026-09 của DX Team)
Single Source of Truth: POP_KB_02_SCREEN_OPERATIONS.md
Source Slide Deck: POP_KNOWLEDGE_BASE/assets/POP.pptx
Slide Images: POP_KNOWLEDGE_BASE/assets/slides_images/
Target Tables: STB_SetInfo, STB_ProdRouteHist, STB_MaterialLotInfo, STB_PackingInfo, STB_DefectInfo, VINA_MATERIAL_INPUT_HIST, VINA_KIOSK_SESSION, VINA_EQUIPMENT_MAPPING, STB_DayProdPlan, STB_BomDetail
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_SLIDE_DECK_MAPPING_AND_ANALYSIS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_SLIDE_DECK_MAPPING_AND_ANALYSIS.md)
  - [POP_USER_MANUAL.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_USER_MANUAL.md)
  - [POP_KB_04_ROLLBACK_AND_SAFETY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md)
-->

# POP_KB_02 — Cẩm Nang Vận Hành Chuyên Sâu Giao Diện POP Kiosk, Luồng Quy Trình & Tác Động Dữ Liệu

> **Hệ thống:** POP Kiosk Web Application — `https://pop.vinatech.com/`  
> **Phiên bản chuẩn hóa:** v2.0 (Cập nhật 2026-09 theo Bộ Slide Đào Tạo Chính Thức của DX Team)  
> **Tác giả tài liệu gốc:** Hanbit Kang | **Hiệu chỉnh:** Vietnam DX Team  
> **Cơ sở dữ liệu liên đới:** `SmartFactoryV2` + `VINATECH_POP`  
> **🔑 Keywords:** process flow, screen operation, ADD mode, SUB mode, WIP label, WH transfer, self inspection, material input, defect, packing, merge pack, label print, marking, auto-save  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 🔄 SƠ ĐỒ LUỒNG VẬN HÀNH TỔNG QUAN (END-TO-END PROCESS FLOW)

Hệ thống POP Web bao gồm 2 phân hệ URL chính với chu trình khép kín:

```mermaid
graph TD
    A[POP Kiosk Login: Mã Nhân Viên / Quét Mã QR Thẻ] --> B{Phân Hệ Nghiệp Vụ}
    
    subgraph "PHÂN HỆ SẢN XUẤT KIOSK (/pop/screen)"
        B -->|Sản Xuất /pop/screen| C[Bước 1: Chọn Line / Kế Hoạch DayPlan / Thẻ LOT]
        C --> D[Bước 2: Nạp Nguyên Vật Liệu Material Input]
        D --> E[Bước 3: Đăng Ký Phế Phẩm Defect Registration]
        E --> F[Bước 4: Ghi Nhận Sản Lượng & Chốt Công Đoạn Save Prod]
        F --> G[Bước 5: Đóng Gói Thành Phẩm Single / Split / Merge Pack]
        G --> H[Bước 6: In Tem Nhãn Mã Vạch QR Vector Label Print]
        
        C -.-> W1[Tiện Ích: WH Chuyển Kho Nhanh #wtModalPanel]
        C -.-> W2[Tiện Ích: In Tem Nhãn WIP Bán Thành Phẩm #wipLabelModal]
        D -.-> D1[Tính Năng Mới: Nút Lượng Kiến Cấp Auto-Fill BOM]
        D -.-> D2[Tính Năng Mới: Nút Tồn Kho Tra Cứu Đích Danh LOT NVL]
        E -.-> E1[⭐ Mới: Nhập Mã Marking Tại Công Đoạn Bọc Vỏ #btnMarkingCode]
        E -.-> W3[Nâng Cao: Chế Độ SUB Mode Hiệu Chỉnh Trừ Số Lỗi]
        F -.-> W4[Nâng Cao: Tái Phân Loại Re-sorting Trích Xuất Hàng Đạt]
        G -.-> G1[⭐ Mới: Hủy Đóng Gói Box Tức Thì Trong Popup Lịch Sử]
    end
    
    subgraph "PHÂN HỆ QUẢN LÝ CHẤT LƯỢNG (/pop/quality)"
        B -->|Chất Lượng /pop/quality| Q0["⭐ Mới: Tự Kiểm Tại Chuyền /pop/quality/self (Auto-Save on Blur)"]
        B -->|Chất Lượng /pop/quality| Q1[IQC: Kiểm Định NVL Đầu Vào]
        B -->|Chất Lượng /pop/quality| Q2[PQC: Kiểm Soát Quá Trình Công Đoạn]
        B -->|Chất Lượng /pop/quality| Q3[OQC / FOQC: Kiểm Định Xuất Xưởng]
        B -->|Chất Lượng /pop/quality| Q4[Route Judgment: Phán Định Tuyến Đặc Biệt]
    end
```

---

## 2. 🏗️ BẢN ĐỒ CẤU TRÚC GIAO DIỆN 4 VÙNG TOÀN DIỆN TRÊN KIOSK
*(Tham chiếu Slide 08 — `image21.png`)*

```
+---------------------------------------------------------------------------------------------------+
| [VÙNG 1: HEADER] Đồng hồ thực · Chip công nhân · Hard Reload · Tên Chuyền · Logo Cty · Menu Thiết Bị|
+------------------------------------+----------------------------------+---------------------------+
| [VÙNG 2: SIDEBAR TRÁI]             | [VÙNG 3: KHU VỰC TRUNG TÂM]      | [VÙNG 4: CONTROL PANEL]   |
| 1. Module Assembly, Label (ND06)   |  - Header Kế hoạch & Model BOM   |  - Header LOT đang chọn   |
| 2. Capacitance, ESR Check (ND07)   |  - Danh sách Thẻ LOT (Card View) |  - Nút In Nhãn Tem        |
| 3. Packing, Label (ND08)           |  - Thẻ Chi tiết LOT Metrics      |  - Chế độ SUB / ADD       |
| ---------------------------------- |    * Sản xuất Đạt (Good)         |  - Bàn phím số Numpad     |
| * Nút WH Chuyển kho                |    * Phẩm lỗi (Defect EA)        |  - Nút LOẠI LỖI (Defect)  |
| * ⭐ Nút Tự kiểm (Self-Inspection) |    * Công nhân & Thời gian       |  - Nút ĐĂNG KÝ            |
| * Nút Nhãn WIP (Bán thành phẩm)    |    * Thiết bị máy móc kết nối    |  - Nút GHI NHẬN SẢN XUẤT  |
|                                    |                                  |  - Menu phụ (⋮)           |
|                                    |                                  |    * 재투입 (Tái nạp liệu)|
|                                    |                                  |    * Tái phân loại        |
+------------------------------------+----------------------------------+---------------------------+
| [FOOTER] Bàn phím ảo On/Off · Đa ngôn ngữ (VI | KO | EN) · Công tắc Chế độ Tối/Sáng 🌓             |
+---------------------------------------------------------------------------------------------------+
```

---

## 3. 🧭 VÙNG 1: HEADER — ĐIỀU KHIỂN HỆ THỐNG & PHIÊN LÀM VIỆC
*(Tham chiếu Slide 09 — `image11.png`)*

| Thành phần / Nút bấm | Selector / ID | Hành vi khi kích hoạt | Tác động Backend & DB |
|----------------------|---------------|-----------------------|-----------------------|
| **Đồng hồ thực** | `.header-clock` | Hiển thị ngày giờ `YYYY-MM-DD HH:mm:ss` chuẩn từ Server | Đồng bộ nhịp tim với `VINA_KIOSK_SESSION.LAST_HEARTBEAT` |
| **Chip Công Nhân** | `#workerChip` / `#workerModal` | Click vào mở **Modal Chọn Công Nhân**, tìm theo mã thẻ/tên | Cập nhật `VINA_KIOSK_SESSION.WORKER_ID` & `WORKER_NAME` |
| **Hard Reload** | `#btnHardReload` | Xóa bộ nhớ đệm Vuex/LocalStorage và ép tải lại toàn bộ DOM từ DB | Khởi tạo lại phiên, đọc lại trạng thái mới nhất từ `SmartFactoryV2` |
| **Badge Tên Chuyền** | `#lineBadge` / `#lineModal` | Click vào mở **Cây phân cấp Xưởng/Chuyền** để đổi sang Line khác | Giải phóng Kiosk Session cũ, bind session sang `LINE_CODE` mới |
| **Menu Thiết Bị** | `#btnEquipmentPanel` | Mở/đóng thanh trạng thái thiết bị ngoại vi gắn với trạm Kiosk | Đọc cấu hình từ `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` |

---

## 4. 🔄 VÙNG 2: SIDEBAR TRÁI — TIẾN TRÌNH ROUTING & TIỆN ÍCH NHANH

### 4.1 Pipeline Công Đoạn Tiêu Chuẩn
Liệt kê toàn bộ các công đoạn sản xuất của dây chuyền hiện hành. Công đoạn đang thao tác được làm sáng (Active). Khi chạm vào công đoạn nào, toàn bộ giao diện làm việc chính sẽ đổi sang công đoạn đó.

### 4.2 Bộ Công Cụ Nhanh (Quick Launch Buttons)
* **`WH Chuyển kho` (`#wtModalPanel`):**
  - Mở giao diện điều chuyển kho nội bộ ngay tại xưởng.
  - Chọn **Kho xuất (Source WH)** $\rightarrow$ **Kho nhập (Target WH)** $\rightarrow$ Chọn Lot để chuyển tồn kho.
  - *Rollback:* Có thể tự đảo ngược chiều chuyển kho nếu phát hiện nhầm lẫn.
* **⭐ `Tự kiểm` (`#btnSelfInspection` at `/pop/quality/self` — Slide 49, 50):**
  - Nút nằm ở **góc dưới cùng bên trái màn hình Kiosk**.
  - Cho phép công nhân tự kiểm tra xác suất định kỳ (In-Line QC) bằng dụng cụ: Thước kẹp (*Caliper*), Panme (*Micrometer*), Cân điện tử (*Scale*)...
  - **Cơ chế Auto-save on blur:** Click ra ngoài ô nhập liệu là hệ thống tự động lưu DB và đồng bộ tức thì về NAIS MES.
* **`Nhãn WIP` (`#btnWipLabel` / `#wipLabelModal`):**
  - In tem mã vạch bán thành phẩm trung gian lưu khay/xe đẩy, lưu trọng lượng khay (Tare weight).

---

## 5. 🏭 CHI TIẾT BƯỚC 1: KHỞI TẠO CA & CHỌN LỆNH SẢN XUẤT (WORK ORDER)
*(Tham chiếu Slide 11, 12, 13, 14, 18, 19, 20)*

### 5.1 Luồng Thao Tác UI
1. **Đăng nhập Worker (Slide 11, 12):** Nhập mã nhân viên hoặc quét trực tiếp thẻ QR bằng máy đọc scanner (API: `/api/common/login`).
2. **Chọn Chuyền (Line):** Chọn nơi làm việc (WorkCenter) và Dây chuyền (Line) tương ứng vị trí Kiosk (API: `/api/common/getLineList`).
3. **Hai Phương Thức Chọn LOT Làm Việc:**
   - **Phương thức 1: Scan Barcode trực tiếp (Slide 19 — `image2.png`):**
     - Quét trực tiếp Barcode từ tem dán trên khay/xe cấp phát vật tư bằng máy đọc barcode scanner.
     - Hệ thống tự động tìm kiếm, hiển thị thông tin LOT và DayPlan tương ứng -> Bấm nút **"Thêm"**.
   - **Phương thức 2: Chọn theo Kế Hoạch Ngày (Slide 13, 20 — `image10.png`, `image8.png`):**
     - Click vào vùng bên dưới thẻ LOT hiện tại -> Mở popup Lịch sản xuất.
     - Dùng nút `◀ ▶` điều hướng tháng, chọn ngày làm việc (mặc định hôm nay).
     - Danh sách các Lệnh sản xuất trong ngày hiển thị ở cột bên phải -> Chọn LSX cần làm.
     - Bấm nút **"Thêm"** để nạp danh sách LOT.

### 5.2 Tác Động Database & API
- **API Đọc:**
  - `POST /api/pop/screen/getDayPlanList`: Đọc `SmartFactoryV2.dbo.STB_DayProdPlan`.
  - `POST /api/pop/screen/getLotList`: Đọc `SmartFactoryV2.dbo.STB_SetInfo` với điều kiện `DayPlanID = @DayPlanID`.
- **Tác động DB:** **HOÀN TOÀN READ-ONLY**. Chưa có dữ liệu nào bị ghi hay thay đổi.

---

## 6. 📦 CHI TIẾT BƯỚC 2: NHẬP NGUYÊN VẬT LIỆU (MATERIAL INPUT)
*(Tham chiếu Slide 21, 22, 23 — `image27.png`, `image34.png`, `image15.png`)*

### 6.1 Luồng Thao Tác & Khóa Liên Động (Interlock)
- **Khóa nút sản xuất (Slide 21):** Nút cam **"Nhập vật liệu"** ở góc dưới phải hiển thị tiến độ `(0/6)` (đã nạp 0/6 loại NVL theo BOM). Nút "Đăng ký" và "Hoàn thành sản xuất" sẽ bị **VÔ HIỆU HÓA HOÀN TOÀN** cho đến khi toàn bộ vật tư theo BOM được nạp đủ!
- **Màn hình chi tiết nạp NVL (Slide 22):** Chia làm 2 tab:
  - Tab **"Nhập thủ công"**: Danh sách các NVL chưa cấp phát.
  - Tab **"Tự động / Hoàn thành"**: Danh sách các NVL đã nạp đủ.

### 6.2 Hai Tính Năng Nạp NVL Nâng Cao Mới
1. **⭐ Nút "Lượng kiến cấp" (Estimated Supply Qty / Auto-Fill BOM — Slide 22):**
   - Chạm vào nút **"Lượng kiến cấp"** -> Hệ thống **tự động tính toán và điền đủ 100% số lượng cần thiết theo định mức BOM**, giúp công nhân không phải gõ số lẻ thập phân thủ công.
   - Khi trạm có kết nối cân điện tử, khối lượng tự động đọc qua cổng RS232/Ethernet.
2. **⭐ Nút "Tồn kho" (Warehouse Stock Lookup — Slide 23):**
   - Chạm vào nút **"Tồn kho"** -> Gõ mã LOT NVL vào ô tìm kiếm.
   - Hệ thống lọc ra danh sách các cuộn/thùng NVL đang có sẵn trong kho công đoạn (`ROUTE_VN_WH`) kèm số lượng tồn thực tế (`CurrentQty`).
   - Công nhân chọn đúng LOT NVL xuất dùng và bấm **Lưu**.

### 6.3 Tác Động Database & Nguy Cơ Sai Lệch
```sql
-- 1. Trừ tồn kho NVL trực tiếp trong SmartFactoryV2
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
SET CurrentQty = CurrentQty - @InputQty,
    ModifyDate = GETDATE(),
    Modifier = @WorkerID
WHERE MaterialLotNo = @MaterialLotNo;

-- 2. Ghi nhật ký tiêu hao vào VINATECH_POP
INSERT INTO VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST (
    LOT_NO, MATERIAL_LOT_NO, SUB_MATERIAL_CODE, SUB_MATERIAL_NAME, 
    INPUT_QTY, INPUT_DATE_TIME, WORKER_ID, ROUTE_CODE, STATUS
) VALUES (
    @LotNo, @MaterialLotNo, @MaterialCode, @MaterialName, 
    @InputQty, GETDATE(), @WorkerID, @RouteCode, 'NORMAL'
);

-- 3. Đánh dấu cờ nạp NVL trên STB_SetInfo
UPDATE SmartFactoryV2.dbo.STB_SetInfo
SET IsLineInput = 1
WHERE LotNo = @LotNo;
```
> [!CAUTION]
> Thao tác Nhập NVL **TRỪ KHO TỨC THÌ**. Trên UI **KHÔNG CÓ NÚT ROLLBACK** để tránh gian lận hao hụt kho ERP.
> Nếu quét nhầm cuộn hoặc nhập sai số lượng, bắt buộc phải nhờ IT xử lý SQL hoàn kho có `BEGIN TRAN...ROLLBACK`.

---

## 7. ⚠️ CHI TIẾT BƯỚC 3: ĐĂNG KÝ PHẾ PHẨM (DEFECT REGISTRATION) & NHẬP MÃ MARKING

### 7.1 Luồng Đăng Ký Lỗi & Chế Độ SUB Mode
*(Tham chiếu Slide 24, 25, 26 — `image32.png`, `image29.png`, `image30.png`)*

- Khi phát hiện sản phẩm lỗi trên chuyền:
  1. Bấm nút **`LOẠI LỖI` (`#btnDefectType`)**.
  2. Chọn Mã lỗi chi tiết trong bảng danh mục lỗi.
  3. Sử dụng Numpad cảm ứng để nhập số lượng phế.
  4. Bấm nút **`ĐĂNG KÝ`** -> Hệ thống ghi nhận số lỗi và tự động reset Numpad về `0`.
- **Cơ Chế Sửa Sai Bằng Chế Độ `SUB Mode`:**
  - Nếu lỡ tay bấm thừa số lỗi (ví dụ: thực tế lỗi 2 cái nhưng bấm nhầm 20 cái):
  - Chuyển công tắc chế độ **`#prodModeIndicator`** từ **`ADD`** sang **`SUB`**.
  - Nhập số lượng cần trừ bớt (`18`) trên Numpad $\rightarrow$ Bấm **`ĐĂNG KÝ`**.
  - Hệ thống tự động trừ lùi số lượng lỗi trong phiên làm việc mà không làm sai lệch số liệu!

### 7.2 ⭐ Nhập Mã Marking Tại Công Đoạn Bọc Vỏ (Curling / Marking)
*(Tham chiếu Slide 29 — `image35.png` — TÍNH NĂNG ĐẶC BIỆT MỚI)*

- **Vị trí UI:** Tại công đoạn **Bọc Vỏ**, nút **"Mã marking"** (`#btnMarkingCode`) nằm ở **góc trên bên phải màn hình, ngay cạnh biểu tượng In nhãn**.
- **Quy trình thao tác:**
  1. Chạm vào nút **"Mã marking"** -> Popup `#markingModal` xuất hiện.
  2. Dùng máy quét mã vạch hoặc bàn phím để nhập mã Marking khắc trên thân vỏ sản phẩm.
  3. Chạm nút **"Lưu lại"** để hệ thống ghi nhận mã Marking vào cơ sở dữ liệu trước khi chuyển công đoạn tiếp theo.

---

## 8. 🚀 CHI TIẾT BƯỚC 4: GHI NHẬN SẢN XUẤT & CHỐT CÔNG ĐOẠN (SAVE PRODUCTION)
*(Tham chiếu Slide 27 — `image16.png`)*

- Sau khi kiểm tra đủ số lượng thành phẩm và phế phẩm:
  1. Công nhân bấm nút lớn **`HOÀN THÀNH SẢN XUẤT`** (Save Production).
  2. Kiosk hiển thị hộp thoại xác nhận: Lot No, Công đoạn, Công nhân, Số lượng Đạt (Good Qty), Số lượng Lỗi (Defect Qty), Thời gian gia công, Danh sách thiết bị kết nối.
  3. Bấm **"Đồng ý"** (Xác nhận kết thúc).
- **Tác động Database:**
  - Gọi SP `SmartFactoryV2.dbo.USP_POP_SET_ROUTE_COMPLETE`.
  - Ghi nhận `STB_ProdRouteHist`.
  - Cập nhật `STB_SetInfo.IsProdFinish = 1` và chuyển `CurrentRoute` sang công đoạn kế tiếp.

---

## 9. 📦 CHI TIẾT BƯỚC 5: ĐÓNG GÓI & ĐÓNG GÓI GỘP (PACKING & MERGE PACK)
*(Tham chiếu Slide 31-39)*

### 9.1 Ba (03) Nghiệp Vụ Đóng Gói Chuẩn Hóa
Chỉ những LOT đã hoàn thành 100% tất cả các công đoạn sản xuất trước đó mới hiển thị trong danh sách Đóng gói với trạng thái **"Đang Chờ"**.

1. **Đóng gói đơn (Single Pack — Slide 34 — `image22.png`):**
   - 1 Box duy nhất cho toàn bộ số lượng của LOT (VD: 1 Box x 5,980 = 5,980 EA).
   - Chọn LOT -> Nhập số lượng -> Bấm **"ĐÓNG GÓI"**.
2. **Đóng gói chia nhiều Box (Split Pack — Slide 35 — `image24.png`):**
   - Áp dụng khi chia 1 LOT ra nhiều Box (Box 1: 1,500, Box 2: 1,500, Box 3: 1,500, Box 4: 1,480 = Tổng 5,980 EA).
   - Nút **"Thêm hộp"** để tăng số box; Dấu **`X`** màu đỏ để xóa bớt box.
   - Bấm **"Đóng gói"** -> Chọn **"Cả" (All)** để hoàn tất toàn bộ các Box.
3. **Đóng gói gộp nhiều LOT (Merge Pack — Slide 36, 37 — `image49.png`, `image25.png`):**
   - Tích chọn từ 2 LOT trở lên. **Các LOT được chọn chuyển sang Màu Tím**.
   - Nhập số lượng đóng gói quy cách (VD: 6,000 EA) -> Hệ thống trừ tuần tự theo **nguyên tắc FIFO từ trên xuống**.
   - **Gộp LOT khác ngày (Slide 37):** Nếu các LOT trong ngày đã hết, bấm nút **"Lệnh SX"** để chọn Kế hoạch của ngày khác. **Yêu cầu bắt buộc: Phải cùng Model sản phẩm!**

### 9.2 ⭐ Lịch Sử Đóng Gói & HỦY ĐÓNG GÓI TRỰC TIẾP TRÊN UI (Slide 39 — `image28.png`)
- Chạm vào nút **"Lịch sử"** ở góc dưới màn hình Đóng gói -> Hộp thoại danh sách Box hiển thị chi tiết: Mã Box, Số lượng, Ngày/giờ, Tên công nhân.
- **In lại nhãn:** Bấm nút **"In"** trên từng Box để in lại tem dán.
- **HỦY ĐÓNG GÓI TỪNG BOX:** Bấm nút **"Hủy"** trên từng Box -> Popup xác nhận số lượng hiển thị -> Bấm đồng ý:
  - Hệ thống hủy mã Box trong `STB_PackingInfo`.
  - **TỰ ĐỘNG HOÀN TRẢ VÀ KHÔI PHỤC NGAY LẬP TỨC** số lượng sản phẩm về lại LOT gốc (trạng thái *Đang Chờ*).
- **HỦY TẤT CẢ (Cancel All Boxes):** Bấm nút **"Hủy tất cả"** ở góc trên để hoàn tác toàn bộ các Box của lệnh sản xuất cùng lúc!

---

## 10. 🏷️ CHI TIẾT BƯỚC 6: IN TEM NHÃN MÃ VẠCH (LABEL PRINTING)
*(Tham chiếu Slide 45, 46, 47 — `image45.png`, `image51.png`, `image43.png`)*

- Bấm nút **"In Nhãn"** ở góc trên bên phải màn hình Lắp ráp hoặc dưới màn hình Đóng gói:
  - **Đề xuất nhãn phù hợp ⭐:** Hệ thống tự động gắn dấu sao cho mẫu tem tối ưu nhất với Model sản phẩm.
  - **Kích thước chuẩn:** `83mm x 49mm` (hoặc quy cách tem dán thùng Box).
  - **Chỉnh sửa tên vật tư:** Cho phép chỉnh sửa trực tiếp trường `MaterialNo` ngay trên giao diện trước khi in nếu có yêu cầu đặc biệt.
  - **Xem trước kích thước thực (Preview):** Hiển thị trực quan mã QR vector 2D và các thông số trước khi xuất lệnh in.
  - **In lại không giới hạn:** Công nhân có thể in lại cùng một nhãn bất kỳ lúc nào nếu tem bị rách hoặc mờ.

---

## 11. ⚙️ TÁC VỤ NÂNG CAO (MENU PHỤ ⋮ — TÁI PHÂN LOẠI RE-SORTING)
*(Tham chiếu Slide 40-43 — `image31.png`, `image33.png`, `image41.png`, `image50.png`)*

- Chạm menu **`⋮`** ở góc dưới phải -> Chọn **"Tái phân loại"** (Bắt buộc phải chọn Lệnh sản xuất trước):
  - **Phương thức 1: Phân phối theo tỷ lệ (Slide 42):** Nhập tổng số lượng tái phân loại -> Hệ thống tự chia đều theo tỷ lệ lỗi còn lại của từng LOT.
  - **Phương thức 2: Nhập riêng từng LOT (Slide 43):** Nhập trực tiếp số lượng vào từng dòng LOT.
- **Tác động dữ liệu:** Tạo ra LOT Tái phân loại MỚI, cộng dồn sản lượng đạt vào kết quả sản xuất. Số lượng lỗi trên LOT gốc không bị trừ mất mà ghi lại lịch sử phân loại để phục vụ kiểm toán truy vết.

---

## 12. 🔬 PHÂN HỆ QUẢN LÝ CHẤT LƯỢNG (/pop/quality) & TỰ KIỂM TẠI CHUYỀN
*(Tham chiếu Slide 48, 49, 50 — `image44.png`, `image46.png`, `image47.png`)*

### 12.1 Hạng Mục Kiểm Tra Thường Xuyên (Tự Kiểm Tại Chuyền)
- **Đường dẫn:** `https://pop.vinatech.com/pop/quality/self` (hoặc bấm nút **"Tự kiểm"** ở góc dưới bên trái Kiosk).
- **Quy trình vận hành:**
  1. Chọn công đoạn cần đo kiểm.
  2. Danh sách các hạng mục kiểm tra hiển thị (chiều dài, chiều rộng, độ dày, khối lượng, điện áp, nội trở...).
  3. **⭐ CƠ CHẾ AUTO-SAVE ON BLUR:** Nhập giá trị đo vào ô dữ liệu -> **Chỉ cần click chuột hoặc chạm ra bên ngoài ô nhập**, hệ thống sẽ **TỰ ĐỘNG LƯU VÀO DATABASE VÀ ĐỒNG BỘ TỨC THÌ VỀ NAIS MES** mà không cần nút Save riêng lẻ!
  4. **Tăng số mẫu đo `[+]`:** Bấm nút `[+]` để tăng số lần đo mẫu kiểm tra hoặc thêm ghi chú giải trình hiện trường.
  5. **Biểu đồ xu hướng (Trend Chart):** Tích hợp biểu đồ theo dõi đường giới hạn Spec (USL/LSL/Target) để kiểm soát chất lượng quá trình.

### 12.2 Tổng Hợp Toàn Bộ Phân Hệ Quality
| Màn hình | Chức Năng Nghiệp Vụ | API / SP Liên Quan | Trạng Thái Phán Định |
|----------|---------------------|-------------------|----------------------|
| **⭐ Tự kiểm (Self-Insp)** | Kiểm tra kích thước tại chuyền (Auto-Save on blur) | `/api/quality/self/save` | Đạt (Pass) / Lỗi (Fail) |
| **IQC (Incoming QC)** | Kiểm tra NVL đầu vào trước khi cấp cho sản xuất | `/api/quality/iqc/save` | Đạt (OK) / Trả hàng (NG) / Chờ xử lý (Hold) |
| **PQC (Process QC)** | Lấy mẫu kiểm tra kích thước, ngoại quan trên chuyền | `/api/quality/pqc/save` | Tiếp tục SX / Dừng chuyền cảnh báo |
| **OQC (Outgoing QC)** | Kiểm định lô đóng gói trước khi nhập kho thành phẩm | `/api/quality/oqc/save` | Nhập kho (Pass) / Rã thùng tái kiểm (Reject) |
| **FOQC (Final OQC)** | Kiểm tra độ tin cậy thành phẩm xuất khẩu | `/api/quality/foqc/save` | Cấp chứng chỉ xuất xưởng (COA) |
| **Route Judgment** | Phán định tuyến điều hướng Lot đặc biệt | `/api/quality/judgeRoute` | Chuyển thẳng / Rework / Tiêu hủy |

---

## 13. 📑 TỔNG HỢP DANH MỤC MODAL & ID PHẦN TỬ ĐỂ DEBUG NHANH

| Tên Modal / Panel | ID Selector | API Endpoint Kích Hoạt | Bảng Database Đích | Tham Chiếu Slide |
|-------------------|-------------|------------------------|--------------------|:----------------:|
| Chọn Kế hoạch SX | `#dayPlanModal` | `/api/pop/screen/getDayPlanList` | `STB_DayProdPlan` | Slide 13, 20 |
| Chọn Chuyền SX | `#lineModal` | `/api/common/getLineList` | `STB_LineInfo` | Slide 09 |
| Chọn Công nhân | `#workerModal` | `/api/common/getWorkerList` | `STB_WorkerInfo` | Slide 11 |
| Bảng Thiết bị | `#equipmentModal` | `/api/common/getEquipmentList` | `VINA_EQUIPMENT_MAPPING` | Slide 08 |
| Đăng ký Loại lỗi | `#defectTypeModal` | `/api/pop/screen/saveDefect` | `STB_DefectInfo` | Slide 24 |
| ⭐ Nhập Mã Marking | `#markingModal` / `#btnMarkingCode` | `/api/pop/screen/saveMarkingCode` | `STB_SetInfo.MarkingCode` | Slide 29 |
| ⭐ Nút Lượng Kiến Cấp | `#btnAutoFillBOM` | Tính toán nội bộ Vuex theo BOM | `STB_BomDetail` | Slide 22 |
| ⭐ Nút Tồn Kho NVL | `#btnWarehouseStock` | `/api/pop/screen/getMaterialStock`| `STB_MaterialLotInfo` | Slide 23 |
| ⭐ Lịch Sử Đóng Gói & Hủy Box | `#packingHistoryModal` | `/api/pop/screen/cancelPacking` | `STB_PackingInfo`, `STB_SetInfo` | Slide 39 |
| In Tem Nhãn | `.label-print-modal` | `/api/pop/screen/printLabel` | `VINA_LABEL_INFO` | Slide 38, 45 |
| In Nhãn WIP | `#wipLabelModal` | `/api/pop/screen/printWipLabel` | `VINA_WIP_STOCK_HIST` | - |
| Điều chuyển kho | `#wtModalPanel` | `/api/pop/screen/transferWarehouse` | `STB_ProdRouteHist` | - |
| ⭐ Màn hình Tự Kiểm | `#btnSelfInspection` | `/api/quality/self/save` (on blur) | `VINA_SELF_INSP_HIST` | Slide 49, 50 |
| Menu Mở rộng | `#secondaryActionsMenu` | Nội bộ Kiosk UI | `VINA_POP_ACTION_LOG` | Slide 28, 41 |

---

## 14. 📌 BẢY (07) QUY TẮC AN TOÀN BẤT BIẾN KHI VẬN HÀNH TRÊN POP

1. **Kiểm tra thông tin Lot:** Luôn đối chiếu tem cứng vật lý trên khay với Lot Card hiển thị trên POP trước khi thao tác. Quét trực tiếp Barcode để tải nhanh và chính xác nhất.
2. **Sử dụng chế độ `SUB Mode` để sửa sai số lượng:** Nếu lỡ tay bấm thừa số lượng sản phẩm hoặc phế phẩm, chuyển ngay sang chế độ `SUB` Mode để trừ bớt trước khi bấm "Hoàn thành sản xuất".
3. **Quy tắc bắt buộc nhập NVL:** Phải nhập đủ vật liệu theo BOM (dùng nút "Lượng kiến cấp" để nạp nhanh) thì nút "Đăng ký" và "Hoàn thành sản xuất" mới mở khóa.
4. **Nhập mã Marking tại công đoạn Bọc Vỏ:** Bắt buộc bấm nút "Mã marking" ở góc trên bên phải để lưu mã thân vỏ trước khi chuyển công đoạn.
5. **Cơ chế Hủy Đóng Gói (Rollback) kịp thời:** Nếu đóng gói nhầm hoặc cần dán lại tem, bấm nút "Lịch sử" -> bấm nút **[HỦY]** từng Box hoặc **[HỦY TẤT CẢ]** để khôi phục số lượng LOT về trạng thái Đang Chờ ngay trên Kiosk.
6. **Auto-save tại màn hình Tự kiểm:** Chỉ cần click chuột ra ngoài ô nhập liệu là kết quả đo đã được lưu vào cơ sở dữ liệu và đồng bộ NAIS. Không cần tìm nút Save.
7. **Không tự ý chuyển đổi Line khi đang dở ca:** Đổi Line sẽ giải phóng phiên làm việc Kiosk Session hiện hành và đặt lại toàn bộ dữ liệu đang tải dở.
