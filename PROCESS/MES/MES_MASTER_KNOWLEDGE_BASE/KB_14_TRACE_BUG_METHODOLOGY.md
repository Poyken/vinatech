# 📘 KB_14_TRACE_BUG_METHODOLOGY — Cẩm Nang Truy Vết Lỗi & Dữ Liệu NAIS MES

> **Cập nhật:** 2026-05-25 | **Tác giả:** Antigravity (Google DeepMind Team)
> **Mục tiêu:** Hướng dẫn từng bước (Step-by-step) đầy đủ, chính xác, trực quan để kỹ sư vận hành/lập trình viên có thể tự mình truy tìm và sửa lỗi dữ liệu trên hệ thống MES Vinatech mà không cần đoán mò.

---

## 1. 🛡️ TRIẾT LÝ VÀ NGUYÊN TẮC VÀNG
> **"Không đoán mò — Chỉ tin vào dữ liệu thực tế trong Database"**

Khi tiếp nhận báo lỗi từ hiện trường, tuyệt đối không vội vàng đưa ra kết luận dựa trên mô tả cảm tính. Mọi lỗi hệ thống đều để lại dấu vết trong cơ sở dữ liệu. Bắt buộc phải thực hiện truy vấn `SELECT` để xác minh trạng thái thực của dữ liệu trước khi đưa ra phương án xử lý.

> [!IMPORTANT]
> **Quy tắc an toàn giao dịch (Transaction Handling)**
> Mọi lệnh UPDATE hoặc DELETE sửa đổi dữ liệu do sự cố đều bắt buộc phải thực hiện trong một **Explicit Transaction (`BEGIN TRAN ... ROLLBACK / COMMIT`)**. Tuyệt đối không chạy lệnh update trực tiếp mà không kiểm tra `@ROWCOUNT` để tránh cập nhật sai hàng loạt bản ghi.

> [!WARNING]
> **Rủi ro sập luồng do hàm đổi kiểu (TRY_CONVERT vs CONVERT)**
> Hàm `fn_VVT_getdatebyVendorLot` phân tích ngày sản xuất từ mã Lot bằng các hàm cắt chuỗi tĩnh (`substring`) và convert ngày. Khi nhà cung cấp thay đổi format mã Lot (không theo cấu trúc `dd/mm/yyyy`), hàm sẽ crash do lỗi convert kiểu dữ liệu. Hãy luôn sử dụng `TRY_CONVERT` thay vì `CONVERT` để bảo vệ SP khỏi lỗi sập luồng.

> [!CAUTION]
> **Tránh tranh chấp khóa bảng (Table-Lock Deadlocks)**
> Trong giờ cao điểm chốt ca (07:30 - 08:30 và 19:30 - 20:30), lượng bản ghi quét công đoạn gửi lên `STB_ProdRouteHist` đạt mức hàng chục ngàn dòng. Việc cập nhật hàng loạt hoặc chạy trigger đồng bộ tồn kho liên hoàn không tối ưu hóa chỉ mục (Indexes) sẽ dẫn đến lock leo thang (Lock Escalation) thành Table-Lock, gây treo toàn bộ ứng dụng MES hiện trường.

---

## 2. 📋 QUY TRÌNH TRUY VẾT LỖI 5 BƯỚC CHUẨN Y KHOA

```mermaid
graph TD
    A[Bước 1: Thu thập triệu chứng] --> B[Bước 2: Xác định Điểm vào - SP]
    B --> C[Bước 3: Kiểm tra sức khỏe dữ liệu]
    C --> D[Bước 4: Kiểm tra cấu hình Master]
    D --> E[Bước 5: Phân tích Log gói tin thô]
    E --> F[Đề xuất Script Fix & Chạy An Toàn]
```

