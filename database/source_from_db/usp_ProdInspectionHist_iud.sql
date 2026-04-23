
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-02-05
-- Browsable : true
-- Group : 품질관리 > [C540] 제품검사이력 업데이트
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdInspectionHist_iud]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pDescText            NVARCHAR(MAX),    --추가
						@pXml NVARCHAR(MAX) = NULL
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
  DECLARE @MaterialQcNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @InspectionDocType VARCHAR(10)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @QcQty NUMERIC(20,5)
  DECLARE @InspectionType VARCHAR(10)
  DECLARE @BasicDate DATE
  DECLARE @TargetSampleQty INT
  DECLARE @ActualSampleQty INT
  DECLARE @DestoryInspectionQty INT
  DECLARE @ProcessQty NUMERIC(20,5)
  DECLARE @MaxAcceptDefectQty INT
  DECLARE @PassedSampleQty INT
  DECLARE @DefectSampleQty INT
  DECLARE @DecisionResult VARCHAR(10)
  DECLARE @DecisionDateTime DATETIME
  DECLARE @DecisionUserID VARCHAR(20)
  DECLARE @SpecialAcceptDesc NVARCHAR(100)
  DECLARE @DescText NVARCHAR(MAX)            = @pDescText            --추가
  DECLARE @VendorQcReport BIGINT
  DECLARE @VendorLotNo VARCHAR(100)
  DECLARE @MIIExtText01 NVARCHAR(MAX)
  DECLARE @MIIExtText02 NVARCHAR(MAX)
  DECLARE @MIIExtText03 NVARCHAR(MAX)
  DECLARE @MIIExtText04 NVARCHAR(MAX)
  DECLARE @MIIExtText05 NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @iDoc INT  

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialQcInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							MaterialQcNo,
							CompanyCode,
							WorkCenterCode,
							InspectionDocType,
							MaterialCode,
							QcQty,
							InspectionType,
							BasicDate,
							TargetSampleQty,
							ActualSampleQty,
							DestoryInspectionQty,
							ProcessQty,
							MaxAcceptDefectQty,
							PassedSampleQty,
							DefectSampleQty,
							DecisionResult,
							DecisionDateTime,
							DecisionUserID,
							SpecialAcceptDesc,
							DescText,
							VendorQcReport,
							VendorLotNo,
							MIIExtText01,
							MIIExtText02,
							MIIExtText03,
							MIIExtText04,
							MIIExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										MaterialQcNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										InspectionDocType VARCHAR(10),
										MaterialCode VARCHAR(50),
										QcQty NUMERIC(20,5),
										InspectionType VARCHAR(10),
										BasicDate DATETIMEOFFSET,
										TargetSampleQty INT,
										ActualSampleQty INT,
										DestoryInspectionQty INT,
										ProcessQty NUMERIC(20,5),
										MaxAcceptDefectQty INT,
										PassedSampleQty INT,
										DefectSampleQty INT,
										DecisionResult VARCHAR(10),
										DecisionDateTime DATETIMEOFFSET,
										DecisionUserID VARCHAR(20),
										SpecialAcceptDesc NVARCHAR(100),
										DescText NVARCHAR(MAX),
										VendorQcReport BIGINT,
										VendorLotNo VARCHAR(100),
										MIIExtText01 NVARCHAR(MAX),
										MIIExtText02 NVARCHAR(MAX),
										MIIExtText03 NVARCHAR(MAX),
										MIIExtText04 NVARCHAR(MAX),
										MIIExtText05 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					InspectionDocType = ISNULL(SourceTable.InspectionDocType,TargetTable.InspectionDocType),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					QcQty = ISNULL(SourceTable.QcQty,TargetTable.QcQty),
					InspectionType = ISNULL(SourceTable.InspectionType,TargetTable.InspectionType),
					BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					TargetSampleQty = ISNULL(SourceTable.TargetSampleQty,TargetTable.TargetSampleQty),
					ActualSampleQty = ISNULL(SourceTable.ActualSampleQty,TargetTable.ActualSampleQty),
					DestoryInspectionQty = ISNULL(SourceTable.DestoryInspectionQty,TargetTable.DestoryInspectionQty),
					ProcessQty = ISNULL(SourceTable.ProcessQty,TargetTable.ProcessQty),
					MaxAcceptDefectQty = ISNULL(SourceTable.MaxAcceptDefectQty,TargetTable.MaxAcceptDefectQty),
					PassedSampleQty = ISNULL(SourceTable.PassedSampleQty,TargetTable.PassedSampleQty),
					DefectSampleQty = ISNULL(SourceTable.DefectSampleQty,TargetTable.DefectSampleQty),
					DecisionResult = ISNULL(SourceTable.DecisionResult,TargetTable.DecisionResult),
					DecisionDateTime = ISNULL(SourceTable.DecisionDateTime,TargetTable.DecisionDateTime),
					DecisionUserID = ISNULL(SourceTable.DecisionUserID,TargetTable.DecisionUserID),
					SpecialAcceptDesc = ISNULL(SourceTable.SpecialAcceptDesc,TargetTable.SpecialAcceptDesc),
					DescText = ISNULL(SourceTable.DescText,TargetTable.DescText),
					VendorQcReport = ISNULL(SourceTable.VendorQcReport,TargetTable.VendorQcReport),
					VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
					MIIExtText01 = ISNULL(SourceTable.MIIExtText01,TargetTable.MIIExtText01),
					MIIExtText02 = ISNULL(SourceTable.MIIExtText02,TargetTable.MIIExtText02),
					MIIExtText03 = ISNULL(SourceTable.MIIExtText03,TargetTable.MIIExtText03),
					MIIExtText04 = ISNULL(SourceTable.MIIExtText04,TargetTable.MIIExtText04),
					MIIExtText05 = ISNULL(SourceTable.MIIExtText05,TargetTable.MIIExtText05),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						CompanyCode,
						WorkCenterCode,
						InspectionDocType,
						MaterialCode,
						QcQty,
						InspectionType,
						BasicDate,
						TargetSampleQty,
						ActualSampleQty,
						DestoryInspectionQty,
						ProcessQty,
						MaxAcceptDefectQty,
						PassedSampleQty,
						DefectSampleQty,
						DecisionResult,
						DecisionDateTime,
						DecisionUserID,
						SpecialAcceptDesc,
						DescText,
						VendorQcReport,
						VendorLotNo,
						MIIExtText01,
						MIIExtText02,
						MIIExtText03,
						MIIExtText04,
						MIIExtText05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.InspectionDocType,
							SourceTable.MaterialCode,
							SourceTable.QcQty,
							SourceTable.InspectionType,
							SourceTable.BasicDate,
							SourceTable.TargetSampleQty,
							SourceTable.ActualSampleQty,
							SourceTable.DestoryInspectionQty,
							SourceTable.ProcessQty,
							SourceTable.MaxAcceptDefectQty,
							SourceTable.PassedSampleQty,
							SourceTable.DefectSampleQty,
							SourceTable.DecisionResult,
							SourceTable.DecisionDateTime,
							SourceTable.DecisionUserID,
							SourceTable.SpecialAcceptDesc,
							SourceTable.DescText,
							SourceTable.VendorQcReport,
							SourceTable.VendorLotNo,
							SourceTable.MIIExtText01,
							SourceTable.MIIExtText02,
							SourceTable.MIIExtText03,
							SourceTable.MIIExtText04,
							SourceTable.MIIExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialQcInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							MaterialQcNo,
							CompanyCode,
							WorkCenterCode,
							InspectionDocType,
							MaterialCode,
							QcQty,
							InspectionType,
							BasicDate,
							TargetSampleQty,
							ActualSampleQty,
							DestoryInspectionQty,
							ProcessQty,
							MaxAcceptDefectQty,
							PassedSampleQty,
							DefectSampleQty,
							DecisionResult,
							DecisionDateTime,
							DecisionUserID,
							SpecialAcceptDesc,
							DescText,
							VendorQcReport,
							VendorLotNo,
							MIIExtText01,
							MIIExtText02,
							MIIExtText03,
							MIIExtText04,
							MIIExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										MaterialQcNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										InspectionDocType VARCHAR(10),
										MaterialCode VARCHAR(50),
										QcQty NUMERIC(20,5),
										InspectionType VARCHAR(10),
										BasicDate DATETIMEOFFSET,
										TargetSampleQty INT,
										ActualSampleQty INT,
										DestoryInspectionQty INT,
										ProcessQty NUMERIC(20,5),
										MaxAcceptDefectQty INT,
										PassedSampleQty INT,
										DefectSampleQty INT,
										DecisionResult VARCHAR(10),
										DecisionDateTime DATETIMEOFFSET,
										DecisionUserID VARCHAR(20),
										SpecialAcceptDesc NVARCHAR(100),
										DescText NVARCHAR(MAX),
										VendorQcReport BIGINT,
										VendorLotNo VARCHAR(100),
										MIIExtText01 NVARCHAR(MAX),
										MIIExtText02 NVARCHAR(MAX),
										MIIExtText03 NVARCHAR(MAX),
										MIIExtText04 NVARCHAR(MAX),
										MIIExtText05 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.OldMaterialQcNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					InspectionDocType = ISNULL(SourceTable.InspectionDocType,TargetTable.InspectionDocType),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					QcQty = ISNULL(SourceTable.QcQty,TargetTable.QcQty),
					InspectionType = ISNULL(SourceTable.InspectionType,TargetTable.InspectionType),
					BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					TargetSampleQty = ISNULL(SourceTable.TargetSampleQty,TargetTable.TargetSampleQty),
					ActualSampleQty = ISNULL(SourceTable.ActualSampleQty,TargetTable.ActualSampleQty),
					DestoryInspectionQty = ISNULL(SourceTable.DestoryInspectionQty,TargetTable.DestoryInspectionQty),
					ProcessQty = ISNULL(SourceTable.ProcessQty,TargetTable.ProcessQty),
					MaxAcceptDefectQty = ISNULL(SourceTable.MaxAcceptDefectQty,TargetTable.MaxAcceptDefectQty),
					PassedSampleQty = ISNULL(SourceTable.PassedSampleQty,TargetTable.PassedSampleQty),
					DefectSampleQty = ISNULL(SourceTable.DefectSampleQty,TargetTable.DefectSampleQty),
					DecisionResult = ISNULL(SourceTable.DecisionResult,TargetTable.DecisionResult),
					DecisionDateTime = ISNULL(SourceTable.DecisionDateTime,TargetTable.DecisionDateTime),
					DecisionUserID = ISNULL(SourceTable.DecisionUserID,TargetTable.DecisionUserID),
					SpecialAcceptDesc = ISNULL(SourceTable.SpecialAcceptDesc,TargetTable.SpecialAcceptDesc),
					DescText = ISNULL(SourceTable.DescText,TargetTable.DescText),
					VendorQcReport = ISNULL(SourceTable.VendorQcReport,TargetTable.VendorQcReport),
					VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
					MIIExtText01 = ISNULL(SourceTable.MIIExtText01,TargetTable.MIIExtText01),
					MIIExtText02 = ISNULL(SourceTable.MIIExtText02,TargetTable.MIIExtText02),
					MIIExtText03 = ISNULL(SourceTable.MIIExtText03,TargetTable.MIIExtText03),
					MIIExtText04 = ISNULL(SourceTable.MIIExtText04,TargetTable.MIIExtText04),
					MIIExtText05 = ISNULL(SourceTable.MIIExtText05,TargetTable.MIIExtText05),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						CompanyCode,
						WorkCenterCode,
						InspectionDocType,
						MaterialCode,
						QcQty,
						InspectionType,
						BasicDate,
						TargetSampleQty,
						ActualSampleQty,
						DestoryInspectionQty,
						ProcessQty,
						MaxAcceptDefectQty,
						PassedSampleQty,
						DefectSampleQty,
						DecisionResult,
						DecisionDateTime,
						DecisionUserID,
						SpecialAcceptDesc,
						DescText,
						VendorQcReport,
						VendorLotNo,
						MIIExtText01,
						MIIExtText02,
						MIIExtText03,
						MIIExtText04,
						MIIExtText05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.InspectionDocType,
							SourceTable.MaterialCode,
							SourceTable.QcQty,
							SourceTable.InspectionType,
							SourceTable.BasicDate,
							SourceTable.TargetSampleQty,
							SourceTable.ActualSampleQty,
							SourceTable.DestoryInspectionQty,
							SourceTable.ProcessQty,
							SourceTable.MaxAcceptDefectQty,
							SourceTable.PassedSampleQty,
							SourceTable.DefectSampleQty,
							SourceTable.DecisionResult,
							SourceTable.DecisionDateTime,
							SourceTable.DecisionUserID,
							SourceTable.SpecialAcceptDesc,
							SourceTable.DescText,
							SourceTable.VendorQcReport,
							SourceTable.VendorLotNo,
							SourceTable.MIIExtText01,
							SourceTable.MIIExtText02,
							SourceTable.MIIExtText03,
							SourceTable.MIIExtText04,
							SourceTable.MIIExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialQcInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
							    ELSE OldMaterialQcNo
							END AS OldMaterialQcNo,
							MaterialQcNo,
							CompanyCode,
							WorkCenterCode,
							InspectionDocType,
							MaterialCode,
							QcQty,
							InspectionType,
							BasicDate,
							TargetSampleQty,
							ActualSampleQty,
							DestoryInspectionQty,
							ProcessQty,
							MaxAcceptDefectQty,
							PassedSampleQty,
							DefectSampleQty,
							DecisionResult,
							DecisionDateTime,
							DecisionUserID,
							SpecialAcceptDesc,
							DescText,
							VendorQcReport,
							VendorLotNo,
							MIIExtText01,
							MIIExtText02,
							MIIExtText03,
							MIIExtText04,
							MIIExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										MaterialQcNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										InspectionDocType VARCHAR(10),
										MaterialCode VARCHAR(50),
										QcQty NUMERIC(20,5),
										InspectionType VARCHAR(10),
										BasicDate DATETIMEOFFSET,
										TargetSampleQty INT,
										ActualSampleQty INT,
										DestoryInspectionQty INT,
										ProcessQty NUMERIC(20,5),
										MaxAcceptDefectQty INT,
										PassedSampleQty INT,
										DefectSampleQty INT,
										DecisionResult VARCHAR(10),
										DecisionDateTime DATETIMEOFFSET,
										DecisionUserID VARCHAR(20),
										SpecialAcceptDesc NVARCHAR(100),
										DescText NVARCHAR(MAX),
										VendorQcReport BIGINT,
										VendorLotNo VARCHAR(100),
										MIIExtText01 NVARCHAR(MAX),
										MIIExtText02 NVARCHAR(MAX),
										MIIExtText03 NVARCHAR(MAX),
										MIIExtText04 NVARCHAR(MAX),
										MIIExtText05 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo
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
									MaterialQcNo,
									CompanyCode,
									WorkCenterCode,
									InspectionDocType,
									MaterialCode,
									QcQty,
									InspectionType,
									BasicDate,
									TargetSampleQty,
									ActualSampleQty,
									DestoryInspectionQty,
									ProcessQty,
									MaxAcceptDefectQty,
									PassedSampleQty,
									DefectSampleQty,
									DecisionResult,
									DecisionDateTime,
									DecisionUserID,
									SpecialAcceptDesc,
									DescText,
									VendorQcReport,
									VendorLotNo,
									MIIExtText01,
									MIIExtText02,
									MIIExtText03,
									MIIExtText04,
									MIIExtText05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 MaterialQcNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 InspectionDocType VARCHAR(10),
											 MaterialCode VARCHAR(50),
											 QcQty NUMERIC(20,5),
											 InspectionType VARCHAR(10),
											 BasicDate DATETIMEOFFSET,
											 TargetSampleQty INT,
											 ActualSampleQty INT,
											 DestoryInspectionQty INT,
											 ProcessQty NUMERIC(20,5),
											 MaxAcceptDefectQty INT,
											 PassedSampleQty INT,
											 DefectSampleQty INT,
											 DecisionResult VARCHAR(10),
											 DecisionDateTime DATETIMEOFFSET,
											 DecisionUserID VARCHAR(20),
											 SpecialAcceptDesc NVARCHAR(100),
											 DescText NVARCHAR(MAX),
											 VendorQcReport BIGINT,
											 VendorLotNo VARCHAR(100),
											 MIIExtText01 NVARCHAR(MAX),
											 MIIExtText02 NVARCHAR(MAX),
											 MIIExtText03 NVARCHAR(MAX),
											 MIIExtText04 NVARCHAR(MAX),
											 MIIExtText05 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
										ELSE OldMaterialQcNo
									END AS OldMaterialQcNo,
									MaterialQcNo,
									CompanyCode,
									WorkCenterCode,
									InspectionDocType,
									MaterialCode,
									QcQty,
									InspectionType,
									BasicDate,
									TargetSampleQty,
									ActualSampleQty,
									DestoryInspectionQty,
									ProcessQty,
									MaxAcceptDefectQty,
									PassedSampleQty,
									DefectSampleQty,
									DecisionResult,
									DecisionDateTime,
									DecisionUserID,
									SpecialAcceptDesc,
									DescText,
									VendorQcReport,
									VendorLotNo,
									MIIExtText01,
									MIIExtText02,
									MIIExtText03,
									MIIExtText04,
									MIIExtText05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 MaterialQcNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 InspectionDocType VARCHAR(10),
											 MaterialCode VARCHAR(50),
											 QcQty NUMERIC(20,5),
											 InspectionType VARCHAR(10),
											 BasicDate DATETIMEOFFSET,
											 TargetSampleQty INT,
											 ActualSampleQty INT,
											 DestoryInspectionQty INT,
											 ProcessQty NUMERIC(20,5),
											 MaxAcceptDefectQty INT,
											 PassedSampleQty INT,
											 DefectSampleQty INT,
											 DecisionResult VARCHAR(10),
											 DecisionDateTime DATETIMEOFFSET,
											 DecisionUserID VARCHAR(20),
											 SpecialAcceptDesc NVARCHAR(100),
											 DescText NVARCHAR(MAX),
											 VendorQcReport BIGINT,
											 VendorLotNo VARCHAR(100),
											 MIIExtText01 NVARCHAR(MAX),
											 MIIExtText02 NVARCHAR(MAX),
											 MIIExtText03 NVARCHAR(MAX),
											 MIIExtText04 NVARCHAR(MAX),
											 MIIExtText05 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
										ELSE OldMaterialQcNo
									END AS OldMaterialQcNo,
									MaterialQcNo,
									CompanyCode,
									WorkCenterCode,
									InspectionDocType,
									MaterialCode,
									QcQty,
									InspectionType,
									BasicDate,
									TargetSampleQty,
									ActualSampleQty,
									DestoryInspectionQty,
									ProcessQty,
									MaxAcceptDefectQty,
									PassedSampleQty,
									DefectSampleQty,
									DecisionResult,
									DecisionDateTime,
									DecisionUserID,
									SpecialAcceptDesc,
									DescText,
									VendorQcReport,
									VendorLotNo,
									MIIExtText01,
									MIIExtText02,
									MIIExtText03,
									MIIExtText04,
									MIIExtText05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 MaterialQcNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 InspectionDocType VARCHAR(10),
											 MaterialCode VARCHAR(50),
											 QcQty NUMERIC(20,5),
											 InspectionType VARCHAR(10),
											 BasicDate DATETIMEOFFSET,
											 TargetSampleQty INT,
											 ActualSampleQty INT,
											 DestoryInspectionQty INT,
											 ProcessQty NUMERIC(20,5),
											 MaxAcceptDefectQty INT,
											 PassedSampleQty INT,
											 DefectSampleQty INT,
											 DecisionResult VARCHAR(10),
											 DecisionDateTime DATETIMEOFFSET,
											 DecisionUserID VARCHAR(20),
											 SpecialAcceptDesc NVARCHAR(100),
											 DescText NVARCHAR(MAX),
											 VendorQcReport BIGINT,
											 VendorLotNo VARCHAR(100),
											 MIIExtText01 NVARCHAR(MAX),
											 MIIExtText02 NVARCHAR(MAX),
											 MIIExtText03 NVARCHAR(MAX),
											 MIIExtText04 NVARCHAR(MAX),
											 MIIExtText05 NVARCHAR(MAX),
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
								 @MaterialQcNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @InspectionDocType,
								 @MaterialCode,
								 @QcQty,
								 @InspectionType,
								 @BasicDate,
								 @TargetSampleQty,
								 @ActualSampleQty,
								 @DestoryInspectionQty,
								 @ProcessQty,
								 @MaxAcceptDefectQty,
								 @PassedSampleQty,
								 @DefectSampleQty,
								 @DecisionResult,
								 @DecisionDateTime,
								 @DecisionUserID,
								 @SpecialAcceptDesc,
								 @DescText,
								 @VendorQcReport,
								 @VendorLotNo,
								 @MIIExtText01,
								 @MIIExtText02,
								 @MIIExtText03,
								 @MIIExtText04,
								 @MIIExtText05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcInfo',@MaterialQcNo OUTPUT
                    END

                    INSERT INTO STB_MaterialQcInfo
						(
						    MaterialQcNo,
						    CompanyCode,
						    WorkCenterCode,
						    InspectionDocType,
						    MaterialCode,
						    QcQty,
						    InspectionType,
						    BasicDate,
						    TargetSampleQty,
						    ActualSampleQty,
						    DestoryInspectionQty,
						    ProcessQty,
						    MaxAcceptDefectQty,
						    PassedSampleQty,
						    DefectSampleQty,
						    DecisionResult,
						    DecisionDateTime,
						    DecisionUserID,
						    SpecialAcceptDesc,
						    DescText,
						    VendorQcReport,
						    VendorLotNo,
						    MIIExtText01,
						    MIIExtText02,
						    MIIExtText03,
						    MIIExtText04,
						    MIIExtText05,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialQcNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @InspectionDocType,
						    @MaterialCode,
						    @QcQty,
						    @InspectionType,
						    @BasicDate,
						    @TargetSampleQty,
						    @ActualSampleQty,
						    @DestoryInspectionQty,
						    @ProcessQty,
						    @MaxAcceptDefectQty,
						    @PassedSampleQty,
						    @DefectSampleQty,
						    @DecisionResult,
						    @DecisionDateTime,
						    @DecisionUserID,
						    @SpecialAcceptDesc,
						    @DescText,
						    @VendorQcReport,
						    @VendorLotNo,
						    @MIIExtText01,
						    @MIIExtText02,
						    @MIIExtText03,
						    @MIIExtText04,
						    @MIIExtText05,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialQcInfo
						SET
						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    InspectionDocType =   ISNULL(@InspectionDocType,InspectionDocType),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    QcQty =   ISNULL(@QcQty,QcQty),
						    InspectionType =   ISNULL(@InspectionType,InspectionType),
						    BasicDate =   ISNULL(@BasicDate,BasicDate),
						    TargetSampleQty =   ISNULL(@TargetSampleQty,TargetSampleQty),
						    ActualSampleQty =   ISNULL(@ActualSampleQty,ActualSampleQty),
						    DestoryInspectionQty =   ISNULL(@DestoryInspectionQty,DestoryInspectionQty),
						    ProcessQty =   ISNULL(@ProcessQty,ProcessQty),
						    MaxAcceptDefectQty =   ISNULL(@MaxAcceptDefectQty,MaxAcceptDefectQty),
						    PassedSampleQty =   ISNULL(@PassedSampleQty,PassedSampleQty),
						    DefectSampleQty =   ISNULL(@DefectSampleQty,DefectSampleQty),
						    DecisionResult =   ISNULL(@DecisionResult,DecisionResult),
						    DecisionDateTime =   ISNULL(@DecisionDateTime,DecisionDateTime),
						    DecisionUserID =   ISNULL(@DecisionUserID,DecisionUserID),
						    SpecialAcceptDesc =   ISNULL(@SpecialAcceptDesc,SpecialAcceptDesc),
						    DescText =   ISNULL(@DescText,DescText),
						    VendorQcReport =   ISNULL(@VendorQcReport,VendorQcReport),
						    VendorLotNo =   ISNULL(@VendorLotNo,VendorLotNo),
						    MIIExtText01 =   ISNULL(@MIIExtText01,MIIExtText01),
						    MIIExtText02 =   ISNULL(@MIIExtText02,MIIExtText02),
						    MIIExtText03 =   ISNULL(@MIIExtText03,MIIExtText03),
						    MIIExtText04 =   ISNULL(@MIIExtText04,MIIExtText04),
						    MIIExtText05 =   ISNULL(@MIIExtText05,MIIExtText05),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialQcNo = @OldMaterialQcNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialQcInfo
						WHERE
						    MaterialQcNo = @OldMaterialQcNo
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