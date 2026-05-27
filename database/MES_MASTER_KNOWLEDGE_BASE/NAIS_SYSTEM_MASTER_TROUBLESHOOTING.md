# 📘 NAIS SYSTEM MASTER TROUBLESHOOTING

> Tài liệu tổng hợp các lỗi thực tế đã xử lý, kèm phương pháp trace và script fix.
> Mọi chi tiết fix bug đã được chuẩn hóa thành 1 nguồn duy nhất tại các file KB_0x tương ứng để tránh trùng lặp.

---

## 1. LỖI THIẾU THIẾT LẬP VỎ NHÔM (B597)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_05_QC_ELECTRODE.md § 7.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md)

---

## 2. LỖI GỘP TÚI BÓNG QTY = 0 (HN544)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

## 3. LỖI VENDOR LOT (F330 — Nhập kho NVL)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_02_KHO_WMS.md § 4.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md)

---

## 4. LỖI TRACE KẾ HOẠCH SAI LINE (B450)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_03_SAN_XUAT.md § 5.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md)

---

## 5. LỖI POPUP TRỐNG (B270)
👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md)

---

## 6. LỖI KHÔNG ĐĂNG NHẬP ĐƯỢC MES
👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md)

---

## 7. LỖI B597 — CHECKLIST ĐẦY ĐỦ
👉 **Checklist B597:** Xem tại [KB_05_QC_ELECTRODE.md § 8.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md)
👉 **Kiểm tra và Bypass hạn sử dụng NVL:** Xem tại [KB_02_KHO_WMS.md § 4.10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md) và [§ 4.9](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md)

---

## 8. LỖI KHÔNG GỘP ĐƯỢC BOX (B523) — 4 BƯỚC DEBUG CHUẨN
👉 **Chi tiết Trace & Fix (4 bước chuẩn):** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)
👉 **Demo case + Script SQL:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)

---

## 9. LỖI USER MUỐN HỦY KẾT QUẢ / HỦY CÔNG ĐOẠN
👉 **3 kịch bản (Hủy routing, Hủy QC, Hủy OQC):** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Xóa nhập sản lượng công đoạn:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md)

---

## 10. LỖI GỘP BOX 2 LẦN BỊ NHẦM / GỘP BOX SAI SỐ LƯỢNG
👉 **Hủy gộp box + Rã box + Khôi phục Qty:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Gộp túi bóng Qty=0 (HN544):** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)
👉 **Packing Qty âm:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

## 11. LỖI KHÔNG CHỐT ĐƯỢC CÔNG ĐOẠN (B530)
👉 **3 kịch bản (NVL chưa scan, công đoạn đảo thứ tự, Gate 20 phút):** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)

---

## 12. LỖI KHÔNG IN ĐƯỢC TEM (B450 / B523 / B756)
👉 **5 bước kiểm tra + Checklist đầy đủ:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Checklist 7 bước khi user báo không in được:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.12](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

## 13. LỖI MÀN HNC321 NHẬP PHẾ BÁO LỖI TIẾNG HÀN
👉 **Bypass nghiệp vụ + Bypass SQL (chèn lịch sử giả lập):** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Cũng có tại:** [KB_08_KHO_THANH_PHAM_HN.md § 4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md)

---

## 14. LỖI NHẢY BƯỚC CÂN ĐIỆN CỰC MIXING (electrode.weighing)
👉 **Nguyên nhân checkbox CA ĐÊM + Reset Lot kẹt:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)
👉 **Bao gồm cả:** Mã HCE lỗi, sản xuất không ghi nhận, cân than nhảy thứ tự

---

## 15. ĐIỆN CỰC MÃ 3582-600F CY KHÔNG TẠO ĐƯỢC TEM
👉 **Thêm config Slitting + ModelBasicInfo:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md)

---

## 💡 NGUYÊN TẮC VÀNG KHI TỰ SỬA

1. **Luôn SELECT trước khi UPDATE** — đảm bảo WHERE chỉ tác động đúng dòng cần sửa
2. **Dùng BEGIN TRAN ... ROLLBACK/COMMIT** khi sửa dữ liệu quan trọng
3. **Sửa đủ bảng** — thiếu 1 bảng gây lệch dữ liệu (VD: F330 cần sửa 3 bảng)
4. **Ghi log thao tác** — để audit sau

*Cập nhật: 2026-05-26*


màn f742 muốn rollback cắt được
thì cần xóa lịch sử màn f746

