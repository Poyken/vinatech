
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-22
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MainAssemblePartWeight_iud]
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
  DECLARE @OldControlNo VARCHAR(20)
  DECLARE @OldAsmPartCode VARCHAR(50)
  DECLARE @ControlNo VARCHAR(20)
  DECLARE @AsmPartCode VARCHAR(50)
  DECLARE @AsmQty NUMERIC(20,5)
  DECLARE @AsmWorkerCode VARCHAR(20)
  DECLARE @AsmMachineCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MainAssemblePartWeight',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MainAssemblePartWeight AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldControlNo IS NULL THEN ControlNo
							    ELSE OldControlNo
							END AS OldControlNo,
							CASE
							    WHEN OldAsmPartCode IS NULL THEN AsmPartCode
							    ELSE OldAsmPartCode
							END AS OldAsmPartCode,
							ControlNo,
							AsmPartCode,
							AsmQty,
							AsmWorkerCode,
							AsmMachineCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldControlNo VARCHAR(20),
										OldAsmPartCode VARCHAR(50),
										ControlNo VARCHAR(20),
										AsmPartCode VARCHAR(50),
										AsmQty NUMERIC(20,5),
										AsmWorkerCode VARCHAR(20),
										AsmMachineCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ControlNo = SourceTable.ControlNo AND
					TargetTable.AsmPartCode = SourceTable.AsmPartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ControlNo = ISNULL(SourceTable.ControlNo,TargetTable.ControlNo),
					AsmPartCode = ISNULL(SourceTable.AsmPartCode,TargetTable.AsmPartCode),
					AsmQty = ISNULL(SourceTable.AsmQty,TargetTable.AsmQty),
					AsmWorkerCode = ISNULL(SourceTable.AsmWorkerCode,TargetTable.AsmWorkerCode),
					AsmMachineCode = ISNULL(SourceTable.AsmMachineCode,TargetTable.AsmMachineCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ControlNo,
						AsmPartCode,
						AsmQty,
						AsmWorkerCode,
						AsmMachineCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ControlNo,
							SourceTable.AsmPartCode,
							SourceTable.AsmQty,
							SourceTable.AsmWorkerCode,
							SourceTable.AsmMachineCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MainAssemblePartWeight AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldControlNo IS NULL THEN ControlNo
							    ELSE OldControlNo
							END AS OldControlNo,
							CASE
							    WHEN OldAsmPartCode IS NULL THEN AsmPartCode
							    ELSE OldAsmPartCode
							END AS OldAsmPartCode,
							ControlNo,
							AsmPartCode,
							AsmQty,
							AsmWorkerCode,
							AsmMachineCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldControlNo VARCHAR(20),
										OldAsmPartCode VARCHAR(50),
										ControlNo VARCHAR(20),
										AsmPartCode VARCHAR(50),
										AsmQty NUMERIC(20,5),
										AsmWorkerCode VARCHAR(20),
										AsmMachineCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ControlNo = SourceTable.OldControlNo AND
					TargetTable.AsmPartCode = SourceTable.OldAsmPartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ControlNo = ISNULL(SourceTable.ControlNo,TargetTable.ControlNo),
					AsmPartCode = ISNULL(SourceTable.AsmPartCode,TargetTable.AsmPartCode),
					AsmQty = ISNULL(SourceTable.AsmQty,TargetTable.AsmQty),
					AsmWorkerCode = ISNULL(SourceTable.AsmWorkerCode,TargetTable.AsmWorkerCode),
					AsmMachineCode = ISNULL(SourceTable.AsmMachineCode,TargetTable.AsmMachineCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ControlNo,
						AsmPartCode,
						AsmQty,
						AsmWorkerCode,
						AsmMachineCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ControlNo,
							SourceTable.AsmPartCode,
							SourceTable.AsmQty,
							SourceTable.AsmWorkerCode,
							SourceTable.AsmMachineCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MainAssemblePartWeight AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldControlNo IS NULL THEN ControlNo
							    ELSE OldControlNo
							END AS OldControlNo,
							CASE
							    WHEN OldAsmPartCode IS NULL THEN AsmPartCode
							    ELSE OldAsmPartCode
							END AS OldAsmPartCode,
							ControlNo,
							AsmPartCode,
							AsmQty,
							AsmWorkerCode,
							AsmMachineCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldControlNo VARCHAR(20),
										OldAsmPartCode VARCHAR(50),
										ControlNo VARCHAR(20),
										AsmPartCode VARCHAR(50),
										AsmQty NUMERIC(20,5),
										AsmWorkerCode VARCHAR(20),
										AsmMachineCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ControlNo = SourceTable.ControlNo AND
					TargetTable.AsmPartCode = SourceTable.AsmPartCode
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
									OldControlNo,
									OldAsmPartCode,
									ControlNo,
									AsmPartCode,
									AsmQty,
									AsmWorkerCode,
									AsmMachineCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 OldAsmPartCode VARCHAR(50),
											 ControlNo VARCHAR(20),
											 AsmPartCode VARCHAR(50),
											 AsmQty NUMERIC(20,5),
											 AsmWorkerCode VARCHAR(20),
											 AsmMachineCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldControlNo IS NULL THEN ControlNo
										ELSE OldControlNo
									END AS OldControlNo,
									CASE 
										WHEN OldAsmPartCode IS NULL THEN AsmPartCode
										ELSE OldAsmPartCode
									END AS OldAsmPartCode,
									ControlNo,
									AsmPartCode,
									AsmQty,
									AsmWorkerCode,
									AsmMachineCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 OldAsmPartCode VARCHAR(50),
											 ControlNo VARCHAR(20),
											 AsmPartCode VARCHAR(50),
											 AsmQty NUMERIC(20,5),
											 AsmWorkerCode VARCHAR(20),
											 AsmMachineCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldControlNo IS NULL THEN ControlNo
										ELSE OldControlNo
									END AS OldControlNo,
									CASE 
										WHEN OldAsmPartCode IS NULL THEN AsmPartCode
										ELSE OldAsmPartCode
									END AS OldAsmPartCode,
									ControlNo,
									AsmPartCode,
									AsmQty,
									AsmWorkerCode,
									AsmMachineCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 OldAsmPartCode VARCHAR(50),
											 ControlNo VARCHAR(20),
											 AsmPartCode VARCHAR(50),
											 AsmQty NUMERIC(20,5),
											 AsmWorkerCode VARCHAR(20),
											 AsmMachineCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldControlNo,
								 @OldAsmPartCode,
								 @ControlNo,
								 @AsmPartCode,
								 @AsmQty,
								 @AsmWorkerCode,
								 @AsmMachineCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MainAssemblePartWeight WHERE ControlNo = @ControlNo AND AsmPartCode = @AsmPartCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ControlNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MainAssemblePartWeight',@ControlNo OUTPUT
                    END

                    INSERT INTO STB_MainAssemblePartWeight
						(
						    ControlNo,
						    AsmPartCode,
						    AsmQty,
						    AsmWorkerCode,
						    AsmMachineCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ControlNo,
						    @AsmPartCode,
						    @AsmQty,
						    @AsmWorkerCode,
						    @AsmMachineCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MainAssemblePartWeight
						SET
						    ControlNo =   ISNULL(@ControlNo,ControlNo),
						    AsmPartCode =   ISNULL(@AsmPartCode,AsmPartCode),
						    AsmQty =   ISNULL(@AsmQty,AsmQty),
						    AsmWorkerCode =   ISNULL(@AsmWorkerCode,AsmWorkerCode),
						    AsmMachineCode =   ISNULL(@AsmMachineCode,AsmMachineCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ControlNo = @OldControlNo AND
						    AsmPartCode = @OldAsmPartCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MainAssemblePartWeight
						WHERE
						    ControlNo = @OldControlNo AND
						    AsmPartCode = @OldAsmPartCode
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