### BƯỚC 1: Thu Thập Triệu Chứng Hiện Trường (Symptoms)
Trước khi mở SQL Server Management Studio (SSMS), hãy thu thập đủ **5 thông tin vàng**:
1. **Màn hình xảy ra lỗi:** (Mã TCode, ví dụ: `B523`, `B597`, `F330`...).
2. **Mã đối tượng bị lỗi:** (Mã Barcode, mã Lot, mã PO, hoặc mã Nguyên vật liệu...).
3. **Thao tác thực hiện:** (Nhấn nút "Gộp Box", "In tem", hay "Xác nhận nhập kho"...).
4. **Thông báo lỗi hiển thị trên giao diện (UI Error):** (Chụp ảnh màn hình hoặc ghi lại nguyên văn thông báo).
5. **Nhân sự thực hiện & Thời gian xảy ra lỗi:** (Để thu hẹp phạm vi quét log).

---

### BƯỚC 2: Xác Định Điểm Vào Hệ Thống (Entry Point - UI ➔ SP Mapping)
Hệ thống NAIS MES vận hành bằng cách gọi các Stored Procedure (SP) từ UI. Để biết nút bấm trên giao diện gọi SP nào, chạy các câu lệnh tra cứu sau:

```sql
-- 1. Tìm tên màn hình gốc theo mã TCode hiển thị trên UI
SELECT Name AS ScreenName, Caption, TCode 
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE TCode = 'B523'; -- Thay thế bằng TCode bị lỗi

-- 2. Tìm tên Object (Nút bấm) và xem SP/Event tương ứng
-- Kết quả ScreenName ở bước 1 sẽ dùng làm điều kiện lọc ở đây
SELECT ObjectName, Caption, LinkURL, EventName 
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = 'Vietnam_Donggoi_Hnam' -- Tên màn hình tìm được ở bước 1
  AND ObjectType = 'Action';
```

> 💡 **Mẹo:** Tên Stored Procedure thường nằm trong cột `LinkURL` hoặc `EventName` dưới dạng `usp_Vietnam_DoProcess...` hoặc `usp_DoProcess...`.

---

### BƯỚC 3: Kiểm Tra "Sức Khỏe" Dữ Liệu Hiện Tại (Data State Check)
Hệ thống chặn không cho thao tác thường do trạng thái Lot hoặc Barcode không đủ điều kiện (chưa qua công đoạn trước, chưa QC, hoặc đã bị báo phế). Chạy câu lệnh kiểm tra tổng quát sau:

```sql
-- Kiểm tra trạng thái toàn diện của một mã Barcode/Lot
SELECT 
    Barcode,
    MaterialCode,
    ProdQty,
    LotDecisionResult,  -- Trạng thái QC: 'PASS' = Đạt, 'FAIL' = Lỗi, NULL = Chưa đánh giá
    IsDefect,           -- 1 = Đang bị đánh dấu lỗi (NG), 0 = Bình thường
    DefectQty,          -- Số lượng lỗi
    IsProdFinish,       -- 1 = Đã hoàn tất công đoạn sản xuất, 0 = Chưa hoàn tất
    InputLineCode       -- Line sản xuất đăng ký
FROM STB_SetInfo
WHERE Barcode = 'Mã_Barcode_Cần_Check'; -- Ví dụ: 'SP20260525-001'
```

#### 2.1 Cây Chẩn Đoán Lỗi Quét Barcode (Barcode Blockage Decision Tree)

Dưới đây là sơ đồ cây quyết định giúp lập trình viên/AI khoanh vùng nhanh nguyên nhân gây lỗi chặn scan barcode:

