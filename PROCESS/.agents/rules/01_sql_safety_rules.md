# 🛡️ VINATECH PRODUCTION DATABASE EXECUTION & DEPLOYMENT PROTOCOL

> **Tài liệu quy chuẩn:** `.agents/rules/01_sql_safety_rules.md`  
> **Áp dụng cho:** Kỹ sư IT (Nguyen Van Duc - `vanduc`), AI Copilot và toàn bộ công cụ triển khai (`ops.ps1`, `mes.ps1`, `deploy_tool.ps1`).  
> **Mục tiêu:** Đảm bảo 100% can thiệp CSDL Production không gây sập chuyền, không gây deadlock, có snapshot tự động và có khả năng hoàn tác tức thời (1-Click Undo).

---

## ⛔ 1. NGUYÊN TẮC BẤT BIẾN TRƯỚC KHI CAN THIỆP CSDL (PRE-EXECUTION)

1. **RULE 0 — ZERO BLIND QUERY:** Tuyệt đối CẤM chạy câu lệnh `SELECT` để mò mẫm cấu trúc bảng hoặc tên cột. Bắt buộc tra cứu L1 Cache (`POP_MATRIX.json`, `QUICK_MATRIX.json`, `KSYSTEM_MATRIX.json`, `GW_FORM_MATRIX.json`) hoặc tài liệu KB trước khi truy vấn.
2. **RULE 1 — SELECT-ONLY TRÊN PRODUCTION CONSOLE:** Các lệnh query trực tiếp qua `.\mes.ps1 query`, `.\gw.ps1 query`, `.\db.ps1 query` chỉ cho phép đọc dữ liệu. Mọi hành vi can thiệp dữ liệu (`UPDATE`, `DELETE`, `INSERT`, `ALTER`, `DROP`, `TRUNCATE`) BẮT BUỘC phải đóng gói thành file script `.sql` và triển khai qua cơ chế có kiểm soát (`ops deploy` hoặc `mes deploy`).
3. **RULE 15 — BẢO VỆ BẢNG KHỔNG LỒ (MONSTER TABLES GUARD):**
   - Các bảng kích thước siêu lớn: `SmartFactoryV2.dbo.STB_VVT_ESRDATA` (423 triệu dòng, 64.8 GB), `STB_SetInfo` (hàng triệu dòng), `STB_ProductStockInfo`, `STB_ProdRouteHist`.
   - **BẮT BUỘC:** Mọi câu lệnh `SELECT` phải có `WITH (NOLOCK)` và phải có điều kiện lọc theo Clustered Index (ví dụ: `WHERE id > ...` hoặc `WHERE ControlNo = ...` hoặc `WHERE Barcode = ...`). Tuyệt đối CẤM `SELECT * FROM STB_VVT_ESRDATA` không có điều kiện hẹp hoặc `ORDER BY` trên cột không có Index.
4. **KIỂM TRA KHÓA TRƯỚC CAN THIỆP (LOCKS CHECK):** Trước khi can thiệp vào các bảng nhạy cảm trong giờ cao điểm sản xuất, bắt buộc kiểm tra xem có tiến trình nào đang giữ khóa trên bảng hay không qua lệnh:
   ```powershell
   ops mes locks
   # Hoặc
   ops db locks
   ```

---

## 🏗️ 2. CẤU TRÚC 4 PHA BẮT BUỘC CỦA MỌI SCRIPT TRIỂN KHAI (.SQL)

Mọi file script SQL dùng để Hotfix hoặc Triển khai thay đổi trên Production BẮT BUỘC tuân thủ cấu trúc chuẩn 4 pha:

```sql
-- ==============================================================================
-- ISSUE / HOTFIX : [Mã Sự Cố / Tên Nghiệp Vụ Cần Xử Lý]
-- Created At     : [yyyy-MM-dd HH:mm:ss]
-- Author         : vanduc
-- ChangeUserID   : vanduc
-- Target Profile : SmartFactoryV2 (hoặc Groupware / POP / NEOE)
-- Target Entities: [Danh sách Lot, PO, Machine, Document No...]
-- ==============================================================================
USE SmartFactoryV2; -- (Hoặc CSDL đích)
GO

-- ------------------------------------------------------------------------------
-- PHA 1: PRE-FLIGHT VERIFICATION (Kiểm tra hiện trạng trước khi thay đổi)
-- Mục đích: Đảm bảo đúng đối tượng cần sửa, xác nhận số lượng bản ghi chịu tác động.
-- ------------------------------------------------------------------------------
SELECT 
    ControlNo, Barcode, RouteCode, JobDate, ProdDateTime, ProdQty, ChangeUserID
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE Barcode IN ('VVQR2601001')
ORDER BY ControlNo, ProdRouteHistNo;
GO

-- ------------------------------------------------------------------------------
-- PHA 2 & 3: TRANSACTION SAFETY & MUTATION (Can thiệp dữ liệu có bảo vệ)
-- Bắt buộc: BEGIN TRAN, có mệnh đề WHERE chính xác, cập nhật ChangeUserID = 'vanduc'
-- ------------------------------------------------------------------------------
BEGIN TRAN;

UPDATE H
SET 
    H.JobDate = '2026-10-02',
    H.ProdDateTime = DATEADD(HOUR, 10, H.ProdDateTime),
    H.ChangeDateTime = GETDATE(),
    H.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ('VVQR2601001');

-- ------------------------------------------------------------------------------
-- PHA 4: POST-FLIGHT VERIFICATION & ROLLBACK DEFAULT
-- Mặc định trong giai đoạn khảo sát/dry-run: Để ROLLBACK TRAN để kiểm tra an toàn.
-- Chỉ khi triển khai chính thức qua deploy_tool mới chuyển thành COMMIT TRAN.
-- ------------------------------------------------------------------------------
SELECT 
    ControlNo, Barcode, RouteCode, JobDate, ProdDateTime, ProdQty, ChangeUserID
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE Barcode IN ('VVQR2601001');

-- MẶC ĐỊNH DRY-RUN AN TOÀN:
ROLLBACK TRAN;
-- (Khi deploy chính thức, deploy_tool hoặc kỹ sư IT sẽ xác nhận COMMIT TRAN)
GO
```

