# KB_10 — Kiến Trúc & Luồng Dữ Liệu (Architecture & Data Flow)

> **Mục đích:** Hiểu bản chất thiết kế của hệ thống MES NAIS
> **Bảng chính:** `STB_ScreenObjects`, `STB_StringResources`, `STB_ProcedureLog` (19.3M rows)
> **🔑 Keywords:** kiến trúc, architecture, dataflow, trigger, agent job, metadata, framework, screen, SP, naming, OQC, electrode, IoT, cost, shift, serial
> ← [Về INDEX](KB_INDEX.md)

---

## 0. 🥖 Bản Dịch Bình Dân: Hiểu Sơ Đồ Luồng Dữ Liệu MES Trong 5 Phút

> **Dành cho ai?** Tài liệu này dành cho bất kỳ ai (kể cả không biết IT hay Database) muốn hiểu hệ thống NAIS MES đang làm cái gì dưới xưởng.
> **Cách đọc:** Hãy tưởng tượng luồng MES giống như **Quy trình mở một Tiệm Bánh Tráng Trộn Sinh Viên.**

### GIAI ĐOẠN 0: Giao thức từ Tổng công ty (Phase 0 - Master Data)
*Tưởng tượng:* Bạn chuẩn bị khai trương tiệm bánh tráng.
*   **Hệ thống ERP (Kế toán tổng):** Đây là Ông chủ lớn trên trụ sở. Ông ấy gửi cho bạn 2 cuốn sổ:
    1.  **Sổ Nguyên Liệu (M_Materials):** Danh sách các món ăn (Bánh tráng, Xoài, Bò khô, Lạc rang...).
    2.  **Sổ Công Thức (M_BOMs):** Dạy bạn 1 suất bánh tráng thì cần 100g bánh, 20g xoài, 10g bò khô. (Chính là cái gọi là `BomVersion`).
*   **Hành động của MES:** MES lấy 2 cuốn sổ này cất vào tủ sắt (`Cấu Hình Master Data`) để làm thước đo chuẩn mực không ai được làm sai.

### GIAI ĐOẠN 1: Nhận chỉ tiêu bán hàng bắt buộc (Phase 1 - Lệnh Sản Xuất)
*Tưởng tượng:* Sáng sớm, Quản lý giao chỉ tiêu bán hàng trong ngày.
*   **PO Tháng (B310):** Chỉ tiêu tháng này phải bán được 30.000 bịch bánh tráng.
*   **Kế hoạch Ngày (B450 - Kế hoạch Ca):** Chia nhỏ ra, Cửa hàng số 1 (Line 1) ca sáng hôm nay (Shift 1) phải làm xong 1.000 bịch.
*   **⚠️ CÚ CHỐT QUAN TRỌNG NHẤT (`Nút FixDayPlan`):** 
    Quản lý vạch nếp xong phải **Ký Tên Đóng Dấu Chốt Sổ (IsFixed = True)**. Nếu quản lý quên ký, nhân viên bên dưới tuyệt đối không được phép luộc trứng hay thái xoài. (Máy quét dưới xưởng sẽ văng lỗi *Plan is locked*).

### GIAI ĐOẠN 2: Đi chợ nhập nguyên liệu (Phase 2 - Kho NVL)
*Tưởng tượng:* Xe tải ba gác chở Bánh Tráng, Xoài, Bò khô tới trước cửa tiệm.
*   **Bơm vào kho (F330):** Bạn không vác cả bao tải 50kg bò khô ném vào bếp. Bạn lấy túi zip chia nhỏ ra mỗi túi 1kg. Dán lên mỗi túi zip một tờ giấy ghi ID: "Bò Khô - Lô 01". (Đây chính là quá trình **Tạo Mã Barcode nhỏ (`M_Lots`)**).
*   **⚠️ CÚ CHỐT SỐNG CÒN (Đặc Tính 10):** 
    Lúc dán tem, bạn **BẮT BUỘC phải ghi Hạn Sử Dụng (VD: Hết hạn ngày 30/12)**. Nếu bạn quên ghi ngày ném sổ, túi bò khô đó lập tức bị "Bảo vệ" ném vào phòng Giam Lỏng (kho `Holding`). Tuyệt đối cấm mang vào bếp!
*   **Thử Độc (C220 - IQC):** Quản lý chất lượng nếm thử miếng bò mốc không? Ngon (Pass) thì cho lên kệ. Dở (Fail) thì trả lại thằng bán.
*   **Nhập Bếp (F430 - Move Inventory):** Xách cái túi Zip 1kg Bò khô đó từ "Kho Ngoài" (`SubInv: Main`) ném vào "Bàn Bếp" (`SubInv: Line`) để chuẩn bị trộn.

### GIAI ĐOẠN 3: Bếp trưởng trộn bánh và sự tích cấn trừ kho (Phase 3 - Sản Xuất & Tự Kiểm)
*Tưởng tượng:* Quá trình trộn bánh tráng thực tế của Bếp trưởng. (Trái tim của hệ thống MES, nơi dữ liệu dao động dữ dội nhất).
*   **Bắt đầu làm (B540 - Quét mã sinh Lệnh):** 
    Bếp trưởng xách túi Bò Khô 1kg đó ra, lấy "súng bắn bill" tít một phát vào mã vạch trên túi zip. 
    Lúc này, hệ thống sẽ khai sinh ra một chiếc Nồi Trộn Ảo (phần mềm gọi là `W_WIPLots` - Lot Bán Thành Phẩm). Cái nồi này được dán nhãn: **"Đang làm Bịch Bánh Tráng Số 001. Trạng thái: ĐANG NẤU (Run)"**.
*   **⚠️ CÚ PHÉP THUẬT QUAN TRỌNG NHẤT: BACKFLUSH (Cấn trừ tồn kho tự động):**
    Ngay khi tiếng "tít" vang lên, một bóng ma vô hình trong máy tính (gọi là `SP_CONSUME`) sẽ lôi cuốn **Sổ Công Thức (BomVersion)** ra dò.
    *   Sổ ghi: "1 suất hao 10g Bò khô".
    *   Bóng ma sẽ chạy thẳng vào hệ thống máy tính của cái túi Zip Bò khô 1kg kia... nó tự động dùng bút tẩy con số 1000g đi, viết lại thành **990g**. 
    *   => *Đó chính là Backflush! Công nhân không cần phải tự chép tay sổ kho báo "hôm nay tôi xài hết 10g", máy tính đã trừ nợ dùm họ một cách vô hình.*
*   **Kiểm tra Giữa Chiều (B597 - Bếp tự nếm):** 
    Bếp phó nếm thử xem mẻ bánh này vừa miệng chưa. Ghi vào sổ tay nội bộ của nhà bếp (Bảng dữ liệu này mang cờ `TEST`). 
    *Lưu ý: Cái này chỉ là bếp tự kiểm tra nhau cho yên tâm, không có giá trị pháp lý với cơ quan chức năng.*
*   **Khai Báo Phế Liệu (B530 - Báo Lỗi / Defect):** 
    Đang trộn thì bếp trưởng hắt xì hơi văng nước bọt vào nồi! Rất tiếc, cả mẻ bánh đó phải đổ sọt rác. 
    Lúc này thợ phải bấm nút "Khai Báo Lỗi" trên màn hình. Họ chọn mã lỗi C132: "Lỗi mất vệ sinh". Hệ thống sẽ trừ điểm KPI ca làm việc đó. 
    *(⚠️ Chú ý: Cuối giờ chiều, 10 thằng thợ cùng thi nhau bấm "Lưu Lỗi" 1 lúc, cửa hàng sẽ nghẽn mạng! Thợ IT gọi cái này là `Deadlock Table` do nghẽn cổ chai dữ liệu).*
