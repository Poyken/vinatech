-- ==============================================================================
-- ROUTINE: GIAI PHONG KHOA THIET BI TREO (AUTO RELEASE ORPHAN MACHINE LOCKS)
-- Tac vu: Quet va giai phong cac thiet bi bi ket ACTIVE o ke hoach (DayPlan) cu tren Kiosk POP
-- Co che: Ho tro Che do khao sat (DryRun = 1) va Thuc thi (DryRun = 0)
-- Tham chieu: POP_KB_03 § Template 10, POP_KB_06 § 2.2, HOTFIX_LOG ID_57
-- ==============================================================================

USE VINATECH_POP;
GO

DECLARE @IsDryRun BIT = 1; -- Đổi sang 0 khi muốn thực thi thật
DECLARE @OlderThanHours INT = 12; -- Giải phóng máy nếu gán quá 12 tiếng hoặc thuộc DayPlan cũ
DECLARE @TargetLine VARCHAR(50) = NULL; -- Để NULL để quét ALL line, hoặc điền cụ thể 'VVC-10'

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. [SURVEY] Tìm danh sách máy bị kẹt
    SELECT 
        M.MAPPING_ID,
        M.DAY_PLAN_NO,
        M.LINE_CODE,
        M.ROUTE_CODE,
        M.EQUIPMENT_ID,
        M.EQUIPMENT_NAME,
        M.MAPPING_STATUS,
        M.MAPPED_AT,
        DATEDIFF(HOUR, M.MAPPED_AT, GETDATE()) AS [HoursElapsed]
    FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING M WITH(NOLOCK)
    WHERE M.MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
      AND (@TargetLine IS NULL OR M.LINE_CODE = @TargetLine)
      AND (
          LEFT(M.DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112)
          OR M.MAPPED_AT < DATEADD(HOUR, -@OlderThanHours, GETDATE())
      )
    ORDER BY M.LINE_CODE, M.MAPPED_AT;

    DECLARE @LockCount INT = @@ROWCOUNT;
    PRINT N'>> Phat hien: ' + CAST(@LockCount AS NVARCHAR(10)) + N' thiet bi dang bi khoa treo (Orphan Locks).';

    IF @LockCount > 0 AND @IsDryRun = 0
    BEGIN
        -- 2. [EXECUTE] Giải phóng thiết bị
        UPDATE M
        SET M.MAPPING_STATUS      = 'RELEASED',
            M.RELEASED_AT         = GETDATE(),
            M.RELEASE_REASON      = N'Auto-release orphan lock (Old Plan)',
            M.NO_EMP_MODIFYER     = 'auto_job',
            M.CD_COMPANY_MODIFYER = 'VINA'
        FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING M
        WHERE M.MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
          AND (@TargetLine IS NULL OR M.LINE_CODE = @TargetLine)
          AND (
              LEFT(M.DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112)
              OR M.MAPPED_AT < DATEADD(HOUR, -@OlderThanHours, GETDATE())
          );

        DECLARE @UpdatedRows INT = @@ROWCOUNT;
        PRINT N'>> Da giai phong thanh cong: ' + CAST(@UpdatedRows AS NVARCHAR(10)) + N' thiet bi.';
        
        COMMIT TRANSACTION;
        PRINT N'>> TRANSACTION COMMITTED.';
    END
    ELSE
    BEGIN
        IF @IsDryRun = 1
        BEGIN
            PRINT N'>> [DRY-RUN] Khong co du lieu nao bi thay doi. Chuyen @IsDryRun = 0 de thuc thi.';
        END
        ELSE
        BEGIN
            PRINT N'>> Khong co thiet bi nao can giai phong.';
        END
        ROLLBACK TRANSACTION;
        PRINT N'>> TRANSACTION ROLLED BACK (SAFE).';
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT N'>> LOI EXECUTION: ' + @ErrMsg;
    THROW;
END CATCH;
