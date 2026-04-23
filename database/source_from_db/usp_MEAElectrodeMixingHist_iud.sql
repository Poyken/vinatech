
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-11-07
-- Browsable : true
-- Group : MEA
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_MEAElectrodeMixingHist_iud
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
  DECLARE @OldBarcode VARCHAR(20)
  DECLARE @OldMEAMixingStepCode VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @MEAMixingStepCode VARCHAR(20)
  DECLARE @StartDateTime DATETIME
  DECLARE @EndDateTime DATETIME
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MEAElectrodeMixingHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MEAElectrodeMixingHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							CASE
							    WHEN OldMEAMixingStepCode IS NULL THEN MEAMixingStepCode
							    ELSE OldMEAMixingStepCode
							END AS OldMEAMixingStepCode,
							Barcode,
							MEAMixingStepCode,
							StartDateTime,
							EndDateTime,
							MachineCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										OldMEAMixingStepCode VARCHAR(20),
										Barcode VARCHAR(20),
										MEAMixingStepCode VARCHAR(20),
										StartDateTime DATETIMEOFFSET,
										EndDateTime DATETIMEOFFSET,
										MachineCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.Barcode AND
					TargetTable.MEAMixingStepCode = SourceTable.MEAMixingStepCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					MEAMixingStepCode = ISNULL(SourceTable.MEAMixingStepCode,TargetTable.MEAMixingStepCode),
					StartDateTime = ISNULL(SourceTable.StartDateTime,TargetTable.StartDateTime),
					EndDateTime = ISNULL(SourceTable.EndDateTime,TargetTable.EndDateTime),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						MEAMixingStepCode,
						StartDateTime,
						EndDateTime,
						MachineCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.MEAMixingStepCode,
							SourceTable.StartDateTime,
							SourceTable.EndDateTime,
							SourceTable.MachineCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MEAElectrodeMixingHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							CASE
							    WHEN OldMEAMixingStepCode IS NULL THEN MEAMixingStepCode
							    ELSE OldMEAMixingStepCode
							END AS OldMEAMixingStepCode,
							Barcode,
							MEAMixingStepCode,
							StartDateTime,
							EndDateTime,
							MachineCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										OldMEAMixingStepCode VARCHAR(20),
										Barcode VARCHAR(20),
										MEAMixingStepCode VARCHAR(20),
										StartDateTime DATETIMEOFFSET,
										EndDateTime DATETIMEOFFSET,
										MachineCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.OldBarcode AND
					TargetTable.MEAMixingStepCode = SourceTable.OldMEAMixingStepCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					MEAMixingStepCode = ISNULL(SourceTable.MEAMixingStepCode,TargetTable.MEAMixingStepCode),
					StartDateTime = ISNULL(SourceTable.StartDateTime,TargetTable.StartDateTime),
					EndDateTime = ISNULL(SourceTable.EndDateTime,TargetTable.EndDateTime),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						MEAMixingStepCode,
						StartDateTime,
						EndDateTime,
						MachineCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.MEAMixingStepCode,
							SourceTable.StartDateTime,
							SourceTable.EndDateTime,
							SourceTable.MachineCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MEAElectrodeMixingHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							CASE
							    WHEN OldMEAMixingStepCode IS NULL THEN MEAMixingStepCode
							    ELSE OldMEAMixingStepCode
							END AS OldMEAMixingStepCode,
							Barcode,
							MEAMixingStepCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										OldMEAMixingStepCode VARCHAR(20),
										Barcode VARCHAR(20),
										MEAMixingStepCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.Barcode AND
					TargetTable.MEAMixingStepCode = SourceTable.MEAMixingStepCode
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
