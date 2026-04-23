-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량원인정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCauseInfo_iud]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pProcessViewName [varchar](50),
	@pXml [nvarchar](max) = null
WITH EXECUTE AS CALLER
AS
BEGIN
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

    -- Declare Columns Variable
  DECLARE @OldDefectCauseCode VARCHAR(20)
  DECLARE @DefectCauseCode VARCHAR(20)
  DECLARE @BasicDefectCauseName NVARCHAR(50)
  DECLARE @DefectCauseDesc NVARCHAR(200)
  DECLARE @DefectCauseGroupCode VARCHAR(20)
  DECLARE @DisplayIndex INT
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DefectCauseInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DefectCauseInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectCauseCode IS NULL THEN XMLData.DefectCauseCode
							    ELSE XMLData.OldDefectCauseCode
							END AS OldDefectCauseCode,
							XMLData.DefectCauseCode,
							XMLData.BasicDefectCauseName,
							XMLData.DefectCauseDesc,
							XMLData.DefectCauseGroupCode,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectCauseCode VARCHAR(20),
										DefectCauseCode VARCHAR(20),
										BasicDefectCauseName NVARCHAR(50),
										DefectCauseDesc NVARCHAR(200),
										DefectCauseGroupCode VARCHAR(20),
										DisplayIndex INT,
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DefectCauseCode = SourceTable.DefectCauseCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectCauseCode = SourceTable.DefectCauseCode,
					BasicDefectCauseName = SourceTable.BasicDefectCauseName,
					DefectCauseDesc = SourceTable.DefectCauseDesc,
					DefectCauseGroupCode = SourceTable.DefectCauseGroupCode,
					DisplayIndex = SourceTable.DisplayIndex,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectCauseCode,
						BasicDefectCauseName,
						DefectCauseDesc,
						DefectCauseGroupCode,
						DisplayIndex,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectCauseCode,
							SourceTable.BasicDefectCauseName,
							SourceTable.DefectCauseDesc,
							SourceTable.DefectCauseGroupCode,
							SourceTable.DisplayIndex,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DefectCauseInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectCauseCode IS NULL THEN XMLData.DefectCauseCode
							    ELSE XMLData.OldDefectCauseCode
							END AS OldDefectCauseCode,
							XMLData.DefectCauseCode,
							XMLData.BasicDefectCauseName,
							XMLData.DefectCauseDesc,
							XMLData.DefectCauseGroupCode,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectCauseCode VARCHAR(20),
										DefectCauseCode VARCHAR(20),
										BasicDefectCauseName NVARCHAR(50),
										DefectCauseDesc NVARCHAR(200),
										DefectCauseGroupCode VARCHAR(20),
										DisplayIndex INT,
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DefectCauseCode = SourceTable.OldDefectCauseCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectCauseCode = SourceTable.DefectCauseCode,
					BasicDefectCauseName = SourceTable.BasicDefectCauseName,
					DefectCauseDesc = SourceTable.DefectCauseDesc,
					DefectCauseGroupCode = SourceTable.DefectCauseGroupCode,
					DisplayIndex = SourceTable.DisplayIndex,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectCauseCode,
						BasicDefectCauseName,
						DefectCauseDesc,
						DefectCauseGroupCode,
						DisplayIndex,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectCauseCode,
							SourceTable.BasicDefectCauseName,
							SourceTable.DefectCauseDesc,
							SourceTable.DefectCauseGroupCode,
							SourceTable.DisplayIndex,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DefectCauseInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectCauseCode IS NULL THEN XMLData.DefectCauseCode
							    ELSE XMLData.OldDefectCauseCode
							END AS OldDefectCauseCode,
							XMLData.DefectCauseCode,
							XMLData.BasicDefectCauseName,
							XMLData.DefectCauseDesc,
							XMLData.DefectCauseGroupCode,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectCauseCode VARCHAR(20),
										DefectCauseCode VARCHAR(20),
										BasicDefectCauseName NVARCHAR(50),
										DefectCauseDesc NVARCHAR(200),
										DefectCauseGroupCode VARCHAR(20),
										DisplayIndex INT,
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DefectCauseCode = SourceTable.DefectCauseCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldDefectCauseCode,
									XMLData.DefectCauseCode,
									XMLData.BasicDefectCauseName,
									XMLData.DefectCauseDesc,
									XMLData.DefectCauseGroupCode,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectCauseCode VARCHAR(20),
											 DefectCauseCode VARCHAR(20),
											 BasicDefectCauseName NVARCHAR(50),
											 DefectCauseDesc NVARCHAR(200),
											 DefectCauseGroupCode VARCHAR(20),
											 DisplayIndex INT,
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldDefectCauseCode IS NULL THEN XMLData.DefectCauseCode
										ELSE XMLData.OldDefectCauseCode
									END AS OldDefectCauseCode,
									XMLData.DefectCauseCode,
									XMLData.BasicDefectCauseName,
									XMLData.DefectCauseDesc,
									XMLData.DefectCauseGroupCode,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectCauseCode VARCHAR(20),
											 DefectCauseCode VARCHAR(20),
											 BasicDefectCauseName NVARCHAR(50),
											 DefectCauseDesc NVARCHAR(200),
											 DefectCauseGroupCode VARCHAR(20),
											 DisplayIndex INT,
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldDefectCauseCode IS NULL THEN XMLData.DefectCauseCode
										ELSE XMLData.OldDefectCauseCode
									END AS OldDefectCauseCode,
									XMLData.DefectCauseCode,
									XMLData.BasicDefectCauseName,
									XMLData.DefectCauseDesc,
									XMLData.DefectCauseGroupCode,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectCauseCode VARCHAR(20),
											 DefectCauseCode VARCHAR(20),
											 BasicDefectCauseName NVARCHAR(50),
											 DefectCauseDesc NVARCHAR(200),
											 DefectCauseGroupCode VARCHAR(20),
											 DisplayIndex INT,
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectCauseCode,
								 @DefectCauseCode,
								 @BasicDefectCauseName,
								 @DefectCauseDesc,
								 @DefectCauseGroupCode,
								 @DisplayIndex,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DefectCauseInfo WHERE DefectCauseCode = @DefectCauseCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectCauseCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DefectCauseInfo', @DefectCauseCode OUTPUT
                    END

                    INSERT INTO STB_DefectCauseInfo
						(
						    DefectCauseCode,
						    BasicDefectCauseName,
						    DefectCauseDesc,
						    DefectCauseGroupCode,
						    DisplayIndex,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DefectCauseCode,
						    @BasicDefectCauseName,
						    @DefectCauseDesc,
						    @DefectCauseGroupCode,
						    @DisplayIndex,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DefectCauseInfo
						SET
						    DefectCauseCode =   CASE
						                WHEN @DefectCauseCode IS NOT NULL THEN @DefectCauseCode
						                ELSE DefectCauseCode
						            END,
						    BasicDefectCauseName =   CASE
						                WHEN @BasicDefectCauseName IS NOT NULL THEN @BasicDefectCauseName
						                ELSE BasicDefectCauseName
						            END,
						    DefectCauseDesc =   CASE
						                WHEN @DefectCauseDesc IS NOT NULL THEN @DefectCauseDesc
						                ELSE DefectCauseDesc
						            END,
						    DefectCauseGroupCode =   CASE
						                WHEN @DefectCauseGroupCode IS NOT NULL THEN @DefectCauseGroupCode
						                ELSE DefectCauseGroupCode
						            END,
						    DisplayIndex =   CASE
						                WHEN @DisplayIndex IS NOT NULL THEN @DisplayIndex
						                ELSE DisplayIndex
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    DefectCauseCode = @OldDefectCauseCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DefectCauseInfo
						WHERE
						    DefectCauseCode = @DefectCauseCode
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
    END
END


