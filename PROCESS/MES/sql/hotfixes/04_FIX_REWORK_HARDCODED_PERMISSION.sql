-- =============================================
-- Hotfix ID: 04_FIX_REWORK_HARDCODED_PERMISSION
-- Target Object: usp_GetInforLotReworkHaNamFactory_uid
-- Author: vanduc
-- Date: 2026-06-10
-- Description: Thay thế lọc cứng tài khoản người dùng bằng phân quyền động qua SmartFramework
--              với cơ chế Fallback an toàn để không làm gián đoạn sản xuất.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

PRINT 'Starting Hotfix: 04_FIX_REWORK_HARDCODED_PERMISSION...';

-- 1. Sửa đổi stored procedure
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetInforLotReworkHaNamFactory_uid')
BEGIN
    EXEC('
    ALTER PROCEDURE [dbo].[usp_GetInforLotReworkHaNamFactory_uid]
        @pProcessUserID varchar(20)= NULL,
        @pProcessLanguage varchar(20)= NULL,
        @pXml NVARCHAR(MAX) = null,
        @pProcessViewName VARCHAR(50)=null
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
        DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
        DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
        DECLARE @InsertTableName VARCHAR(100) = ''/DataSet/'' + @ProcessViewName + ''_INSERT''
        DECLARE @UpdateTableName VARCHAR(100) = ''/DataSet/'' + @ProcessViewName + ''_UPDATE''
        DECLARE @DeleteTableName VARCHAR(100) = ''/DataSet/'' + @ProcessViewName + ''_DELETE''
        DECLARE @ERROR_MSG NVARCHAR(MAX)
        DECLARE @IUD_FLAG VARCHAR(10)
        DECLARE @IsAutoKey BIT
        DECLARE @IsLoopIUD BIT
        DECLARE @PrefixString VARCHAR(20)
        DECLARE @SerialLen INT
        DECLARE @MaxKeyField VARCHAR(20)

        DECLARE @ID bigint
        DECLARE @LotNo VARCHAR(50)
        DECLARE @LotNoRework VARCHAR(50)
        DECLARE @MaterialCode VARCHAR(50)
        DECLARE @ReworkQty int
        DECLARE @CreateUserID VARCHAR(50)
        DECLARE @iDoc INT

        -- FIX: Loại bỏ hardcode quyền hạn bằng logic phân quyền động kết hợp Fallback an toàn
        DECLARE @HasPermission BIT = 0;
        
        -- 1. Cho phép tài khoản IT/Admin mặc định bypass
        IF @pProcessUserID IN (''vinaadmin'', ''sa'', ''vina_ea'') 
            SET @HasPermission = 1;
            
        -- 2. Cơ chế Fallback: Cho phép danh sách user cũ (để bảo toàn vận hành hiện tại)
        IF @pProcessUserID IN (''HaiTrieu'',''hoangxuan'','''',''ngocanh'',''doanthao'') 
            SET @HasPermission = 1;
            
        -- 3. Kiểm tra phân quyền động từ SmartFramework.dbo.STB_UserPermission (TCode B618 - Rework Hà Nam)
        IF EXISTS (
            SELECT 1 
              FROM SmartFramework.dbo.STB_UserPermission 
             WHERE UserID = @pProcessUserID 
               AND ScreenID = ''B618'' 
               AND Allow = 1
        ) 
            SET @HasPermission = 1;

        IF @HasPermission = 0
        BEGIN
            RAISERROR(N''Bạn không có quyền thao tác Rework, vui lòng liên hệ bộ phận EA!'', 16, 1);
            RETURN;
        END

        EXEC SmartFramework.dbo.usp_GetSerialRule 
            @pTableName = ''STB_LotReworkInfo_HN'',
            @pIsAutoKey = @IsAutoKey OUTPUT,
            @pIsLoopIUD = @IsLoopIUD OUTPUT,
            @pPrefixData = @PrefixString OUTPUT,
            @pSerialLen = @SerialLen OUTPUT

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

        BEGIN TRY
            DECLARE SourceData CURSOR LOCAL FOR 
                SELECT
                    ''INSERT'' AS IUD_FLAG,
                    id,
                    LotNo,
                    LotNoRework,
                    MaterialCode,
                    ReworkQty,
                    CreateUserID
                FROM
                    OPENXML(@idoc , @InsertTableName , 2)
                    WITH (
                        id bigint,
                        LotNo VARCHAR(50),
                        LotNoRework VARCHAR(50),
                        MaterialCode VARCHAR(50),
                        ReworkQty int,
                        CreateUserID VARCHAR(50)
                    )
                UNION ALL
                SELECT
                    ''UPDATE'' AS IUD_FLAG,
                    id,
                    LotNo,
                    LotNoRework,
                    MaterialCode,
                    ReworkQty,
                    CreateUserID
                FROM
                    OPENXML(@idoc , @UpdateTableName , 2)
                    WITH (
                        id bigint,
                        LotNo VARCHAR(50),
                        LotNoRework VARCHAR(50),
                        MaterialCode VARCHAR(50),
                        ReworkQty int,
                        CreateUserID VARCHAR(50)
                    )
                UNION ALL
                SELECT
                    ''DELETE'' AS IUD_FLAG,
                    id,
                    LotNo,
                    LotNoRework,
                    MaterialCode,
                    ReworkQty,
                    CreateUserID
                FROM
                    OPENXML(@idoc , @DeleteTableName , 2)
                    WITH (
                        id bigint,
                        LotNo VARCHAR(50),
                        LotNoRework VARCHAR(50),
                        MaterialCode VARCHAR(50),
                        ReworkQty int,
                        CreateUserID VARCHAR(50)
                    )

            OPEN SourceData

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM SourceData INTO
                    @IUD_FLAG,
                    @ID,
                    @LotNo,
                    @LotNoRework,
                    @MaterialCode,
                    @ReworkQty,
                    @CreateUserID

                IF @@FETCH_STATUS <> 0 BREAK

                IF @IUD_FLAG = ''INSERT''
                BEGIN
                    IF EXISTS (SELECT 1 FROM STB_LotReworkInfo_HN WHERE LotNo = @LotNo)
                    BEGIN
                        RAISERROR(N''Mã LotNo này đã được thêm rồi : KeyField = %s'', 16, 1, @LotNo)
                    END

                    INSERT INTO STB_LotReworkInfo_HN (
                        LotNo, LotNoRework, MaterialCode, ReworkQty, CreateUserID, CreateDateTime
                    ) VALUES (
                        @LotNo, @LotNoRework, @MaterialCode, @ReworkQty, @ProcessUserID, GETDATE()
                    )
                END
                ELSE IF @IUD_FLAG = ''UPDATE''
                BEGIN
                    UPDATE STB_LotReworkInfo_HN
                    SET
                        LotNo = ISNULL(@LotNo, LotNo),
                        LotNoRework = ISNULL(@LotNoRework, LotNoRework),
                        MaterialCode = ISNULL(@MaterialCode, MaterialCode),
                        ReworkQty = ISNULL(@ReworkQty, ReworkQty)
                    WHERE ID = @ID
                END
                ELSE IF @IUD_FLAG = ''DELETE''
                BEGIN
                    DELETE FROM STB_LotReworkInfo_HN WHERE ID = @ID
                END
            END
        END TRY
        BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
            IF CURSOR_STATUS(''local'', ''SourceData'') >= 0
            BEGIN
                CLOSE SourceData;
                DEALLOCATE SourceData;
            END
            EXEC sp_xml_removedocument @idoc
            RAISERROR(@ERROR_MSG, 16, 1)
        END CATCH

        IF CURSOR_STATUS(''local'', ''SourceData'') >= 0
        BEGIN
            CLOSE SourceData;
            DEALLOCATE SourceData;
        END
        EXEC sp_xml_removedocument @idoc
    END
    ');
    PRINT 'Procedure usp_GetInforLotReworkHaNamFactory_uid altered successfully.';
END
ELSE
BEGIN
    PRINT 'Error: Procedure usp_GetInforLotReworkHaNamFactory_uid not found!';
END

-- 2. Chạy thử nghiệm Simulation Test
-- Thiết lập dữ liệu quyền giả lập cho user 'test_rework_user'
DELETE FROM SmartFramework.dbo.STB_UserPermission WHERE UserID = 'test_rework_user' AND ScreenID = 'B618';

-- Test case 1: User 'test_rework_user' chưa có quyền -> Kỳ vọng chặn và báo lỗi
BEGIN TRY
    PRINT 'Test case 1: Expect failure due to missing permissions...';
    EXEC usp_GetInforLotReworkHaNamFactory_uid 'test_rework_user', 'vi-VN', '<DataSet/>', 'STB_LotReworkInfo_HN';
    PRINT 'Test case 1: FAILED! (Did not throw permission error)';
END TRY
BEGIN CATCH
    PRINT 'Test case 1: PASSED. Expected error caught: ' + ERROR_MESSAGE();
END CATCH;

-- Test case 2: Cấp quyền động cho user 'test_rework_user' -> Kỳ vọng chạy qua bước check quyền thành công
INSERT INTO SmartFramework.dbo.STB_UserPermission (UserID, ScreenID, FuncID, Allow, CreateDateTime)
VALUES ('test_rework_user', 'B618', 'EXECUTE', 1, GETDATE());

BEGIN TRY
    PRINT 'Test case 2: Expect permission check to pass after dynamic assignment...';
    -- Sẽ ném lỗi XML trống thay vì lỗi quyền nếu vượt qua check quyền
    EXEC usp_GetInforLotReworkHaNamFactory_uid 'test_rework_user', 'vi-VN', '<DataSet/>', 'STB_LotReworkInfo_HN';
    PRINT 'Test case 2: FAILED! (Should throw XML error, not succeed with empty XML)';
END TRY
BEGIN CATCH
    IF ERROR_MESSAGE() LIKE '%xml%' OR ERROR_MESSAGE() LIKE '%DataSet%'
    BEGIN
        PRINT 'Test case 2: PASSED. Permission check bypassed, failed on XML parser as expected.';
    END
    ELSE
    BEGIN
        PRINT 'Test case 2: FAILED. Unexpected error: ' + ERROR_MESSAGE();
    END
END CATCH;

-- Dọn dẹp dữ liệu test
DELETE FROM SmartFramework.dbo.STB_UserPermission WHERE UserID = 'test_rework_user' AND ScreenID = 'B618';

-- 3. Hủy bỏ thay đổi để an toàn
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
