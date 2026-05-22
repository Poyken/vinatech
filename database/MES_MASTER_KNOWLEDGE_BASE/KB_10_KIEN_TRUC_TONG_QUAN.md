# KB_10 — Kiến Trúc Tổng Quan (NAIS Framework)

> **Mục đích:** Hiểu bản chất thiết kế của hệ thống MES NAIS (Hàn Quốc) đang được sử dụng tại Vinatech.
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🏛️ Tổng Quan Kiến Trúc (The Three Pillars)

> **Câu hỏi cốt lõi:** Khi OP bấm nút "Save" trên màn hình B597 — chuyện gì xảy ra phía sau?

Hệ thống được xây dựng trên **3 Trụ cột chính**:

### Trụ cột 1 — Metadata (SmartFramework): *"UI chỉ là vỏ, não nằm trong DB"*
MES không fix cứng hành vi của từng nút bấm trong code phần mềm (C#/Java). Thay vào đó:
- Mỗi nút "Save" chỉ gọi 1 tên SP được cấu hình trong bảng `STB_ScreenObjects`.
- Muốn thay đổi hành vi → sửa trong DB, **không cần đóng gói lại phần mềm**.

```
OP bấm "Save" → NAIS Framework đọc STB_ScreenObjects → Gọi đúng SP → SP xử lý → Ghi DB
```

### Trụ cột 2 — Stored Procedures: *"Mọi hành động đều có dấu vết"*
Mọi thao tác của OP đều được ghi vào bảng lịch sử (`Hist`) thông qua SP. SP là nơi chứa toàn bộ:
- **Validation** (kiểm tra hợp lệ trước khi lưu).
- **Business logic** (tính toán, kiểm tra FIFO, kiểm tra hạn dùng).
- **Ghi dữ liệu** (INSERT/UPDATE vào DB).

### Trụ cột 3 — Recursive Logic: *"Tồn kho tự cập nhật, không cần triggers"*
> ⚠️ **Cảnh báo (Audit 2026-05-05):** Hệ thống hiện tại **KHÔNG sử dụng Triggers** để cập nhật tồn kho.
Thay vào đó, logic cập nhật tồn kho được thực hiện **trực tiếp** thông qua chuỗi gọi Stored Procedure:
`usp_DoProcessProdRouteHist` → `usp_DoProcessProdGIMaterialByBOM` → `usp_DoCreateMaterialDocLotInfo...`.

---

## 2. 💡 Kiến Trúc Vận Hành NAIS (NAIS Framework Architecture)

> **Nguyên lý cốt lõi:** NAIS (SmartFramework) là hệ thống **Metadata-Driven**. Giao diện (UI) không chứa logic, mọi hành động (Click, Search, Save) đều được cấu hình trong database metadata để gọi Stored Procedure.

### Phân vùng Database
Hệ thống Vinatech MES chia làm 2 cơ sở dữ liệu (DB) chính:
- **`SmartFactoryV2`**: Chứa toàn bộ dữ liệu nghiệp vụ (Sản lượng, Tồn kho, Lệnh sản xuất, BOM, Route).
- **`SmartFramework`**: Chứa Metadata hệ thống (Menu, User, Quyền hạn, Cấu hình giao diện, Template nhãn in `STB_LabelInfo`).

### Cách tìm Logic đằng sau bất kỳ màn hình nào
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

---

## 3. 🧬 Vòng Đời & Phả Hệ Dữ Liệu (Data Lifecycle & Genealogy)

> **Hình dung đơn giản:** Giống như một người đi qua nhiều trạm hải quan. Mỗi trạm đóng dấu (= ghi record). Truy vết = xem lại tất cả các dấu đã đóng trên hộ chiếu.

### Khái niệm cốt lõi:
1. **ControlNo / Barcode**: Chứng minh thư của 1 viên tụ điện. Sinh ra tại máy cuốn, theo suốt đến khi đóng thùng (`VVPR292R710617`).
2. **LotID**: Chứng minh thư của 1 kiện NVL trong kho. Prefix `ML...` = do kho cấp.
3. **PONo**: Số lệnh sản xuất. Gom nhiều Barcode vào 1 nhóm để sản xuất cùng 1 đợt.
4. **RouteCode**: Mã công đoạn. Từ `V-01` (đầu) đến `V-28` (đóng gói). Barcode phải đi đủ các bước theo thứ tự.
5. **ProductGroupCode**: Nhóm phân loại NVL. Dùng trong validation khi OP scan (`ELECTROLYTE`, `SLEEVE`, `CASE`).

### Truy Vết 360 Độ (Golden Query)
Câu lệnh sau truy vấn toàn bộ "lịch sử cuộc đời" của một viên tụ từ lúc sinh ra đến khi vào thùng:
```sql
SELECT 
    PRH.ControlNo AS [Mã vạch SP], 
    PRH.PONo AS [Lệnh SX], 
    RI.RouteName AS [Công đoạn],
    PRH.CreateDateTime AS [Giờ quét],
    DP.PackingID AS [Mã Thùng hàng],
    DP.ParentPackingID AS [Mã BigBox]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = '20260409000089' -- Thay mã vạch cần tra vào đây
ORDER BY PRH.CreateDateTime ASC
```

---

## 4. 🏢 Ma Trận Nhà Máy (The Factory Matrix - VNT vs VVT vs HN)

> **Nhất quán trong sự khác biệt:** MES Vinatech quản lý nhiều nhà máy với các quy tắc đặt tên và logic riêng biệt.

| Đặc điểm | VNT (Bắc Ninh — Electrode) | VVT (Bắc Giang — Cell/Module) | HN (Hà Nam — VVT_F3) |
|-----------|---------------------------|---------------------------|--------------------------|
| **Tiền tố Route** | `E-xx` (E-01, E-02...) | `V-xx` (V-01, V-22...), `MV-xx` (Module) | `VE-xx` (VE01, VE06...) |
| **Mã WorkCenter** | `VNT_F1` ~ `VNT_F5` | `VVT_F1`, `VVT_F2`, `VVT_F4` | `VVT_F3` |
| **Logic Đóng gói** | Standard Packing | Merge Box/Donggoi (VVT logic) | `Vietnam_Donggoi_HN` |
| **Quy tắc Barcode**| `VV...` prefix | `VV...` (Cell), `VJ...` (converted) | `VE...` (VE260507-001) |

---

## 5. 📘 Từ Điển Bảng Dữ Liệu (Table Dictionary)

*Đừng cố nhớ hết các bảng. Chỉ cần hiểu **nhóm bảng** đó phục vụ cho mục đích gì trên chuyền sản xuất.*

### Sơ đồ quan hệ giữa các nhóm bảng
```
            ┌──────────────────────────────────────────────────────────┐
            │                  MASTER DATA (Nhóm 1)                     │
            │   STB_BomHeader ←→ STB_BomDetail                         │
            │   STB_RouteInfo   STB_MaterialMaster                     │
            │   STB_ModelBasicInfo  STB_UserInfo  STB_LineInfo          │
            └──────────────────────┬────────────────────────────────────┘
                                   │ copy xuống
            ┌──────────────────────▼────────────────────────────────────┐
            │              KẾ HOẠCH & LỆNH SX (Nhóm 2)                  │
            │   STB_DayPlanInfo → STB_ProductionOrderInfo                │
            │   STB_ProductionOrderRouting (← RouteInfo)                 │
            │   STB_ProductionOrderBom (← BomDetail)                     │
            │   STB_SetInfo (ControlNo/Barcode)                          │
            │   STB_LineRouteMapping                                     │
            └────────┬───────────────────────────┬──────────────────────┘
                     │                           │
      ┌──────────────▼──────────┐   ┌────────────▼──────────────────────┐
      │  QUẢN LÝ VẬT TƯ (Nhóm 3) │   │  ROUTING & TRACKING (Nhóm 5)      │
      │  STB_MaterialLotInfo ◄──────│──── STB_ProdRouteHist               │
      │  STB_MaterialStock         │   │  (↑ mỗi scan barcode = 1 record)  │
      │  STB_MaterialDocInfo       │   │                                    │
      │  STB_MaterialDocDetail     │   │  Triggers:                         │
      │  STB_MaterialDocLotInfo    │   │   → GI: MaterialDocInfo/Detail     │
      │  STB_MaterialWarehouse...  │   │   → GR: MaterialDocInfo/Detail/Lot │
      │  STB_RawMaterialInputHist  │   └────────────────────────────────────┘
      └──────────────┬─────────────┘
```

---

## 6. 🛠️ TROUBLESHOOTING (Lỗi Hệ Thống & Kiến Trúc)

### 6.1 Lỗi không đăng nhập được MES
> 👉 Hướng dẫn chi tiết cách xử lý lỗi đăng nhập MES, vui lòng xem tại [KB_01_UI_PHAN_QUYEN.md § 1.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md).


*Cập nhật: 2026-05-22*
