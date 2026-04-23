-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2026-04-16
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_JabilManualLabelPrintHist_iud
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
  DECLARE @OldJabilManualLabelPrintHistNo VARCHAR(20)
  DECLARE @JabilManualLabelPrintHistNo VARCHAR(20)
  DECLARE @DC VARCHAR(6)
  DECLARE @QTY VARCHAR(20)
  DECLARE @LOT VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_JabilManualLabelPrintHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldJabilManualLabelPrintHistNo,
									JabilManualLabelPrintHistNo,
									DC,
									QTY,
									LOT,
									CreateDateTime,
									CreateUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldJabilManualLabelPrintHistNo VARCHAR(20),
											 JabilManualLabelPrintHistNo VARCHAR(20),
											 DC VARCHAR(6),
											 QTY VARCHAR(20),
											 LOT VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldJabilManualLabelPrintHistNo IS NULL THEN JabilManualLabelPrintHistNo
										ELSE OldJabilManualLabelPrintHistNo
									END AS OldJabilManualLabelPrintHistNo,
									JabilManualLabelPrintHistNo,
									DC,
									QTY,
									LOT,
									CreateDateTime,
									CreateUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldJabilManualLabelPrintHistNo VARCHAR(20),
											 JabilManualLabelPrintHistNo VARCHAR(20),
											 DC VARCHAR(6),
											 QTY VARCHAR(20),
											 LOT VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldJabilManualLabelPrintHistNo IS NULL THEN JabilManualLabelPrintHistNo
										ELSE OldJabilManualLabelPrintHistNo
									END AS OldJabilManualLabelPrintHistNo,
									JabilManualLabelPrintHistNo,
									DC,
									QTY,
									LOT,
									CreateDateTime,
									CreateUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldJabilManualLabelPrintHistNo VARCHAR(20),
											 JabilManualLabelPrintHistNo VARCHAR(20),
											 DC VARCHAR(6),
											 QTY VARCHAR(20),
											 LOT VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldJabilManualLabelPrintHistNo,
								 @JabilManualLabelPrintHistNo,
								 @DC,
								 @QTY,
								 @LOT,
								 @CreateDateTime,
								 @CreateUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_JabilManualLabelPrintHist WHERE JabilManualLabelPrintHistNo = @JabilManualLabelPrintHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @JabilManualLabelPrintHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_JabilManualLabelPrintHist',@JabilManualLabelPrintHistNo OUTPUT
                    END

                    INSERT INTO STB_JabilManualLabelPrintHist
						(
						    JabilManualLabelPrintHistNo,
						    DC,
						    QTY,
						    LOT,
						    CreateDateTime,
						    CreateUserID
						)
						VALUES
						(
						    @JabilManualLabelPrintHistNo,
						    @DC,
						    @QTY,
						    @LOT,
						    GETDATE(),
						    @pProcessUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_JabilManualLabelPrintHist
						SET
						    DC =   ISNULL(@DC,DC),
						    QTY =   ISNULL(@QTY,QTY),
						    LOT =   ISNULL(@LOT,LOT),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID)
						WHERE
						    JabilManualLabelPrintHistNo = @OldJabilManualLabelPrintHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_JabilManualLabelPrintHist
						WHERE
						    JabilManualLabelPrintHistNo = @OldJabilManualLabelPrintHistNo
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
