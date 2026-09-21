# 🧠 GROUPWARE CHEAT SHEET (Ultra-Condensed Knowledge)

> **Mục tiêu:** Nạp ngữ cảnh siêu tốc (~300 tokens) cho Agent khi tác nghiệp trong workspace Groupware.

---

## ⚡ 1. Bản Đồ Nền Tảng & CSDL Cốt Lõi
- **URL Groupware:** `https://gw.vinatech.com` (Bizbox Alpha by Douzone Bizon).
- **CSDL Chính:** `VINATECH_GROUP` trên `dbserver.hycap.co.kr,5398`.
- **CSDL Liên quan:** `NEOE_ERP` (ERP Douzone iU), `SmartFactoryV2` (MES Sản xuất), `VINATECH_RESTFUL` (SSO Token), `DZICUBE` (Kế toán Bizbox).

---

## 🏛️ 2. Ba Bảng CSDL Cốt Lõi Cần Nhớ
1. `VINA_DOCUMENT_SAVE`: Header chung mọi biểu mẫu (`DOCUMENT_SAVE_CODE`, `DOCUMENT_TYPE_ID`, `DOCUMENT_SAVE_STATE`, `NO_EMP_WRITER`).
2. `VINA_DOCUMENT_POH` / `POL`: Đơn mua hàng (`NO_PO`, `CD_PARTNER`, `DT_PO`, `CD_EXCH`, `CD_ITEM`, `QT_PO`, `UM_EX_PO`).
3. `VINA_EMP`: Danh bạ nhân viên (`NO_EMP`, `NM_KOR`, `NM_ENG`, `CD_DEPT`, `CD_DUTY_RANK`, `CD_INCOM`).

---

## 🔄 3. Năm Mã Trạng Thái Phê Duyệt (`DOCUMENT_SAVE_STATE`)
- `001`: **DRAFT** (Lưu nháp, chưa gửi).
- `002`: **APPROVING** (Đang trình duyệt qua các cấp).
- `008` / `090`: **APPROVED** (Phê duyệt hoàn tất ➔ kích hoạt sync ERP).
- `004`: **REJECTED** (Từ chối).
- `009`: **CANCELLED** (Hủy bỏ / Thu hồi).

---

## 🔗 4. Bản Đồ Tương Tác Biểu Mẫu GW ➔ Màn Hình MES
- **GW Arrival Confirmation** ➔ Mở màn hình **MES F330** (Nhập hàng & in tem barcode NVL).
- **MES C220 (IQC)** PASS ➔ Mở quyền tạo form **GW Receiving Confirmation** (Nhập kho chính thức).
- **GW Month Production Plan** ➔ Mở màn hình **MES B310** (Giám sát PO) & **B450** (Phát hành Lot).
- **GW Shipment Request** ➔ Mở màn hình **MES FG01** (Quét Packing ID xuất kho thành phẩm).
- **GW Shipment Confirmation** ➔ Mở màn hình **MES B750** (In tem Pallet niêm phong).

---

## ⚡ 5. Lệnh CLI Vận Hành Thường Dùng
- `.\gw.ps1 find "<Keyword>"`: Tra cứu nhanh L1 Cache & KB.
- `.\gw.ps1 trace "<DocCode/PONo>"`: Truy vết 360° xuyên GW-ERP-MES.
- `.\gw.ps1 form "<FormID>"`: Xem chi tiết cấu trúc & luồng của một biểu mẫu.
- `.\gw.ps1 check`: Kiểm tra kết nối CSDL Groupware & các hệ thống liên quan.
- `.\gw.ps1 health`: Báo cáo các văn bản đang tồn đọng hoặc kẹt duyệt.
