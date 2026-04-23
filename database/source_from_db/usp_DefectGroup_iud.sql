-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량유형 그룹정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectGroup_iud]
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
  DECLARE @OldDefectGroupCode VARCHAR(20)
  DECLARE @DefectGroupCode VARCHAR(20)
  DECLARE @BasicDefectGroupName NVARCHAR(50)
  DECLARE @DisplayIndex INT
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @UseGroup NVARCHAR(100)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DefectGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DefectGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectGroupCode IS NULL THEN XMLData.DefectGroupCode
							    ELSE XMLData.OldDefectGroupCode
							END AS OldDefectGroupCode,
							XMLData.DefectGroupCode,
							XMLData.BasicDefectGroupName,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ISNULL(XMLData.UseGroup,'') AS UseGroup
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectGroupCode VARCHAR(20),
										DefectGroupCode VARCHAR(20),
										BasicDefectGroupName NVARCHAR(50),
										DisplayIndex INT,
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										UseGroup NVARCHAR(100)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DefectGroupCode = SourceTable.DefectGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectGroupCode = SourceTable.DefectGroupCode,
					BasicDefectGroupName = SourceTable.BasicDefectGroupName,
					DisplayIndex = SourceTable.DisplayIndex,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					UseGroup = SourceTable.UseGroup
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectGroupCode,
						BasicDefectGroupName,
						DisplayIndex,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						UseGroup
					)
				VALUES
					(
							SourceTable.DefectGroupCode,
							SourceTable.BasicDefectGroupName,
							SourceTable.DisplayIndex,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.UseGroup
					);


			-- Process Update Table
            MERGE STB_DefectGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectGroupCode IS NULL THEN XMLData.DefectGroupCode
							    ELSE XMLData.OldDefectGroupCode
							END AS OldDefectGroupCode,
							XMLData.DefectGroupCode,
							XMLData.BasicDefectGroupName,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ISNULL(XMLData.UseGroup,'') AS UseGroup
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectGroupCode VARCHAR(20),
										DefectGroupCode VARCHAR(20),
										BasicDefectGroupName NVARCHAR(50),
										DisplayIndex INT,
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										UseGroup NVARCHAR(100)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DefectGroupCode = SourceTable.OldDefectGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectGroupCode = SourceTable.DefectGroupCode,
					BasicDefectGroupName = SourceTable.BasicDefectGroupName,
					DisplayIndex = SourceTable.DisplayIndex,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					UseGroup = SourceTable.UseGroup
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectGroupCode,
						BasicDefectGroupName,
						DisplayIndex,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						UseGroup
					)
				VALUES
					(
							SourceTable.DefectGroupCode,
							SourceTable.BasicDefectGroupName,
							SourceTable.DisplayIndex,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.UseGroup
					);


			-- Process Delete Table
            MERGE STB_DefectGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldDefectGroupCode IS NULL THEN XMLData.DefectGroupCode
							    ELSE XMLData.OldDefectGroupCode
							END AS OldDefectGroupCode,
							XMLData.DefectGroupCode,
							XMLData.BasicDefectGroupName,
							XMLData.DisplayIndex,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.UseGroup
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectGroupCode VARCHAR(20),
										DefectGroupCode VARCHAR(20),
										BasicDefectGroupName NVARCHAR(50),
										DisplayIndex INT,
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										UseGroup NVARCHAR(100)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DefectGroupCode = SourceTable.DefectGroupCode
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
									XMLData.OldDefectGroupCode,
									XMLData.DefectGroupCode,
									XMLData.BasicDefectGroupName,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.UseGroup
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectGroupCode VARCHAR(20),
											 DefectGroupCode VARCHAR(20),
											 BasicDefectGroupName NVARCHAR(50),
											 DisplayIndex INT,
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 UseGroup NVARCHAR(100)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldDefectGroupCode IS NULL THEN XMLData.DefectGroupCode
										ELSE XMLData.OldDefectGroupCode
									END AS OldDefectGroupCode,
									XMLData.DefectGroupCode,
									XMLData.BasicDefectGroupName,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.UseGroup
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectGroupCode VARCHAR(20),
											 DefectGroupCode VARCHAR(20),
											 BasicDefectGroupName NVARCHAR(50),
											 DisplayIndex INT,
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 UseGroup NVARCHAR(100)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldDefectGroupCode IS NULL THEN XMLData.DefectGroupCode
										ELSE XMLData.OldDefectGroupCode
									END AS OldDefectGroupCode,
									XMLData.DefectGroupCode,
									XMLData.BasicDefectGroupName,
									XMLData.DisplayIndex,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.UseGroup
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectGroupCode VARCHAR(20),
											 DefectGroupCode VARCHAR(20),
											 BasicDefectGroupName NVARCHAR(50),
											 DisplayIndex INT,
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 UseGroup NVARCHAR(100)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectGroupCode,
								 @DefectGroupCode,
								 @BasicDefectGroupName,
								 @DisplayIndex,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @UseGroup


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DefectGroup WHERE DefectGroupCode = @DefectGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DefectGroup', @DefectGroupCode OUTPUT
                    END

                    INSERT INTO STB_DefectGroup
						(
						    DefectGroupCode,
						    BasicDefectGroupName,
						    DisplayIndex,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    UseGroup
						)
						VALUES
						(
						    @DefectGroupCode,
						    @BasicDefectGroupName,
						    @DisplayIndex,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @UseGroup
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DefectGroup
						SET
						    DefectGroupCode =   CASE
						                WHEN @DefectGroupCode IS NOT NULL THEN @DefectGroupCode
						                ELSE DefectGroupCode
						            END,
						    BasicDefectGroupName =   CASE
						                WHEN @BasicDefectGroupName IS NOT NULL THEN @BasicDefectGroupName
						                ELSE BasicDefectGroupName
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
						    ChangeUserID = @pProcessUserID,
						    UseGroup = CASE
										WHEN @UseGroup IS NOT NULL THEN @UseGroup
										ELSE UseGroup
									END
						WHERE
						    DefectGroupCode = @OldDefectGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DefectGroup
						WHERE
						    DefectGroupCode = @DefectGroupCode
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


