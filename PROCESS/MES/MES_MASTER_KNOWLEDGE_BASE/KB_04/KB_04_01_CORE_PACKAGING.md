
<!--
AI-READY METADATA
Purpose: Quy trình đóng gói core (B523, B525), PackingStandard schema, gộp/chia box, Z530/A460 Label Template Architecture & Debugging
Scope: Box Packaging & Label Printing Core Engine
Single Source of Truth: KB_04_01_CORE_PACKAGING.md (Packaging Core & Label Architecture)
Target Screens: B523, B525, B453, B560, B789, B781, B353, B442, A419, A460, B754-B758, B790, Z530, C531
Target Tables: STB_PackingStandard, STB_DividePackaging, STB_ModelLabelInfo, STB_SavePackingTime_VVT
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_04 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/INDEX.md)
  - [KB_04_02_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md)
  - [KB_04_03_SANMINA_LABEL_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_03_SANMINA_LABEL_GUIDE.md)
-->

# KB_04 — Đóng Gói & In Tem (Packaging & Label Printing)

> **Màn hình:** B523, B525, B453, B560, B789, B781, B353, B442, A419, A460, B754~B758, B790, Z530, C531
> **Bảng chính:** `STB_PackingStandard`, `STB_DividePackaging`, `STB_ModelLabelInfo`, `STB_SavePackingTime_VVT`
> **🔑 Keywords:** đóng gói, packing, in tem, label, gộp box, rã box, tiêu chuẩn, PackingID, BoxID, VJ, VV, Hela, PAC, DigiKey
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)


---

## 6. 📦 Đóng gói & In tem nhãn