```mermaid
graph TD
    Start["Scan Barcode gặp lỗi chặn"] --> CheckExist{"1. Barcode có tồn tại trong STB_SetInfo?"}
    
    CheckExist -->|Không| ErrorPO["Lỗi: Barcode chưa được khởi tạo ở B450 / Lệnh PO chưa active"]
    CheckExist -->|Có| CheckHold{"2. Barcode/Lot có bị HOLD?<br/>(MaterialWarehouseCode == 'HOLDING_*_WH')"}
    
    CheckHold -->|Có| ErrorHold["Lỗi: Lô hàng đang bị QC tạm khóa.<br/>Sử dụng stb_vvt_OpenExpiredMaterial để bypass nếu cần."]
    CheckHold -->|Không| CheckExpire{"3. Barcode/Lot có quá hạn dùng?<br/>(Dựa trên LotAttr10 + MMExtInt01)"}
    
    CheckExpire -->|Có| ErrorExpire["Lỗi: Lô hàng quá hạn dùng (Expired).<br/>Yêu cầu QC đánh giá lại hoặc bypass."]
    CheckExpire -->|Không| CheckBOM{"4. Barcode có khớp với BOM?<br/>(Check stb_vvt_materialbo & STB_ProductionOrderRouting)"}
    
    CheckBOM -->|Không| ErrorBOM["Lỗi: Sai chủng loại NVL so với BOM.<br/>Kiểm tra lại cấu hình BOM ngầm."]
    CheckBOM -->|Có| CheckQC{"5. Đã nhập kết quả PQC ở công đoạn trước?<br/>(Kiểm tra STB_DefectRepairInfo)"}
    
    CheckQC -->|Không| ErrorQC["Lỗi: Chưa nhập kết quả đo/phế lỗi ở công đoạn trước.<br/>Yêu cầu QC/OP hoàn tất PQC."]
    CheckQC -->|Có| Success["Cho phép qua cổng thành công"]
    
    style Success fill:#d4edda,stroke:#28a745,stroke-width:2px;
    style ErrorPO fill:#f8d7da,stroke:#dc3545,stroke-width:1px;
    style ErrorHold fill:#f8d7da,stroke:#dc3545,stroke-width:1px;
    style ErrorExpire fill:#f8d7da,stroke:#dc3545,stroke-width:1px;
    style ErrorBOM fill:#f8d7da,stroke:#dc3545,stroke-width:1px;
    style ErrorQC fill:#f8d7da,stroke:#dc3545,stroke-width:1px;
```

---

### BƯỚC 4: Kiểm Tra Cấu Hình Master Data (Configuration Check)
Nhiều lỗi xảy ra do thiếu cấu hình vật tư, thiết bị hoặc phân quyền trên hệ thống:

```sql
-- 1. Kiểm tra cấu hình gộp lot/sử dụng barcode của vật tư (Màn hình F110)
-- Nếu IsLotUse = 0 hoặc IsUseBarcode = 0, hệ thống sẽ chặn không cho quét Lot/In tem
SELECT MaterialCode, IsUseBarcode, IsLotUse 
FROM STB_MaterialStockAttributeInfo
WHERE MaterialCode = 'Mã_Vật_Tư_Cần_Check';

-- 2. Kiểm tra thông số voltage/farad của Model (Màn hình A410)
SELECT ModelCode, MBIExtText04 AS Voltage, MBIExtText05 AS Farad
FROM STB_ModelBasicInfo
WHERE ModelCode = 'Mã_Model_Cần_Check';
```

---

### BƯỚC 5: Phân Tích Log Hệ Thống Để Tìm Nguyên Nhân Gốc (Root Cause Analysis)
Khi giao diện báo lỗi chung chung (Ví dụ: "Lỗi hệ thống, liên hệ Admin"), đây là bước quan trọng nhất để xem lỗi thực tế xảy ra ở dòng code nào trong Database:

```sql
-- 1. Tra cứu log gói tin thô gửi từ Client lên Server
-- Giúp xác định chính xác dữ liệu Client truyền lên là gì
SELECT ProcessDateTime, IPAddress, Data, ProcessResult
FROM STB_ProcessTerminalDataLog
WHERE CAST(ProcessDateTime AS DATE) = CAST(GETDATE() AS DATE)
  AND Data LIKE '%Mã_Barcode_Cần_Check%'
ORDER BY ProcessDateTime DESC;

-- 2. Tra cứu log chi tiết các biến số bên trong Stored Procedure
-- Được SP tự động ghi lại khi xảy ra lỗi/validate chặn
SELECT ProcedureName, VariableName, VariableValue, CreateDateTime
FROM STB_ProcedureLog
WHERE CAST(CreateDateTime AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY CreateDateTime DESC;
```

---

## 3. 🔍 ĐỌC VÀ PHÂN TÍCH CHUỖI DỮ LIỆU LOG (DATA LOG ANATOMY)

Cột `Data` trong bảng `STB_ProcessTerminalDataLog` lưu chuỗi dữ liệu thô phân tách bằng ký tự gạch đứng `|`.

**Ví dụ một chuỗi log gộp Box:**
`PRODPACKING|VELINE-01|VE10|SP20260525-001|1000|PK001|vanduc|...`

