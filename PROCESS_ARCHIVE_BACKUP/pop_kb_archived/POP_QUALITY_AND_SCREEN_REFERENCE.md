<!--
AI-READY METADATA
Purpose: POP Quality & Screen Complete Reference — Toàn thư Kiến trúc & Vận hành Chuyển đổi MES sang POP Web
Scope: pop.vinatech.com/pop/quality, pop.vinatech.com/pop/screen, SmartFactoryV2, VINATECH_POP, Groupware, ERP
Single Source of Truth: POP_KNOWLEDGE_BASE/POP_QUALITY_AND_SCREEN_REFERENCE.md
Related Files:
  - [POP_SYSTEM_INTEGRATION_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_SYSTEM_INTEGRATION_GUIDE.md)
  - [POP_USER_MANUAL.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_USER_MANUAL.md)
  - [POP_TRAINING_SCREEN_QUALITY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_TRAINING_SCREEN_QUALITY.md)
-->

# 🏆 POP QUALITY & SCREEN COMPLETE REFERENCE MANUAL
## Sổ Tay Toàn Thư Vận Hành & Bản Đồ Chuyển Giao: Legacy MES ➔ POP Web

> **Cập nhật:** 2026-08-29 (Xác minh trực tiếp qua Live Automation & Live DB `SmartFactoryV2`)  
> **Cổng Truy Cập:** `https://pop.vinatech.com/pop/screen` & `https://pop.vinatech.com/pop/quality`  
> **Bản quyền:** Vinatech MES & Production Technology Team

---

## 🗺️ 1. MA TRẬN CHUYỂN GIAO TOÀN DIỆN: LEGACY MES (NAIS) ➔ POP WEB

Bảng ánh xạ tương đương giữa các màn hình C# Legacy MES cũ và các phân hệ POP Web mới:

| Phân Hệ Nghiệp Vụ | Màn Hình Legacy MES Cũ | Phân Hệ POP Web Mới (`pop.vinatech.com`) | Bảng CSDL Nguồn (`SmartFactoryV2`) | Stored Procedure Xử Lý |
| :--- | :--- | :--- | :--- | :--- |
| **Sản Xuất / Chốt Sản Lượng** | `B530`, `B540` (Chốt SL công đoạn) | `/pop/screen` (Thẻ LOT, Progress Bar) | `STB_SetInfo`, `STB_ProdRouteHist` | `usp_B530_Save`, `usp_B540_Save` |
| **Nhập Nguyên Vật Liệu (BOM)** | `B782` (Quét NVL vào chuyền) | `/pop/screen` ➔ Tab *Nhập NVL* / Batch | `STB_MaterialLotInfo`, `VINA_BOM_INPUT_ROUTE` | `usp_Material_Input_Save` |
| **Kiểm Tra NVL Đầu Vào** | `C110` (IQC Inspection) | `/pop/quality` ➔ Tab **IQC** | `TB_IQC_RESULT`, `STB_MaterialLotInfo` | `usp_IQC_SaveResult` |
| **Đo Kiểm Công Đoạn (PQC)** | `C220`, `C530` (PQC Data Entry) | `/pop/quality` ➔ Tab **Process (PQC)** | `TB_PQC_RESULT`, `VINA_EQUIPMENT_SETTING`| `usp_PQC_SaveResult` |
| **Phán Định Trạm (Pass/Fail)** | `C546`, `C560` (Route Judge) | `/pop/quality` ➔ Tab **Route Judge (P/F)**| `STB_ProdRouteHist.CompleteRoute` | `usp_Route_Judge_Save` |
| **Kiểm Tra Thành Phẩm (OQC)** | `C310` (OQC Final Inspection) | `/pop/quality` ➔ Tab **OQC** & **FOQC** | `TB_OQC_RESULT`, `STB_SetInfo` | `usp_OQC_SaveResult` |
| **Tái Phân Loại (Re-sorting)** | `B610` (Phân loại thu hồi) | `/pop/screen` ➔ Menu `⋯` *Tái phân loại* | `TB_RESORT_HIST`, `TB_DEFECT_HIST` | `usp_Resort_Process_Save` |
| **Đóng Gói & In Tem Box** | `B810`, `B820` (Đóng gói thùng) | `/pop/screen` ➔ Tab *Đóng gói* (Merge FIFO)| `STB_BoxInfo`, `STB_MaterialMaster` | `usp_Packing_Merge_Save` |
| **In Lại Tem Mã Vạch** | `A120` (In tem nhãn barcode) | `/pop/screen` ➔ Nút *In Nhãn* | `STB_LabelInfo`, `STB_LabelSpecInfo` | `usp_Label_Print_Log` |