> 🚦 **Tham chiếu mở rộng:** Cơ chế cổng chặn (Validation Gates) liên quan đến đóng gói B523 và in tem nhãn được tích hợp trực tiếp trong các Stored Procedure của hệ thống (ví dụ: `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`, `usp_Vietnam_DoProcessProdPacking_VVT`).
>
> 🏭 **Cơ sở gốc:** VVT_F1 (Bắc Ninh) | **Biến thể theo cơ sở:**
> - **Hà Nam (VVT_F3):** HN523 (đóng gói), HN542/HN543 (chia tem), HN544 (gộp túi bóng), HN553/HN711 (tem Solum)
> - **BG2 (VVT_F4):** K130 (tem Module), K160 (lịch sử tem), K198 (tem Bloom Energy SL-7), K199 (tem Nordex) → [KB_03 §6.14](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#614-nhà-máy-bg2--cấu-hình-triển-khai-hệ-thống-mes)
> - **Hưng Yên (VVT_F5):** D051, D100, D110 → [KB_07](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)

### 6.0 Tổng Quan Kiến Trúc In Tem Nhãn (Mô hình Giá sách ➔ Danh mục ➔ Người đọc)
Để dễ hình dung luồng xử lý in tem trong hệ thống NAIS MES, hãy tưởng tượng:
1. **Z530 (Label Info) — "Giá sách" (Thư viện mẫu):**
   * Là nơi cất giữ thiết kế mẫu tem (Design layout) dưới dạng XML trong bảng `SmartFramework.dbo.STB_LabelInfo.XmlLayout`.
   * Mẫu tem mới thiết kế xong chỉ nằm ở đây, chưa được chỉ định cho sản phẩm nào.
2. **A460 (STB_ModelLabelInfo) — "Cuốn danh mục" (Bản đồ Mapping):**
   * Chỉ định: *"Nếu sản xuất mã hàng (ModelCode) A, hãy dùng mẫu thiết kế B ở Z530"*.
   * Giúp tái sử dụng: 10 sản phẩm cùng khách hàng chỉ cần map vào 1 mẫu tem duy nhất ở Z530, không cần vẽ lại tem 10 lần.
3. **Màn hình in tem (B790, B523...) — "Người đọc":**
   * Khi quét mã Lot, hệ thống hỏi: *"Lot này thuộc Model nào?"* (ví dụ: `ECVT30-197`).
   * Hệ thống tra "Cuốn danh mục" (`STB_ModelLabelInfo`): *"Mã `ECVT30-197` dùng tem gì?"* ➔ Trả về `'Phoenix_Contact_V1'`.
   * Hệ thống ra "Giá sách" (`Z530`) tải XML thiết kế và bắn lệnh ra máy in.

---

### 6.0.1 Phân loại tem trong hệ thống

| Loại tem | Màn hình | Stored Procedure / Table | Ghi chú |
|----------|----------|--------------------------|---------|
| **AssembleLabel** (Tem Sản Xuất) | B450, B540 | Gọi qua A460 | Tem chính cho Cell/Module sau khi tạo Lot |
| **PartLabel** (Tem Vật Tư Kho) | F330 | Gọi qua A460 | Tem dán trên NVL nhập kho |
| **자재라벨** (Tem kho Hà Nam) | F721 | `STB_ModelLabelInfo` | Đặc biệt cho Hà Nam (chị Hoàng Xuân) |
| **Phoenix Contact** | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem 5x8cm, Datecode YYMMDD |
| **PAC Inner/Outer** | B754, B755, B756 | `usp_VN_PACBoxLabelPrintHist_iud` | SN riêng biệt cho Inner và Outer |
| **Digi-Key** | B757, B758 | `usp_VN_DigiKeyLabelInnerPrintHist_iud` | Nhãn SP + Nhãn Logistic |
| **Sanmina Label** | B767 | `usp_SanminaLabelPrint_get_Vietnam` | Mở NAIS Designer set `데이터 추가` = `False` chống lặp |

---

### 6.0.1b [B767] Sanmina & Tem Khách Hàng Đặc Biệt — Chi Tiết Cấu Hình & Debug

1. **[B767] Sanmina Label — Sửa Lỗi Lặp Dữ Liệu Grid (Search Lần 2):**
   - **Triệu chứng:** Người dùng mở màn hình B767 bấm Tìm kiếm lần 1 ra 3 dòng. Bấm Tìm kiếm lần 2 ra 6 dòng (bị nhân đôi dữ liệu).
   - **Nguyên nhân:** Thuộc tính `데이터 추가` (Append Data) của Search Function `usp_SanminaLabelPrint_get_Vietnam` trong NAIS Screen Designer đang để là `True`. Do số serial tự tăng (`BoxSerialNo`, `PrintSerialNo`) thay đổi sau mỗi lần thực thi, grid không đè được bản ghi cũ mà tự động nối tiếp (append).
   - **Cách fix:** Mở NAIS Screen Designer màn B767 ➔ Chọn Search Function `usp_SanminaLabelPrint_get_Vietnam` ➔ Tại bảng Property bên phải nhóm `Group` ➔ Chuyển `데이터 추가` từ `True` sang `False` ➔ Bấm Save và Approve layout.

2. **[B754]/[B756] Tem PAC (Inner/Outer Box):**
   - Tem Inner và Outer tính Serial Number riêng biệt. Khi in Outer Box tại B756, công nhân **bắt buộc tick chọn `IsOuter = 1`** trên UI để SP `usp_PACLabelCartonWeight_get_Vietnam` gọi đúng dải serial cho thùng carton lớn.

---

---

### 6.0.2 Tìm mẫu tem đang dùng cho 1 Barcode/LotNo
```sql
SELECT
    SI.Barcode,
    SI.MaterialCode,
    LI.FormatName AS [Ten_Mau_Tem],
    LI.IsApproval,
    LI.ApplyDate
FROM STB_SetInfo SI WITH(NOLOCK)
JOIN STB_MaterialMaster MM WITH(NOLOCK) ON SI.MaterialCode = MM.MaterialCode
LEFT JOIN SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
    ON LI.FormatName LIKE '%' + RIGHT(MM.MaterialCode, 5) + '%'
    AND LI.IsApproval = 1
WHERE SI.Barcode = 'VVQL033R07279S'
```

---

### 6.0.3 Hướng dẫn Trace Debug In Tem (UI + SQL)

Khi gặp lỗi in tem ở **bất kỳ màn hình nào** (B442, B450, B523, B790...), trace theo 2 hướng song song:

#### A. Trace trên UI (NAIS client)

```
Bước 1: Mở Object Explorer
   → Bấm F5 (hoặc Menu → Object(F5))
   → Thấy cây đối tượng: Search Function, Execute Function, Layout, View, Popup, Action...

Bước 2: Tìm action in tem
   → Mở nhánh "Action" → tìm action có Caption = "LabelPrint" hoặc "^LabelPrint^"

Bước 3: Xem Property
   → Chọn action LabelPrint → bấm F4 (Property)
   → Đọc:
      • ActionType = "PrintLabel"      ← xác nhận đây là action in tem
      • Name = "LabelPrint"

Bước 4: Mở Print Label options (quan trọng nhất!)
   → Cuộn xuống phần Options → tìm "라벨인쇄" (Print Label options) → bấm mở
   → Đọc các config:
      • 라벨유형 필드 (Label Type Field)    = tên CỘT chứa LabelType (VD: "LabelType")
      • 참조뷰 이름 (Reference View Name)   = grid/view nào cung cấp data (VD: "SetInfo")
      • 포맷형 필드 (Format Name Field)     = cột chứa FormatName (VD: "FormatName")
      • 참조본 범위 (Reference Scope)       = "SelectedRows" (in dòng đang chọn)
      • 프린터명 (Printer Name)             = tên máy in
```

> **Từ bước 4** ta biết:
> - Data in tem lấy từ grid nào (VD: `SetInfo`)
> - Cột nào quyết định loại tem (VD: `LabelType`)
> - Cột nào quyết định template (VD: `FormatName`)

#### B. Trace trong SQL (SP chain)

Khi biết grid `SetInfo` cung cấp data → tìm SP Search Function tương ứng (VD: `usp_SetInfo_get`).

**Chuỗi JOIN 3 bảng quyết định in tem** (đã xác nhận trong `usp_SetInfo_get`):

```sql
-- Bảng 1: STB_MaterialMaster → NỘI DUNG trên tem (MaterialName)
LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK)
    ON MM.MaterialCode = SI.MaterialCode
-- → MM.MaterialName = text hiển thị trên tem (VD: "Coating-Roll Forming-YP 85 120 (A301)...")
-- → Sửa MaterialName tại A230 = sửa nội dung trên tem

-- Bảng 2: STB_ModelLabelInfo → MAPPING model dùng template nào (A460)
LEFT JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)
    ON MLI.ModelCode = SI.MaterialCode
    AND MLI.LabelType = @LabelType
-- → MLI.FormatName = tên template (VD: "전극라벨")
-- → NẾU THIẾU RECORD → lỗi "Not found label type" ❌

-- Bảng 3: STB_LabelInfo → TEMPLATE thiết kế tem (Z530)
LEFT JOIN LabelInfo LBI    -- CTE từ SmartFramework.dbo.STB_LabelInfo
    ON LBI.LabelType = @LabelType
    AND LBI.FormatName = MLI.FormatName    -- Nối với kết quả bảng 2
    AND LBI.RankIndex = 1                  -- Lấy version mới nhất
-- → LBI.Format = XML layout (thiết kế tem)
```

#### C. Sơ đồ flow tổng thể

```
┌─────────────────────── UI TRACE ───────────────────────┐
│                                                         │
│  F5 (Object) → Action → LabelPrint                     │
│       ↓                                                 │
│  F4 (Property) → ActionType = PrintLabel                │
│       ↓                                                 │
│  Options → Print Label options                          │
│       ├── 참조뷰 이름 = SetInfo       ← grid nào?       │
│       ├── 라벨유형 필드 = LabelType   ← cột nào?        │
│       └── 포맷형 필드 = FormatName   ← template nào?    │
│                                                         │
└──────────────────────────┬──────────────────────────────┘
                           ↓
┌─────────────────────── SQL TRACE ──────────────────────┐
│                                                         │
│  usp_SetInfo_get (@pLabelType = 'ElectLabel')           │
│       │                                                 │
│  ┌────┼── STB_MaterialMaster MM                         │
│  │    │      ON MM.MaterialCode = SI.MaterialCode       │
│  │    │      → MM.MaterialName = NỘI DUNG trên tem     │
│  │    │                                                 │
│  │  ┌─┼── STB_ModelLabelInfo MLI (A460)                 │
│  │  │ │      ON MLI.ModelCode = SI.MaterialCode         │
│  │  │ │      AND MLI.LabelType = @LabelType             │
│  │  │ │      → Thiếu record = "Not found label type" ❌ │
│  │  │ │                                                 │
│  │  │ └── STB_LabelInfo LBI (Z530)                      │
│  │  │        ON LBI.FormatName = MLI.FormatName         │
│  │  │        → XML template = THIẾT KẾ mẫu tem         │
│  │  │                                                   │
│  └──┴───────────────────────────────────────────────────│
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### D. Checklist debug nhanh khi lỗi in tem

| # | Kiểm tra | Query | Lỗi nếu thiếu |
|---|----------|-------|----------------|
| 1 | Model có mapping label? | `SELECT * FROM STB_ModelLabelInfo WITH(NOLOCK) WHERE ModelCode = 'MÃ'` | "Not found label type" |
| 2 | Label template tồn tại? | `SELECT * FROM SmartFramework.dbo.STB_LabelInfo WITH(NOLOCK) WHERE LabelType = 'ElectLabel' AND IsApproval = 1` | In trắng / không ra tem |
| 3 | MaterialName đúng chưa? | `SELECT MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK) WHERE MaterialCode = 'MÃ'` | Tem in sai nội dung |
| 4 | Hardcode exception? | Kiểm tra CASE WHEN trong SP (VD: `usp_SetInfo_get` override MaterialName cho ControlNo cụ thể) | Tem in tên khác master |

> [!TIP]
> **Stack trace chứa `Awoo.SmartFramework.WinForm.Controls.ScreenControl.PrintLabel`** → 100% lỗi ở bước 1 (thiếu `STB_ModelLabelInfo`).
> **Tem in ra nhưng sai nội dung** → lỗi ở bước 3 (MaterialName sai) hoặc bước 4 (hardcode override).


---

> [!NOTE]
> **Khắc phục sự cố & Lỗi thường gặp (B351, B523, B525, B789, HN523, HN544, etc.):**
> Toàn bộ danh sách lỗi chi tiết, nguyên nhân gốc, các kịch bản sự cố khẩn cấp và SQL hotfixes đã được chuyển sang tài liệu chuyên biệt:
> 👉 [KB_04_02_SCREEN_BUGS.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md) để tránh trùng lặp thông tin và dễ dàng tra cứu.

---
*Cập nhật: 2026-07-10 — Loại bỏ trùng lặp nội dung lỗi, tách biệt Core Process vs Screen Bugs.*


