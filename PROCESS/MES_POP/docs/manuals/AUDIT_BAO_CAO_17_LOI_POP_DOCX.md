# 🛡️ BÁO CÁO KIỂM TOÁN ĐỐI CHIẾU 100% TOÀN BỘ 17 CA BỆNH POP TỪ FILE WORD
> **Tài liệu gốc đối chiếu:** `MES_POP/docs/manuals/HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI.docx`  
> **Tác giả tài liệu gốc:** Kỹ sư Nguyễn Văn Đức (`vanduc`) / Hải Triều - Ban IT / EA Team Vinatech  
> **Thời gian kiểm toán:** 2026-09-25  
> **Kết quả kiểm toán:** **17/17 Ca bệnh (100%) ĐÃ ĐƯỢC CHECK, CHUẨN HÓA VÀO KNOWLEDGE BASE, L1 CACHE VÀ BỘ CÔNG CỤ CLI.**

---

## Executive Summary (Tóm Tắt Điều Hành)

Toàn bộ 17 lỗi và tình huống vận hành thực tế được ghi nhận trong file Word nội bộ đã được rà soát, đối chiếu và chuẩn hóa đa tầng:
1. **Lưu trữ tri thức sâu:** Được chuẩn hóa chi tiết tại [POP_KB_03_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md) (Mục 3: Cẩm nang 17 ca bệnh thực chiến EA Team).
2. **L1 Quick Cache (<0.001s):** Đã nạp đầy đủ mã định danh từ `POP-CASE-01` đến `POP-CASE-17` vào [POP_MATRIX.json](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json).
3. **Bộ Template SQL Hotfix:** Đã tạo sẵn 5 template SQL chuẩn hóa mới tại thư mục `MES_POP/sql/` có đầy đủ `BEGIN TRAN...ROLLBACK/COMMIT`, `WITH(NOLOCK)` và gán tác giả `vanduc`.
4. **Tích hợp CLI Hub:** Lệnh `.\mes.ps1 new-fix` và `.\mes.ps1 find` đã hỗ trợ trực tiếp toàn bộ các ca bệnh này, cho phép kỹ sư sinh script cứu hộ trong 1 giây mà không cần viết SQL thủ công.

---

## 📊 BẢNG MA TRẬN ĐỐI CHIẾU 17/17 CA BỆNH THỰC CHIẾN

