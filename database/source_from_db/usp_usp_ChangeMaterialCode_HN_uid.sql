-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-23
-- Description:	Thực hiện thêm sửa xoá để đổi mã nguyên vật liệu
-- =============================================
CREATE PROCEDURE [dbo].[usp_usp_ChangeMaterialCode_HN_uid]
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

    -- Insert statements for procedure here
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
	DECLARE @oldMaterialCode VARCHAR(50)
	DECLARE @NewMaterialCode VARCHAR(50)
	DECLARE @LotID VARCHAR(50)
	DECLARE @PackingID VARCHAR(50)
	DECLARE @CreateUserID VARCHAR(50)
	DECLARE @IsUsed BIT
	DECLARE @iDoc INT

	-- Check quyền user
	IF (@pProcessUserID NOT IN ('HaiTrieu','hoangxuan','ngocanh','doanthao'))
	BEGIN
		RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1)
		RETURN;
	END

	EXEC SmartFramework.dbo.usp_GetSerialRule 
		@pTableName = 'STB_ChangeMaterialCode_HN',
		@pIsAutoKey = @IsAutoKey OUTPUT,
		@pIsLoopIUD = @IsLoopIUD OUTPUT,
		@pPrefixData = @PrefixString OUTPUT,
		@pSerialLen = @SerialLen OUTPUT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	BEGIN TRY
		DECLARE SourceData CURSOR FOR
			SELECT
				'INSERT' AS IUD_FLAG,
				ID,
				oldMaterialCode,
				NewMaterialCode,
				CreateUserID,
				IsUsed,
				PackingID,
				LotID
			FROM
				OPENXML(@idoc , @InsertTableName , 2)
				WITH (
					ID bigint,
					oldMaterialCode VARCHAR(50),
					NewMaterialCode VARCHAR(50),
					CreateUserID VARCHAR(50),
					IsUsed BIT,
					PackingID VARCHAR(50),
					LotID VARCHAR(50)
				)

			UNION ALL
			SELECT
				'UPDATE' AS IUD_FLAG,
				ID,
				oldMaterialCode,
				NewMaterialCode,
				CreateUserID,
				IsUsed,
				PackingID,
				LotID
			FROM
				OPENXML(@idoc , @UpdateTableName , 2)
				WITH (
					ID bigint,
					oldMaterialCode VARCHAR(50),
					NewMaterialCode VARCHAR(50),
					CreateUserID VARCHAR(50),
					IsUsed BIT,
					PackingID VARCHAR(50),
					LotID VARCHAR(50)
				)

			UNION ALL
			SELECT
				'DELETE' AS IUD_FLAG,
				ID,
				oldMaterialCode,
				NewMaterialCode,
				CreateUserID,
				IsUsed,
				PackingID,
				LotID
			FROM
				OPENXML(@idoc , @DeleteTableName , 2)
				WITH (
					ID bigint,
					oldMaterialCode VARCHAR(50),
					NewMaterialCode VARCHAR(50),
					CreateUserID VARCHAR(50),
					IsUsed BIT,
					PackingID VARCHAR(50),
					LotID VARCHAR(50)
				)

		OPEN SourceData

		WHILE 1 = 1
		BEGIN
			FETCH NEXT FROM SourceData INTO
				@IUD_FLAG,
				@ID,
				@oldMaterialCode,
				@NewMaterialCode,
				@CreateUserID,
				@IsUsed,
				@PackingID,
				@LotID

			IF @@FETCH_STATUS <> 0 BREAK

			IF @IUD_FLAG = 'INSERT'
			BEGIN
				IF EXISTS (SELECT 1 FROM STB_ChangeMaterialCode_HN WHERE PackingID = @PackingID)
				BEGIN
					RAISERROR(N'Mã packing này đã được thêm rồi : KeyField = %s', 16, 1, @PackingID)
				END

				INSERT INTO STB_ChangeMaterialCode_HN
				(
					oldMaterialCode,
					NewMaterialCode,
					CreateUserID,
					IsUsed,
					LotID,
					PackingID
				)
				VALUES
				(
					@oldMaterialCode,
					@NewMaterialCode,
					@ProcessUserID,
					@IsUsed,
					@LotID,
					@PackingID
				)
			END
			ELSE IF @IUD_FLAG = 'UPDATE'
			BEGIN
				UPDATE STB_ChangeMaterialCode_HN
				SET
					oldMaterialCode = ISNULL(@oldMaterialCode, oldMaterialCode),
					NewMaterialCode = ISNULL(@NewMaterialCode, NewMaterialCode),
					CreateUserID = ISNULL(@CreateUserID, CreateUserID),
					IsUsed = ISNULL(@IsUsed, IsUsed),
					LotID = ISNULL(@LotID, LotID),
					PackingID = ISNULL(@PackingID, PackingID)
				WHERE ID = @ID
			END
			ELSE IF @IUD_FLAG = 'DELETE'
			BEGIN
				DELETE FROM STB_ChangeMaterialCode_HN
				WHERE ID = @ID
			END
		END
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG, 16, 1)
	END CATCH

	CLOSE SourceData;
	DEALLOCATE SourceData;
	EXEC sp_xml_removedocument @idoc
END
