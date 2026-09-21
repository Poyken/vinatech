# 🌐 BẢN ĐỒ TÍCH HỢP TOÀN HỆ THỐNG VINATECH (GW ↔ ERP ↔ MES ↔ POP)

> **Cập nhật:** 2026-09-21 | **Phạm vi:** Toàn bộ hệ sinh thái phần mềm điều hành & sản xuất Vinatech

---

## 🧭 1. Bản Đồ Tổng Quan 3 Trụ Cột Doanh Nghiệp

```mermaid
graph TD
    subgraph "TRỤ CỘT 1: THƯỢNG NGUỒN — GROUPWARE (https://gw.vinatech.com)"
        GW_PO["Mua Hàng & NVL\n(VINA_DOCUMENT_POH/POL)"]
        GW_EA["Phê Duyệt 17 Biểu Mẫu\n(VINA_DOCUMENT_SAVE)"]
        GW_PLAN["Kế Hoạch SX Tháng\n(VINA_PROD_MONTH_PRODPLAN)"]
        GW_SO["Đơn Bán Hàng Suju\n(VINA_SALES_SELLPLAN)"]
        GW_SSO["Xác Thực Tập Trung\n(VINATECH_RESTFUL)"]
    end

    subgraph "TRỤ CỘT 2: TRUNG NGUỒN — ERP DOUZONE iU (NEOE)"
        ERP_FIN["Sổ Cái Tài Chính & Kế Toán\n(FI_DOCU)"]
        ERP_PO["Đơn Mua Hàng & B/L\n(PU_PO, PU_BL, PU_RCV)"]
        ERP_BOM["Master Data & BOM 2001\n(MA_PITEM, PR_BOM)"]
        ERP_SO["Đơn Bán Hàng & Doanh Thu\n(SA_SO, SA_IV)"]
    end

    subgraph "TRỤ CỘT 3: HẠ NGUỒN — NAIS MES (SmartFactoryV2) & POP (VINATECH_POP)"
        MES_WMS["Kho Hiện Trường: Nhập F330, Xuất FG01, Tem B750"]
        MES_QC["Kiểm Định Chất Lượng: IQC C220, PQC, OQC C512"]
        MES_PROD["Thực Thi Sản Xuất: Lệnh B310, Lot B450, Chuyền B530/B540"]
        POP_KIOSK["Kiosk Cảm Ứng Xưởng: Bắn Barcode, Chốt Mẻ, Báo Phế"]
    end

    GW_PO -->|Auto-sync PO khi State = 008| ERP_PO
    GW_PLAN -->|Auto-sync Lệnh sản xuất| ERP_BOM
    GW_SO -->|Auto-sync Suju| ERP_SO
    GW_EA -->|Duyệt thanh toán & chi phí| ERP_FIN

    ERP_PO -->|Lệnh nhập kho| MES_WMS
    ERP_BOM -->|Cung cấp định mức BOM| MES_PROD

    GW_PO -.->|Khai báo Arrival kích hoạt| MES_WMS
    MES_QC -.->|Kết quả IQC C220 PASS kích hoạt Receiving| GW_PO
    MES_WMS -.->|Quét Barcode trừ tồn thực tế| ERP_SO
    MES_PROD <-->|Sync Realtime MongoToMes| POP_KIOSK
```

---

## 🗄️ 2. Ma Trận Bảng Dữ Liệu Thực Tế Giữa Các CSDL (Live DB Verified)

