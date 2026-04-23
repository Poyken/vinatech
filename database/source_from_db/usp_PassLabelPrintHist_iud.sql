
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-16
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PassLabelPrintHist_iud]
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
  DECLARE @OldPassLabelPrintNo VARCHAR(20)
  DECLARE @PassLabelPrintNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @TestDate DATE
  DECLARE @ManDate DATE
  DECLARE @TestUserID VARCHAR(20)
  DECLARE @StockQty NUMERIC(20,2)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Barcode VARCHAR(100)
  DECLARE @MaterialUnit VARCHAR(10)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PassLabelPrintHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_PassLabelPrintHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPassLabelPrintNo IS NULL THEN PassLabelPrintNo
							    ELSE OldPassLabelPrintNo
							END AS OldPassLabelPrintNo,
							PassLabelPrintNo,
							MaterialCode,
							TestDate,
							ManDate,
							TestUserID,
							StockQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode,
							MaterialUnit
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldPassLabelPrintNo VARCHAR(20),
										PassLabelPrintNo VARCHAR(20),
										MaterialCode VARCHAR(20),
										TestDate DATETIMEOFFSET,
										ManDate DATETIMEOFFSET,
										TestUserID VARCHAR(20),
										StockQty NUMERIC(20,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(100),
										MaterialUnit VARCHAR(10)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PassLabelPrintNo = SourceTable.PassLabelPrintNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					PassLabelPrintNo = ISNULL(SourceTable.PassLabelPrintNo,TargetTable.PassLabelPrintNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					TestDate = ISNULL(SourceTable.TestDate,TargetTable.TestDate),
					ManDate = ISNULL(SourceTable.ManDate,TargetTable.ManDate),
					TestUserID = ISNULL(SourceTable.TestUserID,TargetTable.TestUserID),
					StockQty = ISNULL(SourceTable.StockQty,TargetTable.StockQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					MaterialUnit = ISNULL(SourceTable.MaterialUnit,TargetTable.MaterialUnit)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PassLabelPrintNo,
						MaterialCode,
						TestDate,
						ManDate,
						TestUserID,
						StockQty,
						CreateDateTime,
						CreateUserID,
						Barcode,
						MaterialUnit
					)
				VALUES
					(
							SourceTable.PassLabelPrintNo,
							SourceTable.MaterialCode,
							SourceTable.TestDate,
							SourceTable.ManDate,
							SourceTable.TestUserID,
							SourceTable.StockQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Barcode,
							SourceTable.MaterialUnit
					);


			-- Process Update Table
            MERGE STB_PassLabelPrintHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPassLabelPrintNo IS NULL THEN PassLabelPrintNo
							    ELSE OldPassLabelPrintNo
							END AS OldPassLabelPrintNo,
							PassLabelPrintNo,
							MaterialCode,
							TestDate,
							ManDate,
							TestUserID,
							StockQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode,
							MaterialUnit
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldPassLabelPrintNo VARCHAR(20),
										PassLabelPrintNo VARCHAR(20),
										MaterialCode VARCHAR(20),
										TestDate DATETIMEOFFSET,
										ManDate DATETIMEOFFSET,
										TestUserID VARCHAR(20),
										StockQty NUMERIC(20,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(100),
										MaterialUnit VARCHAR(10)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PassLabelPrintNo = SourceTable.OldPassLabelPrintNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					PassLabelPrintNo = ISNULL(SourceTable.PassLabelPrintNo,TargetTable.PassLabelPrintNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					TestDate = ISNULL(SourceTable.TestDate,TargetTable.TestDate),
					ManDate = ISNULL(SourceTable.ManDate,TargetTable.ManDate),
					TestUserID = ISNULL(SourceTable.TestUserID,TargetTable.TestUserID),
					StockQty = ISNULL(SourceTable.StockQty,TargetTable.StockQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					MaterialUnit = ISNULL(SourceTable.MaterialUnit,TargetTable.MaterialUnit)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PassLabelPrintNo,
						MaterialCode,
						TestDate,
						ManDate,
						TestUserID,
						StockQty,
						CreateDateTime,
						CreateUserID,
						Barcode,
						MaterialUnit
					)
				VALUES
					(
							SourceTable.PassLabelPrintNo,
							SourceTable.MaterialCode,
							SourceTable.TestDate,
							SourceTable.ManDate,
							SourceTable.TestUserID,
							SourceTable.StockQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Barcode,
							SourceTable.MaterialUnit
					);


			-- Process Delete Table
            MERGE STB_PassLabelPrintHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPassLabelPrintNo IS NULL THEN PassLabelPrintNo
							    ELSE OldPassLabelPrintNo
							END AS OldPassLabelPrintNo,
							PassLabelPrintNo,
							MaterialCode,
							TestDate,
							ManDate,
							TestUserID,
							StockQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode,
							MaterialUnit
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldPassLabelPrintNo VARCHAR(20),
										PassLabelPrintNo VARCHAR(20),
										MaterialCode VARCHAR(20),
										TestDate DATETIMEOFFSET,
										ManDate DATETIMEOFFSET,
										TestUserID VARCHAR(20),
										StockQty NUMERIC(20,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(100),
										MaterialUnit VARCHAR(10)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PassLabelPrintNo = SourceTable.PassLabelPrintNo
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
									OldPassLabelPrintNo,
									PassLabelPrintNo,
									MaterialCode,
									TestDate,
									ManDate,
									TestUserID,
									StockQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode,
									MaterialUnit
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPassLabelPrintNo VARCHAR(20),
											 PassLabelPrintNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 TestDate DATETIMEOFFSET,
											 ManDate DATETIMEOFFSET,
											 TestUserID VARCHAR(20),
											 StockQty NUMERIC(20,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(100),
											 MaterialUnit VARCHAR(10)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldPassLabelPrintNo IS NULL THEN PassLabelPrintNo
										ELSE OldPassLabelPrintNo
									END AS OldPassLabelPrintNo,
									PassLabelPrintNo,
									MaterialCode,
									TestDate,
									ManDate,
									TestUserID,
									StockQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode,
									MaterialUnit
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPassLabelPrintNo VARCHAR(20),
											 PassLabelPrintNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 TestDate DATETIMEOFFSET,
											 ManDate DATETIMEOFFSET,
											 TestUserID VARCHAR(20),
											 StockQty NUMERIC(20,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(100),
											 MaterialUnit VARCHAR(10)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldPassLabelPrintNo IS NULL THEN PassLabelPrintNo
										ELSE OldPassLabelPrintNo
									END AS OldPassLabelPrintNo,
									PassLabelPrintNo,
									MaterialCode,
									TestDate,
									ManDate,
									TestUserID,
									StockQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode,
									MaterialUnit
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPassLabelPrintNo VARCHAR(20),
											 PassLabelPrintNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 TestDate DATETIMEOFFSET,
											 ManDate DATETIMEOFFSET,
											 TestUserID VARCHAR(20),
											 StockQty NUMERIC(20,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(100),
											 MaterialUnit VARCHAR(10)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldPassLabelPrintNo,
								 @PassLabelPrintNo,
								 @MaterialCode,
								 @TestDate,
								 @ManDate,
								 @TestUserID,
								 @StockQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Barcode,
								 @MaterialUnit


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PassLabelPrintHist WHERE PassLabelPrintNo = @PassLabelPrintNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PassLabelPrintNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PassLabelPrintHist',@PassLabelPrintNo OUTPUT
                    END

                    INSERT INTO STB_PassLabelPrintHist
						(
						    PassLabelPrintNo,
						    MaterialCode,
						    TestDate,
						    ManDate,
						    TestUserID,
						    StockQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    Barcode,
						    MaterialUnit
						)
						VALUES
						(
						    @PassLabelPrintNo,
						    @MaterialCode,
						    @TestDate,
						    @ManDate,
						    @TestUserID,
						    @StockQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @Barcode,
						    @MaterialUnit
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PassLabelPrintHist
						SET
						    PassLabelPrintNo =   ISNULL(@PassLabelPrintNo,PassLabelPrintNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    TestDate =   ISNULL(@TestDate,TestDate),
						    ManDate =   ISNULL(@ManDate,ManDate),
						    TestUserID =   ISNULL(@TestUserID,TestUserID),
						    StockQty =   ISNULL(@StockQty,StockQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    Barcode =   ISNULL(@Barcode,Barcode),
						    MaterialUnit =   ISNULL(@MaterialUnit,MaterialUnit)
						WHERE
						    PassLabelPrintNo = @OldPassLabelPrintNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PassLabelPrintHist
						WHERE
						    PassLabelPrintNo = @OldPassLabelPrintNo
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
