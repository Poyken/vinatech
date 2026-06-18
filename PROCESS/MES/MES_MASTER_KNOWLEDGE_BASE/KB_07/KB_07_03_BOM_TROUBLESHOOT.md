
### 12.1 Cấu trúc BOM trong DB
*   `STB_BomHeader` (Header — 1 BOM cho 1 Model): Lưu `BomHeaderNo` (PK), `MaterialCode` (Mã Model), `BomVersion`, `Status`.
*   `STB_BomDetail` (Detail — N NVL con cho 1 BOM): Lưu `ChildMaterialCode` (Mã NVL con), `Qty` (Định mức tiêu thụ), `Unit`, `RouteCode` (Công đoạn sử dụng NVL).

### 12.2 BOM Version đang dùng
*   `2001`: BOM Cell line cũ (Việt Nam).
*   `2002`: BOM Cell line mới đang active (Dùng chính cho Việt Nam).
*   `1`: BOM Electrode (Điện cực).

---

## 13. Danh Sách Kho Đầy Đủ (Verified 2026-06-10)

Bảng đối chiếu 100% mã kho sử dụng trên ERP và MES tại các nhà máy Vinatech Việt Nam:

| Mã Kho (Warehouse Code) | Công ty | Nhà máy | Tên Kho Tiếng Hàn | Tên Kho Tiếng Việt | Ghi Chú / Ý Nghĩa Vận Hành |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ROH_VN_WH** | VVT | VVT_F1 | 원자재창고(베트남) | Kho nguyên vật liệu Bắc Giang *(⚠️ Typo dịch)* | **Kho NVL chính nhà máy F1 (Bắc Ninh)** |
| **ROH_BG_WH** | VVT | VVT_F2 | Bg_원자재창고(베트남) | Kho nguyên vật liệu Bắc Ninh *(⚠️ Typo dịch)* | **Kho NVL chính nhà máy F2 (Bắc Giang)** |
| **HOLDING_VN_WH** | VVT | VVT_F1 | Hold원자재창고(베트남) | Kho nguyên vật liệu chờ xử lý Bắc Ninh | Kho tạm giữ kiểm tra IQC (F1 - Bắc Ninh) |
| **HOLDING_BG_WH** | VVT | VVT_F2 | Bg_Hold원자재창고(베트남) | Kho nguyên vật liệu chờ xử lý Bắc Giang | Kho tạm giữ kiểm tra IQC (F2 - Bắc Giang) |
| **MODULE_VN_WH** | VVT | VVT_F1 | 모듈(베트남) | Kho nguyên liệu cho hàng module Bắc Ninh | Kho cấp vật tư cho chuyền sản xuất Module F1 |
| **MODULE_BG_WH** | VVT | VVT_F2 | Bg_모듈(베트남) | Kho nguyên liệu cho hàng module Bắc Giang | Kho cấp vật tư cho chuyền sản xuất Module F2 |
| **ROUTE_VN_WH** | VVT | VVT_F1 | 공정창고(베트남) | Sản xuất Bắc Ninh | Kho ảo trên chuyền sản xuất F1 (Bắc Ninh) |
| **ROUTE_BG_WH** | VVT | VVT_F2 | Bg_공정창고(베트남) | Sản xuất Bắc Giang | Kho ảo trên chuyền sản xuất F2 (Bắc Giang) |
| **PROD_VN_WH** | VVT | VVT_F1 | 완제품창고(베트남) | Kho thành phẩm Bắc Ninh | Kho lưu trữ thành phẩm chính F1 (Bắc Ninh) |
| **PROD_BG_WH** | VVT | VVT_F2 | Bg_완제품창고(베트남) | Kho thành phẩm Bắc Giang | Kho lưu trữ thành phẩm chính F2 (Bắc Giang) |
| **W27** | VVT | VVT_F3 | 창고(비나에너솔) | Kho (Vina Enersol) | Kho nhà máy F3 (Vina Enersol Hà Nam) |

> [!WARNING]
> **LƯU Ý LỖI DỊCH THUẬT KHI LÀM FORM:**
> Cột tên tiếng Việt bị đảo ngược nhầm lẫn giữa Bắc Ninh và Bắc Giang ở hai kho chính: `ROH_VN_WH` ghi nhầm thành Bắc Giang, còn `ROH_BG_WH` ghi nhầm thành Bắc Ninh. Khi thao tác cấu hình hoặc chọn kho trên các form Groupware (`purchaseOrderDocument`, `receivingConfirmationDocument`), người dùng bắt buộc phải tuân theo ký hiệu chuẩn: **`VN` = Nhà máy Bắc Ninh (F1)** và **`BG` = Nhà máy Bắc Giang (F2)** bất kể cột hiển thị tiếng Việt bị dịch sai.

---

## 14. 🛠️ Cẩm Nang Hỗ Trợ Kỹ Thuật (Troubleshooting Guide)

### 14.1 Sự cố Đăng nhập MES
1.  **Lỗi: "Not found user" hoặc "Invalid Password"**
    *   *User Việt Nam:* Check tài khoản đã khởi tạo trong màn hình **Z410** chưa.
    *   *User Hàn Quốc:* Check cột `Appendix8` trong `STB_UserInfo` đã trỏ đúng ID_USER của ERP chưa.