---

## 🔍 2. CHI TIẾT PHÂN HỆ QUALITY WEB (`https://pop.vinatech.com/pop/quality`)

### 2.1 Cấu Trúc 7 Tab Nghiệp Vụ Quality

```
https://pop.vinatech.com/pop/quality
├── 🧪 [nav-btn-iqc] IQC: Kiểm tra chất lượng nguyên vật liệu đầu vào
├── ⚙️ [nav-btn-process] Process (PQC): Đo kiểm thông số công đoạn & máy móc
├── 📦 [nav-btn-oqc] OQC: Kiểm định chất lượng thành phẩm trước khi vào kho
├── 🏁 [nav-btn-foqc] FOQC: Final Outgoing Quality Control
├── ⚖️ [nav-btn-routejudge] Route Judge (P/F): Phán định Đạt/Không đạt từng công đoạn
├── 📜 [nav-btn-insphistory] Inspection Records: Lịch sử và biên bản kiểm tra
└── 👤 [nav-btn-self] Self Insp. View: Màn hình tự kiểm của công nhân chuyền
```

### 2.2 Quy Trình Đo Kiểm PQC Thực Tế & Cơ Chế Validation Tự Động

Khi quét mã Barcode (ví dụ `VWQQ2520001E11`):
1. **Hệ thống tự động tải Sơ đồ Định tuyến (Pipeline Routing Graph):**
   $$\text{01. 믹싱 (Trộn - W-01)} \longrightarrow \text{02. 코팅 (Mạ - W-02)} \longrightarrow \text{03. 롤프레싱 (Ép cuộn - W-03)} \longrightarrow \text{04. 포장 (Đóng gói - W-04)}$$
2. **Nạp 20 Hạng Mục Tiêu Chuẩn Kiểm Tra (Inspection Specs):**
   - Hạng mục: `점도` (Độ nhớt).
   - Quy cách chuẩn: `2700 ± 1000 cps`.
   - Giới hạn dưới (LSL): `1700 cps` | Giới hạn trên (USL): `3700 cps`.
3. **Cơ chế Đánh Giá Real-time:**
   - **Trường hợp Đạt (PASS):** Nhập `2500` ➔ Hệ thống tự động chuyển huy hiệu **`OK` (Màu Xanh)**.
   - **Trường hợp Lỗi (NG):** Nhập `1000` (dưới 1700) ➔ Hệ thống lập tức chuyển thành **`NG` (Màu Đỏ)**, đồng thời khóa chuyển công đoạn kế tiếp.

---

## ⚡ 3. CHI TIẾT PHÂN HỆ PRODUCTION SCREEN (`https://pop.vinatech.com/pop/screen`)

### 3.1 Bố Cục Thao Tác 3 Vùng Độc Lập

```
+-----------------------------------------------------------------------------------------+
| HEADER: [VINATech VINA / Hàn Quốc] | Chuyền: Điện cực Bắc Ninh | Công nhân | Time | (↻) |
+-------------------+---------------------------------------------------------------------+
| [DANH SÁCH LOT]   | [KHU VỰC THAO TÁC CÔNG ĐOẠN HIỆN TẠI]                               |
| - Thẻ LOT 1 (Cam) |  - Công đoạn: 02 코팅 (Mạ Coater #1)                                |
| - Thẻ LOT 2 (Xanh)|  - Quản lý NVL: [BOM] CS200 (615 M2) | Thay thế: GAYF00-001         |
| - Thẻ LOT 3 (Done)|  - Kho cấp: ROUTE_VN_WH | LOT: 26062-65-06369 (Tồn: 5839 M2)        |
|                   |  - Bàn phím số cảm ứng + Nút: [LOẠI LỖI] [ĐĂNG KÝ] [HOÀN THÀNH]     |
+-------------------+---------------------------------------------------------------------+
| Nút: WH Chuyển kho | Tự kiểm | Xem BOM | Menu ⋯ (Tái phân loại)        Ngôn ngữ: VI/KO/EN|
+-----------------------------------------------------------------------------------------+
```

