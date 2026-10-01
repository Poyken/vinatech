---
name: vinatech-mes-troubleshoot
description: Xử lý sự cố lỗi dây chuyền sản xuất MES Vinatech, lỗi chốt sản lượng B530/B540, kẹt Lot HOLD/FIFO, lỗi in tem đóng gói Sanmina, lỗi rã box Hà Nam/Hưng Yên.
---

# Vinatech MES Troubleshooting Skill

## Khi Nào Kích Hoạt Skill Này?
Kích hoạt khi người dùng báo lỗi sản xuất, lỗi kẹt Lot trên line, không nhập được sản lượng, lỗi in tem, rã/gộp thùng, hoặc yêu cầu điều tra nguyên nhân sự cố dây chuyền MES.

## Quy Trình 4 Bước Bắt Buộc:

### Bước 1: Tra Cứu Tài Liệu (Knowledge-First)
- Chạy lệnh: `.\mes.ps1 find "<Mã_Lỗi_Hoặc_ScreenID>"`
- Đọc vị trí lỗi tương ứng trong `KB_09_SCREEN_BUG_FIXBOOK.md` hoặc `KB_11_HANAM_FACTORY_SCREENS.md`.
- Trích dẫn: Tên file KB, số dòng, Root Cause và giải pháp chuẩn.

### Bước 2: Truy Vết Toàn Diện Bằng Golden Query 360°
- Chạy lệnh: `.\mes.ps1 trace "<LotID_Hoặc_Barcode>"`
- Kiểm tra đồng thời 5 bảng:
  1. `STB_MaterialLotInfo`: Trạng thái kho, hạn dùng, MaterialWarehouseCode.
  2. `STB_SetInfo`: Quản lý Set/Thùng, IsProdFinish, Barcode.
  3. `STB_ProdRouteHist`: Lịch sử công đoạn, sản lượng, công nhân chốt.
  4. `STB_MaterialDocDetail`: Chứng từ liên kết NVL / Slitting.
  5. `MongoToMesPerformance`: Trạng thái đồng bộ Kiosk POP Web (`IsDone`, `TotalProdQty`, `SourceType`).

### Bước 3: Sử Dụng Các Lệnh Hotfix Đã Đóng Gói (Built-in Hotfix Hub)
Thay vì viết SQL thủ công, ưu tiên dùng các lệnh hotfix chuẩn đã tích hợp sẵn:
- **Đổi máy nhầm Kiosk (Rule 20.1):** `mes swap-machine -Lots "<Lot>" -Machine "<Machine>"`
- **Cấp cứu thùng dung dịch 150kg:** `mes fix-solution -Lots "<SolutionLot>"`
- **Chuyển ngày chốt B782 chuẩn 10h00 AM:** `mes fix-movedate -Lots "<Lot>" -TargetDate "yyyy-MM-dd"`
- **Xóa mẻ trộn / cuộn slitting kẹt B552:** `mes fix-electrode -Lots "<Lot>" [-Type Slitting|Mixing]`
- **Mở kẹt Kiosk POP "Already completed":** `mes fix-pop-clone -Lots "<Lot>"`
- **Hủy lẻ Box đóng gói:** `mes fix-cancel-pack -Target "<Lot>" -BoxId "<BoxId>"`
- **Sửa mất cột NG do RepairQty NULL:** `mes fix-defect-null -Lots "<Lot>"`
- **Rollback công đoạn B530:** `mes fix-rollback -Lots "<Lot>" -Route "<Route>"`

Nếu cần tạo Hotfix tùy chỉnh:
- Chạy lệnh: `mes new-fix "<Tên_Sự_Cố>"`
- Mở file `.sql` sinh ra trong thư mục `sql/` và điền câu lệnh fix bọc trong khối `BEGIN TRAN ... ROLLBACK`.
- Luôn gán định danh: `Author = 'vanduc'`, `ChangeUserID = 'vanduc'`.

### Bước 4: Triển Khai & Kiểm Tra An Toàn (Rule 24)
- Triển khai an toàn: `mes deploy <Path_to_SQL>` (Hệ thống tự động chụp Snapshot Pre-flight và sinh file hoàn tác).
- Nếu OP báo nhầm, hoàn tác ngay lập tức bằng: `ops rollback -Target <LotID> -Deploy`.

### ⚡ Khuôn Mẫu Phản Hồi Bắt Buộc ("4 Dòng Vàng"):
1. 🎯 **Nguyên nhân gốc rễ (Root Cause):** Tên màn hình, Stored Procedure, cơ chế gây lỗi.
2. 📍 **Hiện trạng thực tế:** Lot đang ở đâu, kẹt cái gì, bảng nào.
3. 🛠️ **Cách OP tự xử lý trên giao diện (Workaround):** Các bước 1-2-3 cho công nhân/tổ trưởng tại xưởng.
4. ⚡ **SQL Hotfix chuẩn (Nếu IT phải can thiệp):** Đã bọc `BEGIN TRAN...ROLLBACK`, có NOLOCK, ChangeUserID='vanduc'.

### 💡 Lưu Ý Vận Hành Bổ Sung Từ Thực Tế:
1. **Lỗi tính phế WinForms (B782):** Mọi công thức trừ phế bắt buộc bọc `ISNULL(DefectQty, 0) - ISNULL(RepairQty, 0)`.
2. **Kẹt trạng thái Kiosk POP:** Xóa `STB_ProdRouteHist` chưa đủ; BẮT BUỘC xóa bản ghi trong `MongoToMesPerformance` để nhả nút chốt sản xuất trên Kiosk.
3. **Thiếu máy trên Kiosk POP:** Kiểm tra `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING`, giải phóng các máy kẹt `ACTIVE` từ DayPlan cũ sang `RELEASED` qua lệnh: `pop unlock "<Machine>" -Deploy`.