2.  **Lỗi: "You are not allowed"**
    *   Kiểm tra AllowFlag của tài khoản trong `STB_UserInfo`. Chạy SQL sửa đổi:
        ```sql
        UPDATE SmartFramework.dbo.STB_UserInfo SET AllowFlag = 'Allow' WHERE UserID = 'Mã_Nhân_Viên'
        ```

### 14.2 Sự cố Đồng bộ Kế hoạch/Sản lượng
1.  **PO tháng không xuất hiện trên MES B310:**
    *   Kiểm tra xem trên Groupware đã nhấn nút **"Xác nhận lô hàng"** chưa (trạng thái phải chuyển sang "Sản xuất").
    *   Kiểm tra BOM Version đã chọn đúng **2001** (hoặc **2002**) chưa.
2.  **Sản lượng sản xuất không hiển thị trên ERP:**
    *   Kiểm tra xem các bản ghi trong `ESM_ProdRouteHist` có bị treo ở trạng thái `'N'` không:
        ```sql
        SELECT Count(*) FROM ESM_ProdRouteHist WITH(NOLOCK) WHERE ErpUpdate = 'N' OR ErpUpdate IS NULL
        ```
    *   Nếu số lượng lớn và không thay đổi trong thời gian dài -> Kiểm tra xem Windows Service **ESM Collector** trên server có bị dừng (Stopped) hay không.

### 14.3 Sự cố IQC (C220) & Nhập kho (Receiving)
*   Nếu không tìm thấy Lot hàng trên form **Receiving Confirmation** của Groupware, check xem QC đã làm IQC chưa hoặc IQC có bị Reject không.
    *   Truy vấn kiểm tra trạng thái QC:
        ```sql
        SELECT MaterialDocNo, MaterialLotNo, QcResult 
        FROM STB_MaterialQcInfo WITH(NOLOCK) 
        WHERE MaterialDocNo = 'Số_Chứng_Từ_Hàng_Về'
        ```
        Nếu `QcResult` khác `'PASS'`, hệ thống sẽ chặn không cho phép lập form nhập kho chính thức.

---

## Appendix — VINATECH_GROUP Database Structure (DB Verified 2026-06-18)

> **Tổng: 382 tables** (VINA_* prefix) — Database cho Groupware (gw.vinatech.com)

### Top 10 Tables by Row Count

| # | Table | Rows | Mô tả |
|---|---|---|---|
| 1 | `VINA_DOCUMENT_APPROVAL_SAVE` | **816K** | **★ Lịch sử phê duyệt tờ trình** |
| 2 | `VINA_DOCUMENT_APPROVAL_SAVE_LIST_VIEW` | 815K | View tổng hợp phê duyệt |
| 3 | `VINA_RELIABILITY_DATA` | 327K | Dữ liệu độ tin cậy sản phẩm |
| 4 | `VINA_RECORD_INCREASE` | 305K | Tracking tăng trưởng record |
| 5 | `VINA_GOOGLE_ECM_SYNC_ERROR_LOG` | 196K | Log đồng bộ ECM ↔ Google |
| 6 | `VINA_ATTACHED_FILE` | 136K | Tệp đính kèm |
| 7 | `VINA_DOCUMENT_SAVE` | 135K | **Bản lưu tờ trình** |
| 8 | `VINA_DOCUMENT_COST_DETAIL` | 96K | Chi phí chi tiết |
| 9 | `VINA_DAILY_ATTENDANCE` | 82K | Chấm công hàng ngày |
| 10 | `VINA_DOCUMENT_ECM_EXPORT` | 78K | Export ECM |

### Document Categories (VINA_DOCUMENT_*)

| Nhóm | Tables | Mô tả |
|---|---|---|
| **Approval Flow** | `_APPROVAL_SAVE`, `_APPROVAL_SETTING`, `_APPROVAL_SHEET` | Quy trình phê duyệt |
| **Purchase** | `_PURCHASE_REQUEST`, `_PURCHASE_ORDER_CHANGE/CANCEL` | Mua hàng + thay đổi |
| **Cost** | `_COST`, `_COST_DETAIL`, `_COST_DOCU`, `_COST_CARD_BAN` | Quản lý chi phí |
| **Production** | `_DAILY_PRODUCTION_ORDER`, `_DAILY_PRODUCTION_REPORT` | **★ Lệnh SX & Báo cáo** |
| **Material** | `_ARRIVAL_CONFIRMATION`, `_ARRIVAL_CONFIRMATION_LOT` | Xác nhận hàng về |
| **BOM** | `_BOM` | BOM từ Groupware |
| **Quality** | `_QUALITY_RELIABILITY` | Dữ liệu chất lượng |
| **HR** | `_ATTENDANCE_MODIFY`, `_BUSINESSTRIP` | Chấm công, Công tác |

### Verified ERP Integration Tables (Liên kết KB_07)

| MES Table/SP | → | Groupware Table | Luồng |
|---|---|---|---|
| `NEOE.MA_USER` / `MA_EMP` | ← | `VINA_DOCUMENT_APPROVAL_SAVE` | User auth → approve |
| `SmartFactoryV2.STB_ProductionOrderInfo` | ← | `VINA_DOCUMENT_DAILY_PRODUCTION_ORDER` | Lệnh SX từ GW → MES |
| `ERPSVR.ERPDB.DBO.*` | ← | `VINA_DOCUMENT_COST` | Chi phí MES → ERP |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: VINATECH_GROUP DB Structure (382 tables) + Top 10 by rows + Document categories + ERP Integration. DB verified.*
