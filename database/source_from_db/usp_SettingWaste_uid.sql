CREATE PROCEDURE [dbo].[usp_SettingWaste_uid](
    @pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null

)
AS
BEGIN

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
	DECLARE @LOAIHANG VARCHAR(50)
	DECLARE @CODENVL NVARCHAR(100)
	DECLARE @NAMESNVL NVARCHAR(100)
	DECLARE @UNIT VARCHAR(10)
	DECLARE @PRICES NUMERIC(20, 5)
	DECLARE @NORM NUMERIC(20, 5)
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
	--								Width NUMERIC(20, 5),
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
	--								Width NUMERIC(20, 5),
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
	--								Width NUMERIC(20, 5),
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
	--SElECT * FROM STB_VN_B598

	--END ELSE BEGIN
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							LOAIHANG,
							CODENVL,
							NAMESNVL,
							UNIT,
							PRICES,
							NORM,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										 LOAIHANG VARCHAR(50),
	                                     CODENVL NVARCHAR(100),
	                                     NAMESNVL NVARCHAR(100),
	                                     UNIT VARCHAR(10),
	                                     PRICES NUMERIC(20, 5),
	                                     NORM NUMERIC(20, 5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							LOAIHANG,
							CODENVL,
							NAMESNVL,
							UNIT,
							PRICES,
							NORM,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										LOAIHANG VARCHAR(50),
	                                     CODENVL NVARCHAR(100),
	                                     NAMESNVL NVARCHAR(100),
	                                     UNIT VARCHAR(10),
	                                     PRICES NUMERIC(20, 5),
	                                     NORM NUMERIC(20, 5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							LOAIHANG,
							CODENVL,
							NAMESNVL,
							UNIT,
							PRICES,
							NORM,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										 LOAIHANG VARCHAR(50),
	                                     CODENVL NVARCHAR(100),
	                                     NAMESNVL NVARCHAR(100),
	                                     UNIT VARCHAR(10),
	                                     PRICES NUMERIC(20, 5),
	                                     NORM NUMERIC(20, 5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@LOAIHANG,
								@CODENVL,
								@NAMESNVL,
								@UNIT,
								@PRICES,
								@NORM,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_VN_B598 WHERE CODENVL = @CODENVL)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CODENVL)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_B598',@CODENVL OUTPUT
                    END

					INSERT INTO STB_VN_B598
						(
							LOAIHANG,
							CODENVL,
							NAMESNVL,
							UNIT,
							PRICES,
							NORM,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@LOAIHANG,
							@CODENVL,
							@NAMESNVL,
							@UNIT,
							@PRICES,
							@NORM,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_VN_B598
						SET
							LOAIHANG = ISNULL(@LOAIHANG, LOAIHANG),
							CODENVL = ISNULL(@CODENVL, CODENVL),
							NAMESNVL = ISNULL(@NAMESNVL, NAMESNVL),
							UNIT = ISNULL(@UNIT, @UNIT),
							PRICES=ISNULL(@PRICES,@PRICES),
							NORM = ISNULL(@NORM, NORM),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							CODENVL = @CODENVL AND NAMESNVL=@NAMESNVL AND LOAIHANG =@LOAIHANG

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_VN_B598
						WHERE
							CODENVL = @CODENVL AND NAMESNVL=@NAMESNVL AND LOAIHANG =@LOAIHANG

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