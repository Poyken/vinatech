-- =============================================
-- Author:		DinhManh
-- Create date: 2024-12-24
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_WidthSlitting_uid]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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

    -- Declare Columns Variable
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @MaterialName NVARCHAR(100)
	DECLARE @CustomName NVARCHAR(100)
	DECLARE @Width NUMERIC(20, 10)
	DECLARE @MaterialUnit VARCHAR(10)
	DECLARE @IsUsed BIT        -- update 2025-01-20
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @iDoc INT

  --EXEC SmartFramework.dbo.usp_GetSerialRule 
		--	@pTableName = 'STB_WidthSlitting',
		--	@pIsAutoKey = @IsAutoKey OUTPUT,
		--	@pIsLoopIUD = @IsLoopIUD OUTPUT,
		--	@pPrefixData = @PrefixString OUTPUT,
		--	@pSerialLen = @SerialLen OUTPUT

	


	

	--IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN

		
	
	--    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	--	BEGIN TRY
			
	--		-- Process Insert Table
	--		MERGE STB_WidthSlitting AS TargetTable
	--		USING
	--			(
	--				SELECT
	--					MaterialCode,
	--					CustomName,
	--					Width,
	--					MaterialUnit,
	--					IsUsed,	       -- update 2025-01-20
	--					GETDATE() AS CreateDateTime,
	--					@pProcessUserID AS CreateUserID,
	--					GETDATE() AS ChangeDateTime,
	--					@pProcessUserID AS ChangeUserID

	--				FROM
	--					OPENXML(@idoc , @InsertTableName , 2)
	--					WITH	(
	--								MaterialCode VARCHAR(50),
	--								CustomName NVARCHAR(100),
	--								Width NUMERIC(20, 10),
	--								MaterialUnit VARCHAR(10),
	--								IsUsed BIT,        -- update 2025-01-20
	--								CreateDateTime DATETIMEOFFSET,
	--								CreateUserID VARCHAR(20),
	--								ChangeDateTime DATETIMEOFFSET,
	--								ChangeUserID VARCHAR(20)
	--							)
	--			) AS SourceTable
	--		ON
	--			(
	--				TargetTable.MaterialCode = SourceTable.MaterialCode
	--			)

	--		WHEN MATCHED THEN
	--			UPDATE SET
	--				MaterialCode = ISNULL(SourceTable.MaterialCode, TargetTable.MaterialCode),
	--				CustomName = ISNULL(SourceTable.CustomName, TargetTable.CustomName),
	--				Width = ISNULL(SourceTable.Width, TargetTable.Width),
	--				MaterialUnit = ISNULL(SourceTable.MaterialUnit, TargetTable.MaterialUnit),
	--				IsUsed = ISNULL(SourceTable.IsUsed, TargetTable.IsUsed),		-- update 2025-01-20
	--				ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
	--				ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)

				

	--		WHEN NOT MATCHED THEN
	--			INSERT
	--				(
	--					MaterialCode,
	--					CustomName,
	--					Width,
	--					MaterialUnit,
	--					IsUsed,	-- update 2025-01-20
	--					CreateDateTime,
	--					CreateUserID
	--				)
	--			VALUES
	--				(
	--					SourceTable.MaterialCode,
	--					SourceTable.CustomName,
	--					SourceTable.Width,
	--					SourceTable.MaterialUnit,
	--					SourceTable.IsUsed, 
	--					SourceTable.CreateDateTime,
	--					SourceTable.CreateUserID
	--				);



	--		-- Process Update Table
	--		MERGE STB_WidthSlitting AS TargetTable
	--		USING
	--			(
	--				SELECT
	--					MaterialCode,
	--					CustomName,
	--					Width,
	--					MaterialUnit,
	--					IsUsed,
	--					GETDATE() AS CreateDateTime,
	--					@pProcessUserID AS CreateUserID,
	--					GETDATE() AS ChangeDateTime,
	--					@pProcessUserID AS ChangeUserID

	--				FROM
	--					OPENXML(@idoc , @UpdateTableName , 2)
	--					WITH	(
	--								MaterialCode VARCHAR(50),
	--								CustomName NVARCHAR(100),
	--								Width NUMERIC(20, 10),
	--								MaterialUnit VARCHAR(10),
	--								IsUsed BIT,
	--								CreateDateTime DATETIMEOFFSET,
	--								CreateUserID VARCHAR(20),
	--								ChangeDateTime DATETIMEOFFSET,
	--								ChangeUserID VARCHAR(20)
	--							)
	--			) AS SourceTable
	--		ON
	--			(
	--				TargetTable.MaterialCode = SourceTable.MaterialCode
	--			)

	--		WHEN MATCHED THEN
	--			UPDATE SET
	--				MaterialCode = ISNULL(SourceTable.MaterialCode, TargetTable.MaterialCode),
	--				CustomName = ISNULL(SourceTable.CustomName, TargetTable.CustomName),
	--				Width = ISNULL(SourceTable.Width, TargetTable.Width),
	--				MaterialUnit = ISNULL(SourceTable.MaterialUnit, TargetTable.MaterialUnit),
	--				IsUsed = ISNULL(SourceTable.IsUsed, TargetTable.IsUsed),
	--				ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
	--				ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)

	--		WHEN NOT MATCHED THEN
	--			INSERT
	--				(
	--					MaterialCode,
	--					CustomName,
	--					Width,
	--					MaterialUnit,
	--					IsUsed,
	--					CreateDateTime,
	--					CreateUserID
	--				)
	--			VALUES
	--				(
	--					SourceTable.MaterialCode,
	--					SourceTable.CustomName,
	--					SourceTable.Width,
	--					SourceTable.MaterialUnit,
	--					SourceTable.IsUsed,
	--					SourceTable.CreateDateTime,
	--					SourceTable.CreateUserID
	--				);



	--		-- Process Delete Table
	--		MERGE STB_WidthSlitting AS TargetTable
	--		USING
	--			(
	--				SELECT
	--					MaterialCode,
	--					CustomName,
	--					Width,
	--					MaterialUnit,
	--					IsUsed,
	--					GETDATE() AS CreateDateTime,
	--					@pProcessUserID AS CreateUserID,
	--					GETDATE() AS ChangeDateTime,
	--					@pProcessUserID AS ChangeUserID

	--				FROM
	--					OPENXML(@idoc , @DeleteTableName , 2)
	--					WITH	(
	--								MaterialCode VARCHAR(50),
	--								CustomName NVARCHAR(100),
	--								Width NUMERIC(20, 10),
	--								MaterialUnit VARCHAR(10),
	--								IsUsed BIT,
	--								CreateDateTime DATETIMEOFFSET,
	--								CreateUserID VARCHAR(20),
	--								ChangeDateTime DATETIMEOFFSET,
	--								ChangeUserID VARCHAR(20)
	--							)
	--			) AS SourceTable
	--		ON
	--			(
	--				TargetTable.MaterialCode = SourceTable.MaterialCode
	--			)

	--		WHEN MATCHED THEN
	--			DELETE;
	
	--	END TRY
	--	BEGIN CATCH
	--		SET @ERROR_MSG = ERROR_MESSAGE()
	--		RAISERROR( @ERROR_MSG ,16, 1)
	--    END CATCH

	--	EXEC sp_xml_removedocument @idoc


	--END ELSE BEGIN
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							MaterialCode,
							CustomName,
							Width,
							MaterialUnit,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										MaterialCode VARCHAR(50),
										CustomName NVARCHAR(100),
										Width NUMERIC(20, 10),
										MaterialUnit VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							MaterialCode,
							CustomName,
							Width,
							MaterialUnit,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										MaterialCode VARCHAR(50),
										CustomName NVARCHAR(100),
										Width NUMERIC(20, 10),
										MaterialUnit VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							MaterialCode,
							CustomName,
							Width,
							MaterialUnit,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										MaterialCode VARCHAR(50),
										CustomName NVARCHAR(100),
										Width NUMERIC(20, 10),
										MaterialUnit VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@MaterialCode,
								@CustomName,
								@Width,
								@MaterialUnit,
								@IsUsed,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_WidthSlitting WHERE MaterialCode = @MaterialCode)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_WidthSlitting',@MaterialCode OUTPUT
                    END

					INSERT INTO STB_WidthSlitting
						(
							MaterialCode,
							CustomName,
							Width,
							MaterialUnit,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@MaterialCode,
							@CustomName,
							@Width,
							@MaterialUnit,
							@IsUsed,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_WidthSlitting
						SET
							MaterialCode = ISNULL(@MaterialCode, MaterialCode),
							CustomName = ISNULL(@CustomName, CustomName),
							Width = ISNULL(@Width, Width),
							MaterialUnit = ISNULL(@MaterialUnit, MaterialUnit),
							IsUsed = ISNULL(@IsUsed, IsUsed),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							MaterialCode = @MaterialCode

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_WidthSlitting
						WHERE
							MaterialCode = @MaterialCode

				END
			END
		END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    --END

END
