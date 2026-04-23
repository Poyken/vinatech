-- =============================================
-- Author:	    Kangs (kilee@vina.co.kr)
-- Create date: 2021-04-27
-- Browsable : true
-- Group : 품질관리 > 제품검사(Lot No)
-- Description:	출하검사 관리 화면을 조회합니다.
-- Modified:  [C530] 시료별 제품검사

--  usp_GetMaterialOQcInfo_DashBoard @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialCode=default,@pDecisionFromDate='2020-09-01',@pDecisionToDate='2020-09-11',@pDecisionResult=default,@pBarCode='VJKR072R750607'
-- usp_GetMaterialOQcInfo_DashBoard @@pCompanyCode= 'VNT', @pDecisionFromDate ='2021-09-01'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialOQcInfo_DashBoard]
	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
 --   @pMaterialCode VARCHAR(50) = NULL,
	--@pDecisionResult VARCHAR(10) = NULL,
	--@pBarCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	--@pProdInspWorkerCode VARCHAR(20) = NULL ,
	@pDecisionFromDate DATE = null,
	@pDecisionToDate DATE = null


AS
BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @MaterialCode VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '%'          ELSE @pMaterialCode   END
	--DECLARE @DecisionResult VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '%'           ELSE @pDecisionResult END 
	--DECLARE @BarCode        VARCHAR(20) = CASE WHEN ISNULL(@pBarCode,'') = ''        THEN '%'           ELSE @pBarCode        END 
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*'            ELSE @pCompanyCode END  --2019.12.25 추가
	--DECLARE @ProdInspWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProdInspWorkerCode,'') = '' THEN '*' ELSE @pProdInspWorkerCode END
	DECLARE @DecisionFromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pDecisionFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @DecisionToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pDecisionToDate)), 121) + ' 23:59:59'     -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    


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
			--MQI.BasicDate,
			MQI.DecisionDateTime AS DecisionDate,          --2020.09.14 
			PWI.WorkerName               --#2020.05.18
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MQI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON MQI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)	ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_DecisionResult DR                    			ON DR.DecisionResult = MQI.DecisionResult
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI                            ON PWI.WorkerCode = MQI.MIIExtText01                  
	WHERE 1=1
			AND (MQI.InspectionDocType = 'OQC') 
			--AND (MQI.DecisionResult LIKE @DecisionResult) 
			--AND (MQI.MaterialCode LIKE @MaterialCode) 
			AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시로 변경 (이미정, 2020.09.14)	 

			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                                                                                -- CompanyCode 추가 (2019.12.25)
		
			--AND (MQI.MaterialQcNo LIKE @BarCode 
			--  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode) 
			--  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
			--AND MQI.MaterialQcNo Not In ('VJLU253R850601', 'VJLU183R850609', 'VJLU153R850602', 'VJLU183R850612', 'VJMJ013R850602', 'VJLU113R850606', 'VJLU153R850603')  --22. 01. 20 삼성 오딧 관련 추가. 22. 01. 24일 이후 삭제 예정
		
				
END
