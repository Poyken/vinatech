<!--
AI-READY METADATA
Purpose: Nhật ký ghi chép lịch sử xử lý bug & hotfix đã được AI triển khai thành công
Scope: Hotfix History Registry
Single Source of Truth: HOTFIX_LOG.md (Lịch sử hotfixes) & KB_09 (Sổ tay cứu hộ)
Related Files:
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [KB_09_SCREEN_BUG_FIXBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)
  - [record_hotfix.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/record_hotfix.ps1)
-->

# 📓 Vinatech MES Agent — Hotfix Log (Nhật ký lỗi & Giải pháp)

> **Mục đích:** Bảng lưu trữ lịch sử các con bug đã được AI xử lý thành công. File này đóng vai trò là "Bộ nhớ dài hạn" để AI tra cứu trước khi xử lý các sự cố tiếp theo nhằm tự tối ưu bản thân qua thời gian.
> **Quy trình:** Khi hoàn thành fix bất kỳ lỗi nào, AI bắt buộc phải mô tả chi tiết lỗi vào danh sách dưới đây và thực hiện commit.

> **⚠️ Lưu ý:** KHÔNG paste toàn bộ source code SP vào file này — chỉ ghi tóm tắt ALTER + logic chính. Dùng `db_sync_tool.ps1` để xem full SP.

---

## 📋 Danh sách Lịch sử Sửa lỗi (Hotfix Registry)

### 📌 Mẫu ghi chép (Template)
* **Ngày sửa:** `YYYY-MM-DD`
* **Màn hình liên quan (TCode):** `[TCODE_ID] - Tên màn hình`
* **Triệu chứng lỗi:** `Nội dung lỗi hiển thị trên UI (Tiếng Hàn/Anh/Việt)`
* **Nguyên nhân gốc (Root Cause):** `Giải thích lỗi do code SP hay do dữ liệu CSDL`
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- Chèn câu lệnh SQL fix hoặc giải pháp xử lý đã thực hiện
  ```

---

## ⚡ Các Lỗi Đã Được Xử Lý (Resolved Bugs)

### [HN544] — 📍 ID_21 Hủy gộp box / Rã box túi bóng ở màn hình HN544
* **Ngày sửa:** `2026-07-30`
* **Màn hình liên quan (TCode):** `[HN544] - Gộp túi bóng thành hộp nhỏ`
* **Triệu chứng lỗi:** Cần hủy gộp mã Packing `PK20260730000000004` (hoặc rã box túi bóng) giải phóng các Lot con để đóng gói lại.
* **Nguyên nhân gốc (Root Cause):** Gộp nhầm box hoặc thao tác hủy trên giao diện UI bị chặn/lỗi.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Giải phóng liên kết PackingID khỏi các Lot con trong STB_MaterialLotInfo
  UPDATE STB_MaterialLotInfo SET PackingID = NULL WHERE PackingID = 'PK20260730000000004';
  -- 2. Xóa thông tin lịch sử gộp box trong STB_DividePackaging
  DELETE FROM STB_DividePackaging WHERE PackingID = 'PK20260730000000004';
  COMMIT TRANSACTION;
  ```

### [K366] — 📍 ID_18 Cột Status trống trên Lot Tracking BG2
* **Ngày sửa:** `2026-07-06`
* **Màn hình liên quan (TCode):** `K366 - Lot Tracking BG2`
* **Triệu chứng lỗi:** Cột Status (Kết luận cuối cùng Pass/Fail) hiển thị trống trên grid
* **Nguyên nhân gốc (Root Cause):** SP `usp_LotTrackingInfo_VVTF4_get` không trả về cột Status cho grid mapping.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  ALTER PROCEDURE [dbo].[usp_LotTrackingInfo_VVTF4_get]
  -- Thêm cột Status vào SELECT:
  -- CASE WHEN df.ControlNo IS NULL THEN 'PASS'
  --      WHEN rp.Barcode IS NOT NULL THEN 'PASS'
  --      ELSE 'FAIL' END AS Status
  -- Tối ưu: dùng temp tables (#TmpBarcodes, #TmpDefect, #TmpMaterialInput, #TmpRepair)
  --         thay vì subquery để giảm thời gian truy vấn.
  -- Full SP: db_sync_tool.ps1 -SPName "usp_LotTrackingInfo_VVTF4_get"
  ```

### [B523] — 📍 ID_19 Sanmina QR code trùng lặp trên tem Inner
* **Ngày sửa:** `2026-07-06`
* **Màn hình liên quan (TCode):** `B523 - Đóng gói (Sanmina Label)`
* **Triệu chứng lỗi:** Sanmina QR code hiển thị số lượng và serial trùng lặp trên inner labels
* **Nguyên nhân gốc (Root Cause):** SP `usp_SanminaLabelPrint_get_Vietnam` không lọc riêng serial/quantity cho inner labels — trả về cùng data cho cả Outer và Inner.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
  -- Thêm #LabelTypes (Outer, Inner-01, Inner-02) + CROSS JOIN #tmp
  -- Quantity: Outer = @pQuantity, Inner = @pQuantity/2
  -- Serial: BoxSerialNo = base, PrintSerialNo = base + suffix
  -- Thêm SerialListForQR: Outer = concat(outer||inner1||inner2), Inner = serial riêng
  -- Full SP: db_sync_tool.ps1 -SPName "usp_SanminaLabelPrint_get_Vietnam"
  ```

### [B767] — 📍 ID_20 S/N tem Outer trống trên Sanmina label
* **Ngày sửa:** `2026-07-16`
* **Màn hình liên quan (TCode):** `B767 - In tem Sanmina`
* **Triệu chứng lỗi:** S/N của tem đầu tiên (Outer label) bị trống khi in
* **Nguyên nhân gốc (Root Cause):** SP `usp_SanminaLabelPrint_get_Vietnam` set PrintSerialNo trống và BoxSerialNo = serial Inner đầu tiên cho Outer label.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- 1. Sửa SP: BoxSerialNo + PrintSerialNo cho Outer = comma-separated list (Inner1, Inner2)
  ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam] ...

  -- 2. Mở rộng cột BoxSerialNo để chứa chuỗi gộp:
  ALTER TABLE STB_SanminaIndiaLabelPrintHist ALTER COLUMN BoxSerialNo VARCHAR(50);

  -- 3. Sửa SP insert lịch sử:
  ALTER PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_iud] ... (@pBoxSerialNo VARCHAR(50) = NULL)
  ```
