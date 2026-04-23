-- =============================================
-- Author: kilee 
-- Create date: 2020-03-12
-- Browsable : true
-- Group : Power-BI
-- Description:	
-- Modified:  

-- 프로시저 실행 : EXEC usp_GetMaterialOQcInfo_PowerBI  @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialCode=default,@pFromDate='2019-07-28',@pToDate='2019-07-29',@pDecisionResult=default,@pBarCode='19072900001'
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetMaterialOQcInfo_PowerBI]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pDecisionResult VARCHAR(10) = NULL,
	@pBarCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL      

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialCode VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '%'          ELSE @pMaterialCode   END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @DecisionResult VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '%'           ELSE @pDecisionResult END 
	DECLARE @BarCode        VARCHAR(20) = CASE WHEN ISNULL(@pBarCode,'') = ''        THEN '%'           ELSE @pBarCode        END 
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*'            ELSE @pCompanyCode END               --2019.12.25 추가
	
	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		SET @FromDate = CONVERT(CHAR(4), GETDATE(), 121) + '-01-01'
		SET @ToDate = CONVERT(CHAR(4), GETDATE(), 121) + '-12-31'
	END
	 
	SELECT
			MQI.MaterialQcNo AS OldMaterialQcNo,
			MQI.MaterialQcNo,
			DR.DecisionResultText,
			MQI.CompanyCode,
			CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,

			MQI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			MM.MaterialSpec,
			MM.MaterialSource,
			MM.BeforeMaterialCode,

			MQI.QcQty,
			MQI.InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			MQI.DecisionResult,
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			MQI.SpecialAcceptDesc,
			MQI.DescText,
			MQI.VendorQcReport,
			MQI.VendorLotNo,
			MQI.MIIExtText01,
			MQI.MIIExtText02,
			MQI.MIIExtText03,
			MQI.MIIExtText04,
			MQI.MIIExtText05,
			MQI.CreateDateTime,
			MQI.CreateUserID,
			MQI.ChangeDateTime,
			MQI.ChangeUserID,
			MQI.BasicDate,	
			
			--2020.03.13 추가사항		
			SI.LineCode,
			LI.LineName	
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MQI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON MQI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)				ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)				ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_DecisionResult DR                    				ON DR.DecisionResult = MQI.DecisionResult

			-- 여기부터가 제품검사화면과 다른점 (주영진부장 요청)
			LEFT OUTER JOIN (SELECT LotNumber, MAX(InputLineCode) AS LineCode FROM STB_SetInfo GROUP BY LotNumber) SI ON SI.LotNumber = MQI.MaterialQcNo   
			LEFT OUTER JOIN STB_LineInfo LI																							             ON SI.LineCode = LI.LineCode
	WHERE 1=1
			AND (MQI.InspectionDocType = 'OQC') 
			AND (MQI.DecisionResult LIKE @DecisionResult) 
			AND (MQI.MaterialCode LIKE @MaterialCode) 
			AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)
			-- 대표Lot로 묶인 제품검사 Lot의 경우 내부 Lot로도 대표 Lot를 조회할 수 있도록 조회조건 수정. 품질부문. 2019.10.28. By Jackaroe
			AND (MQI.MaterialQcNo LIKE @BarCode
					OR MQI.MaterialQcNo IN (SELECT LotNumber FROM STB_SetInfo WHERE Barcode = @Barcode)
			) 

			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                                           -- 2019.12.25 추가
			--AND MQI.MaterialQcNo Not In ('VJLU253R850601', 'VJLU183R850609', 'VJLU153R850602', 'VJLU183R850612', 'VJMJ013R850602', 'VJLU113R850606', 'VJLU153R850603')  --22. 01. 20 삼성 오딧 관련 추가. 22. 01. 24일 이후 삭제 예정
END