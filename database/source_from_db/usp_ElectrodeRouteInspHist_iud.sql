
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-29
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ElectrodeRouteInspHist_iud
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
  DECLARE @OldElectrodeRouteInspHistNo VARCHAR(20)
  DECLARE @ElectrodeRouteInspHistNo VARCHAR(20)
  DECLARE @MeasureDate DATE
  DECLARE @MaterialName NVARCHAR(200)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @REQ_A011 NUMERIC(20,5)
  DECLARE @REQ_A021 NUMERIC(20,5)
  DECLARE @REQ_A031 NUMERIC(20,5)
  DECLARE @REQ_A012 NUMERIC(20,5)
  DECLARE @REQ_A022 NUMERIC(20,5)
  DECLARE @REQ_A032 NUMERIC(20,5)
  DECLARE @REQ_A013 NUMERIC(20,5)
  DECLARE @REQ_A023 NUMERIC(20,5)
  DECLARE @REQ_A033 NUMERIC(20,5)
  DECLARE @REQ_W01 NUMERIC(20,5)
  DECLARE @REQ_W02 NUMERIC(20,5)
  DECLARE @REQ_W03 NUMERIC(20,5)
  DECLARE @REQ_E01 BIT
  DECLARE @REQ_E02 BIT
  DECLARE @REQ_E03 BIT
  DECLARE @Remark NVARCHAR(1000)
  DECLARE @InspWorkerName NVARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @ProcessDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeRouteInspHist',
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
									OldElectrodeRouteInspHistNo,
									ElectrodeRouteInspHistNo,
									MeasureDate,
									MaterialName,
									Barcode,
									REQ_A011,
									REQ_A021,
									REQ_A031,
									REQ_A012,
									REQ_A022,
									REQ_A032,
									REQ_A013,
									REQ_A023,
									REQ_A033,
									REQ_W01,
									REQ_W02,
									REQ_W03,
									REQ_E01,
									REQ_E02,
									REQ_E03,
									Remark,
									InspWorkerName,
									CreateDateTime,
									ProcessDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeRouteInspHistNo VARCHAR(20),
											 ElectrodeRouteInspHistNo VARCHAR(20),
											 MeasureDate DATETIMEOFFSET,
											 MaterialName NVARCHAR(200),
											 Barcode VARCHAR(20),
											 REQ_A011 NUMERIC(20,5),
											 REQ_A021 NUMERIC(20,5),
											 REQ_A031 NUMERIC(20,5),
											 REQ_A012 NUMERIC(20,5),
											 REQ_A022 NUMERIC(20,5),
											 REQ_A032 NUMERIC(20,5),
											 REQ_A013 NUMERIC(20,5),
											 REQ_A023 NUMERIC(20,5),
											 REQ_A033 NUMERIC(20,5),
											 REQ_W01 NUMERIC(20,5),
											 REQ_W02 NUMERIC(20,5),
											 REQ_W03 NUMERIC(20,5),
											 REQ_E01 BIT,
											 REQ_E02 BIT,
											 REQ_E03 BIT,
											 Remark NVARCHAR(1000),
											 InspWorkerName NVARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 ProcessDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeRouteInspHistNo IS NULL THEN ElectrodeRouteInspHistNo
										ELSE OldElectrodeRouteInspHistNo
									END AS OldElectrodeRouteInspHistNo,
									ElectrodeRouteInspHistNo,
									MeasureDate,
									MaterialName,
									Barcode,
									REQ_A011,
									REQ_A021,
									REQ_A031,
									REQ_A012,
									REQ_A022,
									REQ_A032,
									REQ_A013,
									REQ_A023,
									REQ_A033,
									REQ_W01,
									REQ_W02,
									REQ_W03,
									REQ_E01,
									REQ_E02,
									REQ_E03,
									Remark,
									InspWorkerName,
									CreateDateTime,
									ProcessDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeRouteInspHistNo VARCHAR(20),
											 ElectrodeRouteInspHistNo VARCHAR(20),
											 MeasureDate DATETIMEOFFSET,
											 MaterialName NVARCHAR(200),
											 Barcode VARCHAR(20),
											 REQ_A011 NUMERIC(20,5),
											 REQ_A021 NUMERIC(20,5),
											 REQ_A031 NUMERIC(20,5),
											 REQ_A012 NUMERIC(20,5),
											 REQ_A022 NUMERIC(20,5),
											 REQ_A032 NUMERIC(20,5),
											 REQ_A013 NUMERIC(20,5),
											 REQ_A023 NUMERIC(20,5),
											 REQ_A033 NUMERIC(20,5),
											 REQ_W01 NUMERIC(20,5),
											 REQ_W02 NUMERIC(20,5),
											 REQ_W03 NUMERIC(20,5),
											 REQ_E01 BIT,
											 REQ_E02 BIT,
											 REQ_E03 BIT,
											 Remark NVARCHAR(1000),
											 InspWorkerName NVARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 ProcessDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeRouteInspHistNo IS NULL THEN ElectrodeRouteInspHistNo
										ELSE OldElectrodeRouteInspHistNo
									END AS OldElectrodeRouteInspHistNo,
									ElectrodeRouteInspHistNo,
									MeasureDate,
									MaterialName,
									Barcode,
									REQ_A011,
									REQ_A021,
									REQ_A031,
									REQ_A012,
									REQ_A022,
									REQ_A032,
									REQ_A013,
									REQ_A023,
									REQ_A033,
									REQ_W01,
									REQ_W02,
									REQ_W03,
									REQ_E01,
									REQ_E02,
									REQ_E03,
									Remark,
									InspWorkerName,
									CreateDateTime,
									ProcessDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeRouteInspHistNo VARCHAR(20),
											 ElectrodeRouteInspHistNo VARCHAR(20),
											 MeasureDate DATETIMEOFFSET,
											 MaterialName NVARCHAR(200),
											 Barcode VARCHAR(20),
											 REQ_A011 NUMERIC(20,5),
											 REQ_A021 NUMERIC(20,5),
											 REQ_A031 NUMERIC(20,5),
											 REQ_A012 NUMERIC(20,5),
											 REQ_A022 NUMERIC(20,5),
											 REQ_A032 NUMERIC(20,5),
											 REQ_A013 NUMERIC(20,5),
											 REQ_A023 NUMERIC(20,5),
											 REQ_A033 NUMERIC(20,5),
											 REQ_W01 NUMERIC(20,5),
											 REQ_W02 NUMERIC(20,5),
											 REQ_W03 NUMERIC(20,5),
											 REQ_E01 BIT,
											 REQ_E02 BIT,
											 REQ_E03 BIT,
											 Remark NVARCHAR(1000),
											 InspWorkerName NVARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 ProcessDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeRouteInspHistNo,
								 @ElectrodeRouteInspHistNo,
								 @MeasureDate,
								 @MaterialName,
								 @Barcode,
								 @REQ_A011,
								 @REQ_A021,
								 @REQ_A031,
								 @REQ_A012,
								 @REQ_A022,
								 @REQ_A032,
								 @REQ_A013,
								 @REQ_A023,
								 @REQ_A033,
								 @REQ_W01,
								 @REQ_W02,
								 @REQ_W03,
								 @REQ_E01,
								 @REQ_E02,
								 @REQ_E03,
								 @Remark,
								 @InspWorkerName,
								 @CreateDateTime,
								 @ProcessDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeRouteInspHist WHERE ElectrodeRouteInspHistNo = @ElectrodeRouteInspHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeRouteInspHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ElectrodeRouteInspHist',@ElectrodeRouteInspHistNo OUTPUT
                    END

                    INSERT INTO STB_ElectrodeRouteInspHist
						(
						    ElectrodeRouteInspHistNo,
						    MeasureDate,
						    MaterialName,
						    Barcode,
						    REQ_A011,
						    REQ_A021,
						    REQ_A031,
						    REQ_A012,
						    REQ_A022,
						    REQ_A032,
						    REQ_A013,
						    REQ_A023,
						    REQ_A033,
						    REQ_W01,
						    REQ_W02,
						    REQ_W03,
						    REQ_E01,
						    REQ_E02,
						    REQ_E03,
						    Remark,
						    InspWorkerName,
						    CreateDateTime,
						    ProcessDateTime
						)
						VALUES
						(
						    @ElectrodeRouteInspHistNo,
						    @MeasureDate,
						    @MaterialName,
						    @Barcode,
						    @REQ_A011,
						    @REQ_A021,
						    @REQ_A031,
						    @REQ_A012,
						    @REQ_A022,
						    @REQ_A032,
						    @REQ_A013,
						    @REQ_A023,
						    @REQ_A033,
						    @REQ_W01,
						    @REQ_W02,
						    @REQ_W03,
						    @REQ_E01,
						    @REQ_E02,
						    @REQ_E03,
						    @Remark,
						    @InspWorkerName,
						    GETDATE(),
						    @ProcessDateTime
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeRouteInspHist
						SET
						    ElectrodeRouteInspHistNo =   ISNULL(@ElectrodeRouteInspHistNo,ElectrodeRouteInspHistNo),
						    MeasureDate =   ISNULL(@MeasureDate,MeasureDate),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    REQ_A011 =   ISNULL(@REQ_A011,REQ_A011),
						    REQ_A021 =   ISNULL(@REQ_A021,REQ_A021),
						    REQ_A031 =   ISNULL(@REQ_A031,REQ_A031),
						    REQ_A012 =   ISNULL(@REQ_A012,REQ_A012),
						    REQ_A022 =   ISNULL(@REQ_A022,REQ_A022),
						    REQ_A032 =   ISNULL(@REQ_A032,REQ_A032),
						    REQ_A013 =   ISNULL(@REQ_A013,REQ_A013),
						    REQ_A023 =   ISNULL(@REQ_A023,REQ_A023),
						    REQ_A033 =   ISNULL(@REQ_A033,REQ_A033),
						    REQ_W01 =   ISNULL(@REQ_W01,REQ_W01),
						    REQ_W02 =   ISNULL(@REQ_W02,REQ_W02),
						    REQ_W03 =   ISNULL(@REQ_W03,REQ_W03),
						    REQ_E01 =   ISNULL(@REQ_E01,REQ_E01),
						    REQ_E02 =   ISNULL(@REQ_E02,REQ_E02),
						    REQ_E03 =   ISNULL(@REQ_E03,REQ_E03),
						    Remark =   ISNULL(@Remark,Remark),
						    InspWorkerName =   ISNULL(@InspWorkerName,InspWorkerName),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    ProcessDateTime =   ISNULL(@ProcessDateTime,ProcessDateTime)
						WHERE
						    ElectrodeRouteInspHistNo = @OldElectrodeRouteInspHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeRouteInspHist
						WHERE
						    ElectrodeRouteInspHistNo = @OldElectrodeRouteInspHistNo
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
