-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_MaterialQcDetail_iud_BendingCutting
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
  DECLARE @OldMaterialQcNo VARCHAR(20)
  DECLARE @OldMaterialQcDetailNo INT
  DECLARE @MaterialQcNo VARCHAR(20)
  DECLARE @MaterialQcDetailNo INT
  DECLARE @QcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionGroupName NVARCHAR(50)
  DECLARE @QcInspectionGroupDesc NVARCHAR(200)
  DECLARE @QcInspectionItemCode VARCHAR(20)
  DECLARE @QcInspectionItemName NVARCHAR(200)
  DECLARE @QcInspectionItemDesc NVARCHAR(MAX)
  DECLARE @GroupInspectionPrior INT
  DECLARE @GroupReportPrior INT
  DECLARE @ItemInspectionPrior INT
  DECLARE @ItemReportPrior INT
  DECLARE @QcSpecDesc NVARCHAR(MAX)
  DECLARE @InspectionType VARCHAR(20)
  DECLARE @IsMaterialSpec VARCHAR(1)
  DECLARE @InspectionLevel VARCHAR(20)
  DECLARE @AQL NUMERIC(10,3)
  DECLARE @RequestSampleQty INT
  DECLARE @MaxAcceptDefectQty INT
  DECLARE @SampleQty INT
  DECLARE @PassedSampleQty INT
  DECLARE @DefectSampleQty INT
  DECLARE @SkipSampleQty INT
  DECLARE @SpecValue NUMERIC(20,5)
  DECLARE @USL NUMERIC(20,5)
  DECLARE @LSL NUMERIC(20,5)
  DECLARE @UCL NUMERIC(20,5)
  DECLARE @LCL NUMERIC(20,5)
  DECLARE @TextSpecValue NVARCHAR(200)
  DECLARE @DecisionResult VARCHAR(10)
  DECLARE @Description NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcDetail_BendingCutting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialQcDetail_BendingCutting AS TargetTable
			USING
				(
					SELECT
							CASE WHEN OldMaterialQcNo IS NULL        THEN MaterialQcNo			ELSE OldMaterialQcNo			END AS OldMaterialQcNo,
							CASE WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo	ELSE OldMaterialQcDetailNo	END AS OldMaterialQcDetailNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							QcInspectionGroupCode,
							QcInspectionGroupName,
							QcInspectionGroupDesc,
							QcInspectionItemCode,
							QcInspectionItemName,
							QcInspectionItemDesc,
							GroupInspectionPrior,
							GroupReportPrior,
							ItemInspectionPrior,
							ItemReportPrior,
							QcSpecDesc,
							InspectionType,
							IsMaterialSpec,
							InspectionLevel,
							AQL,
							RequestSampleQty,
							MaxAcceptDefectQty,
							SampleQty,
							PassedSampleQty,
							DefectSampleQty,
							SkipSampleQty,
							SpecValue,
							USL,
							LSL,
							UCL,
							LCL,
							TextSpecValue,
							DecisionResult,
							Description,
							GETDATE()          AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE()          AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										GroupInspectionPrior INT,
										GroupReportPrior INT,
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionType VARCHAR(20),
										IsMaterialSpec VARCHAR(1),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										RequestSampleQty INT,
										MaxAcceptDefectQty INT,
										SampleQty INT,
										PassedSampleQty INT,
										DefectSampleQty INT,
										SkipSampleQty INT,
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										DecisionResult VARCHAR(10),
										Description NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.MaterialQcDetailNo
				)

			WHEN MATCHED THEN

			-- UPDATE문
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					MaterialQcDetailNo = ISNULL(SourceTable.MaterialQcDetailNo,TargetTable.MaterialQcDetailNo),
					QcInspectionGroupCode = ISNULL(SourceTable.QcInspectionGroupCode,TargetTable.QcInspectionGroupCode),
					QcInspectionGroupName = ISNULL(SourceTable.QcInspectionGroupName,TargetTable.QcInspectionGroupName),
					QcInspectionGroupDesc = ISNULL(SourceTable.QcInspectionGroupDesc,TargetTable.QcInspectionGroupDesc),
					QcInspectionItemCode = ISNULL(SourceTable.QcInspectionItemCode,TargetTable.QcInspectionItemCode),
					QcInspectionItemName = ISNULL(SourceTable.QcInspectionItemName,TargetTable.QcInspectionItemName),
					QcInspectionItemDesc = ISNULL(SourceTable.QcInspectionItemDesc,TargetTable.QcInspectionItemDesc),
					GroupInspectionPrior = ISNULL(SourceTable.GroupInspectionPrior,TargetTable.GroupInspectionPrior),
					GroupReportPrior = ISNULL(SourceTable.GroupReportPrior,TargetTable.GroupReportPrior),
					ItemInspectionPrior = ISNULL(SourceTable.ItemInspectionPrior,TargetTable.ItemInspectionPrior),
					ItemReportPrior = ISNULL(SourceTable.ItemReportPrior,TargetTable.ItemReportPrior),
					QcSpecDesc = ISNULL(SourceTable.QcSpecDesc,TargetTable.QcSpecDesc),
					InspectionType = ISNULL(SourceTable.InspectionType,TargetTable.InspectionType),
					IsMaterialSpec = ISNULL(SourceTable.IsMaterialSpec,TargetTable.IsMaterialSpec),
					InspectionLevel = ISNULL(SourceTable.InspectionLevel,TargetTable.InspectionLevel),
					AQL = ISNULL(SourceTable.AQL,TargetTable.AQL),
					RequestSampleQty = ISNULL(SourceTable.RequestSampleQty,TargetTable.RequestSampleQty),                                                       -- 대상샘플
					MaxAcceptDefectQty = ISNULL(SourceTable.MaxAcceptDefectQty,TargetTable.MaxAcceptDefectQty),
					SampleQty = ISNULL(SourceTable.SampleQty,TargetTable.SampleQty),                                                                                      -- 샘플수량
					PassedSampleQty = ISNULL(SourceTable.PassedSampleQty,TargetTable.PassedSampleQty),
					DefectSampleQty = ISNULL(SourceTable.DefectSampleQty,TargetTable.DefectSampleQty),
					SkipSampleQty = ISNULL(SourceTable.SkipSampleQty,TargetTable.SkipSampleQty),
					SpecValue = ISNULL(SourceTable.SpecValue,TargetTable.SpecValue),
					USL = ISNULL(SourceTable.USL,TargetTable.USL),
					LSL = ISNULL(SourceTable.LSL,TargetTable.LSL),
					UCL = ISNULL(SourceTable.UCL,TargetTable.UCL),
					LCL = ISNULL(SourceTable.LCL,TargetTable.LCL),
					TextSpecValue = ISNULL(SourceTable.TextSpecValue,TargetTable.TextSpecValue),
					DecisionResult = ISNULL(SourceTable.DecisionResult,TargetTable.DecisionResult),
					Description = ISNULL(SourceTable.Description,TargetTable.Description),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN


			--- INSERT문
				INSERT
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						QcInspectionGroupCode,
						QcInspectionGroupName,
						QcInspectionGroupDesc,
						QcInspectionItemCode,
						QcInspectionItemName,
						QcInspectionItemDesc,
						GroupInspectionPrior,
						GroupReportPrior,
						ItemInspectionPrior,
						ItemReportPrior,
						QcSpecDesc,
						InspectionType,
						IsMaterialSpec,
						InspectionLevel,
						AQL,
						RequestSampleQty,
						MaxAcceptDefectQty,
						SampleQty,
						PassedSampleQty,
						DefectSampleQty,
						SkipSampleQty,
						SpecValue,
						USL,
						LSL,
						UCL,
						LCL,
						TextSpecValue,
						DecisionResult,
						Description,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.MaterialQcDetailNo,
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionGroupName,
							SourceTable.QcInspectionGroupDesc,
							SourceTable.QcInspectionItemCode,
							SourceTable.QcInspectionItemName,
							SourceTable.QcInspectionItemDesc,
							SourceTable.GroupInspectionPrior,
							SourceTable.GroupReportPrior,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.QcSpecDesc,
							SourceTable.InspectionType,
							SourceTable.IsMaterialSpec,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.RequestSampleQty,
							SourceTable.MaxAcceptDefectQty,
							SourceTable.SampleQty,
							SourceTable.PassedSampleQty,
							SourceTable.DefectSampleQty,
							SourceTable.SkipSampleQty,
							SourceTable.SpecValue,
							SourceTable.USL,
							SourceTable.LSL,
							SourceTable.UCL,
							SourceTable.LCL,
							SourceTable.TextSpecValue,
							SourceTable.DecisionResult,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialQcDetail_BendingCutting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							CASE
							    WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
							    ELSE OldMaterialQcDetailNo
							END AS OldMaterialQcDetailNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							QcInspectionGroupCode,
							QcInspectionGroupName,
							QcInspectionGroupDesc,
							QcInspectionItemCode,
							QcInspectionItemName,
							QcInspectionItemDesc,
							GroupInspectionPrior,
							GroupReportPrior,
							ItemInspectionPrior,
							ItemReportPrior,
							QcSpecDesc,
							InspectionType,
							IsMaterialSpec,
							InspectionLevel,
							AQL,
							RequestSampleQty,
							MaxAcceptDefectQty,
							SampleQty,
							PassedSampleQty,
							DefectSampleQty,
							SkipSampleQty,
							SpecValue,
							USL,
							LSL,
							UCL,
							LCL,
							TextSpecValue,
							DecisionResult,
							Description,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										GroupInspectionPrior INT,
										GroupReportPrior INT,
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionType VARCHAR(20),
										IsMaterialSpec VARCHAR(1),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										RequestSampleQty INT,
										MaxAcceptDefectQty INT,
										SampleQty INT,
										PassedSampleQty INT,
										DefectSampleQty INT,
										SkipSampleQty INT,
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										DecisionResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										Description NVARCHAR(200),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.OldMaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.OldMaterialQcDetailNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					MaterialQcDetailNo = ISNULL(SourceTable.MaterialQcDetailNo,TargetTable.MaterialQcDetailNo),
					QcInspectionGroupCode = ISNULL(SourceTable.QcInspectionGroupCode,TargetTable.QcInspectionGroupCode),
					QcInspectionGroupName = ISNULL(SourceTable.QcInspectionGroupName,TargetTable.QcInspectionGroupName),
					QcInspectionGroupDesc = ISNULL(SourceTable.QcInspectionGroupDesc,TargetTable.QcInspectionGroupDesc),
					QcInspectionItemCode = ISNULL(SourceTable.QcInspectionItemCode,TargetTable.QcInspectionItemCode),
					QcInspectionItemName = ISNULL(SourceTable.QcInspectionItemName,TargetTable.QcInspectionItemName),
					QcInspectionItemDesc = ISNULL(SourceTable.QcInspectionItemDesc,TargetTable.QcInspectionItemDesc),
					GroupInspectionPrior = ISNULL(SourceTable.GroupInspectionPrior,TargetTable.GroupInspectionPrior),
					GroupReportPrior = ISNULL(SourceTable.GroupReportPrior,TargetTable.GroupReportPrior),
					ItemInspectionPrior = ISNULL(SourceTable.ItemInspectionPrior,TargetTable.ItemInspectionPrior),
					ItemReportPrior = ISNULL(SourceTable.ItemReportPrior,TargetTable.ItemReportPrior),
					QcSpecDesc = ISNULL(SourceTable.QcSpecDesc,TargetTable.QcSpecDesc),
					InspectionType = ISNULL(SourceTable.InspectionType,TargetTable.InspectionType),
					IsMaterialSpec = ISNULL(SourceTable.IsMaterialSpec,TargetTable.IsMaterialSpec),
					InspectionLevel = ISNULL(SourceTable.InspectionLevel,TargetTable.InspectionLevel),
					AQL = ISNULL(SourceTable.AQL,TargetTable.AQL),
					RequestSampleQty = ISNULL(SourceTable.RequestSampleQty,TargetTable.RequestSampleQty),
					MaxAcceptDefectQty = ISNULL(SourceTable.MaxAcceptDefectQty,TargetTable.MaxAcceptDefectQty),
					SampleQty = ISNULL(SourceTable.SampleQty,TargetTable.SampleQty),
					PassedSampleQty = ISNULL(SourceTable.PassedSampleQty,TargetTable.PassedSampleQty),
					DefectSampleQty = ISNULL(SourceTable.DefectSampleQty,TargetTable.DefectSampleQty),
					SkipSampleQty = ISNULL(SourceTable.SkipSampleQty,TargetTable.SkipSampleQty),
					SpecValue = ISNULL(SourceTable.SpecValue,TargetTable.SpecValue),
					USL = ISNULL(SourceTable.USL,TargetTable.USL),
					LSL = ISNULL(SourceTable.LSL,TargetTable.LSL),
					UCL = ISNULL(SourceTable.UCL,TargetTable.UCL),
					LCL = ISNULL(SourceTable.LCL,TargetTable.LCL),
					TextSpecValue = ISNULL(SourceTable.TextSpecValue,TargetTable.TextSpecValue),
					DecisionResult = ISNULL(SourceTable.DecisionResult,TargetTable.DecisionResult),
					Description = ISNULL(SourceTable.Description,TargetTable.Description),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						QcInspectionGroupCode,
						QcInspectionGroupName,
						QcInspectionGroupDesc,
						QcInspectionItemCode,
						QcInspectionItemName,
						QcInspectionItemDesc,
						GroupInspectionPrior,
						GroupReportPrior,
						ItemInspectionPrior,
						ItemReportPrior,
						QcSpecDesc,
						InspectionType,
						IsMaterialSpec,
						InspectionLevel,
						AQL,
						RequestSampleQty,
						MaxAcceptDefectQty,
						SampleQty,
						PassedSampleQty,
						DefectSampleQty,
						SkipSampleQty,
						SpecValue,
						USL,
						LSL,
						UCL,
						LCL,
						TextSpecValue,
						DecisionResult,
						Description,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.MaterialQcDetailNo,
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionGroupName,
							SourceTable.QcInspectionGroupDesc,
							SourceTable.QcInspectionItemCode,
							SourceTable.QcInspectionItemName,
							SourceTable.QcInspectionItemDesc,
							SourceTable.GroupInspectionPrior,
							SourceTable.GroupReportPrior,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.QcSpecDesc,
							SourceTable.InspectionType,
							SourceTable.IsMaterialSpec,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.RequestSampleQty,
							SourceTable.MaxAcceptDefectQty,
							SourceTable.SampleQty,
							SourceTable.PassedSampleQty,
							SourceTable.DefectSampleQty,
							SourceTable.SkipSampleQty,
							SourceTable.SpecValue,
							SourceTable.USL,
							SourceTable.LSL,
							SourceTable.UCL,
							SourceTable.LCL,
							SourceTable.TextSpecValue,
							SourceTable.DecisionResult,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialQcDetail_BendingCutting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							CASE
							    WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
							    ELSE OldMaterialQcDetailNo
							END AS OldMaterialQcDetailNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							QcInspectionGroupCode,
							QcInspectionGroupName,
							QcInspectionGroupDesc,
							QcInspectionItemCode,
							QcInspectionItemName,
							QcInspectionItemDesc,
							GroupInspectionPrior,
							GroupReportPrior,
							ItemInspectionPrior,
							ItemReportPrior,
							QcSpecDesc,
							InspectionType,
							IsMaterialSpec,
							InspectionLevel,
							AQL,
							RequestSampleQty,
							MaxAcceptDefectQty,
							SampleQty,
							PassedSampleQty,
							DefectSampleQty,
							SkipSampleQty,
							SpecValue,
							USL,
							LSL,
							UCL,
							LCL,
							TextSpecValue,
							DecisionResult,
							Description,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										GroupInspectionPrior INT,
										GroupReportPrior INT,
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionType VARCHAR(20),
										IsMaterialSpec VARCHAR(1),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										RequestSampleQty INT,
										MaxAcceptDefectQty INT,
										SampleQty INT,
										PassedSampleQty INT,
										DefectSampleQty INT,
										SkipSampleQty INT,
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										DecisionResult VARCHAR(10),
										Description NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.MaterialQcDetailNo
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
									OldMaterialQcNo,
									OldMaterialQcDetailNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									QcInspectionGroupCode,
									QcInspectionGroupName,
									QcInspectionGroupDesc,
									QcInspectionItemCode,
									QcInspectionItemName,
									QcInspectionItemDesc,
									GroupInspectionPrior,
									GroupReportPrior,
									ItemInspectionPrior,
									ItemReportPrior,
									QcSpecDesc,
									InspectionType,
									IsMaterialSpec,
									InspectionLevel,
									AQL,
									RequestSampleQty,
									MaxAcceptDefectQty,
									SampleQty,
									PassedSampleQty,
									DefectSampleQty,
									SkipSampleQty,
									SpecValue,
									USL,
									LSL,
									UCL,
									LCL,
									TextSpecValue,
									DecisionResult,
									Description,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 GroupInspectionPrior INT,
											 GroupReportPrior INT,
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionType VARCHAR(20),
											 IsMaterialSpec VARCHAR(1),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 RequestSampleQty INT,
											 MaxAcceptDefectQty INT,
											 SampleQty INT,
											 PassedSampleQty INT,
											 DefectSampleQty INT,
											 SkipSampleQty INT,
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 DecisionResult VARCHAR(10),
											 Description NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo										ELSE OldMaterialQcNo									END AS OldMaterialQcNo,
									CASE 										WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo										ELSE OldMaterialQcDetailNo									END AS OldMaterialQcDetailNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									QcInspectionGroupCode,
									QcInspectionGroupName,
									QcInspectionGroupDesc,
									QcInspectionItemCode,
									QcInspectionItemName,
									QcInspectionItemDesc,
									GroupInspectionPrior,
									GroupReportPrior,
									ItemInspectionPrior,
									ItemReportPrior,
									QcSpecDesc,
									InspectionType,
									IsMaterialSpec,
									InspectionLevel,
									AQL,
									RequestSampleQty,
									MaxAcceptDefectQty,
									SampleQty,
									PassedSampleQty,
									DefectSampleQty,
									SkipSampleQty,
									SpecValue,
									USL,
									LSL,
									UCL,
									LCL,
									TextSpecValue,
									DecisionResult,
									Description,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 GroupInspectionPrior INT,
											 GroupReportPrior INT,
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionType VARCHAR(20),
											 IsMaterialSpec VARCHAR(1),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 RequestSampleQty INT,
											 MaxAcceptDefectQty INT,
											 SampleQty INT,
											 PassedSampleQty INT,
											 DefectSampleQty INT,
											 SkipSampleQty INT,
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 DecisionResult VARCHAR(10),
											 Description NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo										ELSE OldMaterialQcNo									END AS OldMaterialQcNo,
									CASE 										WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo										ELSE OldMaterialQcDetailNo									END AS OldMaterialQcDetailNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									QcInspectionGroupCode,
									QcInspectionGroupName,
									QcInspectionGroupDesc,
									QcInspectionItemCode,
									QcInspectionItemName,
									QcInspectionItemDesc,
									GroupInspectionPrior,
									GroupReportPrior,
									ItemInspectionPrior,
									ItemReportPrior,
									QcSpecDesc,
									InspectionType,
									IsMaterialSpec,
									InspectionLevel,
									AQL,
									RequestSampleQty,
									MaxAcceptDefectQty,
									SampleQty,
									PassedSampleQty,
									DefectSampleQty,
									SkipSampleQty,
									SpecValue,
									USL,
									LSL,
									UCL,
									LCL,
									TextSpecValue,
									DecisionResult,
									Description,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 GroupInspectionPrior INT,
											 GroupReportPrior INT,
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionType VARCHAR(20),
											 IsMaterialSpec VARCHAR(1),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 RequestSampleQty INT,
											 MaxAcceptDefectQty INT,
											 SampleQty INT,
											 PassedSampleQty INT,
											 DefectSampleQty INT,
											 SkipSampleQty INT,
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 DecisionResult VARCHAR(10),
											 Description NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialQcNo,
								 @OldMaterialQcDetailNo,
								 @MaterialQcNo,
								 @MaterialQcDetailNo,
								 @QcInspectionGroupCode,
								 @QcInspectionGroupName,
								 @QcInspectionGroupDesc,
								 @QcInspectionItemCode,
								 @QcInspectionItemName,
								 @QcInspectionItemDesc,
								 @GroupInspectionPrior,
								 @GroupReportPrior,
								 @ItemInspectionPrior,
								 @ItemReportPrior,
								 @QcSpecDesc,
								 @InspectionType,
								 @IsMaterialSpec,
								 @InspectionLevel,
								 @AQL,
								 @RequestSampleQty,
								 @MaxAcceptDefectQty,
								 @SampleQty,
								 @PassedSampleQty,
								 @DefectSampleQty,
								 @SkipSampleQty,
								 @SpecValue,
								 @USL,
								 @LSL,
								 @UCL,
								 @LCL,
								 @TextSpecValue,
								 @DecisionResult,
								 @Description,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcDetail_BendingCutting WHERE MaterialQcNo = @MaterialQcNo AND MaterialQcDetailNo = @MaterialQcDetailNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcDetail_BendingCutting',@MaterialQcNo OUTPUT
                    END

                    INSERT INTO STB_MaterialQcDetail_BendingCutting
						(
						    MaterialQcNo,
						    MaterialQcDetailNo,
						    QcInspectionGroupCode,
						    QcInspectionGroupName,
						    QcInspectionGroupDesc,
						    QcInspectionItemCode,
						    QcInspectionItemName,
						    QcInspectionItemDesc,
						    GroupInspectionPrior,
						    GroupReportPrior,
						    ItemInspectionPrior,
						    ItemReportPrior,
						    QcSpecDesc,
						    InspectionType,
						    IsMaterialSpec,
						    InspectionLevel,
						    AQL,
						    RequestSampleQty,
						    MaxAcceptDefectQty,
						    SampleQty,
						    PassedSampleQty,
						    DefectSampleQty,
						    SkipSampleQty,
						    SpecValue,
						    USL,
						    LSL,
						    UCL,
						    LCL,
						    TextSpecValue,
						    DecisionResult,
							Description,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialQcNo,
						    @MaterialQcDetailNo,
						    @QcInspectionGroupCode,
						    @QcInspectionGroupName,
						    @QcInspectionGroupDesc,
						    @QcInspectionItemCode,
						    @QcInspectionItemName,
						    @QcInspectionItemDesc,
						    @GroupInspectionPrior,
						    @GroupReportPrior,
						    @ItemInspectionPrior,
						    @ItemReportPrior,
						    @QcSpecDesc,
						    @InspectionType,
						    @IsMaterialSpec,
						    @InspectionLevel,
						    @AQL,
						    @RequestSampleQty,
						    @MaxAcceptDefectQty,
						    @SampleQty,
						    @PassedSampleQty,
						    @DefectSampleQty,
						    @SkipSampleQty,
						    @SpecValue,
						    @USL,
						    @LSL,
						    @UCL,
						    @LCL,
						    @TextSpecValue,
						    @DecisionResult,
							@Description,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialQcDetail_BendingCutting
						SET
						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
						    MaterialQcDetailNo =   ISNULL(@MaterialQcDetailNo,MaterialQcDetailNo),
						    QcInspectionGroupCode =   ISNULL(@QcInspectionGroupCode,QcInspectionGroupCode),
						    QcInspectionGroupName =   ISNULL(@QcInspectionGroupName,QcInspectionGroupName),
						    QcInspectionGroupDesc =   ISNULL(@QcInspectionGroupDesc,QcInspectionGroupDesc),
						    QcInspectionItemCode =   ISNULL(@QcInspectionItemCode,QcInspectionItemCode),
						    QcInspectionItemName =   ISNULL(@QcInspectionItemName,QcInspectionItemName),
						    QcInspectionItemDesc =   ISNULL(@QcInspectionItemDesc,QcInspectionItemDesc),
						    GroupInspectionPrior =   ISNULL(@GroupInspectionPrior,GroupInspectionPrior),
						    GroupReportPrior =   ISNULL(@GroupReportPrior,GroupReportPrior),
						    ItemInspectionPrior =   ISNULL(@ItemInspectionPrior,ItemInspectionPrior),
						    ItemReportPrior =   ISNULL(@ItemReportPrior,ItemReportPrior),
						    QcSpecDesc =   ISNULL(@QcSpecDesc,QcSpecDesc),
						    InspectionType =   ISNULL(@InspectionType,InspectionType),
						    IsMaterialSpec =   ISNULL(@IsMaterialSpec,IsMaterialSpec),
						    InspectionLevel =   ISNULL(@InspectionLevel,InspectionLevel),
						    AQL =   ISNULL(@AQL,AQL),
						    RequestSampleQty =   ISNULL(@RequestSampleQty,RequestSampleQty),
						    MaxAcceptDefectQty =   ISNULL(@MaxAcceptDefectQty,MaxAcceptDefectQty),
						    SampleQty =   ISNULL(@SampleQty,SampleQty),
						    PassedSampleQty =   ISNULL(@PassedSampleQty,PassedSampleQty),
						    DefectSampleQty =   ISNULL(@DefectSampleQty,DefectSampleQty),
						    SkipSampleQty =   ISNULL(@SkipSampleQty,SkipSampleQty),
						    SpecValue =   ISNULL(@SpecValue,SpecValue),
						    USL =   ISNULL(@USL,USL),
						    LSL =   ISNULL(@LSL,LSL),
						    UCL =   ISNULL(@UCL,UCL),
						    LCL =   ISNULL(@LCL,LCL),
						    TextSpecValue =   ISNULL(@TextSpecValue,TextSpecValue),
						    DecisionResult =   ISNULL(@DecisionResult,DecisionResult),
							Description = ISNULL(@Description,Description),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialQcNo = @OldMaterialQcNo AND
						    MaterialQcDetailNo = @OldMaterialQcDetailNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialQcDetail_BendingCutting
						WHERE
						    MaterialQcNo = @OldMaterialQcNo AND
						    MaterialQcDetailNo = @OldMaterialQcDetailNo
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

