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

### Bước 3: Soạn Thảo Hotfix An Toàn
- Chạy lệnh: `.\mes.ps1 new-fix "<Tên_Sự_Cố>"`
- Mở file `.sql` sinh ra trong thư mục `sql/` và điền câu lệnh fix bọc trong khối `BEGIN TRAN ... ROLLBACK`.
- Đảm bảo tính toàn vẹn đa bảng và bọc `ISNULL(col, 0)` cho mọi phép toán số học.

### Bước 4: Triển Khai & Kiểm Tra
- Chạy lệnh: `.\mes.ps1 deploy <Path_to_SQL>` (Hệ thống tự động Snapshot Pre-flight backup dữ liệu trước khi chạy).

### 💡 Lưu Ý Vận Hành Bổ Sung Từ Thực Tế:
1. **Lỗi tính phế WinForms (B782):** Mọi công thức trừ phế bắt buộc bọc `ISNULL(DefectQty, 0) - ISNULL(RepairQty, 0)`.
2. **Kẹt trạng thái Kiosk POP:** Xóa `STB_ProdRouteHist` chưa đủ; BẮT BUỘC xóa bản ghi trong `MongoToMesPerformance` để nhả nút chốt sản xuất trên Kiosk.
3. **Thiếu máy trên Kiosk POP:** Kiểm tra `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING`, giải phóng các máy kẹt `ACTIVE` từ DayPlan cũ sang `RELEASED`.