| Nghiệp Vụ | CSDL Groupware (`VINATECH_GROUP`) | CSDL ERP (`NEOE`) | CSDL MES (`SmartFactoryV2` / `SmartFramework`) | CSDL Hỗ Trợ Khác |
| :--- | :--- | :--- | :--- | :--- |
| **Đơn Mua Hàng** | `VINA_DOCUMENT_POH`, `POL` | `NEOE.PU_POH`, `PU_POL` | `dbo.STB_ProductionOrderInfo` | - |
| **Hàng Về / Khai Báo** | `VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H/L` | `NEOE.PU_BL` (Hải quan / B/L) | Màn hình `F330` (`materialDocNo`) | - |
| **Kiểm Định IQC** | Kiểm tra cờ QC PASS trước khi lập Receiving | - | `dbo.STB_MaterialQcInfo` (`QcResult = 'PASS'`) | - |
| **Nhập Kho Chính Thức** | `VINA_DOCUMENT_RECEIVING_CONFIRMATION_H/L` | `NEOE.PU_RCVH`, `PU_RCVL` | `dbo.STB_MaterialLotInfo` | - |
| **Quyết Toán Mua Hàng** | `VINA_DOCUMENT_PURCHASE_RESOLUTION` | `NEOE.FI_DOCU`, `FI_DOCU_D` (Khớp `ED-...`) | - | `VINA_DOCUMENT_ERP_DOCU_INFO_VIEW` |
| **Kế Hoạch Tháng** | `VINA_PROD_MONTH_PRODPLAN` | `NEOE.PR_WO` | `dbo.STB_DayProdPlan` (Màn hình `B310`) | - |
| **Lot Sản Xuất** | `dailyProductionOrderDocument` | `NEOE.PR_BOM` (Version 2001) | `dbo.STB_DayProdPlan`, `dbo.STB_ProdRouteHist` (`B450`) | `VINATECH_POP` |
| **Bán Hàng & Suju** | `VINA_SALES_SELLPLAN` | `NEOE.SA_SOH`, `SA_SOL` | - | - |
| **Đề Nghị Xuất Kho** | `VINA_SALES_PROD_HAND` | `NEOE.SA_GIRH`, `SA_GIRL` | Màn hình `FG01` (Quét Box PASS OQC) | - |
| **Xuất Kho & Tem Pallet** | `VINA_TRADE_ALL_INVOICE`, `VINA_DOCUMENT_TR_INV` | `NEOE.SA_IVH`, `SA_IVL` | Màn hình `B750` (Tem Pallet), `B752` (Container) | - |
| **Hồ Sơ Nhân Sự** | `VINA_EMP`, `VINA_ORG_CHART_NODE` | `NEOE.MA_USER`, `NEOE.MA_EMP` (Trigger `UT_MA_EMP_BIZBOX_GW`) | `SmartFramework.dbo.STB_UserInfo` (`Appendix8`) | `SmartFactoryV2.dbo.STB_VN_Employees` |
| **Chấm Công & Giờ Làm** | `VINA_DOCUMENT_LEAVE_REQUEST`, `leaveDocument` | `NEOE.HR_WTM_*` (Thủ tục `UP_HR_WTMCALC_TIME_CALC`) | `dbo.STB_VN_ATTENDANCE_TIME` (Job `SyncFingerData`) | `Stb_fingerUserInfo` |
| **Xác Thực Đăng Nhập** | SSO Token Gateway | Xác thực mật khẩu ERP (`ERPiUVerify` cho HQ) | `SmartFramework.dbo.usp_DoGUILogin` | `VINATECH_RESTFUL.dbo.VINA_SSO_TOKEN` |
| **Xem Tài Liệu PDF** | E-Approval Web Viewer | - | - | `streamdocs.dbo.pdf_resource` |
| **Bảng Tính Trực Tuyến** | Web Spreadsheet | - | - | `VINATECH_SPREADSHEET.dbo.VINA_SPREAD_SHEET_JSON` |
| **Chuông Báo Thời Gian Thực**| Realtime Push Notification | - | Đổi màu TV Andon khi máy dừng | `VINATECH_WEBSOCKET.dbo.VINA_MODULE` |

---

## ⚡ 3. Các Điểm Nghẽn Tích Hợp Thường Gặp & Cách Khắc Phục

1. **GW ➔ ERP PO Synchronization Failure:**
   - Khi PO duyệt `008` trên GW nhưng không sang ERP: Thường do mã nhà cung cấp `CD_PARTNER` hoặc mã vật tư `CD_ITEM` chưa được mở trên ERP `NEOE`.
2. **GW ➔ MES Arrival Failure:**
   - Khi đã làm Arrival trên GW nhưng MES `F330` không hiện: Kiểm tra phiếu Arrival đã sang trạng thái `008` chưa và mã kho nhận `CD_SL` có khớp phân quyền thủ kho không.
3. **MES ➔ GW IQC Gatekeeper:**
   - Khi QC đã kiểm tra xong nhưng GW không cho làm Receiving: Đảm bảo kỹ thuật viên QC đã nhấn nút **Confirm PASS** trên màn hình `C220` để cập nhật cột `QcResult = 'PASS'` trong bảng `STB_MaterialQcInfo`.
4. **BOM Version Lock (Chốt chặn phiên bản BOM 2001/2002):**
   - Khi tạo PO sản xuất tháng hoặc kế hoạch ngày, bắt buộc phiên bản BOM phải là **2001** (cho toàn bộ sản phẩm Việt Nam) hoặc **2002** (cho Cell line mới). Bất kỳ BOM version nào khác đều bị MES `B310`/`B450` từ chối nhận lệnh và không cho tạo Lot.
5. **Đồng Bộ Nhân Sự & Tổ Chức (Trigger `UT_MA_EMP_BIZBOX_GW`):**
   - Khi chuyển phòng ban cho nhân viên trong ERP `MA_EMP`, Trigger sẽ tự ghi vào `USER_MAPPING_INFO`. IT cần kiểm tra thêm bảng `SmartFactoryV2.dbo.STB_VN_Employees` (cột `CODEDEPARTMENT`) để MES không bị lệch thông tin phòng ban với Groupware.
6. **Truy Vết Chứng Từ ERP Qua Chuỗi `(ED-...)`:**
   - Khi một tờ trình Groupware được duyệt, mã hồ sơ `RECORD_INCREASE_CODE` (ví dụ `ED-VJPMTR000000021`) được chèn vào trường `NM_PUMM` của chứng từ kế toán `NEOE.NEOE.FI_DOCU`. Dùng View `VINA_DOCUMENT_ERP_DOCU_INFO_VIEW` để tra cứu hai chiều tức thì.