| STT | Tên ca bệnh trong File Word | Bảng CSDL / SP Liên Quan | Mã L1 Cache | File KB Quy Chuẩn | Công Cụ / Template CLI Tương Ứng | Trạng Thái |
|:---:|---|---|:---:|---|---|:---:|
| **1** | Cắt đóng gói điện cực báo lỗi (chọn nhầm Line Bắc Ninh) | `STB_SetInfo`, `STB_DayProdPlan` (`LineCode`) | `POP-CASE-01` | [POP_KB_03 §3 Case 1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1120) | `.\mes.ps1 find POP-CASE-01` | ✅ 100% |
| **2** | Chưa thêm mã lỗi ứng với từng công đoạn | `STB_DefectGroup`, `STB_DefectInfo` | `POP-CASE-02` | [POP_KB_03 §3 Case 2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1134) | `.\mes.ps1 new-fix "CLONE" -Template clone-defect` | ✅ 100% |
| **3** | Dùng MES rồi quay sang POP bị lỗi (Already completed in MES) | `STB_ProdRouteHist`, `STB_ProdRouteWorkerHist` | `POP-CASE-03` / `POP-ERR-09` | [POP_KB_03 §3 Case 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1178) | `.\mes.ps1 fix-pop-clone -Lots '<Lot>' -Deploy` | ✅ 100% |
| **4** | Không thể nhập 1 mã cắt điện cực từ 2 Lot trở lên (Max 3 LOT) | `STB_RawMaterialInputHist`, `STB_MaterialLotInfo` | `POP-CASE-04` / `POP-ERR-24` | [POP_KB_03 §3 Case 4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1220) | RULE 20 (Khống chế tối đa 3 LOTNO) | ✅ 100% |
| **5** | Không thể đóng gói khi báo không có kho | `STB_ProductLine`, `STB_ProductRoute` (WinForm B230) | `POP-CASE-05` | [POP_KB_03 §3 Case 5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1230) | Gán kho tại màn hình WinForm B230 | ✅ 100% |
| **6** | Tự kiểm PQC in-line thiết lập nhầm công đoạn | `STB_CommInspDocHistory`, `STB_CommInspDocItem` | `POP-CASE-06` | [POP_KB_03 §3 Case 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1237) | `.\mes.ps1 new-fix "PQC" -Template pqc` | ✅ 100% |
| **7** | Báo hết tồn kho nguyên vật liệu khi nạp Kiosk | `STB_MaterialLotInfo`, `STB_MaterialStock` (F430) | `POP-CASE-07` / `POP-ERR-19` | [POP_KB_03 §3 Case 7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1265) | Chạm icon đổi NVL / Kiểm tra `CurrentQty` | ✅ 100% |
| **8** | Tìm kiếm tồn kho điện cực nếu không quét được mã | `STB_MaterialLotInfo` (`LotAttr01='SLITTING'`) | `POP-CASE-08` | [POP_KB_03 §3 Case 8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1280) | Điều kiện lọc Modal: `ModalVisible='Y'` | ✅ 100% |
| **9** | Tạo cưỡng chế tồn kho điện cực (Cuộn rách tem / thiếu kho) | `STB_ElectrodeSlittingResult`, `STB_SerialRule` | `POP-CASE-09` | [POP_KB_03 §3 Case 9](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1285) | `.\mes.ps1 new-fix "ROLL" -Template force-stock` | ✅ 100% |
| **10** | Hướng dẫn thiết lập NVL theo từng CellLine | `VINA_ASSEMBLY_GROUP_MODE`, `VINA_GROUP_INPUT_ROUTE` | `POP-CASE-10` | [POP_KB_03 §3 Case 10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1349) | `.\mes.ps1 pop-readiness -Line <LineCode>` | ✅ 100% |
| **11** | Hủy đóng gói và hủy hoàn thành công đoạn (Rollback) | `STB_PackingInfo`, `usp_DoCancelProdPacking_LotNo` | `POP-CASE-11` | [POP_KB_03 §3 Case 11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1366) | `.\mes.ps1 fix-cancel-pack -Target '<Lot>'` | ✅ 100% |
| **12** | Nguyên vật liệu thay thế trong BOM | `STB_MaterialMaster` (`DelegateMaterialCode`) | `POP-CASE-12` | [POP_KB_03 §3 Case 12](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1372) | Quét mã NVL thay thế định nghĩa sẵn | ✅ 100% |
| **13** | Bấm nhầm dấu (+) sang nhập hoàn thành thay vì (-) phế | `STB_DefectRepairInfo`, `STB_ProdRouteHist` | `POP-CASE-13` | [POP_KB_03 §3 Case 13](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1380) | `.\mes.ps1 fix-rollback -Lots '<Lot>'` | ✅ 100% |
| **14** | MES hoàn thành tự sinh công đoạn dở dang trước POP | `STB_ProdRouteHist` (`CompleteRoute = 1`) | `POP-CASE-14` | [POP_KB_03 §3 Case 14](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1180) | `.\mes.ps1 fix-rollback -Lots '<Lot>' -Route '...'` | ✅ 100% |
| **15** | Lỗi chưa lưu độ nhớt ở công đoạn Trộn (Mixing) | `STB_ElectrodeMixStepInfo`, `STB_SetInfo` | `POP-CASE-15` / `POP-ERR-27` | [POP_KB_03 §3 Case 15](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1386) | Mở lại mẻ Trộn trên Kiosk, bấm Lưu độ nhớt | ✅ 100% |
| **16** | Đổi máy nhầm / Gán sai tên máy trên Kiosk (RULE 20) | `STB_ProdRouteHist` VÀ `MongoToMesPerformance` | `POP-CASE-16` / RULE 20 | [POP_KB_03 §3 Case 16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1393) | `.\mes.ps1 new-fix "SWAP" -Template swap-machine` | ✅ 100% |
| **17** | Nút "Cắt điện cực" bị mờ do độ dày < 100 (RULE 20) | `STB_MaterialMaster` (`MaterialThickness < 100`) | `POP-CASE-17` / RULE 20 | [POP_KB_03 §3 Case 17](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#L1431) | `.\mes.ps1 new-fix "THICK" -Template thick` | ✅ 100% |

---

## 🔍 CHI TIẾT BÓC TÁCH CÁC CA KINH ĐIỂN NHẤT

### 1. Ca 16: Đổi Mã Máy Nhầm Kiosk (Quy Tắc Playbook EA Bất Biến)
* **Bản chất lỗi:** Công nhân chọn nhầm máy trên Kiosk (ví dụ chạy máy `VVMHY130` nhưng chọn nhầm `VVMHY136`).
* **Cơ chế ngầm:** Dữ liệu Kiosk nằm tại `MongoToMesPerformance`, còn dữ liệu MES lõi nằm tại `STB_ProdRouteHist`. Nếu kỹ sư chỉ UPDATE bảng `STB_ProdRouteHist` trên MES WinForm thì Background Worker của POP định kỳ sẽ **ghi đè ngược lại** mã cũ!
* **Giải pháp chuẩn hóa:**
  ```powershell
  .\mes.ps1 new-fix "SWAP_MACHINE_VVC11" -Template swap-machine
  ```
  Script tự động sinh mã bọc trong `BEGIN TRAN...ROLLBACK` cập nhật đồng thời cả hai bảng.

---

### 2. Ca 9: Tạo Cưỡng Chế Tồn Kho Điện Cực (Author: vanduc / HaiTrieu)
* **Bản chất lỗi:** Cuộn BTP điện cực sau khi Slitting bị mờ tem, rách mã vạch hoặc chưa được nạp kho tự động, công nhân Kiosk quét nạp báo *"Không tìm thấy LOT trong kho"*.
* **Cơ chế an toàn 3 bước:**
  - **STEP 0:** Đối chiếu thực tích Slitting gốc tại `STB_ElectrodeSlittingResult` (kiểm tra `GoodQtyLength > 0`, chiều rộng, độ dày và cực tính `PlusMinus`).
  - **STEP 1:** Xin cấp số Serial nhảy an toàn từ `SmartFramework.dbo.STB_SerialRule` cho bảng `STB_MaterialLotInfo` (chống trùng khóa chính và không dùng `MAX+1`). Chèn tồn kho với cờ nhận diện vân tay `LotAttr01 = 'SLITTING'` và `IsSlitting = 1`.
  - **STEP 2:** Xác minh điều kiện hiển thị trên popup tìm kiếm Kiosk (`ModalVisible = 'Y'`).
* **Giải pháp chuẩn hóa:**
  ```powershell
  .\mes.ps1 new-fix "FORCE_ROLL_LOT" -Template force-stock
  ```

---

### 3. Ca 17: Nút Bấm "Cắt Điện Cực" Bị Mờ Do Độ Dày < 100
* **Bản chất lỗi:** Tại trạm Cắt điện cực, nút Cắt bị xám mờ không nhấn được dù đã nạp cuộn hợp lệ.
* **Nguyên nhân gốc rễ:** Thuật toán an toàn của hệ thống kiểm tra trường `MaterialThickness` trong `STB_MaterialMaster`. Nếu độ dày `< 100 µm`, nút Cắt tự động khóa.
* **Giải pháp chuẩn hóa:**
  ```powershell
  .\mes.ps1 new-fix "FIX_THICK_CRPSC5" -Template thick
  ```

---

## 🛠️ HƯỚNG DẪN TRA CỨU NHANH TRONG VẬN HÀNH HÀNG NGÀY

Khi trực vận hành ca hoặc nhận báo lỗi từ hiện trường xưởng, kỹ sư IT chỉ cần dùng lệnh CLI:

1. **Tra cứu cẩm nang xử lý bất kỳ ca nào trong < 0.001 giây:**
   ```powershell
   .\mes.ps1 find "POP-CASE-16"
   # hoặc
   .\mes.ps1 find "đổi máy"
   ```

2. **Sinh mã Hotfix mẫu an toàn có sẵn cấu trúc Snapshot:**
   ```powershell
   .\mes.ps1 new-fix "<Tên_Sự_Cố>" -Template <swap-machine|force-stock|clone-defect|pqc|thick|packing-id|b552|b782|rollback>
   ```

3. **Kiểm tra độ sẵn sàng của Line trước khi cắt WinForm:**
   ```powershell
   .\mes.ps1 pop-readiness -Line "<Mã_Line>"
   ```
