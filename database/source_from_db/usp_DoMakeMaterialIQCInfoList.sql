
-- =============================================
-- Author:	    shjoo
-- Create date: 2016-02-16
-- Browsable : true
-- Group : 품질관리
-- Description:	입하 시 수입검사 정보를 생성합니다.
-- Modified:

-- usp_DoMakeMaterialIQCDetailList (Insert 테이블 : STB_MaterialQcDetail) 호출하는 프로시저
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialIQCInfoList]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pMaterialDocNo VARCHAR(20) = null,
					@pMaterialCode VARCHAR(50) = NULL,
					@pInspectionType VARCHAR(20) = NULL,
					@pMaterialStockAttribute VARCHAR(20) = NULL, 
					@pStockAttrib1 VARCHAR(20) = NULL,
					@pVendorLotNo VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @MaxKeyField VARCHAR(20)
	
	-- Declare Columns Variable
	DECLARE @MaterialIqcNo VARCHAR(20)
	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @InspectionType VARCHAR(20) = @pInspectionType
	DECLARE @MaterialStockAttribute VARCHAR(20) = @pMaterialStockAttribute
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @VendorLotNo VARCHAR(100) = ISNULL(@pVendorLotNo,'')
	
	DECLARE @MaxSampleQty BIGINT
	DECLARE @MaxDefectQty BIGINT
	

    EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialQCInfo',
												@MaterialIqcNo OUTPUT
			
	------------------------------- Cursor ~
				
    BEGIN					

	PRINT '3-1'
		
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
			    TargetSampleQty, --
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
		SELECT
				@MaterialIqcNo,
			    MDI.TargetCompanyCode,
			    MDI.TargetWorkCenterCode,
				'IQC',
			    MDD.MaterialCode,
			    SUM(MDD.PickingAssignQty) AS ArriveQty,
			    @InspectionType AS InspectionType,
				MDI.BasicDate,
			    0 AS TargetSampleQty,
			    0 AS ActualSampleQty,
			    0 AS DestoryInspectionQty,
			    SUM(MDD.PickingAssignQty) AS GrProcessQty,
			    0 AS MaxAcceptDefectQty,
			    0 AS PassedSampleQty,
			    0 AS DefectSampleQty,
			    'None' AS DecisionResult,
			    NULL DecisionDateTime,
			    NULL DecisionUserID,
			    NULL SpecialAcceptDesc,
			    NULL DescText,
			    NULL AS VendorQcReport,
				@VendorLotNo,
			    NULL AS MIIExtText01,
			    NULL AS MIIExtText02,
			    NULL AS MIIExtText03,
			    NULL AS MIIExtText04,
			    NULL AS MIIExtText05,
			    GETDATE(),
			    @pProcessUserID,
			    NULL,
			    NULL
		FROM
				STB_MaterialDocDetail MDD
				LEFT OUTER JOIN STB_MaterialDocInfo MDI
					ON (MDI.MaterialDocNo = MDD.MaterialDocNo)
		WHERE
				MDD.MaterialDocNo = @MaterialDocNo AND
				MDD.MaterialCode = @MaterialCode AND
				MDD.InspectionType = @InspectionType AND
				MDD.MaterialStockAttribute = @MaterialStockAttribute AND
				MDD.StockAttrib1 = @StockAttrib1 AND
				((MDD.VendorLotNo IS NULL) OR (MDD.VendorLotNo = @VendorLotNo))
		GROUP BY
				MDI.TargetCompanyCode,
			    MDI.TargetWorkCenterCode,
			    MDI.MaterialDocNo,
				MDI.BasicDate,
			    MDD.MaterialCode
						
		PRINT '3-2'
			
		UPDATE STB_MaterialDocDetail
		SET
				MaterialIqcNo = @MaterialIqcNo
		WHERE
				MaterialDocNo = @MaterialDocNo AND
				MaterialCode = @MaterialCode AND
				InspectionType = @InspectionType AND
				MaterialStockAttribute = @MaterialStockAttribute AND
				StockAttrib1 = @StockAttrib1 AND
				((VendorLotNo IS NULL) OR (VendorLotNo = @VendorLotNo))
		-- ~~여기까지 Master
		

		PRINT '3-3'
		-- DetailProcedure 호출
		exec usp_DoMakeMaterialIQCDetailList @ProcessUserID, @ProcessLanguage, @MaterialIqcNo
		
		PRINT '@MaxSampleQty ::::: ' + CONVERT(VARCHAR(20), @MaxSampleQty)
		PRINT '@MaxDefectQty ::::: ' + CONVERT(VARCHAR(20), @MaxDefectQty)

		SET @MaxSampleQty = (SELECT ISNULL(MAX(RequestSampleQty), 0) FROM STB_MaterialQcDetail WHERE MaterialQcNo = @MaterialIqcNo)
		SET @MaxDefectQty = (SELECT ISNULL(MAX(MaxAcceptDefectQty), 0) FROM STB_MaterialQcDetail WHERE MaterialQcNo = @MaterialIqcNo)

		UPDATE STB_MaterialQcInfo
		SET
				TargetSampleQty = @MaxSampleQty,
				MaxAcceptDefectQty = @MaxDefectQty
		WHERE
				MaterialQcNo = @MaterialIqcNo
	END			

END
