-- BƯỚC 1: Bắt đầu một Transaction an toàn
BEGIN TRAN;

-- BƯỚC 2: Kiểm tra lại toàn bộ dữ liệu chắc chắn sẽ bị xóa (Review trước)
SELECT 
    SI.Barcode AS [Số_Lot_Sẽ_Xoá], 
    PRH.ControlNo,
    PRH.RouteCode AS [Công_Đoạn_Bi_Gán_Sai], 
    MM.MachineName AS [Tên_Máy_Sẽ_Gỡ_Bỏ],
    PRH.ProdQty,
    PRH.ProdDateTime
FROM STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
LEFT JOIN STB_MachineMaster MM WITH (NOLOCK) ON PRH.MachineCode = MM.MachineCode
WHERE 
    SI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE '%35105%')
    AND PRH.RouteCode = 'V-23_BG' 
    AND MM.MachineName LIKE '%Winding%'
    AND PRH.ProdDateTime >= '2026-04-01'; -- Giới hạn từ đầu tháng cho an toàn

-- BƯỚC 3: Lệnh Delete thực sự chạy để xóa rác
DELETE PRH
FROM STB_ProdRouteHist PRH
INNER JOIN STB_SetInfo SI ON PRH.ControlNo = SI.ControlNo
LEFT JOIN STB_MachineMaster MM ON PRH.MachineCode = MM.MachineCode
WHERE 
    SI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE '%35105%')
    AND PRH.RouteCode = 'V-23_BG' 
    AND MM.MachineName LIKE '%Winding%'
    AND PRH.ProdDateTime >= '2026-04-01';

-- =========================================================
-- BƯỚC 4: QUYẾT ĐỊNH (Anh bôi đen 1 trong 2 dòng dưới rồi chạy F5)
-- =========================================================

-- NẾU THẤY: "Rows affected" ở lệnh DELETE khớp y xì với số dòng hiển thị ra ở lệnh SELECT 
-- => BÔI ĐEN DÒNG NÀY RỒI F5 ĐỂ CHỐT LƯU THAY ĐỔI
-- COMMIT TRAN;


-- NẾU THẤY: Báo lỗi, hoặc "Rows affected" cực kì lớn, xóa nhầm hàng loạt 
-- => BÔI ĐEN DÒNG NÀY RỒI F5 ĐỂ PHỤC HỒI LẠI TOÀN BỘ NHƯ CŨ (KHÔNG LƯU GÌ CẢ)
-- ROLLBACK TRAN;

