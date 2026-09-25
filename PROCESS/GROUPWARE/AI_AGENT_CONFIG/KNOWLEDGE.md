# 🧠 GROUPWARE CHEAT SHEET (Ultra-Condensed Knowledge)

> **Mục tiêu:** Nạp ngữ cảnh siêu tốc (~300 tokens) cho Agent khi tác nghiệp trong workspace Groupware.  
> **Kim chỉ nam cốt lõi:** `GROUPWARE_KNOWLEDGE_BASE/GW_00_CORE_OPERATING_PRINCIPLES.md` (7 Quy tắc bất biến)

---

## ⚡ 1. Bản Đồ Nền Tảng & CSDL Cốt Lõi
- **Vị thế cốt lõi:** Groupware là Cổng Thẩm Quyền Thượng Nguồn (*"No Approved Document, No Physical Movement"*).
- **URL Groupware:** `https://gw.vinatech.com` (Bizbox Alpha by Douzone Bizon).
- **CSDL Chính:** `VINATECH_GROUP` trên `dbserver.hycap.co.kr,5398`.
- **CSDL Vệ tinh:** `VINATECH_RESTFUL` (SSO Token), `streamdocs` (PDF K-SOX), `VINATECH_SPREADSHEET` (JSON Sheet), `VINATECH_WEBSOCKET` (Realtime Push).
- **Hệ thống liên quan:** `NEOE_ERP` (ERP Douzone iU), `SmartFactoryV2` / `SmartFramework` (MES Sản xuất), `VINATECH_POP` (Kiosk Cảm Ứng Xưởng).

---

## 🏛️ 2. Ba Bảng CSDL Cốt Lõi Cần Nhớ
1. `VINA_DOCUMENT_SAVE`: Header chung mọi biểu mẫu (`DOCUMENT_SAVE_CODE`, `DOCUMENT_TYPE_ID`, `DOCUMENT_SAVE_STATE`, `NO_EMP_WRITER`).
2. `VINA_DOCUMENT_POH` / `POL`: Đơn mua hàng (`NO_PO`, `CD_PARTNER`, `DT_PO`, `CD_EXCH`, `CD_ITEM`, `QT_PO`, `UM_EX_PO`).
3. `VINA_EMP`: Danh bạ nhân viên (`NO_EMP`, `NM_KOR`, `NM_ENG`, `CD_DEPT`, `CD_DUTY_RANK`, `CD_INCOM`).

---

## 🔄 3. Năm Mã Trạng Thái Phê Duyệt (`DOCUMENT_SAVE_STATE`)
- `001`: **DRAFT** (Lưu nháp, chưa gửi).
- `002`: **APPROVING** (Đang trình duyệt qua các cấp).
- `008` / `090`: **APPROVED** (Phê duyệt hoàn tất ➔ kích hoạt 5 side-effects: ký PDF streamdocs, cấp mã ED-..., sync ERP NEOE, push WebSocket, lock data).
- `004`: **REJECTED** (Từ chối).
- `009`: **CANCELLED** (Hủy bỏ / Thu hồi).

---

## 🔗 4. Bản Đồ Khóa Liên Động (Interlocks: GW ↔ ERP ↔ MES ↔ POP)
- **GW Arrival Confirmation** `008` ➔ Mở màn hình **MES F330** (Nhập hàng & in tem barcode NVL).
- **MES C220 (IQC)** PASS ➔ Mở quyền tạo form **GW Receiving Confirmation** (Nhập kho tài chính).
- **BOM Version Lock (2001/2002)** ➔ Bắt buộc trên PO Kế hoạch sản xuất để **MES B310/B450** phát hành Lot và **POP Kiosk** nạp định mức cấp NVL.
- **GW Month Production Plan** `008` ➔ Kích hoạt màn hình **MES B310** (Giám sát PO) & **B450** (Tạo Lot) ➔ nạp vào **Kiosk POP**.
- **POP Dual-Buffer (RULE 20)** ➔ Chốt sản lượng Kiosk ghi `MongoToMesPerformance` (POP) ➔ Worker đồng bộ sang `STB_ProdRouteHist` (MES). Sửa máy nhầm phải update cả 2 bảng!
- **GW Shipment Request** `008` ➔ Mở màn hình **MES FG01** (Quét Box OQC PASS xuất kho thành phẩm).
- **GW Shipment Confirmation** `008` ➔ Mở màn hình **MES B750** (In tem Pallet) & **B752** (Container).

---

## ⚡ 5. Lệnh CLI Vận Hành Thường Dùng
- `.\gw.ps1 find "<Keyword>"`: Tra cứu nhanh L1 Cache & KB.
- `.\gw.ps1 trace "<DocCode/PONo>"`: Truy vết 360° xuyên GW-ERP-MES.
- `.\gw.ps1 form "<FormID>"`: Xem chi tiết cấu trúc & luồng của một biểu mẫu.
- `.\gw.ps1 check`: Kiểm tra kết nối CSDL Groupware & các hệ thống liên quan.
- `.\gw.ps1 health`: Báo cáo các văn bản đang tồn đọng hoặc kẹt duyệt.