---

## 📸 3. QUY TRÌNH PRE-FLIGHT SNAPSHOT & TỰ ĐỘNG SINH MÃ HOÀN TÁC (UNDO)

Trước khi thực thi bất kỳ lệnh `UPDATE` hay `DELETE` nào trên Production, công cụ triển khai (`deploy_tool.ps1` hoặc `ops deploy`) tự động kích hoạt hàm `Create-SafePreflightSnapshot`:

1. **Chụp ảnh dữ liệu gốc (JSON Snapshot):**
   - Trích xuất toàn bộ các dòng hiện tại thỏa mãn điều kiện `WHERE` của lệnh sửa đổi.
   - Lưu trữ bản chụp JSON chi tiết tại: `backups/snapshots/snap_<TargetID>_<Timestamp>.json`.
2. **Sinh mã hoàn tác tự động (Reversible Undo Script):**
   - Tự động sinh file SQL hoàn tác đối xứng tại: `backups/undo/undo_<TargetID>_<Timestamp>.sql`.
   - File hoàn tác tự động đóng dấu `-- Profile: <DbProfile>` ở đầu tệp.
   - Mỗi dòng dữ liệu được sinh thành một lệnh `UPDATE` khôi phục lại chính xác từng giá trị của từng cột trước khi sửa đổi, được bọc an toàn trong `BEGIN TRANSACTION ... COMMIT TRANSACTION ... BEGIN CATCH ... ROLLBACK`.

---

## 🚀 4. QUY TRÌNH TRIỂN KHAI THỰC CHIẾN (DEPLOYMENT PIPELINE)

Quy trình triển khai gồm 5 bước tiêu chuẩn không thể bỏ qua:

```
┌────────────────┐     ┌────────────────┐     ┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│  BƯỚC 1: LINT  │ ──> │ BƯỚC 2: SNAP   │ ──> │ BƯỚC 3: DEPLOY │ ──> │ BƯỚC 4: VERIFY │ ──> │ BƯỚC 5: AUDIT  │
│ validate_sql   │     │ Auto-Snapshot  │     │ Batch Exec     │     │ Trace lại Lot  │     │ Ghi HOTFIX_LOG │
└────────────────┘     └────────────────┘     └────────────────┘     └────────────────┘     └────────────────┘
```

1. **Bước 1: Kiểm định an toàn (Pre-flight Lint):**
   - Chạy qua `validate_sql.ps1` để phát hiện các câu lệnh cấm: `DROP TABLE`, `TRUNCATE`, `DELETE` thiếu `WHERE`.
2. **Bước 2: Chụp Snapshot & Tạo Undo Script:**
   - Đảm bảo dữ liệu nguyên trạng được cất giữ an toàn.
3. **Bước 3: Thực thi Triển khai qua CLI:**
   - Triển khai bằng lệnh duy nhất:
     ```powershell
     ops deploy <đường_dẫn_file.sql> [-Profile <DbProfile>]
     ```
   - Script tự động bóc tách từng khối `GO`, thực thi qua ADO.NET Connection có CommandTimeout 120s.
4. **Bước 4: Nghiệm thu kết quả (Post-flight Verification):**
   - Dùng lệnh Golden Query 360° tương ứng để xác nhận:
     - `ops trace "<LotID>"` hoặc `mes trace "<LotID>"`
     - `pop nvl "<LotID>"`
     - `gw trace "<DocCode>"`
   - Yêu cầu công nhân hoặc tổ trưởng kiểm tra lại trên màn hình WinForm/Kiosk xưởng.
5. **Bước 5: Ghi nhật ký & Học hỏi tri thức:**
   - Tự động ghi nhật ký vào `AI_AGENT_CONFIG/HOTFIX_LOG.jsonl`.
   - Nếu phát hiện quy luật mới, dùng lệnh `/learn` để ghi nhận vĩnh viễn vào `02_learned_patterns.md`.

---

## ⏪ 5. QUY TRÌNH HOÀN TÁC KHẨN CẤP (1-CLICK EMERGENCY ROLLBACK)

Nếu sau khi triển khai phát hiện dữ liệu sai lệch hoặc người vận hành hiện trường báo nhầm:

1. **Khảo sát câu lệnh hoàn tác (Dry-run):**
   ```powershell
   ops rollback -Target <LotID_hoặc_Mã_Sự_Cố>
   ```
   Hệ thống sẽ tự động quét thư mục `backups/undo/`, tìm script hoàn tác gần nhất cho đối tượng, bóc tách Database Profile tương ứng và hiển thị toàn bộ nội dung hoàn tác lên màn hình.

2. **Kích hoạt hoàn tác tức thì:**
   ```powershell
   ops rollback -Target <LotID_hoặc_Mã_Sự_Cố> -Deploy
   ```
   Hệ thống tự động kết nối đúng CSDL đích, mở Transaction, thực thi toàn bộ script khôi phục lại dữ liệu nguyên vẹn ban đầu trong thời gian `< 1.5 giây`.
