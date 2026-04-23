-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량원인 그룹정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCauseGroup_iud]
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
  DECLARE @OldDefectCauseGroupCode VARCHAR(20)
  DECLARE @DefectCauseGroupCode VARCHAR(20)
  DECLARE @BasicDefectCauseGroupName NVARCHAR(50)
  DECLARE @DisplayIndex INT
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DefectCauseGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DefectCauseGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectCauseGroupCode IS NULL THEN XMLData.DefectCauseGroupCode
							    ELSE XMLData.OldDefectCauseGroupCode
							END AS OldDefectCauseGroupCode,
							XMLData.DefectCauseGroupCode,
							XMLData.BasicDefectCauseGroupName,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectCauseGroupCode VARCHAR(20),
										DefectCauseGroupCode VARCHAR(20),
										BasicDefectCauseGroupName NVARCHAR(50),
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
					TargetTable.DefectCauseGroupCode = SourceTable.DefectCauseGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectCauseGroupCode = SourceTable.DefectCauseGroupCode,
					BasicDefectCauseGroupName = SourceTable.BasicDefectCauseGroupName,
					DisplayIndex = SourceTable.DisplayIndex,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectCauseGroupCode,
						BasicDefectCauseGroupName,
						DisplayIndex,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectCauseGroupCode,
							SourceTable.BasicDefectCauseGroupName,
							SourceTable.DisplayIndex,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DefectCauseGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectCauseGroupCode IS NULL THEN XMLData.DefectCauseGroupCode
							    ELSE XMLData.OldDefectCauseGroupCode
							END AS OldDefectCauseGroupCode,
							XMLData.DefectCauseGroupCode,
							XMLData.BasicDefectCauseGroupName,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectCauseGroupCode VARCHAR(20),
										DefectCauseGroupCode VARCHAR(20),
										BasicDefectCauseGroupName NVARCHAR(50),
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
					TargetTable.DefectCauseGroupCode = SourceTable.OldDefectCauseGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectCauseGroupCode = SourceTable.DefectCauseGroupCode,
					BasicDefectCauseGroupName = SourceTable.BasicDefectCauseGroupName,
					DisplayIndex = SourceTable.DisplayIndex,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectCauseGroupCode,
						BasicDefectCauseGroupName,
						DisplayIndex,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectCauseGroupCode,
							SourceTable.BasicDefectCauseGroupName,
							SourceTable.DisplayIndex,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DefectCauseGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectCauseGroupCode IS NULL THEN XMLData.DefectCauseGroupCode
							    ELSE XMLData.OldDefectCauseGroupCode
							END AS OldDefectCauseGroupCode,
							XMLData.DefectCauseGroupCode,
							XMLData.BasicDefectCauseGroupName,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectCauseGroupCode VARCHAR(20),
										DefectCauseGroupCode VARCHAR(20),
										BasicDefectCauseGroupName NVARCHAR(50),
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
					TargetTable.DefectCauseGroupCode = SourceTable.DefectCauseGroupCode
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
									XMLData.OldDefectCauseGroupCode,
									XMLData.DefectCauseGroupCode,
									XMLData.BasicDefectCauseGroupName,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectCauseGroupCode VARCHAR(20),
											 DefectCauseGroupCode VARCHAR(20),
											 BasicDefectCauseGroupName NVARCHAR(50),
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
										WHEN XMLData.OldDefectCauseGroupCode IS NULL THEN XMLData.DefectCauseGroupCode
										ELSE XMLData.OldDefectCauseGroupCode
									END AS OldDefectCauseGroupCode,
									XMLData.DefectCauseGroupCode,
									XMLData.BasicDefectCauseGroupName,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectCauseGroupCode VARCHAR(20),
											 DefectCauseGroupCode VARCHAR(20),
											 BasicDefectCauseGroupName NVARCHAR(50),
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
										WHEN XMLData.OldDefectCauseGroupCode IS NULL THEN XMLData.DefectCauseGroupCode
										ELSE XMLData.OldDefectCauseGroupCode
									END AS OldDefectCauseGroupCode,
									XMLData.DefectCauseGroupCode,
									XMLData.BasicDefectCauseGroupName,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectCauseGroupCode VARCHAR(20),
											 DefectCauseGroupCode VARCHAR(20),
											 BasicDefectCauseGroupName NVARCHAR(50),
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
								 @OldDefectCauseGroupCode,
								 @DefectCauseGroupCode,
								 @BasicDefectCauseGroupName,
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

                    IF EXISTS (SELECT 1 FROM STB_DefectCauseGroup WHERE DefectCauseGroupCode = @DefectCauseGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectCauseGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DefectCauseGroup', @DefectCauseGroupCode OUTPUT
                    END

                    INSERT INTO STB_DefectCauseGroup
						(
						    DefectCauseGroupCode,
						    BasicDefectCauseGroupName,
						    DisplayIndex,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DefectCauseGroupCode,
						    @BasicDefectCauseGroupName,
						    @DisplayIndex,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DefectCauseGroup
						SET
						    DefectCauseGroupCode =   CASE
						                WHEN @DefectCauseGroupCode IS NOT NULL THEN @DefectCauseGroupCode
						                ELSE DefectCauseGroupCode
						            END,
						    BasicDefectCauseGroupName =   CASE
						                WHEN @BasicDefectCauseGroupName IS NOT NULL THEN @BasicDefectCauseGroupName
						                ELSE BasicDefectCauseGroupName
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
						    DefectCauseGroupCode = @OldDefectCauseGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DefectCauseGroup
						WHERE
						    DefectCauseGroupCode = @DefectCauseGroupCode
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


