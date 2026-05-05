

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-11-08
-- Browsable : true
-- Group : 품질관리 > 수입검사
-- Description:	수입검사 목록을 업데이트 한다.
-- Modified:   Mr.Tung  on  2022-12-27 
-- =============================================


CREATE PROCEDURE [dbo].[usp_MaterialQcInfo_iud]
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
  --DECLARE @ManufacturerCode VARCHAR(20)
  --DECLARE @WeekCode VARCHAR(10)
  --DECLARE @RevisionsVer NVARCHAR(30)
  DECLARE @DecisionResult VARCHAR(10)
  DECLARE @DecisionDateTime DATETIME
  DECLARE @DecisionUserID VARCHAR(20)
  DECLARE @SpecialAcceptDesc NVARCHAR(100)
  DECLARE @DescText NVARCHAR(MAX)
  DECLARE @QcMarking VARCHAR(50)
  DECLARE @CapDungLuong NVARCHAR(20)
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
  DECLARE @IQCSampleLotList NVARCHAR(MAX)


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
							--ManufacturerCode,
							--WeekCode,
							--RevisionsVer,
							DecisionResult,
							DecisionDateTime,
							DecisionUserID,
							SpecialAcceptDesc,
							DescText,
							QcMarking,
							CapDungLuong,
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
							@pProcessUserID AS ChangeUserID,
							IQCSampleLotList
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
										--ManufacturerCode VARCHAR(20),
										--WeekCode VARCHAR(10),
										--RevisionsVer NVARCHAR(30),
										DecisionResult VARCHAR(10),
										DecisionDateTime DATETIMEOFFSET,
										DecisionUserID VARCHAR(20),
										SpecialAcceptDesc NVARCHAR(100),
										DescText NVARCHAR(MAX),
										QcMarking VARCHAR(50),
										CapDungLuong NVARCHAR(20),
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
										ChangeUserID VARCHAR(20),
										IQCSampleLotList NVARCHAR(MAX)
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
					--ManufacturerCode = ISNULL(SourceTable.ManufacturerCode,TargetTable.ManufacturerCode),
					--WeekCode = ISNULL(SourceTable.WeekCode,TargetTable.WeekCode),
					--RevisionsVer = ISNULL(SourceTable.RevisionsVer, TargetTable.RevisionsVer),
					DecisionResult = ISNULL(SourceTable.DecisionResult,TargetTable.DecisionResult),
					DecisionDateTime = ISNULL(SourceTable.DecisionDateTime,TargetTable.DecisionDateTime),
					DecisionUserID = ISNULL(SourceTable.DecisionUserID,TargetTable.DecisionUserID),
					SpecialAcceptDesc = ISNULL(SourceTable.SpecialAcceptDesc,TargetTable.SpecialAcceptDesc),
					DescText = ISNULL(SourceTable.DescText,TargetTable.DescText),
					QcMarking = ISNULL(SourceTable.QcMarking, TargetTable.QcMarking),
					CapDungLuong = ISNULL(SourceTable.CapDungLuong, TargetTable.CapDungLuong),
					VendorQcReport = ISNULL(SourceTable.VendorQcReport,TargetTable.VendorQcReport),
					VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
					MIIExtText01 = ISNULL(SourceTable.MIIExtText01,TargetTable.MIIExtText01),
					MIIExtText02 = ISNULL(SourceTable.MIIExtText02,TargetTable.MIIExtText02),
					MIIExtText03 = ISNULL(SourceTable.MIIExtText03,TargetTable.MIIExtText03),
					MIIExtText04 = ISNULL(SourceTable.MIIExtText04,TargetTable.MIIExtText04),
					MIIExtText05 = ISNULL(SourceTable.MIIExtText05,TargetTable.MIIExtText05),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IQCSampleLotList = ISNULL(SourceTable.IQCSampleLotList,TargetTable.IQCSampleLotList)
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
						--ManufacturerCode,
						--WeekCode,
						--RevisionsVer,
						DecisionResult,
						DecisionDateTime,
						DecisionUserID,
						SpecialAcceptDesc,
						DescText,
						QcMarking,
						CapDungLuong,
						VendorQcReport,
						VendorLotNo,
						MIIExtText01,
						MIIExtText02,
						MIIExtText03,
						MIIExtText04,
						MIIExtText05,
						CreateDateTime,
						CreateUserID,
						IQCSampleLotList
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
							--SourceTable.ManufacturerCode,
							--SourceTable.WeekCode,
							--SourceTable.RevisionsVer,
							SourceTable.DecisionResult,
							SourceTable.DecisionDateTime,
							SourceTable.DecisionUserID,
							SourceTable.SpecialAcceptDesc,
							SourceTable.DescText,
							SourceTable.QcMarking,
							SourceTable.CapDungLuong,
							SourceTable.VendorQcReport,
							SourceTable.VendorLotNo,
							SourceTable.MIIExtText01,
							SourceTable.MIIExtText02,
							SourceTable.MIIExtText03,
							SourceTable.MIIExtText04,
							SourceTable.MIIExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IQCSampleLotList
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
							--ManufacturerCode,
							--WeekCode,
							--RevisionsVer,
							DecisionResult,
							DecisionDateTime,
							DecisionUserID,
							SpecialAcceptDesc,
							DescText,
							QcMarking,
							CapDungLuong,
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
							@pProcessUserID AS ChangeUserID,
							IQCSampleLotList
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
										--ManufacturerCode VARCHAR(20),
										--WeekCode VARCHAR(10),
										--RevisionsVer NVARCHAR(30),
										DecisionResult VARCHAR(10),
										DecisionDateTime DATETIMEOFFSET,
										DecisionUserID VARCHAR(20),
										SpecialAcceptDesc NVARCHAR(100),
										DescText NVARCHAR(MAX),
										QcMarking VARCHAR(50),
										CapDungLuong NVARCHAR(20),
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
										ChangeUserID VARCHAR(20),
										IQCSampleLotList NVARCHAR(MAX)
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
					--BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					TargetSampleQty = ISNULL(SourceTable.TargetSampleQty,TargetTable.TargetSampleQty),
					ActualSampleQty = ISNULL(SourceTable.ActualSampleQty,TargetTable.ActualSampleQty),
					DestoryInspectionQty = ISNULL(SourceTable.DestoryInspectionQty,TargetTable.DestoryInspectionQty),
					ProcessQty = ISNULL(SourceTable.ProcessQty,TargetTable.ProcessQty),
					MaxAcceptDefectQty = ISNULL(SourceTable.MaxAcceptDefectQty,TargetTable.MaxAcceptDefectQty),
					PassedSampleQty = ISNULL(SourceTable.PassedSampleQty,TargetTable.PassedSampleQty),
					DefectSampleQty = ISNULL(SourceTable.DefectSampleQty,TargetTable.DefectSampleQty),
					--ManufacturerCode = ISNULL(SourceTable.ManufacturerCode, TargetTable.ManufacturerCode),
					--WeekCode = ISNULL(SourceTable.WeekCode, TargetTable.WeekCode),
					--RevisionsVer = ISNULL(SourceTable.RevisionsVer, TargetTable.RevisionsVer),
					DecisionResult = ISNULL(SourceTable.DecisionResult,TargetTable.DecisionResult),
					DecisionDateTime = ISNULL(SourceTable.DecisionDateTime,TargetTable.DecisionDateTime),
					DecisionUserID = ISNULL(SourceTable.DecisionUserID,TargetTable.DecisionUserID),
					SpecialAcceptDesc = ISNULL(SourceTable.SpecialAcceptDesc,TargetTable.SpecialAcceptDesc),
					DescText = ISNULL(SourceTable.DescText,TargetTable.DescText),
					QcMarking = ISNULL(SourceTable.QcMarking, TargetTable.QcMarking),
					CapDungLuong = ISNULL(SourceTable.CapDungLuong, TargetTable.CapDungLuong),
					VendorQcReport = ISNULL(SourceTable.VendorQcReport,TargetTable.VendorQcReport),
					VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
					MIIExtText01 = ISNULL(SourceTable.MIIExtText01,TargetTable.MIIExtText01),
					MIIExtText02 = ISNULL(SourceTable.MIIExtText02,TargetTable.MIIExtText02),
					MIIExtText03 = ISNULL(SourceTable.MIIExtText03,TargetTable.MIIExtText03),
					MIIExtText04 = ISNULL(SourceTable.MIIExtText04,TargetTable.MIIExtText04),
					MIIExtText05 = ISNULL(SourceTable.MIIExtText05,TargetTable.MIIExtText05),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IQCSampleLotList = ISNULL(SourceTable.IQCSampleLotList,TargetTable.IQCSampleLotList)
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
						--ManufacturerCode,
						--WeekCode,
						--RevisionsVer,
						DecisionResult,
						DecisionDateTime,
						DecisionUserID,
						SpecialAcceptDesc,
						DescText,
						QcMarking,
						CapDungLuong,
						VendorQcReport,
						VendorLotNo,
						MIIExtText01,
						MIIExtText02,
						MIIExtText03,
						MIIExtText04,
						MIIExtText05,
						CreateDateTime,
						CreateUserID,
						IQCSampleLotList
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
							--SourceTable.ManufacturerCode,
							--SourceTable.WeekCode,
							--SourceTable.RevisionsVer,
							SourceTable.DecisionResult,
							SourceTable.DecisionDateTime,
							SourceTable.DecisionUserID,
							SourceTable.SpecialAcceptDesc,
							SourceTable.DescText,
							SourceTable.QcMarking,
							SourceTable.CapDungLuong,
							SourceTable.VendorQcReport,
							SourceTable.VendorLotNo,
							SourceTable.MIIExtText01,
							SourceTable.MIIExtText02,
							SourceTable.MIIExtText03,
							SourceTable.MIIExtText04,
							SourceTable.MIIExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IQCSampleLotList
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
							MaterialQcNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										MaterialQcNo VARCHAR(20)
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
									--ManufacturerCode,
									--WeekCode,
									--RevisionsVer,
									DecisionResult,
									DecisionDateTime,
									DecisionUserID,
									SpecialAcceptDesc,
									DescText,
									QcMarking,
									CapDungLuong,
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
									ChangeUserID,
									IQCSampleLotList
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
											 --ManufacturerCode VARCHAR(20),
											 --WeekCode VARCHAR(10),
											 --RevisionsVer NVARCHAR(30),
											 DecisionResult VARCHAR(10),
											 DecisionDateTime DATETIMEOFFSET,
											 DecisionUserID VARCHAR(20),
											 SpecialAcceptDesc NVARCHAR(100),
											 DescText NVARCHAR(MAX),
											 QcMarking VARCHAR(50),
											 CapDungLuong NVARCHAR(20),
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
											 ChangeUserID VARCHAR(20),
											 IQCSampleLotList NVARCHAR(MAX)
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
									--ManufacturerCode,
									--WeekCode,
									--RevisionsVer,
									DecisionResult,
									DecisionDateTime,
									DecisionUserID,
									SpecialAcceptDesc,
									DescText,
									QcMarking,
									CapDungLuong,
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
									ChangeUserID,
									IQCSampleLotList
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
											 --ManufacturerCode VARCHAR(20),
											 --WeekCode VARCHAR(10),
											 --RevisionsVer NVARCHAR(20),
											 DecisionResult VARCHAR(10),
											 DecisionDateTime DATETIMEOFFSET,
											 DecisionUserID VARCHAR(20),
											 SpecialAcceptDesc NVARCHAR(100),
											 DescText NVARCHAR(MAX),
											 QcMarking VARCHAR(50),
											 CapDungLuong NVARCHAR(20),
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
											 ChangeUserID VARCHAR(20),
											 IQCSampleLotList NVARCHAR(MAX)
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
									--ManufacturerCode,
									--WeekCode,
									--RevisionsVer,
									DecisionResult,
									DecisionDateTime,
									DecisionUserID,
									SpecialAcceptDesc,
									DescText,
									QcMarking,
									CapDungLuong,
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
									ChangeUserID,
									IQCSampleLotList
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
											 --ManufacturerCode VARCHAR(20),
											 --WeekCode VARCHAR(10),
											 --RevisionsVer NVARCHAR(20),
											 DecisionResult VARCHAR(10),
											 DecisionDateTime DATETIMEOFFSET,
											 DecisionUserID VARCHAR(20),
											 SpecialAcceptDesc NVARCHAR(100),
											 DescText NVARCHAR(MAX),
											 QcMarking VARCHAR(50),
											 CapDungLuong NVARCHAR(20),
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
											 ChangeUserID VARCHAR(20),
											 IQCSampleLotList NVARCHAR(MAX)
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
								 --@ManufacturerCode,
								 --@WeekCode,
								 --@RevisionsVer,
								 @DecisionResult,
								 @DecisionDateTime,
								 @DecisionUserID,
								 @SpecialAcceptDesc,
								 @DescText,
								 @QcMarking,
								 @CapDungLuong,
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
								 @ChangeUserID,
								 @IQCSampleLotList

        


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MaterialQcInfo',@MaterialQcNo OUTPUT
                    END


					-- INSERT부분
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
							--ManufacturerCode,
							--WeekCode,
							--RevisionsVer,
						    DecisionResult,
						    DecisionDateTime,
						    DecisionUserID,
						    SpecialAcceptDesc,
						    DescText,
							QcMarking,
							CapDungLuong,
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
						    ChangeUserID,
						    IQCSampleLotList
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
							--@ManufacturerCode,
							--@WeekCode,
							--@RevisionsVer,
						    @DecisionResult,
						    @DecisionDateTime,
						    @DecisionUserID,
						    @SpecialAcceptDesc,
						    @DescText,
							@QcMarking,
							@CapDungLuong,
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
						    @ChangeUserID,
						    @IQCSampleLotList
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' 
				
				BEGIN 

					IF @CompanyCode = 'VVT' BEGIN -- add by Jackaroe on 2023-01-02
						declare @ccount INT=0;                      ---  add  by  Mr.Tung  on  2022-12-27 

						select  @ccount=count(*) 
						from    STB_MaterialQcInfo  with(nolock) 
						where   IQCSampleLotList = @IQCSampleLotList 
					
						if (@ccount>0) begin 
							declare @errrr nvarchar(500) = N'Trùng mã LotNo='+ @IQCSampleLotList; 
							raiserror(@errrr,16,1); 
							BREAK; 
							return; 
						end 
					END


                    UPDATE STB_MaterialQcInfo 
						SET 
						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    InspectionDocType =   ISNULL(@InspectionDocType,InspectionDocType),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    QcQty =   ISNULL(@QcQty,QcQty),
						    InspectionType =   ISNULL(@InspectionType,InspectionType),
						    --BasicDate =   ISNULL(@BasicDate,BasicDate),
						    TargetSampleQty =   ISNULL(@TargetSampleQty,TargetSampleQty),
						    ActualSampleQty =   ISNULL(@ActualSampleQty,ActualSampleQty),
						    DestoryInspectionQty =   ISNULL(@DestoryInspectionQty,DestoryInspectionQty),
						    ProcessQty =   ISNULL(@ProcessQty,ProcessQty),
						    MaxAcceptDefectQty =   ISNULL(@MaxAcceptDefectQty,MaxAcceptDefectQty),
						    PassedSampleQty =   ISNULL(@PassedSampleQty,PassedSampleQty),
						    DefectSampleQty =   ISNULL(@DefectSampleQty,DefectSampleQty),
							--ManufacturerCode = ISNULL(@ManufacturerCode, ManufacturerCode),
							--WeekCode = ISNULL(@WeekCode, WeekCode),
							--RevisionsVer = ISNULL(@RevisionsVer, RevisionsVer),
						    DecisionResult =   ISNULL(@DecisionResult,DecisionResult),
						    DecisionDateTime =   ISNULL(@DecisionDateTime,DecisionDateTime),
						    DecisionUserID =   ISNULL(@DecisionUserID,DecisionUserID),
						    SpecialAcceptDesc =   ISNULL(@SpecialAcceptDesc,SpecialAcceptDesc),
						    DescText =   ISNULL(@DescText,DescText),
							QcMarking = ISNULL(@QcMarking, QcMarking),
							CapDungLuong = ISNULL(@CapDungLuong, CapDungLuong),
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
						    ChangeUserID = @pProcessUserID,
						    IQCSampleLotList =   ISNULL(@IQCSampleLotList,IQCSampleLotList)
						WHERE
						    MaterialQcNo = @OldMaterialQcNo


  -- 2020.11.10 업데이트문 추가 START   ---------------------------------------
             --   IF @IQCSampleLotList IS NOT NULL 
				   
				  --1. STB_IQcDefectReport 업데이트
				   --Begin Tran
				   -- Commit
				   -- RollBack
					UPDATE STB_IQcDefectReport
						 SET LotNo = @IQCSampleLotList		
						 --SET LotNo = '2222'
					FROM                          STB_MaterialQcInfo     MQI     
							   LEFT OUTER JOIN STB_IQcDefectReport SIQ	   ON SIQ.LotNo = MQI.IQCSampleLotList  
							   LEFT OUTER JOIN STB_NCR_REPORT     NCR   ON NCR.NcrNo = SIQ.DefectReportNo  And NCR.LotNo = MQI.IQCSampleLotList  
					WHERE 1=1
					  AND MQI.MaterialQcNo = @OldMaterialQcNo
					  --AND MQI.MaterialQcNo = '20110500002'
					  
					
				-- 2. STB_NCR_Report 업데이트
					UPDATE STB_NCR_Report
						 SET LotNo = @IQCSampleLotList				
					FROM                          STB_MaterialQcInfo     MQI     
							   LEFT OUTER JOIN STB_IQcDefectReport SIQ		ON SIQ.LotNo = MQI.IQCSampleLotList  
							   LEFT OUTER JOIN STB_NCR_REPORT     NCR   ON NCR.NcrNo = SIQ.DefectReportNo  And NCR.LotNo = MQI.IQCSampleLotList  
					WHERE 1=1
					  AND MQI.MaterialQcNo = @OldMaterialQcNo
					  
          --  END 
-- 2020.11.10 업데이트문 추가 END ---------------------------------------


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

