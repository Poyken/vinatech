# 📘 Glossary — Từ Điển Thuật Ngữ Nghiệp Vụ & Viết Tắt MES Vinatech

> **Mục đích:** Định nghĩa toàn bộ thuật ngữ chuyên ngành và các từ viết tắt sử dụng trong hệ thống tài liệu và database của NAIS MES tại Vinatech. Giúp AI mới và lập trình viên hiểu nhất quán nghiệp vụ của nhà máy.
> ← [Về INDEX](KB_INDEX.md)

---

## 📦 1. Phân Hệ Kho Nguyên Vật Liệu (WMS - Warehouse Management System)

*   **WMS (Warehouse Management System):** Hệ thống quản lý kho nguyên vật liệu.
*   **NVL (Nguyên Vật Liệu):** Vật tư đầu vào mua ngoài phục vụ sản xuất (ví dụ: bột than, dung môi electrolyte, vỏ nhôm alu case, sleeve...).
*   **IQC (Incoming Quality Control):** Kiểm tra chất lượng nguyên vật liệu đầu vào. Hàng nhập kho bắt buộc phải qua IQC (Màn hình `C220`) và đạt trạng thái **PASS** mới được cấp phát.
*   **LotID / MaterialLotNo:** Mã vạch duy nhất do kho cấp khi tiếp nhận NVL (thường bắt đầu bằng prefix `ML...`).
*   **Vendor Lot / LotExtText10 (Đặc tính 10 / LotAttr10):** Mã Lot của nhà cung cấp in trên tem hàng về. Hệ thống sử dụng hàm parse SQL để tách ngày sản xuất từ mã này nhằm tính thời hạn sử dụng.
*   **Location (Vị trí):** Vị trí vật lý lưu trữ Lot hàng trong kho (ví dụ: `ROH_HN_WH_01`).
*   **FIFO (First In, First Out):** Nguyên tắc Nhập trước - Xuất trước. Hệ thống chặn xuất Lot mới nếu còn Lot cũ cùng mã hàng trong kho.
*   **Holding (Kho khóa):** Trạng thái Lot hàng bị khóa chất lượng hoặc cận date, tự động hoặc thủ công di chuyển vào các kho ảo `HOLDING_WH` để ngăn chặn cấp phát lên chuyền.
*   **Shelf Life (Hạn sử dụng):** Số tháng sử dụng của NVL tính từ Ngày sản xuất (quy định trong cột `MMExtInt01` của `STB_MaterialMaster`).
*   **GR (Goods Receipt) / GI (Goods Issue):** 
    *   *GR (Nhập kho):* Nhận hàng vào kho vật lý hoặc kho ảo.
    *   *GI (Xuất kho):* Xuất hàng cấp phát cho sản xuất hoặc xuất kho ảo tiêu hao theo BOM.

---

## ⚡ 2. Phân Hệ Sản Xuất & Lịch Sử Định Tuyến (WIP & Route Control)

*   **WIP (Work In Progress):** Bán thành phẩm đang nằm trên dây chuyền sản xuất giữa các công đoạn.
*   **PO (Production Order) / PONo:** Lệnh sản xuất tháng hoặc PO sản xuất. Dùng để gom nhóm các barcode sản phẩm chạy chung một model và tiêu chuẩn kỹ thuật.
*   **DayPlan / DayPlanNo:** Kế hoạch sản xuất theo ngày (Màn hình `B450`), được tạo từ PO và gán cho các Line cụ thể. Tích chọn `IsFixed = 1` để chốt kế hoạch và bắt đầu sinh Lot sản phẩm.
*   **Barcode / ControlNo:** 
    *   *Barcode:* Mã tem in ra dán lên Lot sản phẩm thực tế (ví dụ: `VVPO...`, `VE...`).
    *   *ControlNo:* Mã số định danh nội bộ (PK) của Barcode đó trong database để liên kết lịch sử routing, tránh trùng lặp khi đổi mã tem.