**Phân tích cấu trúc:**
1. `PRODPACKING`: Tên Action/Event (Sẽ được Route vào SP `usp_DoProcessTerminalData`).
2. `VELINE-01`: Mã Line sản xuất thực hiện.
3. `VE10`: Mã công đoạn sản xuất.
4. `SP20260525-001`: Mã Lot/Barcode sản phẩm.
5. `1000`: Số lượng sản phẩm (`ProdQty`).
6. `PK001`: Mã thùng/Box ID đích.
7. `vanduc`: Tài khoản User thực hiện.

> ⚠️ **Dấu hiệu bất thường cần tìm:**
> - Số lượng (`ProdQty`) truyền lên bằng `0` hoặc âm.
> - Mã Line hoặc mã Công đoạn bị trống hoặc không tồn tại trong Master Data.
> - Tài khoản User thực hiện chưa được phân quyền trên Line/Kho đó.

---


---

## 4. 🛠️ CÁC CÂU LỆNH SQL UTILITIES CỨU HỘ NHANH

### A. Kiểm tra nhanh lịch sử di chuyển Lot (Routing Trace)
Khi Lot không hiển thị ở công đoạn hiện tại, kiểm tra xem nó đã qua công đoạn trước chưa:
```sql
SELECT Barcode, ProcSeq, ProcessCode, MachineCode, InQty, OutQty, JobDate, CreateUserID, CreateDateTime
FROM STB_ProdRouteHist
WHERE Barcode = 'Mã_Barcode_Cần_Tra'
ORDER BY ProcSeq ASC;
```

### B. Kiểm tra Lot Nguyên vật liệu đầu vào (WMS Trace)
Khi kho NVL báo không gộp được hoặc hệ thống báo Lot nguyên vật liệu không tồn tại:
```sql
SELECT MaterialLotNo, MaterialCode, WarehouseCode, CurrentQty, LotState, UseFlag
FROM STB_MaterialLotInfo
WHERE MaterialLotNo = 'Mã_Lot_NVL_Cần_Check';
-- LotState: 'U' = Đang sử dụng (Active), 'H' = Holding (Bị khóa), 'D' = Báo phế
```

### C. Tra cứu nhanh các ngoại lệ bỏ qua chặn FIFO/Hạn sử dụng
Nếu một Lot NVL hết hạn nhưng được phép dùng tiếp, kiểm tra xem đã được khai báo bypass chưa:
```sql
SELECT * FROM stb_vvt_OpenExpiredMaterial WHERE LotID = 'Mã_Lot_NVL';
```

### D. Kiểm tra block session (Khóa bảng/Database bị treo)
Khi hệ thống phản hồi cực kỳ chậm hoặc giao diện bị xoay vòng vô tận (hang) do tranh chấp tài nguyên dữ liệu, chạy query sau để tìm session đang khóa (block) các session khác:
```sql
SELECT 
    blocking_session_id AS [ID Người Chặn],
    session_id AS [ID Bị Chặn],
    wait_time / 1000 AS [Thời gian đợi (s)],
    wait_type AS [Loại đợi],
    last_wait_type AS [Loại đợi cuối]
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
```

---

## 5. ⚠️ CHECKLIST AN TOÀN TUYỆT ĐỐI CHO DEVELOPER
1. **SELECT trước, UPDATE/DELETE sau:** Luôn chạy câu lệnh SELECT với điều kiện WHERE định sửa để kiểm tra số dòng bị ảnh hưởng.
2. **Không tự ý chạy UID trực tiếp trên Production:** Viết script dưới dạng mẫu có **Transaction (BEGIN TRAN, ROLLBACK/COMMIT)** và gửi cho User có thẩm quyền tự chạy qua SSMS.
3. **Trigger Alert:** Nhớ rằng bảng `STB_MaterialLotInfo` có trigger cập nhật số tồn kho tự động. Khi can thiệp thủ công số lượng, phải kiểm tra các bảng liên quan như `STB_MaterialDocInfo` và `STB_MaterialDocDetail`.

---

*Cập nhật: 2026-05-26 | Tổng hợp và chuẩn hóa bởi Antigravity AI.*