để "hủy xuất / trả lại kho", tôi đã dùng SQL thực hiện 2 thao tác sau trên hệ thống:

Bước 1: Xóa lịch sử xuất kho vừa làm ở màn F430

sql
DELETE FROM STB_MaterialWarehouseInOutHist 
WHERE LotID = 'ML20260209000136' AND MaterialWarehouseInOutHistNo = '20260511000320';
Bước 2: Cập nhật lại vị trí hiện tại của Lot về kho gốc

sql
UPDATE STB_MaterialLotInfo
SET 
    MaterialWarehouseCode = 'ROH_HN_WH', 
    MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID = 'ML20260209000136';
Làm sao check được ML20260209000136 đang ở kho nào?
Bạn có thể dùng SQL để truy vấn vào bảng STB_MaterialLotInfo (xem trạng thái hiện tại) và STB_MaterialWarehouseInOutHist (xem lịch sử di chuyển). Trước khi tôi sửa, dữ liệu báo như sau:

Lot đang ở kho ROUTE_HN_WH (đã lên chuyền).
Lịch sử xuất báo: Xuất từ kho ROH_HN_WH lên chuyền VELINE-09 bởi user VES-019 vào lúc 12:07:31 trưa nay (11/05/2026).
1. Script Kiểm tra (Đọc dữ liệu)
Trước khi làm bất kỳ thao tác nào thay đổi dữ liệu, nguyên tắc bắt buộc là phải chạy lệnh SELECT để xem tình trạng hiện tại:

sql
SELECT * FROM STB_MaterialWarehouseInOutHist
WHERE LotID = 'ML20260209000136'
ORDER BY CreateDateTime DESC;
Ý nghĩa: Trích xuất toàn bộ lịch sử xuất/nhập của Lot này.
Mục đích: Để tìm ra được cái mã số MaterialWarehouseInOutHistNo = 20260511000320. Đây là ID đại diện cho cú click "Xuất kho lên chuyền" (F430) mà chị C vừa thao tác sai lúc 12:07 trưa nay. Nếu không có ID này, ta không thể xóa chính xác được.
2. Script Xử lý (Revert / Rollback)
Sau khi đã xác định được ID lịch sử xuất sai và kho gốc cần trả về, kịch bản sửa lỗi sẽ như sau:

sql
BEGIN TRAN;
Ý nghĩa: Bắt đầu một Transaction (Phiên giao dịch).
Mục đích an toàn: Giúp khóa (lock) dữ liệu tạm thời. Nếu trong lúc chạy có 1 câu lệnh bị lỗi, dữ liệu sẽ tự động hoàn tác (ROLLBACK) để không bị tình trạng "xóa được lịch sử nhưng quên chưa đổi kho", làm hỏng database.
sql
DELETE FROM STB_MaterialWarehouseInOutHist 
WHERE LotID = 'ML20260209000136' 
  AND MaterialWarehouseInOutHistNo = '20260511000320';
Ý nghĩa: Xóa đi vệt lưu vết (log) giao dịch xuất kho tại F430.
Mục đích: Dọn dẹp chứng cứ xuất sai. Hệ thống sẽ coi như hành động xuất kho vào lúc 12:07 trưa nay chưa từng xảy ra.
sql
UPDATE STB_MaterialLotInfo
SET 
    MaterialWarehouseCode = 'ROH_HN_WH', 
    MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID = 'ML20260209000136';
Ý nghĩa: Chỉnh sửa thông tin thực tế của cuộn nguyên liệu (LotID).
Mục đích: Kéo cuộn nguyên liệu từ kho ảo trên chuyền (ROUTE_HN_WH) quay trở về lại kho vật lý ban đầu (ROH_HN_WH). Thao tác này giúp cuộn nguyên liệu hiển thị lại trên các màn hình quản lý kho (F721, F330) của thủ kho.
sql
COMMIT TRAN;
Ý nghĩa: Ghi nhận thay đổi vĩnh viễn vào hệ thống Database.
Mục đích: Xác nhận 2 thao lệnh DELETE và UPDATE ở trên là chính xác và chính thức áp dụng nó lên Production.
Tóm lại: Script đã thực hiện xóa dấu vết xuất sai và chuyển dời vị trí vật tư về lại chỗ cũ 1 cách an toàn.
SELECT OBJECT_NAME(id) AS SP_Name, text
FROM syscomments
WHERE text LIKE '%Sanmina%' 
  AND text LIKE '%Label%'
