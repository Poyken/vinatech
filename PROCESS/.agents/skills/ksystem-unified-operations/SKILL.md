---
name: ksystem-unified-operations
description: Kỹ năng điều phối, tra cứu và liên thông dữ liệu YoungLimWon K-System Ace Web ERP Suite (evn.vinatech.com, DB VINATECVN / VINATECVNCommon, CompanySeq=1, FrmWPDLotList, _TPRProdResult, _TACSlip).
---

# 🏢 YoungLimWon K-System Ace ERP Operations Skill

Kỹ năng này hướng dẫn toàn bộ quy trình tra cứu, truy vết và đối soát dữ liệu trên hệ thống ERP K-System Ace của Vinatech Việt Nam.

---

## 1. Bản Chất Hệ Thống K-System Ace
- **Nền tảng:** Web ERP Suite (`https://evn.vinatech.com/`)
- **Pháp nhân cốt lõi:** `비나텍(베트남법인)` — Công ty TNHH Vinatech Vina (`CompanySeq = 1`)
- **CSDL:**
  * `VINATECVN`: CSDL nghiệp vụ chính (hơn 5.500 bảng: sản xuất, kho, mua bán, kế toán).
  * `VINATECVNCommon`: CSDL metadata, phân quyền, từ điển chương trình (`_TDAProgram`).
- **Single Source of Truth:** `FINAL/ARCHITECTURE/` (4 Volumes Kiến Trúc Vận Hành Thâm Sâu)
- **CLI Hub:** `.\ksys.ps1` hoặc gọi qua `ops trace`

---

## 2. Các Quy Tắc Bất Biến Khi Làm Việc Với K-System:
1. **Khóa Pháp Nhân `CompanySeq = 1`:** Mọi bảng giao dịch đều phải lọc theo `CompanySeq = 1` để tránh nhầm sang dữ liệu Vinatech Hàn Quốc (`CompanySeq = 2`).
2. **Khóa Chống Nghẽn `WITH(NOLOCK)`:** Mọi câu SELECT trên CSDL `VINATECVN` bắt buộc phải có `WITH(NOLOCK)`.
3. **Giới Hạn `TOP 50`:** Bảng giao dịch K-System rất lớn (`_TACSlip`, `_TPRProdResult`), luôn giới hạn số dòng.
4. **Không Thử Sai Bằng SELECT:** Tra cứu bảng và module qua L1 Cache `KSYSTEM_MATRIX.json` trước.

---

## 3. Các Lệnh Vận Hành Thường Dùng:

### Tra cứu phân hệ & quy trình L1 Cache:
```powershell
ksys find "<Keyword>"
```
Ví dụ: `ksys find "Lot"`, `ksys find "ProdResult"`, `ksys find "Slip"`

### Truy vết LOT & Lệnh sản xuất 360°:
```powershell
ksys trace "<LotNo_hoặc_WorkOrder>"
```
Truy vết ngược về màn hình quản lý Lot `FrmWPDLotList` (`PgmSeq: 522308`) và đối chiếu với MES.

### Tra cứu cấu trúc bảng & trường dữ liệu:
```powershell
ksys schema -Table "<TableName>"
```
Ví dụ: `ksys schema -Table "_TPRProdResult"`

### Kiểm tra sức khỏe kết nối K-System:
```powershell
ksys health
```
