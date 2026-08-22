-- ==============================================================================
-- 03_rollback_script.sql — KHÔI PHỤC DỮ LIỆU VỀ 100% NGUYÊN TRẠNG GỐC BAN ĐẦU
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Khôi phục toàn bộ STB_ProdRouteHist từ bảng snapshot gốc ban đầu
    UPDATE PRH
    SET 
        PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.JobDate        = BK.JobDate,
        PRH.ProdDateTime   = BK.ProdDateTime,
        PRH.ChangeDateTime = BK.ChangeDateTime,
        PRH.ChangeUserID   = BK.ChangeUserID,
        PRH.ShiftCode      = BK.ShiftCode,
        PRH.WorkerCode     = BK.WorkerCode,
        PRH.MachineCode    = BK.MachineCode,
        PRH.ProdQty        = BK.ProdQty
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_HY_STB_ProdRouteHist BK WITH (NOLOCK)
        ON PRH.ControlNo = BK.ControlNo AND PRH.RouteCode = BK.RouteCode
    WHERE PRH.ChangeUserID = 'ADMIN_HY_FIX';

    -- 2. Khôi phục toàn bộ STB_SavePackingTime_VVT từ bảng snapshot gốc ban đầu
    UPDATE SPT
    SET 
        SPT.PrintTime   = BK.PrintTime,
        SPT.EmpNo       = BK.EmpNo,
        SPT.EmpChange   = BK.EmpChange,
        SPT.PackQty     = BK.PackQty,
        SPT.isPrinted   = BK.isPrinted
    FROM dbo.STB_SavePackingTime_VVT SPT WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_HY_STB_SavePackingTime_VVT BK WITH (NOLOCK)
        ON SPT.id = BK.id
    WHERE SPT.id IN (SELECT id FROM dbo.BK_20260821_HY_STB_SavePackingTime_VVT);

    -- 3. Xóa cờ ChangeUserID ADMIN_HY_FIX nếu có bản ghi sót
    UPDATE PRH
    SET 
        PRH.ChangeUserID = NULL
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    WHERE PRH.ChangeUserID = 'ADMIN_HY_FIX';

    COMMIT TRANSACTION;
    PRINT 'DA KHOI PHUC 100% DU LIEU VE TRANG THAI GOC TRUOC KHI THUC HIEN CUOC TRO CHUYEN!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK: %s', 16, 1, @ErrMsg);
END CATCH;
