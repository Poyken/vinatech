
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-05-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReportReInspectionResult_iud]
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
  DECLARE @OldDefectReportNo VARCHAR(20)
  DECLARE @OldDefectCode VARCHAR(20)
  DECLARE @DefectReportNo VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @InspectionQty INT
  DECLARE @DefectQty INT
  DECLARE @DefectRate NUMERIC(27,13)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QcDefectReportReInspectionResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_QcDefectReportReInspectionResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							DefectReportNo,
							DefectCode,
							InspectionQty,
							DefectQty,
							DefectRate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										OldDefectCode VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectCode VARCHAR(20),
										InspectionQty INT,
										DefectQty INT,
										DefectRate NUMERIC(27,13),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.DefectReportNo AND
					TargetTable.DefectCode = SourceTable.DefectCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectReportNo = ISNULL(SourceTable.DefectReportNo,TargetTable.DefectReportNo),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					InspectionQty = ISNULL(SourceTable.InspectionQty,TargetTable.InspectionQty),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectCode,
						InspectionQty,
						DefectQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectCode,
							SourceTable.InspectionQty,
							SourceTable.DefectQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_QcDefectReportReInspectionResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							DefectReportNo,
							DefectCode,
							InspectionQty,
							DefectQty,
							DefectRate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										OldDefectCode VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectCode VARCHAR(20),
										InspectionQty INT,
										DefectQty INT,
										DefectRate NUMERIC(27,13),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.OldDefectReportNo AND
					TargetTable.DefectCode = SourceTable.OldDefectCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectReportNo = ISNULL(SourceTable.DefectReportNo,TargetTable.DefectReportNo),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					InspectionQty = ISNULL(SourceTable.InspectionQty,TargetTable.InspectionQty),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectCode,
						InspectionQty,
						DefectQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectCode,
							SourceTable.InspectionQty,
							SourceTable.DefectQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_QcDefectReportReInspectionResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							DefectReportNo,
							DefectCode,
							InspectionQty,
							DefectQty,
							DefectRate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										OldDefectCode VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectCode VARCHAR(20),
										InspectionQty INT,
										DefectQty INT,
										DefectRate NUMERIC(27,13),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.DefectReportNo AND
					TargetTable.DefectCode = SourceTable.DefectCode
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
									OldDefectReportNo,
									OldDefectCode,
									DefectReportNo,
									DefectCode,
									InspectionQty,
									DefectQty,
									DefectRate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 OldDefectCode VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectCode VARCHAR(20),
											 InspectionQty INT,
											 DefectQty INT,
											 DefectRate NUMERIC(27,13),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectReportNo IS NULL THEN DefectReportNo
										ELSE OldDefectReportNo
									END AS OldDefectReportNo,
									CASE 
										WHEN OldDefectCode IS NULL THEN DefectCode
										ELSE OldDefectCode
									END AS OldDefectCode,
									DefectReportNo,
									DefectCode,
									InspectionQty,
									DefectQty,
									DefectRate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 OldDefectCode VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectCode VARCHAR(20),
											 InspectionQty INT,
											 DefectQty INT,
											 DefectRate NUMERIC(27,13),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectReportNo IS NULL THEN DefectReportNo
										ELSE OldDefectReportNo
									END AS OldDefectReportNo,
									CASE 
										WHEN OldDefectCode IS NULL THEN DefectCode
										ELSE OldDefectCode
									END AS OldDefectCode,
									DefectReportNo,
									DefectCode,
									InspectionQty,
									DefectQty,
									DefectRate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 OldDefectCode VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectCode VARCHAR(20),
											 InspectionQty INT,
											 DefectQty INT,
											 DefectRate NUMERIC(27,13),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectReportNo,
								 @OldDefectCode,
								 @DefectReportNo,
								 @DefectCode,
								 @InspectionQty,
								 @DefectQty,
								 @DefectRate,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QcDefectReportReInspectionResult WHERE DefectReportNo = @DefectReportNo AND DefectCode = @DefectCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectReportNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReportReInspectionResult',@DefectReportNo OUTPUT
                    END

                    INSERT INTO STB_QcDefectReportReInspectionResult
						(
						    DefectReportNo,
						    DefectCode,
						    InspectionQty,
						    DefectQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectCode,
						    @InspectionQty,
						    @DefectQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_QcDefectReportReInspectionResult
						SET
						    DefectReportNo =   ISNULL(@DefectReportNo,DefectReportNo),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    InspectionQty =   ISNULL(@InspectionQty,InspectionQty),
						    DefectQty =   ISNULL(@DefectQty,DefectQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    DefectReportNo = @OldDefectReportNo AND
						    DefectCode = @OldDefectCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_QcDefectReportReInspectionResult
						WHERE
						    DefectReportNo = @OldDefectReportNo AND
						    DefectCode = @OldDefectCode
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