### 3.2 Các Quy Tắc Interlock Vận Hành Bất Biến

1. **Khóa Nút Hoàn Thành Sản Xuất (BOM Strict Interlock):**
   - Công nhân **bắt buộc** phải nhập đủ 100% lượng NVL theo BOM trước khi nút *Hoàn thành sản xuất* chuyển từ màu xám (Disabled) sang tím (Active).
2. **Cơ Chế Trừ Tồn Kho FIFO Khi Đóng Gói Gộp (Merge Pack):**
   - Đóng gói gộp $\ge 2$ LOTs sẽ tự động trừ lùi số lượng tuần tự từ trên xuống dưới theo thời gian nhập kho.
3. **Đóng Gói Khác Nhà Máy (Cross-plant Packing):**
   - Khi đóng gói sản phẩm sản xuất tại nhà máy khác (VD: Bắc Ninh chuyển sang Hưng Yên), hệ thống tự động bật popup bắt buộc chọn **Kho Nhập Đích** trước khi xuất mã Box.
4. **Hủy Thùng Khôi Phục Dữ Liệu (Cancel Box Auto-rollback):**
   - Khi bấm Hủy Box trong tab Lịch sử đóng gói, hệ thống tự động hoàn trả số lượng thành phẩm về lại LOT gốc mà không làm sai lệch tồn kho.

---

## 🏛️ 4. BẢO TỒN DỮ LIỆU KHI CHUYỂN GIAO: MES ➔ POP WEB

Khi công ty chuyển giao từ phần mềm cài đặt máy tính (Legacy MES) sang ứng dụng Web (POP Web), **toàn bộ 33 cơ sở dữ liệu và quy trình Groupware được giữ nguyên vẹn 100%**:

```mermaid
graph LR
    subgraph Frontend Layer
        OLD[Legacy MES C# Client] -.->|Thay thế hoàn toàn bằng| NEW[POP Web: pop.vinatech.com]
    end

    subgraph Data & Backend Layer (GIỮ NGUYÊN)
        NEW --> SF[SmartFactoryV2: Dữ liệu Sản xuất & Kho]
        NEW --> VPOP[VINATECH_POP: Cấu hình Kiosk & Interlock]
        NEW --> GW[VINATECH_GROUP: Phê duyệt Lệnh SX & NCR]
        NEW --> ERP[DZICUBE / NEOE: Master Data & Kế toán]
        NEW --> SSO[VINATECH_RESTFUL: Quản lý Token đăng nhập]
    end
```

### 📋 Checklist Kiểm Tra Cho Kỹ Sư Vận Hành Khi Chuyển Giao:
- [x] **Xác thực SSO:** Đảm bảo tài khoản công nhân (`VINA_EMP` / `DZICUBE.dbo.SEMP`) đăng nhập thông suốt qua `VINATECH_RESTFUL`.
- [x] **Ánh xạ Kiosk:** Đăng ký địa chỉ MAC của máy trạm Kiosk trong bảng `VINATECH_POP.dbo.VINA_PC_MAC`.
- [x] **Ràng buộc BOM Route:** Khai báo danh sách mã quét bắt buộc tại `VINATECH_POP.dbo.VINA_BOM_INPUT_ROUTE`.
- [x] **Thông số thiết bị Coater/PLC:** Thiết lập ngưỡng nhiệt độ và chu kỳ quét trong `VINATECH_POP.dbo.VINA_EQUIPMENT_SETTING`.
- [x] **Kiểm định chất lượng PQC:** Đảm bảo các tiêu chuẩn LSL/USL được nạp đúng vào bảng `TB_PQC_STANDARD`.
