-- Procedure: usp_CommInspMeasureHistForPS_iud

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-08-14
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CommInspMeasureHistForPS_iud
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
  DECLARE @OldCommInspMeasureNo VARCHAR(20)
  DECLARE @CommInspMeasureNo VARCHAR(20)
  DECLARE @CommInspDocItemNo VARCHAR(20)
  DECLARE @MeasureSeq INT
  DECLARE @TextMeasure VARCHAR(50)
  DECLARE @NumericMeasure NUMERIC(20,5)
  DECLARE @MeasureResult VARCHAR(4)
  DECLARE @MeasureDateTime DATETIME
  DECLARE @MeasureUserID VARCHAR(20)
  DECLARE @ErrorField VARCHAR(10)
  DECLARE @InspWorkerCode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CommInspMeasureHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CommInspMeasureHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspMeasureNo IS NULL THEN CommInspMeasureNo
							    ELSE OldCommInspMeasureNo
							END AS OldCommInspMeasureNo,
							CommInspMeasureNo,
							CommInspDocItemNo,
							MeasureSeq,
							TextMeasure,
							NumericMeasure,
							MeasureResult,
							MeasureDateTime,
							MeasureUserID,
							ErrorField,
							InspWorkerCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCommInspMeasureNo VARCHAR(20),
										CommInspMeasureNo VARCHAR(20),
										CommInspDocItemNo VARCHAR(20),
										MeasureSeq INT,
										TextMeasure VARCHAR(50),
										NumericMeasure NUMERIC(20,5),
										MeasureResult VARCHAR(4),
										MeasureDateTime DATETIMEOFFSET,
										MeasureUserID VARCHAR(20),
										ErrorField VARCHAR(10),
										InspWorkerCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspMeasureNo = SourceTable.CommInspMeasureNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspMeasureNo = ISNULL(SourceTable.CommInspMeasureNo,TargetTable.CommInspMeasureNo),
					CommInspDocItemNo = ISNULL(SourceTable.CommInspDocItemNo,TargetTable.CommInspDocItemNo),
					MeasureSeq = ISNULL(SourceTable.MeasureSeq,TargetTable.MeasureSeq),
					TextMeasure = ISNULL(SourceTable.TextMeasure,TargetTable.TextMeasure),
					NumericMeasure = ISNULL(SourceTable.NumericMeasure,TargetTable.NumericMeasure),
					MeasureResult = ISNULL(SourceTable.MeasureResult,TargetTable.MeasureResult),
					MeasureDateTime = ISNULL(SourceTable.MeasureDateTime,TargetTable.MeasureDateTime),
					MeasureUserID = ISNULL(SourceTable.MeasureUserID,TargetTable.MeasureUserID),
					ErrorField = ISNULL(SourceTable.ErrorField,TargetTable.ErrorField),
					InspWorkerCode = ISNULL(SourceTable.InspWorkerCode,TargetTable.InspWorkerCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspMeasureNo,
						CommInspDocItemNo,
						MeasureSeq,
						TextMeasure,
						NumericMeasure,
						MeasureResult,
						MeasureDateTime,
						MeasureUserID,
						ErrorField,
						InspWorkerCode
					)
				VALUES
					(
							SourceTable.CommInspMeasureNo,
							SourceTable.CommInspDocItemNo,
							SourceTable.MeasureSeq,
							SourceTable.TextMeasure,
							SourceTable.NumericMeasure,
							SourceTable.MeasureResult,
							SourceTable.MeasureDateTime,
							SourceTable.MeasureUserID,
							SourceTable.ErrorField,
							SourceTable.InspWorkerCode
					);


			-- Process Update Table
            MERGE STB_CommInspMeasureHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspMeasureNo IS NULL THEN CommInspMeasureNo
							    ELSE OldCommInspMeasureNo
							END AS OldCommInspMeasureNo,
							CommInspMeasureNo,
							CommInspDocItemNo,
							MeasureSeq,
							TextMeasure,
							NumericMeasure,
							MeasureResult,
							MeasureDateTime,
							MeasureUserID,
							ErrorField,
							InspWorkerCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCommInspMeasureNo VARCHAR(20),
										CommInspMeasureNo VARCHAR(20),
										CommInspDocItemNo VARCHAR(20),
										MeasureSeq INT,
										TextMeasure VARCHAR(50),
										NumericMeasure NUMERIC(20,5),
										MeasureResult VARCHAR(4),
										MeasureDateTime DATETIMEOFFSET,
										MeasureUserID VARCHAR(20),
										ErrorField VARCHAR(10),
										InspWorkerCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspMeasureNo = SourceTable.OldCommInspMeasureNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspMeasureNo = ISNULL(SourceTable.CommInspMeasureNo,TargetTable.CommInspMeasureNo),
					CommInspDocItemNo = ISNULL(SourceTable.CommInspDocItemNo,TargetTable.CommInspDocItemNo),
					MeasureSeq = ISNULL(SourceTable.MeasureSeq,TargetTable.MeasureSeq),
					TextMeasure = ISNULL(SourceTable.TextMeasure,TargetTable.TextMeasure),
					NumericMeasure = ISNULL(SourceTable.NumericMeasure,TargetTable.NumericMeasure),
					MeasureResult = ISNULL(SourceTable.MeasureResult,TargetTable.MeasureResult),
					MeasureDateTime = ISNULL(SourceTable.MeasureDateTime,TargetTable.MeasureDateTime),
					MeasureUserID = ISNULL(SourceTable.MeasureUserID,TargetTable.MeasureUserID),
					ErrorField = ISNULL(SourceTable.ErrorField,TargetTable.ErrorField),
					InspWorkerCode = ISNULL(SourceTable.InspWorkerCode,TargetTable.InspWorkerCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspMeasureNo,
						CommInspDocItemNo,
						MeasureSeq,
						TextMeasure,
						NumericMeasure,
						MeasureResult,
						MeasureDateTime,
						MeasureUserID,
						ErrorField,
						InspWorkerCode
					)
				VALUES
					(
							SourceTable.CommInspMeasureNo,
							SourceTable.CommInspDocItemNo,
							SourceTable.MeasureSeq,
							SourceTable.TextMeasure,
							SourceTable.NumericMeasure,
							SourceTable.MeasureResult,
							SourceTable.MeasureDateTime,
							SourceTable.MeasureUserID,
							SourceTable.ErrorField,
							SourceTable.InspWorkerCode
					);


			-- Process Delete Table
            MERGE STB_CommInspMeasureHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspMeasureNo IS NULL THEN CommInspMeasureNo
							    ELSE OldCommInspMeasureNo
							END AS OldCommInspMeasureNo,
							CommInspMeasureNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCommInspMeasureNo VARCHAR(20),
										CommInspMeasureNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspMeasureNo = SourceTable.CommInspMeasureNo
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
									OldCommInspMeasureNo,
									CommInspMeasureNo,
									CommInspDocItemNo,
									MeasureSeq,
									TextMeasure,
									NumericMeasure,
									MeasureResult,
									MeasureDateTime,
									MeasureUserID,
									ErrorField,
									InspWorkerCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCommInspMeasureNo VARCHAR(20),
											 CommInspMeasureNo VARCHAR(20),
											 CommInspDocItemNo VARCHAR(20),
											 MeasureSeq INT,
											 TextMeasure VARCHAR(50),
											 NumericMeasure NUMERIC(20,5),
											 MeasureResult VARCHAR(4),
											 MeasureDateTime DATETIMEOFFSET,
											 MeasureUserID VARCHAR(20),
											 ErrorField VARCHAR(10),
											 InspWorkerCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspMeasureNo IS NULL THEN CommInspMeasureNo
										ELSE OldCommInspMeasureNo
									END AS OldCommInspMeasureNo,
									CommInspMeasureNo,
									CommInspDocItemNo,
									MeasureSeq,
									TextMeasure,
									NumericMeasure,
									MeasureResult,
									MeasureDateTime,
									MeasureUserID,
									ErrorField,
									InspWorkerCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCommInspMeasureNo VARCHAR(20),
											 CommInspMeasureNo VARCHAR(20),
											 CommInspDocItemNo VARCHAR(20),
											 MeasureSeq INT,
											 TextMeasure VARCHAR(50),
											 NumericMeasure NUMERIC(20,5),
											 MeasureResult VARCHAR(4),
											 MeasureDateTime DATETIMEOFFSET,
											 MeasureUserID VARCHAR(20),
											 ErrorField VARCHAR(10),
											 InspWorkerCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspMeasureNo IS NULL THEN CommInspMeasureNo
										ELSE OldCommInspMeasureNo
									END AS OldCommInspMeasureNo,
									CommInspMeasureNo,
									CommInspDocItemNo,
									MeasureSeq,
									TextMeasure,
									NumericMeasure,
									MeasureResult,
									MeasureDateTime,
									MeasureUserID,
									ErrorField,
									InspWorkerCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCommInspMeasureNo VARCHAR(20),
											 CommInspMeasureNo VARCHAR(20),
											 CommInspDocItemNo VARCHAR(20),
											 MeasureSeq INT,
											 TextMeasure VARCHAR(50),
											 NumericMeasure NUMERIC(20,5),
											 MeasureResult VARCHAR(4),
											 MeasureDateTime DATETIMEOFFSET,
											 MeasureUserID VARCHAR(20),
											 ErrorField VARCHAR(10),
											 InspWorkerCode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCommInspMeasureNo,
								 @CommInspMeasureNo,
								 @CommInspDocItemNo,
								 @MeasureSeq,
								 @TextMeasure,
								 @NumericMeasure,
								 @MeasureResult,
								 @MeasureDateTime,
								 @MeasureUserID,
								 @ErrorField,
								 @InspWorkerCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CommInspMeasureHist WHERE CommInspMeasureNo = @CommInspMeasureNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CommInspMeasureNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_CommInspMeasureHist',@CommInspMeasureNo OUTPUT
                    END

                    INSERT INTO STB_CommInspMeasureHist
						(
						    CommInspMeasureNo,
						    CommInspDocItemNo,
						    MeasureSeq,
						    TextMeasure,
						    NumericMeasure,
						    MeasureResult,
						    MeasureDateTime,
						    MeasureUserID,
						    ErrorField,
						    InspWorkerCode
						)
						VALUES
						(
						    @CommInspMeasureNo,
						    @CommInspDocItemNo,
						    @MeasureSeq,
						    @TextMeasure,
						    @NumericMeasure,
						    @MeasureResult,
						    @MeasureDateTime,
						    @MeasureUserID,
						    @ErrorField,
						    @InspWorkerCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CommInspMeasureHist
						SET
						    CommInspMeasureNo =   ISNULL(@CommInspMeasureNo,CommInspMeasureNo),
						    CommInspDocItemNo =   ISNULL(@CommInspDocItemNo,CommInspDocItemNo),
						    MeasureSeq =   ISNULL(@MeasureSeq,MeasureSeq),
						    TextMeasure =   ISNULL(@TextMeasure,TextMeasure),
						    NumericMeasure =   ISNULL(@NumericMeasure,NumericMeasure),
						    MeasureResult =   ISNULL(@MeasureResult,MeasureResult),
						    MeasureDateTime =   ISNULL(@MeasureDateTime,MeasureDateTime),
						    MeasureUserID =   ISNULL(@MeasureUserID,MeasureUserID),
						    ErrorField =   ISNULL(@ErrorField,ErrorField),
						    InspWorkerCode =   ISNULL(@InspWorkerCode,InspWorkerCode)
						WHERE
						    CommInspMeasureNo = @OldCommInspMeasureNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CommInspMeasureHist
						WHERE
						    CommInspMeasureNo = @OldCommInspMeasureNo
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

GO

