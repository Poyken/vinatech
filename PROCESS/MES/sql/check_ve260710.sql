-- ======================================================
-- 1. XEM CẤU HÌNH CÔNG ĐOẠN THEO PO (MÀN HÌNH B310)
-- Bảng này quy định thứ tự chuẩn (SeqNo) từ công đoạn đầu đến cuối của PO
-- ======================================================
SELECT 
    POR.PONo,
    POR.SeqNo           AS [Thu_Tu_Cong_Doan],
    POR.RouteCode       AS [Ma_Cong_Doan],
    POR.WorkCenterCode  AS [Xuong_San_Xuat],
    POR.IsInputRoute    AS [Cong_Doan_Dau],
    POR.IsOutputRoute   AS [Cong_Doan_Cuoi],
    POR.IsRequireMachine AS [Bat_Buoc_Chon_May]
FROM STB_ProductionOrderRouting POR WITH(NOLOCK)
WHERE POR.PONo = '260708000011'
ORDER BY POR.SeqNo;

-- ======================================================
-- 2. XEM LỊCH SỬ SCAN CÁC CÔNG ĐOẠN THỰC TẾ (MÀN HÌNH B530)
-- Bảng này thể hiện Barcode đã đi qua những công đoạn nào và AftProdQty
-- ======================================================
SELECT 
    PRH.ControlNo,
    PRH.Barcode,
    PRH.RouteIndex      AS [Thu_Tu_Scan],
    PRH.RouteCode       AS [Ma_Cong_Doan_Da_Quet],
    PRH.ProdQty         AS [SL_Hoan_Thanh],
    PRH.AftProdQty      AS [SL_Cong_Doan_Sau],
    PRH.DefectQty       AS [SL_Loi],
    PRH.CreateDateTime  AS [Thoi_Gian_Quet]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
WHERE PRH.Barcode = 'VE260710-002' 
   OR PRH.ControlNo = (SELECT TOP 1 ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'VE260710-002')
ORDER BY PRH.RouteIndex;