*   **Route (Định tuyến/Công đoạn):** Chuỗi công đoạn sản xuất sản phẩm (ví dụ: `V-22` Cuốn, `V-23` Lắp cao su, `V-25` Bọc vỏ...).
*   **Making:** Trạng thái sản xuất đang diễn ra, bắt buộc phải chọn ở cột Status khi công nhân chốt sản lượng tại màn hình `B530` ở công đoạn `V-25`.
*   **Backflush:** Cơ chế tự động trừ tồn kho nguyên vật liệu tương ứng trong kho ảo cạnh chuyền (`ROUTE_WH`) dựa trên định mức BOM khi công đoạn sản xuất tương ứng hoàn thành.
*   **IsOutputRoute:** Cờ đánh dấu công đoạn cuối cùng của sản phẩm (ví dụ: `V-28` hoặc `VE-10`), khi chốt công đoạn này hệ thống tự động tạo phiếu nhận thành phẩm (GR).

---

## 🔬 3. Phân Hệ Kiểm Chất Lượng (Quality Control & Audit)

*   **PQC (Process Quality Control):** Kiểm tra chất lượng trong công đoạn sản xuất. Được thực hiện tại trạm `C443` nhằm phát hiện sớm sản phẩm NG.
*   **OQC / FOQC (Outgoing Quality Control / Final OQC):** Kiểm tra chất lượng thành phẩm đầu ra trước khi đóng thùng xuất xưởng (Màn hình `C530`/`C546`).
*   **Defect (NG - Not Good):** Sản phẩm lỗi, phế phẩm phát sinh trên dây chuyền.
*   **DefectQty:** Số lượng sản phẩm bị lỗi ghi nhận tại công đoạn (lưu trong `STB_SetInfo` hoặc `STB_DefectRepairInfo`).
*   **QC Audit Pass / Reject:** Trạng thái phê duyệt xuất xưởng của lô thành phẩm. Nếu trạng thái là **Reject**, hệ thống sẽ chặn cứng không cho xuất kho tại màn hình Cargo.
*   **Bypass:** Cơ chế cấu hình hoặc dùng SQL can thiệp để bỏ qua một bước kiểm tra (ví dụ: bypass hạn dùng cho Lot NVL, bypass Gate chốt sản lượng...).

---

## 📦 4. Phân Hệ Đóng Gói & Thành Phẩm (Packing & Finished Goods)

*   **PackingID / BoxID:** Mã số định danh của túi hoặc hộp nhỏ đựng sản phẩm sau khi gộp box (Màn hình `B523`).
*   **BigBoxID / ParentPackingID:** Mã số định danh của thùng carton lớn chứa nhiều hộp nhỏ để xuất xưởng.
*   **Box Matching (Khớp Box):** Quy trình quét kiểm tra khớp nhãn giữa các hộp con và thùng mẹ để tránh đóng gói sai chủng loại Model.
*   **FG (Finished Goods):** Thành phẩm cuối cùng đã qua đóng gói và QC Audit đạt chuẩn, sẵn sàng giao cho khách hàng (giao Cargo).

---

## 🛠 5. Thuật Ngữ Kỹ Thuật Hệ Thống (Technical terms)

*   **SP (Stored Procedure):** Thủ tục lưu trữ trong SQL Server. Chứa 90% logic nghiệp vụ và validation của hệ thống NAIS MES.
*   **TCode (Transaction Code):** Mã rút gọn của màn hình giao diện (ví dụ: `B523`, `F330`, `C220`...).
*   **Bridge Table (Bảng cầu nối):** Các bảng trung gian trong database `SmartFactoryV2` bắt đầu bằng prefix `STB_ESM_...` dùng để đồng bộ dữ liệu giữa MES và ERP Douzone.
*   **Active Trigger:** Các trigger đang hoạt động trên các bảng giao dịch để tự động thực thi đồng bộ dữ liệu (như đồng bộ tồn kho sang `STB_MaterialStock`).
*   **SQL Agent Job:** Các tiến trình chạy ngầm theo lịch trình của SQL Server để tự động backup, đồng bộ ERP, hoặc gửi email cảnh báo.