ORDER BY SP_Name;
check dựa vào im tem cho nhà sx abc thì dùng sp nào chẳng hạn
SELECT OBJECT_NAME(id) AS SP_Name
FROM syscomments
WHERE text LIKE '%Sanmina%'
GROUP BY OBJECT_NAME(id)
SELECT 
    LabelType, 
    FormatName, 
    LabelRemark,
    -- Nếu cột DataSourceViewName trống, hãy nhìn vào các cột lân cận
    DataSourceViewName,
    CreateUserID,
    ChangeDateTime
FROM SmartFramework.dbo.STB_LabelInfo
WHERE LabelType = 'SanminaIndiaLabel_ver2' 
   OR FormatName = 'SanminaIndiaLabel_ver2'
Phân tích nguyên nhân lỗi "Gộp box tùy chỉnh" trên màn hình HN523
IMPORTANT

Hiện tượng: Khi nhấn nút "Gộp box tùy chỉnh" cho mã Lot SP260511-004, hệ thống báo lỗi tiếng Hàn: "Bạn chưa nhập kết quả sản xuất cho công đoạn này", mặc dù thực tế công nhân đã làm xong.

Bước 1: Xác định "Cầu nối" dữ liệu
Dựa trên ảnh chụp màn hình, tôi xác định được tên kỹ thuật của bảng dữ liệu (Grid) là ProdPackingForBarcode. Tôi dùng từ khóa này để truy quét trong toàn bộ Database và tìm ra Stored Procedure (SP) chịu trách nhiệm đổ dữ liệu cho màn hình này:

SP tìm được: usp_Vietnam_GetProdPackingForBarcode_VVT
Bước 2: "Mổ xẻ" logic của Stored Procedure
Khi đọc mã nguồn của SP trên, tôi phát hiện ra cách hệ thống tính toán con số OutputQty (Sản lượng đầu ra) để hiện lên màn hình:

Hệ thống thực hiện một lệnh JOIN (kết nối) giữa mã Lot với bảng Quy trình sản xuất (Routing).
Điều kiện bắt buộc là: Chỉ lấy sản lượng từ công đoạn nào được đánh dấu là IsOutputRoute = 1 (Công đoạn đầu ra).
Bước 3: Đối soát dữ liệu thực tế
Tôi thực hiện kiểm tra song song hai bảng dữ liệu của mã Lot SP260511-004:

Bảng Lịch sử sản xuất (STB_ProdRouteHist): Kết quả cho thấy Lot này đã làm xong 10 lần, từ công đoạn VE01 đến VE10. Mỗi công đoạn đều ghi nhận 100 sản phẩm. -> Chứng tỏ công nhân không làm sai.
Bảng Cấu hình quy trình (STB_ProductionOrderRouting): Kết quả cho thấy trong 10 công đoạn từ VE01 đến VE10, không có công đoạn nào được tích chọn vào ô IsOutputRoute (tất cả đều là False).
Bước 4: Kết luận nguyên nhân gốc rễ
Hệ thống MES hoạt động theo nguyên tắc: Nếu bạn không chỉ định đâu là công đoạn cuối cùng để lấy sản lượng (Output Route), hệ thống sẽ mặc định sản lượng đầu ra là 0.

Vì OutputQty = 0, nên khi bạn nhấn "Gộp box", chương trình kiểm tra và thấy "chưa có hàng" nên đã chặn lại và phát ra cảnh báo bằng tiếng Hàn.

💡 Bài học kinh nghiệm:
Khi gặp lỗi liên quan đến sản lượng hiện lên bằng 0 hoặc không gộp được box/in được tem, hãy kiểm tra 2 thứ:

Công nhân đã quét đủ các bước chưa? (Kiểm tra STB_ProdRouteHist).
Lệnh sản xuất đó đã được cấu hình đúng Công đoạn đầu ra chưa? (Kiểm tra STB_ProductionOrderRouting).
INSERT INTO STB_ChangeMaterialCode_HN (
    oldMaterialCode, 
    IsUsed, 
    CreateDateTime, 
    CreateUserID, 
    NewMaterialCode, 
    PackingID, 
    LotID
)
VALUES (
    '2VSC820MC8XXXXVC01', 
    1, 
    getdate(),  
    'vanduc',  
    '2RSC820MC7XXXXB001', 
    'PKQN1100015', 
    'SP260511-001'
);
HN15
INSERT INTO STB_MaterialMaster (
    MaterialCode, 
    MaterialName, 
    MaterialTypeCode, 
    ProductGroupCode, 
    IsProdPlan, 
    BasicRoutingCode
)
VALUES 
('50VHV39MD12XXXVC01', N'Polymer AL-Cap', 'FERT', 'SMD', 1, 'VE_ChipRouting')
Thêm NVL
từ con số duy nhất là mã Lot VE260506-001 để ra được toàn bộ "đống" ID và phương án xử lý bên trên.

