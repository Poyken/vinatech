-- =============================================
-- Author: Nguyễn Hải Triều
-- Create date:2025-12-15
-- Description:	Thêm sửa xoá màn hình theo dõi lot Rework
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetInforLotReworkHaNamFactory_uid]
	-- Add the parameters for the stored procedure here
	@pProcessUserID varchar(20)= NULL,
    @pProcessLanguage varchar(20)= NULL,
    @pXml NVARCHAR(MAX) = null,
	@pProcessViewName VARCHAR(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
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

	-- Check quyền user
	IF (@pProcessUserID NOT IN ('HaiTrieu','hoangxuan','ngocanh','doanthao'))
	BEGIN
		RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1)
		RETURN;
	END

	EXEC SmartFramework.dbo.usp_GetSerialRule 
		@pTableName = 'STB_LotReworkInfo_HN',
		@pIsAutoKey = @IsAutoKey OUTPUT,
		@pIsLoopIUD = @IsLoopIUD OUTPUT,
		@pPrefixData = @PrefixString OUTPUT,
		@pSerialLen = @SerialLen OUTPUT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	BEGIN TRY
		DECLARE SourceData CURSOR LOCAL FOR  -- Thêm LOCAL để tối ưu hóa cursor
			SELECT
				'INSERT' AS IUD_FLAG,
				id,
				LotNo,
				LotNoRework,
				MaterialCode,
				ReworkQty,
				CreateUserID  -- ĐÃ SỬA: Thêm dấu phẩy (,) sau ReworkQty nếu nó bị thiếu

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
				'UPDATE' AS IUD_FLAG,
				id,
				LotNo,
				LotNoRework,
				MaterialCode,
				ReworkQty,   -- ĐÃ SỬA: THÊM DẤU PHẨY (,) BỊ THIẾU
				CreateUserID -- Đảm bảo đây là cột thứ 7

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
				'DELETE' AS IUD_FLAG,
				id,
				LotNo,
				LotNoRework,
				MaterialCode,
				ReworkQty,
				CreateUserID -- ĐÃ SỬA: Thêm dấu phẩy (,) sau ReworkQty nếu nó bị thiếu
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
			-- ĐÃ SỬA: THÊM BIẾN @CreateUserID BỊ THIẾU ĐỂ KHỚP VỚI 7 CỘT CỦA SELECT
			FETCH NEXT FROM SourceData INTO
				@IUD_FLAG,
				@ID,
				@LotNo,
				@LotNoRework,
				@MaterialCode,
				@ReworkQty,
				@CreateUserID

			IF @@FETCH_STATUS <> 0 BREAK

			IF @IUD_FLAG = 'INSERT'
			BEGIN
				IF EXISTS (SELECT 1 FROM STB_LotReworkInfo_HN WHERE LotNo = @LotNo)
				BEGIN
					RAISERROR(N'Mã LotNo này đã được thêm rồi : KeyField = %s', 16, 1, @LotNo)
					-- Đảm bảo bạn CŨNG kiểm tra LotNoRework nếu nó là key duy nhất
				END

				INSERT INTO STB_LotReworkInfo_HN
				(
					LotNo,
					LotNoRework,
					MaterialCode,
					ReworkQty,
					CreateUserID,
					CreateDateTime
				)
				VALUES
				(
					@LotNo,
					@LotNoRework,
					@MaterialCode,
					@ReworkQty,
					@ProcessUserID,
					GETDATE()
				)
			END
			ELSE IF @IUD_FLAG = 'UPDATE'
			BEGIN
				UPDATE STB_LotReworkInfo_HN
				SET
					LotNo = ISNULL(@LotNo, LotNo),
					LotNoRework = ISNULL(@LotNoRework, LotNoRework),
					MaterialCode = ISNULL(@MaterialCode, MaterialCode),
					ReworkQty = ISNULL(@ReworkQty, ReworkQty)
				WHERE ID = @ID
			END
			ELSE IF @IUD_FLAG = 'DELETE'
			BEGIN
				DELETE FROM STB_LotReworkInfo_HN
				WHERE ID = @ID
			END
		END
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		-- Thêm phần đóng cursor trong CATCH để tránh bị leak
		IF CURSOR_STATUS('local', 'SourceData') >= 0
		BEGIN
			CLOSE SourceData;
			DEALLOCATE SourceData;
		END
		EXEC sp_xml_removedocument @idoc
		RAISERROR(@ERROR_MSG, 16, 1)
	END CATCH

	-- Đóng cursor trong khối chính
	IF CURSOR_STATUS('local', 'SourceData') >= 0
	BEGIN
		CLOSE SourceData;
		DEALLOCATE SourceData;
	END
	EXEC sp_xml_removedocument @idoc
END
