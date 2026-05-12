# 🔄 Vinatech MES - Data Flow & System Architecture

Tài liệu này đóng vai trò thay thế cho `Vinatech_MES_Complete_DataFlow.md` và `SOLO_CONTEXT_OVERVIEW.md` nhằm mục đích tra cứu luồng dữ liệu (Data Flow) khi gặp các bug chưa từng có trong Knowledge Base (KB).

## 1. Luồng Nguyên Vật Liệu (WMS Flow)
*   **F330 (Tiếp nhận & In tem):** Nhận NVL từ Vendor -> Sinh mã Lot (Vendor Lot parsing) -> Đẩy vào `STB_MaterialLotInfo`.
*   **F312 (Chỉnh sửa Lot):** Sửa thông tin Lot NVL nếu sai sót.
*   **F430 (Xuất kho):** Xuất NVL lên Production Line (E-xx, V-xx, VE-xx) -> Lưu lịch sử vào `STB_MaterialWarehouseInOutHist`.

## 2. Luồng Kế Hoạch & Định Mức (Master Data Flow)
*   **Groupware -> MES:** PO và Kế hoạch ngày được lập trên Groupware -> Đẩy xuống B310 (PO) và B450 (Kế hoạch ngày).
*   **A230 / A310:** Cấu hình BOM và Item Master (đồng bộ từ ERP/Groupware). Cần BOM Version 2001.

## 3. Luồng Sản Xuất (Production Flow)
*   **B450 (Tạo Lot):** Từ kế hoạch ngày, sinh ra Lot sản xuất.
*   **B597 (Quy trình đầu / Cuốn):** Bắt đầu quy trình sản xuất (Jelly Roll). Kiểm tra Lot NVL (F330). Nếu NVL bị HOLD hoặc hết hạn -> Block.
*   **C512 / C443 (QC Inspection):** Lấy mẫu kiểm tra chất lượng. Nếu Pass -> tiếp tục. Nếu Fail -> Hold/Scrap.
*   **B523 (Đóng Gói & In Tem):** Gộp các sản phẩm đạt tiêu chuẩn thành Box (Packing). Ghi nhận vào `STB_SavePackingTime_VVT`. Thường xuyên gặp lỗi trùng lặp dữ liệu hoặc khác Part No.
*   **B767 (In tem khách hàng):** In tem Sanmina, v.v.

## 4. Bảng Database Cốt Lõi
*   `STB_MaterialLotInfo`: Tồn kho NVL/Thành phẩm.
*   `STB_ProdRouteHist`: Lịch sử chạy qua các công đoạn.
*   `STB_ProcedureLog`: Chứa log lỗi của SP (cực kỳ quan trọng để debug).
*   `STB_SetInfo`: Chứa thông tin gốc của Barcode/Lot.

*Tham khảo file `AGENTS.md` để biết thêm quy tắc truy vấn.*
