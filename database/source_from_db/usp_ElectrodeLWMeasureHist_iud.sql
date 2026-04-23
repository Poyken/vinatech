-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-10-20
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ElectrodeLWMeasureHist_iud
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
  DECLARE @OldElectrodeLotNumber VARCHAR(20)
  DECLARE @OldSideCode VARCHAR(1)
  DECLARE @OldMeasureTimeCode VARCHAR(10)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @SideCode VARCHAR(1)
  DECLARE @MeasureTimeCode VARCHAR(10)
  DECLARE @Seq INT
  DECLARE @MeasureValue1 NUMERIC(20,10)
  DECLARE @MeasureValue2 NUMERIC(20,10)
  DECLARE @MeasureValue3 NUMERIC(20,10)
  DECLARE @MeasureValue4 NUMERIC(20,10)
  DECLARE @MeasureValue5 NUMERIC(20,10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeLWMeasureHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeLWMeasureHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSideCode IS NULL THEN SideCode
							    ELSE OldSideCode
							END AS OldSideCode,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							SideCode,
							MeasureTimeCode,
							Seq,
							MeasureValue1,
							MeasureValue2,
							MeasureValue3,
							MeasureValue4,
							MeasureValue5,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSideCode VARCHAR(1),
										OldMeasureTimeCode VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										SideCode VARCHAR(1),
										MeasureTimeCode VARCHAR(10),
										Seq INT,
										MeasureValue1 NUMERIC(20,10),
										MeasureValue2 NUMERIC(20,10),
										MeasureValue3 NUMERIC(20,10),
										MeasureValue4 NUMERIC(20,10),
										MeasureValue5 NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.SideCode = SourceTable.SideCode AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					SideCode = ISNULL(SourceTable.SideCode,TargetTable.SideCode),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					MeasureValue1 = ISNULL(SourceTable.MeasureValue1,TargetTable.MeasureValue1),
					MeasureValue2 = ISNULL(SourceTable.MeasureValue2,TargetTable.MeasureValue2),
					MeasureValue3 = ISNULL(SourceTable.MeasureValue3,TargetTable.MeasureValue3),
					MeasureValue4 = ISNULL(SourceTable.MeasureValue4,TargetTable.MeasureValue4),
					MeasureValue5 = ISNULL(SourceTable.MeasureValue5,TargetTable.MeasureValue5),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						SideCode,
						MeasureTimeCode,
						Seq,
						MeasureValue1,
						MeasureValue2,
						MeasureValue3,
						MeasureValue4,
						MeasureValue5,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.SideCode,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.MeasureValue1,
							SourceTable.MeasureValue2,
							SourceTable.MeasureValue3,
							SourceTable.MeasureValue4,
							SourceTable.MeasureValue5,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeLWMeasureHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSideCode IS NULL THEN SideCode
							    ELSE OldSideCode
							END AS OldSideCode,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							SideCode,
							MeasureTimeCode,
							Seq,
							MeasureValue1,
							MeasureValue2,
							MeasureValue3,
							MeasureValue4,
							MeasureValue5,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSideCode VARCHAR(1),
										OldMeasureTimeCode VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										SideCode VARCHAR(1),
										MeasureTimeCode VARCHAR(10),
										Seq INT,
										MeasureValue1 NUMERIC(20,10),
										MeasureValue2 NUMERIC(20,10),
										MeasureValue3 NUMERIC(20,10),
										MeasureValue4 NUMERIC(20,10),
										MeasureValue5 NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.SideCode = SourceTable.OldSideCode AND
					TargetTable.MeasureTimeCode = SourceTable.OldMeasureTimeCode AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					SideCode = ISNULL(SourceTable.SideCode,TargetTable.SideCode),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					MeasureValue1 = ISNULL(SourceTable.MeasureValue1,TargetTable.MeasureValue1),
					MeasureValue2 = ISNULL(SourceTable.MeasureValue2,TargetTable.MeasureValue2),
					MeasureValue3 = ISNULL(SourceTable.MeasureValue3,TargetTable.MeasureValue3),
					MeasureValue4 = ISNULL(SourceTable.MeasureValue4,TargetTable.MeasureValue4),
					MeasureValue5 = ISNULL(SourceTable.MeasureValue5,TargetTable.MeasureValue5),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						SideCode,
						MeasureTimeCode,
						Seq,
						MeasureValue1,
						MeasureValue2,
						MeasureValue3,
						MeasureValue4,
						MeasureValue5,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.SideCode,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.MeasureValue1,
							SourceTable.MeasureValue2,
							SourceTable.MeasureValue3,
							SourceTable.MeasureValue4,
							SourceTable.MeasureValue5,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeLWMeasureHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSideCode IS NULL THEN SideCode
							    ELSE OldSideCode
							END AS OldSideCode,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							SideCode,
							MeasureTimeCode,
							Seq
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSideCode VARCHAR(1),
										OldMeasureTimeCode VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										SideCode VARCHAR(1),
										MeasureTimeCode VARCHAR(10),
										Seq INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.SideCode = SourceTable.SideCode AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
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
        PRINT 'Loop was removed'
    END
END
