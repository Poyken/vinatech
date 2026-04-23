
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionGroup_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
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

    -- Declare Columns Variable
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @OldQcInspectionGroupCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @QcInspectionGroupCode VARCHAR(20)
  DECLARE @GroupInspectionPrior INT
  DECLARE @GroupReportPrior INT
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInspectionGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialQcInspectionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldQcInspectionGroupCode IS NULL THEN QcInspectionGroupCode
							    ELSE OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							MaterialCode,
							QcInspectionGroupCode,
							GroupInspectionPrior,
							GroupReportPrior,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionGroupCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionGroupCode VARCHAR(20),
										GroupInspectionPrior INT,
										GroupReportPrior INT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.QcInspectionGroupCode = SourceTable.QcInspectionGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					QcInspectionGroupCode = ISNULL(SourceTable.QcInspectionGroupCode,TargetTable.QcInspectionGroupCode),
					GroupInspectionPrior = ISNULL(SourceTable.GroupInspectionPrior,TargetTable.GroupInspectionPrior),
					GroupReportPrior = ISNULL(SourceTable.GroupReportPrior,TargetTable.GroupReportPrior),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						QcInspectionGroupCode,
						GroupInspectionPrior,
						GroupReportPrior,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.QcInspectionGroupCode,
							SourceTable.GroupInspectionPrior,
							SourceTable.GroupReportPrior,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialQcInspectionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldQcInspectionGroupCode IS NULL THEN QcInspectionGroupCode
							    ELSE OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							MaterialCode,
							QcInspectionGroupCode,
							GroupInspectionPrior,
							GroupReportPrior,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionGroupCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionGroupCode VARCHAR(20),
										GroupInspectionPrior INT,
										GroupReportPrior INT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.QcInspectionGroupCode = SourceTable.OldQcInspectionGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					QcInspectionGroupCode = ISNULL(SourceTable.QcInspectionGroupCode,TargetTable.QcInspectionGroupCode),
					GroupInspectionPrior = ISNULL(SourceTable.GroupInspectionPrior,TargetTable.GroupInspectionPrior),
					GroupReportPrior = ISNULL(SourceTable.GroupReportPrior,TargetTable.GroupReportPrior),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						QcInspectionGroupCode,
						GroupInspectionPrior,
						GroupReportPrior,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.QcInspectionGroupCode,
							SourceTable.GroupInspectionPrior,
							SourceTable.GroupReportPrior,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialQcInspectionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldQcInspectionGroupCode IS NULL THEN QcInspectionGroupCode
							    ELSE OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							MaterialCode,
							QcInspectionGroupCode,
							GroupInspectionPrior,
							GroupReportPrior,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionGroupCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionGroupCode VARCHAR(20),
										GroupInspectionPrior INT,
										GroupReportPrior INT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.QcInspectionGroupCode = SourceTable.QcInspectionGroupCode
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
									OldMaterialCode,
									OldQcInspectionGroupCode,
									MaterialCode,
									QcInspectionGroupCode,
									GroupInspectionPrior,
									GroupReportPrior,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldQcInspectionGroupCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 QcInspectionGroupCode VARCHAR(20),
											 GroupInspectionPrior INT,
											 GroupReportPrior INT,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN OldQcInspectionGroupCode IS NULL THEN QcInspectionGroupCode
										ELSE OldQcInspectionGroupCode
									END AS OldQcInspectionGroupCode,
									MaterialCode,
									QcInspectionGroupCode,
									GroupInspectionPrior,
									GroupReportPrior,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldQcInspectionGroupCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 QcInspectionGroupCode VARCHAR(20),
											 GroupInspectionPrior INT,
											 GroupReportPrior INT,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN OldQcInspectionGroupCode IS NULL THEN QcInspectionGroupCode
										ELSE OldQcInspectionGroupCode
									END AS OldQcInspectionGroupCode,
									MaterialCode,
									QcInspectionGroupCode,
									GroupInspectionPrior,
									GroupReportPrior,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldQcInspectionGroupCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 QcInspectionGroupCode VARCHAR(20),
											 GroupInspectionPrior INT,
											 GroupReportPrior INT,
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
								 @OldMaterialCode,
								 @OldQcInspectionGroupCode,
								 @MaterialCode,
								 @QcInspectionGroupCode,
								 @GroupInspectionPrior,
								 @GroupReportPrior,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInspectionGroup WHERE MaterialCode = @MaterialCode AND QcInspectionGroupCode = @QcInspectionGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcInspectionGroup',@MaterialCode OUTPUT
                    END

                    INSERT INTO STB_MaterialQcInspectionGroup
						(
						    MaterialCode,
						    QcInspectionGroupCode,
						    GroupInspectionPrior,
						    GroupReportPrior,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialCode,
						    @QcInspectionGroupCode,
						    @GroupInspectionPrior,
						    @GroupReportPrior,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialQcInspectionGroup
						SET
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    QcInspectionGroupCode =   ISNULL(@QcInspectionGroupCode,QcInspectionGroupCode),
						    GroupInspectionPrior =   ISNULL(@GroupInspectionPrior,GroupInspectionPrior),
						    GroupReportPrior =   ISNULL(@GroupReportPrior,GroupReportPrior),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    QcInspectionGroupCode = @OldQcInspectionGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialQcInspectionGroup
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    QcInspectionGroupCode = @OldQcInspectionGroupCode
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