Đây là quy trình 3 bước "thám tử" mà tôi đã thực hiện để tìm ra chân tướng sự việc:

Bước 1: Tìm "Chứng minh thư" (ControlNo) của Lot
Trong hệ thống NAIS, mã Lot bạn nhìn thấy (VE260506-001) chỉ là cái tên bề ngoài (Barcode). Để lục tìm trong các bảng dữ liệu sâu hơn, ta cần tìm mã định danh nội bộ gọi là ControlNo.

Câu lệnh tra cứu:
sql
SELECT Barcode, ControlNo, PONo 
FROM STB_SetInfo 
WHERE Barcode = 'VE260506-001'
Kết quả thu được: Tôi thấy ControlNo là 20260428000408. Từ giờ, tôi sẽ dùng mã này để truy lùng mọi dấu vết.
Bước 2: Xem "Nhật ký hành trình" (Routing History)
Sử dụng ControlNo vừa tìm được, tôi kiểm tra xem Lot này đã đi qua những đâu và đang dừng ở đâu.

Câu lệnh tra cứu:
sql
SELECT ProdRouteHistNo, RouteCode, ProdQty, CreateDateTime 
FROM STB_ProdRouteHist 
WHERE ControlNo = '20260428000408' 
ORDER BY CreateDateTime ASC
Kết quả thu được: Tôi thấy danh sách từ VE01 đến VE09. Nhìn vào CreateDateTime, tôi thấy VE08 và VE09 vừa mới được quét vào lúc 16:29 và 16:31 chiều nay. Đây chính là 2 bản ghi cần xóa.
Bước 3: Truy tìm các bản ghi Lỗi (NG) liên quan
Vì bạn nói muốn "nhập lại số lượng NG", nên tôi phải tìm xem trong lúc quét VE08/VE09, OP đã nhập những lỗi gì và nó nằm ở đâu.

Câu lệnh tra cứu:
sql
SELECT DefectSummaryNo, FindRouteCode, DefectQty, CreateDateTime 
FROM STB_DefectRepairInfo 
WHERE ControlNo = '20260428000408' 
AND CreateDateTime >= '2026-05-11 16:00:00' -- Lọc các lỗi vừa nhập chiều nay
Kết quả thu được: Tôi thấy 7 dòng lỗi với các mã DefectSummaryNo khác nhau. Tổng số lượng NG này chính là nguyên nhân làm sản lượng của bạn bị giảm khi sang VE08.
Tóm tắt phương án xử lý "từ gốc":
Nếu sau này bạn gặp Lot khác, bạn chỉ cần làm đúng 3 bước này:

Tra Barcode ra ControlNo.
Tra ControlNo trong STB_ProdRouteHist để tìm các dòng ProdRouteHistNo của công đoạn muốn hủy.
Tra ControlNo trong STB_DefectRepairInfo để tìm các dòng DefectSummaryNo của các lỗi nhập sai.
Cuối cùng, gom các ID (ProdRouteHistNo và DefectSummaryNo) đó vào lệnh DELETE như tôi đã gửi ở trên là xong.

BEGIN TRANSACTION;

-- Xóa Routing bước 8, 9
DELETE FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
AND RouteCode IN ('VE08', 'VE09');

-- Xóa NG liên quan
DELETE FROM STB_DefectRepairInfo 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
AND (
    FindRouteCode IN ('VE08', 'VE09')
    OR 
    (FindRouteCode = 'VE07' AND CreateDateTime >= '2026-05-11 16:00:00')
);

-- Kiểm tra lại: Lot phải hiện ra bước cuối là VE07 với ProdQty = 5883
SELECT RouteCode, ProdQty, CreateDateTime 
FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
ORDER BY CreateDateTime ASC;

-- ROLLBACK; -- Chạy dòng này nếu muốn hủy lệnh xóa
-- COMMIT;   -- Chạy dòng này nếu thấy kết quả đã OK

tại sao lại phải thêm :  (FindRouteCode = 'VE07' AND CreateDateTime >= '2026-05-11 16:00:00')?