*   **Thanh Tra Y Tế Gõ Cửa (C443 - PQC Độc Lập):** 
    Đây là thanh tra của Cục Vệ sinh An toàn thực phẩm (Phòng QC riêng biệt). Họ lấy mẫu mang về phòng Lab xét nghiệm vi khuẩn. Dữ liệu của họ lưu vào một cuốn sổ xịn có Mộc Đỏ (Cờ `QUALITY`).
    *   **Nếu Thanh tra bảo MẶN QUÁ (Fail):** Chiếc "Nồi Trộn 001" ngay lập tức bị cảnh sát niêm phong! Phần mềm đổi Trạng thái nhãn nồi thành **HOLD (Khóa/Giam lỏng)**. Không ai được quyền đụng vào nồi bánh này để mang đi đóng gói.
    *   **Nếu Thanh tra OK (Pass):** Nồi bánh dán mộc XANH, tiếp tục chờ đi sang phòng Đóng Hộp.

### GIAI ĐOẠN 4 & 5: Đóng hộp và dán tem bảo hành (Phase 4 & 5 - Đóng gói & Đầu ra)
*Tưởng tượng:* Nhét 50 bịch bánh nhỏ vào 1 cái Thùng Cartoon lớn giao Shipper.
*   **Tạo thùng bự (B523 - Đóng Packing):** Gom 50 bịch bánh con nhét vô 1 Thùng Carton bự. Máy sinh ra mã vạch bự, dán lên thùng (Barcode `Outer`).
*   **⚠️ LƯU Ý MỰC IN:** Luật của xưởng là tem Thùng Bự chỉ được phát ra duy nhất 1 lần để chống làm giả nhái. Máy in rách tem thì khóc ròng, phải gọi IT vào phá khóa (`Void`) mới in lại được.
*   **Khám nghiệm tử thi lần cuối (C530 - Đo 20 Params):** Thùng đóng xong, QC lôi ra đo cân nặng, đo độ mặn ngọt, độ giòn bề mặt (20 thông số). 
*   **⚠️ CÚ CHỐT VÀO KHO (EvaluateResult = OK):** Đo xong phải đóng dấu MỘC ĐỎ chữ "OK / NGON". Cột dữ liệu thiếu chữ OK này thì kho Thành phẩm (Bắc Ninh/Bắc Giang) kiên quyết không mở cửa cho xe tải đổ hàng vào. (Lệnh bị khóa `Hold_Line_FG`).

### GIAI ĐOẠN CỐT: Xe tải lăn bánh & Thu tiền (Phase 6 - Kết xuất ERP)
*Tưởng tượng:* Shipper tới bốc thùng hàng đi giao.
*   **In tem ra đường (B453):** Dán cái mã bưu điện ngoài cùng lên Thùng Cartoon. Trên phần mềm phải đánh dấu Tick vô cái ô "Là Tem Ngoài" (`IsOuterPrinted`). Không tick ô này, ông bảo vệ cổng không cho ra.
*   **Thu tiền (Job Sync ERP):** Khi Thùng Cartoon bước qua khỏi cổng điện tử nhà máy, Hệ thống Tự Động Gửi 1 Vạn Tin Nhắn SMS (`Trigger Background Job`) bắn báo cáo về Kế Toán Trụ Sở. 
*   **Kết cục:** Kế toán nghe "Ting Ting" -> Xuất Hóa Đơn -> Đếm tiền. Cây gia phả Lô sản phẩm khép lại một kiếp luân hồi êm đẹp.

---

## 1. 🏛️ Kiến Trúc Hệ Thống (NAIS Architecture)

### 1.1 Tổng Quan Kiến Trúc (The Three Pillars)

> **Câu hỏi cốt lõi:** Khi OP bấm nút "Save" trên màn hình B597 — chuyện gì xảy ra phía sau?

Hệ thống được xây dựng trên **3 Trụ cột chính**:

*   **Trụ cột 1 — Metadata (SmartFramework):** *"UI chỉ là vỏ, não nằm trong DB"*
    MES không fix cứng hành vi của từng nút bấm trong code phần mềm (C#/Java). Thay vào đó:
    *   Mỗi nút "Save" chỉ gọi 1 tên SP được cấu hình trong bảng `STB_ScreenObjects`.
    *   Muốn thay đổi hành vi → sửa trong DB, **không cần đóng gói lại phần mềm**.
    
    ```
    OP bấm "Save" → NAIS Framework đọc STB_ScreenObjects → Gọi đúng SP → SP xử lý → Ghi DB
    ```

*   **Trụ cột 2 — Stored Procedures:** *"Mọi hành động đều có dấu vết"*
    Mọi thao tác của OP đều được ghi vào bảng lịch sử (`Hist`) thông qua SP. SP là nơi chứa toàn bộ:
    *   **Validation** (kiểm tra hợp lệ trước khi lưu).
    *   **Business logic** (tính toán, kiểm tra FIFO, kiểm tra hạn dùng).
    *   **Ghi dữ liệu** (INSERT/UPDATE vào DB).

*   **Trụ cột 3 — Recursive Logic (Tính toán trực tiếp):** *"Tồn kho sản xuất tự cập nhật qua SP, không dùng triggers"*
    > ⚠️ **Lưu ý (Audit 2026-05-05):** Hệ thống **không sử dụng Triggers trên các bảng sản xuất chính** (như `STB_ProdRouteHist`, `STB_SetInfo`) để tự động trừ kho/cập nhật tồn kho sản phẩm.
    
    Thay vào đó, logic cập nhật tồn kho sản xuất được thực hiện **trực tiếp** thông qua chuỗi gọi Stored Procedure:
    `usp_DoProcessProdRouteHist` → `usp_DoProcessProdGIMaterialByBOM` → `usp_DoCreateMaterialDocLotInfoNotUsedBarcode`.
    *(Lưu ý: Đối với phân hệ kho WMS vật tư, hệ thống vẫn sử dụng Trigger liên hoàn như `tgMaterialLotInfoForUpdate` trên bảng `STB_MaterialLotInfo` để đồng bộ số lượng tồn kho tổng sang `STB_MaterialStock`).*

### 1.2 Kiến Trúc Vận Hành NAIS (NAIS Framework Architecture)

> **Nguyên lý cốt lõi:** NAIS (SmartFramework) là hệ thống **Metadata-Driven**. Giao diện (UI) không chứa logic, mọi hành động (Click, Search, Save) đều được cấu hình trong database metadata để gọi Stored Procedure.

#### Phân vùng Database
Hệ thống Vinatech MES chia làm 2 cơ sở dữ liệu (DB) chính:
*   **`SmartFactoryV2`**: Chứa toàn bộ dữ liệu nghiệp vụ (Sản lượng, Tồn kho, Lệnh sản xuất, BOM, Route).
*   **`SmartFramework`**: Chứa Metadata hệ thống (Menu, User, Quyền hạn, Cấu hình giao diện, Template nhãn in `STB_LabelInfo`).

#### Cách tìm Logic đằng sau bất kỳ màn hình nào
Để hiểu thấu đáo hệ thống, bạn không cần đọc code C#, chỉ cần truy vấn database `SmartFramework` với tài khoản `vanduc`:

**Bước 1: Tìm Tên Màn Hình (ScreenName)**
Tra cứu `Caption` (hiển thị trên tab) và `Name` (ID kỹ thuật) trong `STB_ScreenInfo`.

**Bước 2: Tìm SP tương ứng**
```sql
SELECT ScreenName, ObjectName, ObjectType, Description 
FROM SmartFramework.dbo.STB_ScreenObjects 
WHERE ScreenName = 'VVT_MaterialStockList' -- Thay bằng tên màn hình
```
*   `SearchFunction`: SP dùng để nạp dữ liệu vào Grid (lưới).
*   `ExecuteFunction`: SP dùng khi nhấn nút Save/Delete/Process.

### 1.3 Bảng Ánh Xạ Screen → SP → Table (Database-Driven Architecture)

> **Nguyên tắc vàng:** Mọi thứ trên UI — button, grid, thông báo lỗi, thông báo chặn — đều **khởi nguồn từ database**. Hệ thống MES được thiết kế hoàn toàn **Database-Driven**: IT Admin tạo SP/Function dưới DB → kéo lên UI qua bảng `STB_ScreenObjects` → tạo ra CRUD, UX, validation.

#### Quy mô hệ thống (thống kê thực tế)

| Thành phần | Số lượng | Nằm ở đâu |
|---|---|---|
| Stored Procedures | **3,395** | SmartFactoryV2 |
| Functions (Scalar + Table) | **106** | SmartFactoryV2 |
| Triggers | **33** | SmartFactoryV2 |
| RAISERROR points (trong SP) | **960** | Trong code SP |
| Lệnh `usp_RaiseLocalizedError` | **134** | Đa ngôn ngữ KR/VN/EN |
| String Resources (label/error) | **17,751** | SmartFramework |
| Screen definitions | **1,467 (1,026 unique TCodes)** | SmartFramework |
| Screen Objects (Action/Search/Execute/View) | **7,604** | SmartFramework |

#### Mô hình 3 tầng: UI → SP → Table

```
┌─────────────────────────────────────────────────────────────────────┐
│                      BỀ MẶT (SmartFramework UI)                     │
│                                                                     │
│  STB_ScreenInfo (1,467 screens / 1,026 TCodes) → Name, TCode, Caption             │
│       │                                                             │
│       └── STB_ScreenObjects (7,604 objects)                        │
│               ├── SearchFunction (1,856) → SP _get → nạp Grid      │
│               ├── ExecuteFunction (1,572) → SP _iud → ghi dữ liệu │
│               ├── Action (2,362) → Nút bấm → gọi ExecuteFunction   │
│               └── View (1,814) → Định nghĩa Grid/Tab hiển thị     │
└─────────────────────────────┬───────────────────────────────────────┘
                              │ gọi SP
┌─────────────────────────────▼───────────────────────────────────────┐
│                   BẢN CHẤT (SmartFactoryV2 DB)                      │
│                                                                     │
│  3,395 SPs chứa: Validation → Business Logic → CRUD → RAISERROR   │
│  106 Functions: fn_VVT_getdatebyVendorLot, fn_GetWeekIndex...      │
│  33 Triggers: Auto-log, auto-sync, chặn sửa, đồng bộ DayPlanNo   │
└─────────────────────────────┬───────────────────────────────────────┘
                              │ đọc/ghi
┌─────────────────────────────▼───────────────────────────────────────┐
│                       DỮ LIỆU (Tables)                              │
│                                                                     │
│  STB_SetInfo, STB_ProdRouteHist, STB_MaterialLotInfo...            │
│  + Cross-DB: SmartFramework.dbo.STB_StringResources (error msgs)   │
│  + Cross-DB: SmartFramework.dbo.STB_LabelInfo (tem XML layout)     │
└─────────────────────────────────────────────────────────────────────┘
```

#### Ví dụ cụ thể: B523 (Đóng gói) — 46 objects

| ObjectType | ObjectName | Chức năng |
|---|---|---|
| **SearchFunction** | `usp_Vietnam_GetProdPackingForBarcode_VVT` | Load danh sách Lot theo Barcode |
| **SearchFunction** | `usp_Vietnam_GetBoxIDForLotNo_VVT` | Load box đã gộp |
| **ExecuteFunction** | `usp_Vietnam_DoProcessProdPacking_VVT` | **Core:** Gộp box → validation → ghi DB |
| **ExecuteFunction** | `usp_DoCreatePackingLabelInfo` | Tạo dữ liệu in tem |
| **ExecuteFunction** | `usp_SplitPackingBox` | Chia box |
| **Action** | `MergeBox` | Nút "Box합포" (Gộp box) → gọi ExecuteFunction ở trên |
| **Action** | `SplitBoxQty` | Nút "Chia box" |
| **Action** | `LabelPrint` | Nút "In tem" |
| **View** | `ProdPackingForBarcode` | Grid hiển thị kết quả Search |

> 💡 **Query tra cứu nhanh:** Khi nhận lỗi từ bất kỳ màn hình nào, chạy query sau để biết SP nào đứng đằng sau:
> ```sql
> -- Bước 1: Tìm ScreenName từ TCode
> SELECT Name FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'B523'
> -- Kết quả: 'Vietnam_Donggoi'
>
> -- Bước 2: Liệt kê tất cả SP/Action
> SELECT ObjectName, ObjectType, Caption
> FROM SmartFramework.dbo.STB_ScreenObjects
> WHERE ScreenName = 'Vietnam_Donggoi'
> ORDER BY ObjectType, ObjectName
> ```

### 1.4 Cơ Chế Error / Notification (Từ DB → UI Popup)

> **Mọi thông báo lỗi, thông báo chặn trên UI đều xuất phát từ SP trong database.**

#### Pipeline xử lý Error Message

```
Bước 1: SP viết message (thường tiếng Hàn)
        SET @ErrorMsg = '이미 Lot를 생성하였습니다'
                        ↓
Bước 2: Gọi usp_RaiseLocalizedError(@pProcessLanguage, @ErrorMsg)
                        ↓
Bước 3: SP này wrap message = '^' + @pMessage + '^'
                        ↓
Bước 4: Gọi SmartFramework.dbo.usp_GetAddonStringResource
        → Lookup trong STB_StringResources theo Language + Name
                        ↓
Bước 5: Tìm thấy bản dịch Vietnamese/English → trả về @ErrorMessage
                        ↓
Bước 6: RAISERROR(@ErrorMessage, 16, 1) → Client nhận → Popup UI
```

#### Bảng `STB_StringResources` (17,751 bản ghi)

| Language | Số lượng | Ghi chú |
|---|---|---|
| Default (Korean) | 17,751 | Bản gốc — mọi message viết tiếng Hàn trước |
| Vietnamese | 15,548 | Bản dịch cho operator VN |
| English | 7,377 | Bản dịch EN (chưa đầy đủ) |

> ⚠️ **Tại sao popup hiện tiếng Hàn?** Vì message đó chưa có bản dịch Vietnamese trong `STB_StringResources`. Fix: INSERT thêm bản ghi Language='Vietnamese' với Value tiếng Việt.

#### 2 Pattern Error trong SP

| Pattern | Cách dùng | Số lượng | Khi nào dùng |
|---|---|---|---|
| `RAISERROR(@msg, 16, 1)` | Trực tiếp, hardcode message | 960 | Logic đơn giản, không cần đa ngôn ngữ |
| `EXEC usp_RaiseLocalizedError` | Qua pipeline đa ngôn ngữ | 134 | Cần hiển thị đúng ngôn ngữ user |

#### Query debug error message

```sql
-- Tìm bản dịch của 1 error message
SELECT Language, Name, Value
FROM SmartFramework.dbo.STB_StringResources
WHERE Name LIKE '%이미 Lot%'  -- Tìm theo tiếng Hàn gốc
ORDER BY Language

-- Thêm bản dịch Vietnamese cho message chưa có
INSERT INTO SmartFramework.dbo.STB_StringResources (Language, Type, Name, Value, ChangeDateTime)
VALUES ('Vietnamese', 'Addon', '^이미 Lot를 생성하였습니다^', N'Lot đã được tạo rồi', GETDATE())
```

### 1.5 Cross-Database Links (Liên kết giữa các DB)

> **"Link dữ liệu giữa các màn hình thực chất là link dữ liệu giữa các table giữa các database."**

#### 3 Database chính + liên kết

```
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│   SmartFactoryV2     │     │   SmartFramework      │     │  SmartFramework_File │
│                      │     │                       │     │                      │
│ 3,395 SPs            │────▶│ STB_ScreenObjects     │     │ File attachments     │
│ Dữ liệu nghiệp vụ   │     │ STB_StringResources   │     │ Label XML layout     │
│ STB_SetInfo          │     │ STB_LabelInfo         │     │                      │
│ STB_ProdRouteHist    │◀────│ STB_ScreenInfo        │     │                      │
│ STB_MaterialLotInfo  │     │ STB_UserInfo          │     │                      │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
         │                            │
         │ 869 SPs gọi cross-DB       │
         └────────────────────────────┘
```

| Hướng link | Mục đích | Ví dụ SP |
|---|---|---|
| SmartFactoryV2 → SmartFramework | Serial generation | `SmartFramework.dbo.usp_DoCreateSerial` |
| SmartFactoryV2 → SmartFramework | Error message lookup | `SmartFramework.dbo.usp_GetAddonStringResource` |
| SmartFactoryV2 → SmartFramework | User info | `SmartFramework.dbo.STB_UserInfo` |
| SmartFactoryV2 → SmartFramework | Label template | `SmartFramework.dbo.STB_LabelInfo` |
| SmartFactoryV2 → SmartFramework | Serial rule config | `SmartFramework.dbo.usp_GetSerialRule` |

> **Số lượng:** 869 SPs trong SmartFactoryV2 có cross-DB reference tới SmartFramework.

### 1.6 Triggers — Logic Ẩn Tự Chạy (33 Triggers)

> **Triggers = hành động tự động chạy khi data thay đổi.** Operator không biết, không thấy trên UI, nhưng ảnh hưởng trực tiếp đến dữ liệu.

#### Inventory đầy đủ 33 Triggers

| # | Trigger | Bảng | Loại | Tác động |
|---|---|---|---|---|
| 1 | `tgMaterialLotInfoForInsert` | STB_MaterialLotInfo | INSERT | Auto-log khi tạo Lot NVL mới |
| 2 | `tgMaterialLotInfoForUpdate` | STB_MaterialLotInfo | UPDATE | **Đồng bộ tồn kho → STB_MaterialStock** |
| 3 | `tgMaterialLotInfoForDelete` | STB_MaterialLotInfo | DELETE | Auto-log khi xóa Lot |
| 4 | `tgMaterialDocDetailForInsert` | STB_MaterialDocDetail | INSERT | Auto-log phiếu nhập chi tiết |
| 5 | `tgMaterialDocDetailForUpdate` | STB_MaterialDocDetail | UPDATE | Auto-log sửa phiếu |
| 6 | `tgMaterialDocDetailForDelete` | STB_MaterialDocDetail | DELETE | Auto-log xóa phiếu |
| 7 | `tgMaterialDocInfoDelete` | STB_MaterialDocInfo | DELETE | Auto-log xóa header phiếu |
| 8 | `tgMaterialDocLotInfoIUD` | STB_MaterialDocLotInfo | IUD | Auto-log mọi thay đổi Lot phiếu |
| 9 | `tgMaterialDocPickingPlanIUD` | STB_MaterialDocPickingPlan | IUD | Auto-log picking plan |
| 10 | `TR_DayProdPlan_Close` | STB_DayProdPlan | UPDATE | **Chặn sửa kế hoạch đã Close** |
| 11 | `utr_STB_SetInfo_DayPlanNo_iu` | STB_SetInfo | I/U | Đồng bộ DayPlanNo vào SetInfo |
| 12 | `utr_SetInfoRemoveHist` | STB_SetInfo | DELETE | **Log khi xóa Lot** (truy vết) |
| 13 | `utr_ProdRouteHist_DayPlanNo_iu` | STB_ProdRouteHist | I/U | Đồng bộ DayPlanNo vào routing |
| 14 | `utr_MaterialCodeByLine_i` | STB_ProdRouteHist | INSERT | Track vật tư đang chạy trên Line |
| 15 | `utr_DefectRepairInfo_DayPlanNo_iu` | STB_DefectRepairInfo | I/U | Đồng bộ DayPlanNo vào sửa lỗi |
| 16 | `trg_syncSTB_DefectRepairInfo` | STB_DefectRepairInfo | I/U | Sync thông tin sửa lỗi |
| 17 | `utr_ElectrodeCoatingInfo_DayPlanNo_iu` | STB_ElectrodeCoatingInfo | I/U | Đồng bộ DayPlanNo vào Coating |
| 18 | `utr_ElectrodeRollPressingInfo_DayPlanNo_iu` | STB_ElectrodeRollPressingInfo | I/U | Đồng bộ DayPlanNo vào Rolling |
| 19 | `utr_ElectrodeSlittingResult_DayPlanNo_iu` | STB_ElectrodeSlittingResult | I/U | Đồng bộ DayPlanNo vào Slitting |
| 20 | `utr_ElectrodeWasteInfo_DayPlanNo_iu` | STB_ElectrodeWasteInfoNew | I/U | Đồng bộ DayPlanNo vào phế điện cực |
| 21 | `TRG_FinalProductInfo` | STB_FinalProductInfo | I/U | Auto xử lý thành phẩm |
| 22 | `utr_DeleteCheckScheduleExceptionHist` | STB_LineInfo | DELETE | Xóa lịch ngoại lệ khi xóa Line |
| 23 | `utr_MachineInfoChangeHist` | STB_MachineMaster | UPDATE | **Log mọi thay đổi thông tin máy** |
| 24 | `utr_ModelSpecHist_insert` | STB_ModelSpec | INSERT | Log thêm spec model |
| 25 | `utr_ModelSpecHist_update` | STB_ModelSpec | UPDATE | Log sửa spec model |
| 26 | `utr_ModelSpecHist_delete` | STB_ModelSpec | DELETE | Log xóa spec model |
| 27-29 | `utr_ProductStockInfoUpload_i/u/d` | STB_ProductStockInfoUpload | IUD | Auto sync tồn kho TP |
| 30 | `TR_RawMaterialInputHist_DelegateLog_Insert` | STB_RawMaterialInputHist | INSERT | **Log ủy quyền quét NVL** |
| 31 | `TR_RawMaterialInputHist_DelegateLog_update` | STB_RawMaterialInputHist | UPDATE | Log sửa ủy quyền NVL |
| 32 | `utr_UpdateDeleteRollbackForLogTable` | DDLChangeLog | DELETE | Chặn xóa log DDL |
| 33 | `utr_ProcedureChangesLog` | (DDL Trigger) | ALTER/DROP | **Track mọi thay đổi SP/Function** |

> ⚠️ **Quan trọng cho IT Admin:**
> - Trigger #2 (`tgMaterialLotInfoForUpdate`) là **"bóng ma"** đồng bộ tồn kho. Khi UPDATE `STB_MaterialLotInfo` trực tiếp bằng SQL → trigger tự chạy → `STB_MaterialStock` tự cập nhật.
> - Trigger #33 (`utr_ProcedureChangesLog`) ghi lại **mọi lần ALTER/DROP SP** vào bảng `DDLChangeLog`. Dùng để truy vết ai sửa SP gì, lúc nào.

### 1.7 Hệ Sinh Thái 20 Database (Full Ecosystem Map)

> Toàn bộ hệ thống Vinatech chạy trên **20 databases** trên cùng SQL Server, chia thành 4 nhóm:

| Nhóm | Database | Chức năng |
|---|---|---|
| **Core MES** | `SmartFactoryV2` (994 tables, 3,395 SPs) | Dữ liệu nghiệp vụ chính |
| | `SmartFramework` (Screen, User, Label, String) | Metadata framework |
| | `SmartFramework_File` | File attachments, tem XML |
| | `SmartFramework_Temp` | Data tạm |
| **ERP & Kế toán** | `NEOE` | ERP Douzone (Master Data, PO, Invoice) |
| | `erpdb` | ERP legacy |
| | `DZICUBE` | OLAP Cube cho BI/báo cáo |
| **Groupware & HR** | `VINATECH_GROUP` | Văn phòng duyệt, HR, tờ trình |
| | `VINATECH_DATA_KSOX` | Dữ liệu ký số xác thực |
| | `VINATECH_SPREADSHEET` | Spreadsheet nội bộ |
| | `streamdocs` | Xem PDF an toàn |
| **Hệ thống phụ trợ** | `VINATECH_POP` (43 tables) | POP Kiosk xưởng (VINA_PC_MAC, BOM_INPUT_ROUTE) |
| | `VINATECH_RESTFUL` | SSO & API authentication |
| | `VINATECH_WEBSOCKET` | Real-time notification |
| | `AndonDB` (3 tables) | Hệ thống cảnh báo lỗi Line |
| | `WCMS_Standard` / `WCMS_STANDARD_NEW` | Chuyển tiền ngân hàng (Cash Management) |
| **Backup & Incubator** | `SmartFactoryV2_261807` | Backup snapshot |
| | `SmartFactoryIncubator` | Môi trường thử nghiệm |
| | `VINATECH_POP_240625` | POP backup |

#### Linked Servers (Kết nối ERP Korea)

| Linked Server | IP | Mục đích |
|---|---|---|
| `ERPSVR` | 110.11.27.7:2433 | ERP Korea (đọc Master Data gốc) |
| `OLDNAISSVR` | 110.11.27.5 | NAIS server cũ (legacy) |
| `CMS_VINA_LINK` | 110.11.27.5\MESTESTDB:8080 | CMS ngân hàng |

### 1.8 SQL Agent Jobs — Tự Động Hóa Nền (Background Automation)

> Hệ thống có **~40 Agent Jobs** chạy tự động mỗi ngày. Đây là "người lao công vô hình" xử lý đồng bộ dữ liệu, snapshot, và backup.

| Nhóm | Job | Lịch | Chức năng |
|---|---|---|---|
| **Đồng bộ liên nhà máy** | `Tranfer_BacGiang_To_BacNinh` (20+ steps) | Daily | Sync dữ liệu BG → BN |
| | `Tranfer_BN_BG` (19 steps) | Daily | Sync dữ liệu BN → BG |
| **Thành phẩm** | `Transfer_FG00_To_C560` | Daily | Chuyển data FG00 → C560 (OQC) |
| | `VN_FINISHEDGOODS_TO_KR_FINISHEDGOODS` | Daily | Sync tồn kho TP → HQ Korea |
| | `VVT_GETDATA_FINISHEDGOOD` | Daily | Lấy data thành phẩm tổng hợp |
| | `vvt_finishgoodCapture` | Daily | Snapshot tồn kho TP |
| **Snapshot & Capture** | `vvt_materialSnapshot` | Daily | Snapshot tồn kho NVL |
| | `vvt_semiInventoryCapture` | Daily | Snapshot bán thành phẩm |
| | `vvt_productreceipt560` | Daily | Auto-insert sản lượng C560 |
| **HR & Chấm công** | `SyncFingerData` | Daily | Đồng bộ dữ liệu vân tay |
| | `VCM_thoigian_08PM` | Daily 8PM | Cập nhật giờ công |
| | `NameShift` | Daily | Phân ca tự động |
| **Email Alert** | `MakeMaterialExpirationEmailAlert` | Daily | Cảnh báo NVL sắp hết hạn |
| | `MakeEmailEquipmentCalibrationCheck` | Daily | Cảnh báo hiệu chuẩn thiết bị |
| **ERP I/F** | `ERP ?????? ??(IU)` (12 jobs) | Monthly | Đồng bộ ERP hàng tháng |
| | `ERP ???? I/F` | Daily | Interface ERP hàng ngày |
| **Backup** | `DB???(4??).?? ??_1` | Daily | Full backup DB (4TB) |
| | `ERPU_DB_full-backup-daily` | Daily | Backup ERP |

> ⚠️ **Quan trọng:** Job `Tranfer_BacGiang_To_BacNinh` có 20+ steps — nếu 1 step fail, dữ liệu giữa 2 nhà máy sẽ bị lệch. Kiểm tra Job History khi phát hiện data BG/BN không khớp.

### 1.9 SP Naming Convention & Phân Lớp Code (Code Archaeology)

#### Quy tắc đặt tên SP (3,395 SPs)

| Pattern | Số lượng | Ý nghĩa | Ví dụ |
|---|---|---|---|
| `*_get` | **594** | Đọc dữ liệu (SELECT) — dùng cho SearchFunction | `usp_ProdRouteHist_get` |
| `*_iud` | **347** | Insert/Update/Delete — dùng cho ExecuteFunction | `usp_SetInfo_iud` |
| `usp_Do*` | **380** | Hành động xử lý (Process) — core engine | `usp_DoProcessProdRouteHist` |
| `usp_VN_*` | **377** | Vinatech custom (VN = Vietnam) | `usp_VN_Update_GoodFinish_HY_New` |
| `usp_Vietnam_*` | **159** | Vinatech custom (tên dài hơn) | `usp_Vietnam_DoProcessProdPacking_VVT` |
| `usp_vvt*` | **105** | VVT-specific logic | `usp_vvt_MaterialLotInfo_get` |
| `*_uid` | **32** | Variant: Update/Insert/Delete | `usp_VN_FinishGood_BG_StockIn_uid` |
| `pop_*` | **5** | POP Kiosk chuyên dụng | `pop_Electrode_Coating_iud` |
| Other | 1,416 | NAIS gốc (Korea) | `usp_BomHeader_iud` |

#### Phân lớp: NAIS gốc vs Vinatech custom

```
SmartFactoryV2 (994 tables)
├── NAIS gốc (Korea): ~793 tables (STB_* prefix)
│   └── SP gốc: usp_*, pop_*
└── Vinatech custom: 201 tables (VVT_*, VN_*, Vietnam_*, FinishGood*, stb_vvt_*)
    └── SP custom: usp_VN_*, usp_Vietnam_*, usp_vvt*
```

> 💡 **Cách phân biệt nhanh:** SP có `VN`, `Vietnam`, `VVT`, `HN`, `BG`, `HY`, `Enesol` trong tên = **Vinatech tự viết**. SP không có = **NAIS gốc** (Korea dev viết).

#### Serial Rules (Cách sinh mã tự động)

| Bảng | Prefix | SerialLen | Ví dụ mã sinh ra |
|---|---|---|---|
| STB_SetInfo | YYYYMMDD | 6 | `20260618000001` |
| STB_ProdRouteHist | YYYYMMDD | 6 | `20260618000001` |
| STB_MaterialLotInfo | YYYYMMDD | 6 | `ML20260618000001` |
| STB_MaterialDocInfo | YYMMDD | 6 | `260618000001` |
| STB_DayProdPlan | YYYYMMDD | 5 | `2026061800001` |
| STB_DividePackaging | HNDPK | 10 | `HNDPK0000000001` |

#### Hệ thống phân quyền (80 UserTypes)

| Nhóm | UserType | Số users | Quyền |
|---|---|---|---|
| **Sản xuất** | ProductionManagement | 191 | Quản lý SX toàn bộ |
| | vi_productionCell | 127 | Operator Cell Line |
| | VVT_WorkerManagement | 106 | Quản lý công nhân VVT |
| | vi_productionTech | 56 | Kỹ thuật SX |
| **QC** | QualityManagement | 130 | Quản lý QC |
| | vi_QC | 100 | Nhân viên QC |
| | VVT_QC_Team | 46 | QC Team VVT |
| **Kho** | MaterialManagement | 97 | Quản lý NVL |
| | vi_warehouse | 74 | Thủ kho |
| | ROHWarehouseUser | 56 | User kho nguyên liệu |
| **IT** | Admin | 69 | Full quyền |
| | Developer | 14 | Dev (debug) |
| | FunctionExtentsion | 38 | Mở rộng function |

> Quyền được gán qua `STB_UserPermissionGroup` (UserID → UserType) + `STB_UserTypeBasicPermission` (UserType → ScreenID + FuncID + Allow).

#### VW_WipResult — View tính WIP lớn nhất (17,684 chars, 9 tables)

View này join: `STB_ProdRouteHist` + `STB_SetInfo` + `STB_RouteInfo` + `STB_LineInfo` + `STB_MaterialMaster` + `STB_MaterialQcInfo` + `STB_DefectRepairInfo` + `STB_BasicRoutingInfo` + `STB_BasicRoutingDetail` → Tính toán WIP (Work In Progress) toàn nhà máy.

#### DDLChangeLog — Audit Trail cho IT Admin

```sql
-- Xem 10 thay đổi SP gần nhất
SELECT TOP 10 PostTime, LoginName, EventType, ObjectName, LEFT(CommandText, 100) AS Preview
FROM SmartFactoryV2.dbo.DDLChangeLog WITH(NOLOCK)
ORDER BY PostTime DESC

-- Xem ai sửa 1 SP cụ thể
SELECT PostTime, LoginName, EventType
FROM SmartFactoryV2.dbo.DDLChangeLog WITH(NOLOCK)
WHERE ObjectName = 'usp_Vietnam_DoProcessProdPacking_VVT'
ORDER BY PostTime DESC
```

> **Columns:** LogID, EventType, PostTime, LoginName, UserName, DatabaseName, ObjectName, CommandText (full SQL), EventXML, IpAddr

### 1.10 OQC Pipeline (Luồng Kiểm Tra Chất Lượng Thành Phẩm)

> OQC = Outgoing Quality Control — kiểm tra SP trước khi xuất kho cho khách hàng.

```
C451 (PQC InProcess)     C560 (FG Receipt)      C530 (OQC Sample)        C531 (OQC Packing)
┌─────────────────┐     ┌──────────────────┐    ┌──────────────────┐     ┌──────────────────┐
│ Quét barcode SP  │     │ Nhập sản lượng   │    │ Đo 20 params     │     │ Gộp box OQC      │
│                  │────▶│ vào kho FG       │───▶│ Pass/Fail/Hold   │────▶│ In tem OQC       │
│ usp_DoFinish     │     │ usp_Products     │    │ usp_DoUpdateMat  │     │ usp_DoProcess    │
│ CommInspDoc_VNT  │     │ ReceiptHist_iud  │    │ QcInfo_Success   │     │ OQCrefer_VVT     │
└─────────────────┘     └──────────────────┘    └──────────────────┘     └──────────────────┘
                                                         │
                                                   C540 (OQC History)
                                                ┌──────────────────┐
                                                │ Lịch sử kết quả  │
                                                │ usp_ProdInspec   │
                                                │ tionHist_get     │
                                                └──────────────────┘
```

| TCode | Tên | SPs chính | Chức năng |
|---|---|---|---|
| C451 | PQC In-Process | `usp_DoFinishCommInspDoc_VNT`, `usp_DoAddCommInspMeasureHistForBarcode` | Nhập kết quả kiểm tra công đoạn |
| C530 | OQC Sample Management | `usp_DoUpdateMaterialQcInfo_Success/Fail/Hold/Complete`, `usp_DoMakeMaterialQcSampleResult` | **Core OQC:** Đo mẫu, nhập 20 params, quyết định Pass/Fail |
| C531 | OQC Packing | `usp_DoProcessOQCrefer_VVT`, `usp_DoProcessProdPackingByOne_VNT` | Gộp box OQC + in tem OQC |
| C540 | OQC History | `usp_ProdInspectionHist_get` | Xem lịch sử kết quả OQC |
| C560 | FG Receipt | `usp_ProductsReceiptHist_iud` | Nhập sản lượng thành phẩm vào kho FG |

> 💡 **Kết quả OQC ảnh hưởng trực tiếp:** Pass → FG Stock-In cho phép xuất kho. Fail → Hold. Rescreening = kiểm tra lại lần 2.

### 1.11 Electrode Manufacturing Flow (Sản Xuất Điện Cực)

> Điện cực = vật liệu quan trọng nhất trong sản xuất tụ điện. Lỗi điện cực = lỗi toàn bộ sản phẩm.

```
B802 (Nhập SX)         F743 (Slitting)       F744 (Width)        F745 (Merge Lot)       F748 (Transfer WH)
┌──────────────┐      ┌───────────────┐     ┌──────────────┐    ┌───────────────┐      ┌───────────────┐
│ Quét barcode  │      │ Chia cuộn     │     │ Kiểm tra     │    │ Gộp các cuộn  │      │ Chuyển kho    │
│ cuộn điện cực │─────▶│ (Split Lot)   │────▶│ chiều rộng   │───▶│ nhỏ thành     │─────▶│ sau QC Pass   │
│               │      │ usp_DoSplit   │     │ Width Test   │    │ cuộn lớn      │      │               │
│ usp_Vietnam_  │      │ LotSlitting   │     │ usp_Width    │    │ usp_Vietnam_  │      │ usp_Update_   │
│ Electrode     │      │               │     │ Slitting_uid │    │ DoProcessMat  │      │ POIL_Lot_     │
│ ProdRouteHist │      │               │     │              │    │ PackingVVT    │      │ Transfer_WH   │
│ _get          │      │               │     │              │    │               │      │               │
└──────────────┘      └───────────────┘     └──────────────┘    └───────────────┘      └───────────────┘
                              │
                        F746 (History)
                      ┌───────────────┐
                      │ Xem lịch sử   │
                      │ Parent→Child   │
                      │ chia cuộn      │
                      └───────────────┘
```

| TCode | SPs chính | Mục đích |
|---|---|---|
| B802 | `usp_Vietnam_ElectrodeProdRouteHist_get` | Nhập SX Electrode vào routing |
| F743 | `usp_DoSlittingLot`, `usp_DoSplitLot`, `usp_ChotSlittingLot` | **Core:** Chia cuộn lớn → nhiều cuộn nhỏ |
| F744 | `usp_WidthSlitting_uid` | Kiểm tra chiều rộng sau slitting |
| F745 | `usp_Vietnam_DoProcessMaterialPacking_VVT` | Gộp các cuộn nhỏ thành batch lớn |
| F746 | `usp_GetParentSplitedMaterialLotInfo`, `usp_GetChildSplitedMaterialLotInfo` | Truy vết Parent→Child cuộn |
| F748 | `usp_Update_POIL_Lot_Transfer_WarehouseCode` | Chuyển kho sau QC |

> ⚠️ **Bảng key Electrode:** `STB_ElectrodeCoatingInfo`, `STB_ElectrodeSlittingResult`, `STB_ElectrodeRollPressingInfo`, `STB_ElectrodeWasteInfoNew`.

### 1.12 Customer Label Pipeline (In Tem Khách Hàng Chuyên Biệt)

> Mỗi khách hàng lớn có luồng in tem riêng, với template XML riêng và SP riêng.

| TCode | Khách hàng | SP chính | Đặc biệt |
|---|---|---|---|
| **K198** | Bloom Energy | `usp_DoPrintBloomEnergySL7Label` | Barcode SL-7 format riêng |
| **K199** | Nordex | `usp_NordexPackingLabelPrintingHist_get` | Packing label chuyên dụng |
| **B754** | PAC | `usp_VN_PACBoxLabelPrintHist_iud`, `usp_PACBoxLabalInfo_get_Vietnam` | Tem thùng KH PAC |
| **B755** | PAC (History) | `usp_PACBoxLabelPrintHist_get` | Lịch sử in tem PAC |
| **B756** | PAC (Carton) | `usp_PACLabelCartonWeight_get_Vietnam` | Tem carton + cân nặng |
| **B757** | DigiKey | `usp_VN_DigiKeyLabelInnerPrintHist_iud`, `usp_DigiKeyLabelInner_get_Vietnam` | Tem inner DigiKey |
| **B758** | DigiKey (Package) | `usp_VN_DigiKeySingleLevelPackagePrintHist_iud` | Single-level package DigiKey |
| **B790** | Phoenix Contact | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem Phoenix Contact |

> 💡 Template XML lưu trong `SmartFramework.dbo.STB_LabelInfo`, mỗi khách có layout riêng. Khi thêm khách hàng mới → phải: (1) Tạo template XML, (2) Tạo SP in tem, (3) Cấu hình ScreenObjects.

### 1.13 Subsystem Map (Hệ Thống Phụ Trợ)

| Subsystem | DB | Tables | Chức năng | Liên kết MES |
|---|---|---|---|---|
| **Groupware** | VINATECH_GROUP | **383** | Document workflow, HR, tuyển dụng, đánh giá, bán hàng | `VINA_DOCUMENT_*` → tờ trình, duyệt, kế hoạch SX |
| **POP Kiosk** | VINATECH_POP | 43 | Kiosk xưởng: quét NVL, in tem, hiển thị sản lượng | `VINA_PC_MAC` map IP→Line, gọi SP SmartFactoryV2 |
| **RESTful/SSO** | VINATECH_RESTFUL | 3 | SSO: `VINA_SSO_TOKEN`, `VINA_SSO_LOGIN`, `VINA_ALLOWED_IP` | Xác thực user login cho tất cả hệ thống |
| **WebSocket** | VINATECH_WEBSOCKET | 7 | Push notification real-time | Alert sản xuất, cảnh báo lỗi |
| **Andon** | AndonDB | 3 | Cảnh báo lỗi Line: `STB_LineSituation_VVT` (error/status) | Hiển thị trên TV/dashboard sản xuất |
| **CMS** | WCMS_Standard | ? | Cash Management — chuyển tiền ngân hàng | Linked Server `CMS_VINA_LINK` |
| **Enesol/HY** | SmartFactoryV2 (shared) | 3 riêng + shared | Sản phẩm pin Enesol, screens D-series (D000→D110) | Dùng chung DB nhưng có UserType `EnesolProd*` riêng |
| **ERP** | NEOE, erpdb | ? | Douzone ERP: Master Data, PO, Invoice, GL | Linked Server `ERPSVR` (110.11.27.7:2433) |
| **BI/Cube** | DZICUBE | ? | OLAP Cube cho báo cáo, dashboard BI | Aggregation từ SmartFactoryV2 |
| **Spreadsheet** | VINATECH_SPREADSHEET | ? | Spreadsheet nội bộ (kiểu Google Sheets) | Import/Export data MES |

#### Groupware Document Types (Ví dụ luồng phiếu)

```
Groupware VINA_DOCUMENT_*
├── VINA_DOCUMENT_APPROVAL → Duyệt tờ trình/đề xuất
├── VINA_DOCUMENT_PURCHASE_REQUEST → Yêu cầu mua hàng → ERP PO
├── VINA_DOCUMENT_SALES_ORDER → Đơn hàng → Production Plan
├── VINA_DOCUMENT_SAMPLE_REQUEST → Yêu cầu mẫu QC
├── VINA_DOCUMENT_SERVICE_REQUEST → Yêu cầu dịch vụ
├── VINA_DOCUMENT_SEAL_REQUEST → Yêu cầu đóng dấu
└── VINA_WORKFLOW → Luồng duyệt (VINA_WORKFLOW_STEP → từng bước duyệt)
```

### 1.15 IoT & Sensor System (S-series)

> S120 = IoT Measure History dashboard. Dữ liệu sensor nhiệt độ/độ ẩm từ các máy trên Line.

| Bảng/SP | Size | Chức năng |
|---|---|---|
| `STB_IoTMeasureHist` | **28.7 triệu rows** | Lưu giá trị đo (DeviceID, MeasureItemCode, MeasureValue) |
| `usp_VN_Temperature_Humidity` | 19,392 chars | Xử lý dữ liệu nhiệt độ/độ ẩm — SP lớn nhất IoT |
| `usp_IoTDeviceDataSpecOverAlram` | 5,505 chars | Cảnh báo khi sensor vượt ngưỡng |
| `usp_VN_Temperature_TVshow` | 808 chars | Hiển thị lên TV dashboard |
| `usp_DoCreateIoTMeasureHist` | 635 chars | INSERT dữ liệu IoT vào bảng |

> 💡 **Luồng IoT:** Sensor gửi data → `usp_DoCreateIoTMeasureHist` INSERT → `usp_IoTDeviceDataSpecOverAlram` kiểm tra ngưỡng → Alert nếu vượt → `usp_VN_Temperature_TVshow` hiển thị TV.

### 1.16 Cost Management (T-series / StagePrices)

> Giá công đoạn = tiền trả cho công nhân theo từng bước sản xuất.

**Bảng `STB_VVT_StagePrices`** — 83 columns:
- `model` = mã sản phẩm
- `RouteV22` → `RouteV34` = 13 công đoạn BN/BG1 (V-series)
- `PriceV22` → `PriceV34` = Giá tương ứng
- `RouteVE01` → `RouteVE10` = 10 công đoạn Hà Nam (VE-series)
- `PriceVE01` → `PriceVE10` = Giá HN
- `RouteVP01` → `RouteVP08` = 8 công đoạn Hưng Yên (P-series)
- `PriceVP01` → `PriceVP08` = Giá HY
- `MaterialCodeVN_V22` → `_V34` = Mã vật tư VN tương ứng

> ⚠️ **Hardcode columns:** Mỗi nhà máy có cột riêng (V, VE, VP). Nếu thêm nhà máy mới → phải ALTER TABLE thêm cột.

### 1.17 Ca Làm Việc (Shift System)

| CodeShift | Tên | Giờ bắt đầu | Giờ kết thúc |
|---|---|---|---|
| CS01 | Ca ngày | 10:29 | 22:30 |
| CS02 | Ca đêm | 22:31 | 10:30 |

**Tính ca tự động:** Function `fnGetJobDateShiftTime(DateTime, CompanyCode, WorkCenter, Line, Route, NULL)` → trả về `YYYYMMDD` + `ShiftCode` + `TimeCode`. SP `usp_DoProcessProdRouteHist` gọi function này mỗi lần quét barcode → **OP không chọn ca, hệ thống tự tính.**

### 1.18 Vision & XRF Inspection (S-series Deep)

| TCode | Tên | SP chính | Chức năng |
|---|---|---|---|
| S212 | Vision Group Inspection | `usp_VisionGroupInspectionInfo_get` | Kết quả kiểm tra thị giác (camera AI) — report only |
| S213 | Vision Inspection Result | `usp_VisionInspectionResult_get` | Chi tiết kết quả Vision theo lô |
| S215 | XRF Inspection | `usp_XRFInspectionInfo_get` | Kết quả kiểm tra XRF (X-Ray Fluorescence) — thành phần hóa học |

> 💡 Vision + XRF = thiết bị kiểm tra tự động (không cần OP nhập tay). Data ghi trực tiếp từ máy vào DB.

### 1.19 Reliability Test (R-series)

> Kiểm tra độ tin cậy sản phẩm — chạy test dài hạn (nhiệt độ, độ ẩm, tuổi thọ).

```
R110 (Yêu cầu test)    →    R210 (Quản lý test)    →    R220 (Nhập kết quả đo)
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│ Tạo yêu cầu   │           │ Confirm/Cancel │           │ Nhập giá trị  │
│ + Chọn mẫu    │──────────▶│ quản lý tiến độ│──────────▶│ đo theo time  │
│ _iud + Sample  │           │ DoConfirmRT    │           │ MeasureInfo   │
│ Info_iud       │           │ DoCancelRT     │           │ _iud          │
└───────────────┘           └───────────────┘           └───────────────┘
                                                              │
                                                        R230 (RT Master)
                                                        usp_RTInfo_iud
                                                        usp_DoMakeNewRTSeq
```

### 1.20 FG Product Management (G-series) & Daifuku Warehouse

| TCode | Tên | SP chính | Chức năng |
|---|---|---|---|
| G100/G102 | Sales GI | `usp_SalesGI_*` | Xuất kho bán hàng |
| G610 | Product Stock | `usp_ProductStock_get` | Tồn kho thành phẩm |
| G630 | Transform Model | `usp_TransformModel_*` | Chuyển đổi model sản phẩm |
| **G660** | **Daifuku Warehouse** | `usp_DaifukuWarehouse_iud/get/Del` | **Robot kho tự động Daifuku** |
| G661 | Warehouse Receipt | `usp_WarehouseReceipt_get` | Nhập kho robot |
| G662 | Warehouse Delivery | `usp_WarehouseDelivery_get` | Xuất kho robot |
| G680 | Product Stock Upload | `usp_ProductStockInfo_*` | Upload tồn kho (Agent Job snapshot) |
| G710 | Shipment History | `usp_ShipmentHist_*` | Lịch sử xuất hàng |

> 💡 **Daifuku** = hệ thống kho tự động robot Nhật Bản. MES gửi lệnh nhập/xuất → Daifuku robot tự lấy hàng. `usp_WarehouseGrid_iud` = quản lý vị trí (slot) trong kho robot.

---
### 1.14 Bản Đồ TCode Prefix (Phân Loại 1,026 Màn Hình Unique)

> Mỗi prefix = 1 module chức năng. Biết prefix = biết ngay chức năng thuộc nhóm nào.

| Prefix | Screens | Module | Ví dụ |
|---|---|---|---|
| **B** | 373 | **Sản xuất** (Production) — màn hình lớn nhất | B523 (Đóng gói), B530 (Nhập SL), B597 (Scan NVL) |
| **H** | 180 | **Hà Nam** (VVT_F3) — variant của B-series | HN523, HN530, HN597 |
| **C** | 155 | **QC & Chất lượng** (Quality Control) | C451 (PQC), C530 (OQC), C560 (FG Receipt) |
| **F** | 124 | **Kho & Vật tư** (Material/Warehouse) | F330 (Phiếu NVL), F721 (Tồn kho), F743 (Slitting) |
| **Z** | 52 | **System Admin** (Quản trị hệ thống) | Z410 (User), Z530 (Label Design), Z320 (StringResource) |
| **A** | 33 | **Master Data & Kế hoạch** | A210 (BOM), A310 (Route), A418 (Model), A510 (PO) |
| **P** | 30 | **Nhân sự & Tài liệu** (HR/Document) | P111 (Chấm công), P170 (NV Info), P210 (Document) |
| **K** | 28 | **Đặc biệt / Khách hàng** | K101 (LotTracking), K198 (Bloom), K199 (Nordex) |
| **V** | 26 | **Vietnam TOP Menu** (Kế toán, HR, SX, QC, Kho, Máy) | V100(Accounting), V300(Cell), V500(QC), V700(WH) |
| **L** | 25 | **SPT Support** (Sản phẩm phụ trợ) | L120(NVL SPT), L140(Đóng gói SPT), L310(Tồn kho SPT) |
| **E** | 24 | **Bán hàng** (Sales) | E310 (Sales Order), E410 (GI Request), E610 (Complaints) |
| **G** | 23 | **Thành phẩm** (FG Stock/Sales GI) | G100(Xuất KH), G610(Tồn kho TP), G680(Upload), G710(Shipment) |
| **M** | 22 | **MEA** (Đo lường & bản vẽ sản phẩm) | M130(NVL MEA), M220(OQC MEA), M910(ClassInfo) |
| **T** | 16 | **Chi phí SX** (Cost Management) | T110(Chi phí Route), T120(Apply), T888(Thông tin phế) |
| **D** | 6 | **Enesol/Hưng Yên** | D051, D100, D110 |
| **Khác** | 49 | **S**(SmartFactory/IoT), **W**(WorkTime/Ca), **R**(Reliability Test), **I**(IT Inventory) | S120(IoT), W210(DailyWork), R110(Request), IT01(Devices) |

---

