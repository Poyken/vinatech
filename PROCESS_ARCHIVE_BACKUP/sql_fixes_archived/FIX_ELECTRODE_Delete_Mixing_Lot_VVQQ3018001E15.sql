-- ==============================================================================
-- SQL HOTFIX: XOA ME TRON DIEN CUC THUA (YP 180 A301) - CA DEM KHONG CHAY DEN
-- Target DB: SmartFactoryV2 (dbserver.hycap.co.kr,5398)
-- Screen Reference: B470 / B552 (Electrode Mixing & Coating)
-- KB Reference: KB_05_01_QC_AND_ELECTRODE_CORE.md (§8.6)
-- Lot Target: VVQQ3018001E15 (CRFYN85L-01)
-- Date Created: 2026-08-31
-- Author: Vinatech MES Agent
-- ==============================================================================

USE SmartFactoryV2;
GO

SET NOCOUNT ON;

PRINT '======================================================================';
PRINT '  [PRE-FLIGHT CHECK] KIEM TRA DU LIEU TRUOC KHI XOA LOT: VVQQ3018001E15';
PRINT '======================================================================';

-- 1. Kiem tra so luong ban ghi hien tai
SELECT 'STB_ElectrodeMixStepInfo' AS TableName, COUNT(*) AS RecordCount 
FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) 
WHERE ElectrodeLotNumber = 'VVQQ3018001E15'
UNION ALL
SELECT 'STB_ElectrodeMixInfo', COUNT(*) 
FROM STB_ElectrodeMixInfo WITH(NOLOCK) 
WHERE ElectrodeLotNumber = 'VVQQ3018001E15'
UNION ALL
SELECT 'STB_SetInfo', COUNT(*) 
FROM STB_SetInfo WITH(NOLOCK) 
WHERE Barcode = 'VVQQ3018001E15'
UNION ALL
SELECT 'STB_ElectrodeCoatingInfo (Must be 0)', COUNT(*) 
FROM STB_ElectrodeCoatingInfo WITH(NOLOCK) 
WHERE ElectrodeLotNumber = 'VVQQ3018001E15';

-- 2. Thuc hien xoa an toan trong Transaction
BEGIN TRANSACTION;

BEGIN TRY
    -- 2.1 Backup snapshot truoc khi xoa (Phong truong hop can audit/rollback)
    IF OBJECT_ID('tempdb..#BAK_ElectrodeMixStepInfo') IS NOT NULL DROP TABLE #BAK_ElectrodeMixStepInfo;
    SELECT * INTO #BAK_ElectrodeMixStepInfo 
    FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = 'VVQQ3018001E15';

    IF OBJECT_ID('tempdb..#BAK_ElectrodeMixInfo') IS NOT NULL DROP TABLE #BAK_ElectrodeMixInfo;
    SELECT * INTO #BAK_ElectrodeMixInfo 
    FROM STB_ElectrodeMixInfo WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = 'VVQQ3018001E15';

    IF OBJECT_ID('tempdb..#BAK_SetInfo') IS NOT NULL DROP TABLE #BAK_SetInfo;
    SELECT * INTO #BAK_SetInfo 
    FROM STB_SetInfo WITH(NOLOCK) 
    WHERE Barcode = 'VVQQ3018001E15';

    PRINT '--> Snapshot backup thanh cong vao tempdb.';

    -- 2.2 Xoa du lieu buoc can tron (7 buoc D & G)
    DELETE FROM STB_ElectrodeMixStepInfo
    WHERE ElectrodeLotNumber = 'VVQQ3018001E15';
    PRINT '--> Da xoa du lieu buoc can: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dong tu STB_ElectrodeMixStepInfo.';

    -- 2.3 Xoa thong tin me tron dien cuc
    DELETE FROM STB_ElectrodeMixInfo
    WHERE ElectrodeLotNumber = 'VVQQ3018001E15';
    PRINT '--> Da xoa me tron: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dong tu STB_ElectrodeMixInfo.';

    -- 2.4 Xoa khoi tao ma Lot thung / SetInfo
    DELETE FROM STB_SetInfo
    WHERE Barcode = 'VVQQ3018001E15';
    PRINT '--> Da xoa ma Lot SetInfo: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dong tu STB_SetInfo.';

    -- 2.5 Kiem tra lai sau khi xoa (Post-flight check)
    PRINT '----------------------------------------------------------------------';
    PRINT '  [POST-FLIGHT CHECK] XAC NHAN DU LIEU SAU KHI XOA';
    PRINT '----------------------------------------------------------------------';
    
    DECLARE @RemainCount INT = 0;
    SELECT @RemainCount = 
        (SELECT COUNT(*) FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQQ3018001E15') +
        (SELECT COUNT(*) FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQQ3018001E15') +
        (SELECT COUNT(*) FROM STB_SetInfo WHERE Barcode = 'VVQQ3018001E15');

    IF @RemainCount = 0
    BEGIN
        PRINT '--> Xac nhan sach du lieu toan dien (0 record con lai).';
        COMMIT TRANSACTION;
        PRINT '==> [THANH CONG] GIAO DICH DA DUOC COMMIT VAO PRODUCTION DATABASE.';
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT '==> [CANH BAO] CON DU LIEU TON DONG (' + CAST(@RemainCount AS VARCHAR) + ' dong) -> DA ROLLBACK AN TOAN!';
    END

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    PRINT '==> [LOI] CO LOI XAY RA TRONG QUA TRINH XOA -> DA ROLLBACK TRANSACTION!';
    PRINT 'Chi tiet loi: ' + ERROR_MESSAGE();
END CATCH;
GO