Câu hỏi này rất thực tế. Tôi sẽ giải thích bằng một bài toán trừ đơn giản để bạn thấy tại sao nếu thiếu dòng này, bạn sẽ không thể nhập lại số lượng NG như ý muốn:

Hãy xem con số thực tế của Lot này:
Bước 7 (VE07): Kết thúc với 5883 con.
Bước 8 (VE08): Khi bạn quét máy, bạn đã nhập 290 con lỗi (cho công đoạn 7).
Kết quả: Hệ thống làm phép tính: 5883 - 290 = 5593. Con số 5593 này chính là sản lượng bạn thấy ở bước 8.
Chuyện gì xảy ra nếu bạn CHỈ xóa bước 8 và NG của bước 8?
Bản ghi Routing bước 8 biến mất => OK.
Nhưng 290 con lỗi của bước 7 (nhập chiều nay) vẫn nằm lù lù trong máy.
Hậu quả: Khi bạn mở màn hình MES để nhập lại bước 8, hệ thống sẽ tự động trừ đi 290 con lỗi này ngay lập tức. Bạn sẽ thấy sản lượng vẫn là 5593 mà không cách nào đưa nó quay lại con số gốc 5883 để nhập lại NG mới được.
Vì vậy, ta thêm dòng đó để:
Xóa sạch số lượng 290 con lỗi mà bạn đã lỡ nhập cho bước 7 vào chiều nay.

Tại sao cần CreateDateTime >= 16:00? Để hệ thống biết rằng: "Tôi chỉ muốn xóa 290 con lỗi vừa nhập nhầm chiều nay thôi, còn những lỗi 'thật' của bước 7 đã nhập từ tuần trước (nếu có) thì phải giữ nguyên cho tôi".
Tóm lại: Thêm dòng đó là để "trả lại 290 con hàng" về cho Lot, giúp sản lượng quay về mức tối đa 5883 trước khi bạn bắt đầu nhập lại NG mới cho công đoạn 8.

màn b540 không thể tích vào check box  prodqtyfinishyn vì công đoạn đó đang sản xuất và nó sẽ auto check box khi chốt sản lượng ở màn b530
màn 530 không thể hoàn thành kết quả sản xuất khi chưa update null công đoạn trước đó để chốt lại sau đó mở ra công đoạn next
SELECT 
    blocking_session_id AS [ID Người Chặn],
    session_id AS [ID Bị Chặn],
    wait_time / 1000 AS [Thời gian đợi (s)],
    wait_type AS [Loại đợi],
    last_wait_type AS [Loại đợi cuối]
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0

usp_GetElectroMixPresentStep_vietnam 'VVQN1220001E25','kdem' và usp_ElectrodeStep_electron 2 store để kiểm tra bến điện cực CMC và két hợp đọc code electronJS nữa nhé mấy a dể fix cái CMC bên điện cực ạ @All

sao biết :VEC3R0367QG (3562) - Tương ứng mã hệ thống: ECVT30-098 hoặc tương đương. và VEC3R0367QG (3562) hiểu là gì ?
thực hiện truy vấn trực tiếp vào bảng Master Data của hệ thống (STB_ModelBasicInfo).

Trong hệ thống MES của mình, một sản phẩm thường có 2 loại mã:

ModelCode: Mã quản lý nội bộ của IT/Hệ thống (thường bắt đầu bằng ECVT...).
ModelName: Tên thương mại hoặc tên hiển thị cho người dùng (chứa thông số kỹ thuật).
Kết quả truy vấn của em cho thấy:

ModelCode: ECVT30-197 (hoặc ECVT30-098 tùy phiên bản BOM).
ModelName: HY-CAP VEC3R0367QG (3562).
=> Do đó, khi chị cần làm việc với DB hoặc viết SQL, mình phải dùng mã ECVT... thì hệ thống mới hiểu chính xác được ạ.

2. Giải mã VEC3R0367QG (3562) là gì?
Dựa trên cấu trúc đặt tên của Vinatech và dữ liệu em lọc được từ cột thông số (MBIExtText04, MBIExtText05), mã này có ý nghĩa như sau:

VEC: Viết tắt của dòng sản phẩm (thường là dòng tụ điện của Vinatech).
3R0: Ký hiệu của Điện áp 3.0V (R tương đương với dấu phẩy).
367: Ký hiệu của Điện dung 360F (Số 36 và 7 chữ số 0 phía sau đơn vị pF, quy đổi ra là 360 Farad).
QG: Có thể là mã quy định về kiểu chân hoặc tiêu chuẩn đóng gói riêng.
(3562): Đây là Mã dự án (Project Code) hoặc mã định danh riêng cho khách hàng/thị trường cụ thể mà Sale đang quản lý.
Nói cách khác, đây là con tụ 3.0V - 360F thuộc dự án 3562. Chị có thể kiểm tra lại thông tin này trên bản vẽ hoặc thông tin từ phía QC để xác nhận nhé!

Z530 (Label Info) là "Giá sách" (Thư viện)
Màn hình Z530 là nơi chị cất giữ tất cả các mẫu thiết kế (Design).

Mỗi con tem chị vẽ xong, hệ thống lưu vào bảng STB_LabelInfo.
Nó được đặt tên để quản lý, ví dụ: FormatName = 'Phoenix_Contact_V1'.
Lúc này con tem mới chỉ là một tệp thiết kế nằm trong kho, chưa biết sẽ dán cho ai.
2. STB_ModelLabelInfo là "Cuốn danh mục" (Mapping)
Đây là bảng quan trọng nhất để kết nối. Nó đóng vai trò "chỉ định":

Chị ghi vào bảng này: "Nếu sản xuất mã hàng ECVT30-197, hãy dùng mẫu tem Phoenix_Contact_V1".
Nếu không có bảng này, khi chị bấm in, hệ thống sẽ "ngơ ngác" vì không biết trong hàng nghìn mẫu thiết kế ở Z530, mẫu nào dành cho sản phẩm này.
3. Màn hình in (B790, B523...) là "Người đọc"
Khi chị mở màn hình in và quét một mã Lot:

Hệ thống hỏi: "Lot này thuộc mã hàng (ModelCode) nào?" -> Trả về ECVT30-197.
Hệ thống tra "Danh mục" (STB_ModelLabelInfo): "Mã ECVT30-197 này dùng tem gì?" -> Trả về Phoenix_Contact_V1.
Hệ thống ra "Giá sách" (Z530): "Cho tôi xin nội dung file thiết kế của Phoenix_Contact_V1 để tôi gửi ra máy in".
Tại sao mình phải làm vậy?
Tiết kiệm công sức: Chị chỉ cần thiết kế mẫu tem Phoenix 1 lần duy nhất trong Z530. Sau này nếu có thêm 10 mã hàng khác cũng bán cho Phoenix, chị chỉ cần vào bảng mapping thêm 10 dòng là xong, không phải vẽ lại tem 10 lần.
Linh hoạt: Nếu khách hàng Phoenix muốn đổi mẫu tem, chị chỉ cần vào Z530 sửa mẫu đó. Lập tức tất cả các màn hình in trên toàn nhà máy sẽ tự động cập nhật theo mà không cần sửa code phần mềm.

SELECT MarkingCode FROM STB_MaterialLotInfo WHERE LotNo = 'VE251120-002'
đi ngược từ màn hình -> về Stored Procedure -> về Bảng Master -> và cuối cùng là xem cột Audit (ChangeUserID/Date)
SELECT MarkingCode, MarkingName, Barcode, 
       CreateUserID, CreateDateTime, 
       ChangeUserID, ChangeDateTime 
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE MarkingCode = 'MK00000974'
b771
print  label option

select * from STB_ProductionOrderRouting where PONo='260506000015' order by routeindex
check công đoạn cho 1 pôn
pono
tìm thông tin của barcode này select *  from STB_SetInfo where barcode='VE260509-001' sau đó mới lấy được poNo
đây là công đoạn chuẩn cần theo
SELECT RouteCode, ProdQty, CreateDateTime FROM STB_ProdRouteHist WHERE ControlNo = '20260507000467' ORDER BY CreateDateTime
đây là công đoạn thực hiện được trong thực tế
từ barcode='VE260509-001' tìm thấy thông tin sản xuất
select  * from STB_ProdRouteHist where ControlNo='20260507000467'-> tìm được các công đoạn trong sản xuất thực tế
select * from STB_ProductionOrderRouting where PONo='260506000015' order by routeindex-> các công đoạn trong sản xuất theo hệ thống

exec usp_GetElectroMixPresentStep_vietnam 'VVQN1620001E28',''
exec   usp_Vietnam_ElectrodeMixingConfig_get 'VVQN1620001E28','','ML20260124000020','' 2 Store để fix các bước CMC điện cực và kết hợp đọc code ở phần mềm nữa nhé các anh @All .