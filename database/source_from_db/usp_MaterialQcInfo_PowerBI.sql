-- =============================================
-- Author:	    Kangs(kilee@vina.co.kr)
-- Create date: 2020-11-18
-- Browsable : True
-- Group : 품질관리>PowerBI용
-- Description : 박진호님 PowerBI용
-- Modified:  

-- EXEC usp_MaterialQcInfo_PowerBI '','','','','','2020-04-20','2020-04-23','','IQC', 'VVT' ,'ROH' ,'SEPARATOR'
-- EXEC usp_MaterialQcInfo_PowerBI  '','','','','','2020-10-01','2020-11-05','None','IQC', 'VNT' ,'' ,'', '2020-10-01','2020-11-05'
-- ====================================================================================================
Create PROCEDURE [dbo].[usp_MaterialQcInfo_PowerBI]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialDocNo VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pCustomerCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pDecisionResult VARCHAR(10) = NULL,
						@pInspectionDocType VARCHAR(20) = 'IQC',
						@pCompanyCode VARCHAR(20) = NULL,                                             			
						@pMaterialTypeCode  VARCHAR(20) = NULL,                                         			
						@pProductGroupCode VARCHAR(20) = NULL,
						@pDecisionFromDate DATE = NULL,
						@pDecisionToDate DATE = NULL
						
AS

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialDeliveryNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '%' ELSE @pMaterialDocNo END
	DECLARE @MaterialCode         VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '%' ELSE @pMaterialCode   END

	DECLARE @FromDate DATE    = CASE WHEN @pFromDate IS NULL THEN GETDATE() ELSE @pFromDate END
	DECLARE @ToDate    DATE     = CASE WHEN @pToDate IS NULL    THEN GETDATE() ELSE @pToDate    END

	DECLARE @DecisionResult      VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '%' ELSE @pDecisionResult END 
	DECLARE @CustomerCode      VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END 
	DECLARE @InspectionDocType VARCHAR(10) = @pInspectionDocType
	DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END              -- 사업장코드 kilee 추가 (2020.03.31)

	DECLARE @MaterialTypeCode  VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END       -- 코드 kilee 추가 (2020.03.31)
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END     -- 코드 kilee 추가 (2020.03.31)

	DECLARE @DecisionFromDate DATE = CASE WHEN @pDecisionFromDate IS NULL THEN GETDATE() ELSE @pDecisionFromDate END   -- 판정일시 조건추가 (박진호, 2020-08-11)
	DECLARE @DecisionToDate    DATE = CASE WHEN @pDecisionToDate     IS NULL THEN GETDATE() ELSE @pDecisionToDate    END


	SELECT	       
			MQI.MaterialQcNo AS OldMaterialQcNo,
			MQI.MaterialQcNo,
			DR.DecisionResultText,
			MQI.CompanyCode,
			CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,			
			MDI.MaterialDocNo,
	        MDI.TargetMaterialWarehouseCode,
	        MW.MaterialWarehouseName,
			MDI.SourceCustomerCode,
	        C.CustomerName,
			MQI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialUnit,                            -- 2020.04.24 추가 (박진호대리요청)
			MM.MaterialSource,
			MM.AvgGrDay,
			MM.IsPurchase,
			MM.IsOrder,
			MM.IsClosed,
			MM.BeforeMaterialCode,
			MQI.QcQty,
			CASE WHEN MIII.InspectionType IS NULL      THEN MQI.InspectionType ELSE MQI.InspectionType END AS InspectionType ,    -- 2020.07.09
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,                -- 실샘플수량
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,                                  -- 불합격시료수량
			MQI.DecisionResult,
			MQI.DecisionDateTime,                                 -- 판정일시
			MQI.DecisionUserID       AS DecisionUserID,      -- 품질검사자 ID                       			
			SUI.UserName              AS DecisionName,       -- 품질검사자 Name (2020.07.21 추가)
			MQI.SpecialAcceptDesc,			
			MQI.IQCSampleLotList AS IQCSampleLotList,   -- 검사 Lot No  (박진호님 요청)      
			MQI.VendorQcReport,
			MQI.VendorLotNo,
			MQI.MIIExtText01,
			MQI.MIIExtText02,		
		    CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) AS RequestDate,   -- 회신요청일 : 검사일+7일 (2020.07.20 박진호대리)
			MQI.MIIExtText04,
		   Case when  MQI.MIIExtText04       = 0 then 0 when MDD.LotNo_Qty = 0         then 0 	else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.MIIExtText04) / CONVERT(NUMERIC(20,5), MDD.LotNo_Qty)  * 100))               End as DefectiveRate,   -- Lot불량율(%) 박진호요청
		   Case when  MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0  then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- 불량율(PPM) 박진호요청			
			MQI.MIIExtText05,
			MQI.CreateDateTime,
		    CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)                                                                                                                AS TestDate,      -- 2019.07.24 kilee 추가 (합격라벨관련, 검사일자) 
			MQI.CreateUserID                                                                                                                                                            AS CreateUserID,
	    -- MQI.CreateUserID                                                                                                                                                             AS TestUser,      -- 2019.07.24 kilee 추가 (합격라벨관련)			                                                 
		   (SELECT STD.UserName FROM SmartFramework.dbo.STB_UserInfo STD Where STD.UserID = MQI.CreateUserID)                                     AS TestUser,      -- 2019.07.24 kilee 추가 (합격라벨관련, 검사자)				
			CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MQI.CreateDateTime), 121)), 121) AS PackDate,      -- 2019.07.24 kilee 추가 (합격라벨관련, 유효일자)
			MQI.ChangeDateTime,
			MQI.ChangeUserID,
			MQI.BasicDate,
		    'Report' AS CommandType,
			0 as LabelQty
			, SIQ.DefectReportNo AS     DefectReportNo       -- 부적합번호
			, MDD.LotNo_Qty                                           -- Lot수량   (2020-09-06 추가 )
	
	FROM                        STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 
			LEFT OUTER JOIN STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			
			LEFT OUTER JOIN (
										 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH 수정 DocDetail에 같은 자재를 2개 등록할경우 한개의 수입검사 문서가 만들어지기 때문에 바로 Join하면 n개가 나올수 있어서 DISTINCT
													MDD.MaterialIqcNo,
													Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 추가 	
											FROM
													STB_MaterialDocDetail MDD WITH(NOLOCK)
													INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
													INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
													INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
											WHERE
													MQI.InspectionDocType LIKE @InspectionDocType 
													AND	(MQI.DecisionResult LIKE @DecisionResult) 
													AND	(MQI.MaterialCode LIKE @MaterialCode) 
													AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
													AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 
													AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)
											Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 추가 	
									) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult
		 -- LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)			--	ON MVM.MaterialCode = MQI.MaterialCode AND			--	MVM.CustomerCode = MDI.SourceCustomerCode
			LEFT OUTER JOIN STB_MaterialQcInspectionItem MIII				ON MIII.MaterialCode = MQI.MaterialCode  AND MIII.QcInspectionItemCode = MQI.MaterialCode 			
		-- LEFT OUTER JOIN STB_IQcDefectReport SIQ				             ON SIQ.LotNo = MQI.MaterialQcNo  	
			LEFT OUTER JOIN STB_IQcDefectReport SIQ				             ON SIQ.LotNo = MQI.IQCSampleLotList  						
		 -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	     ON QDR.PublishEmpID = EI1.EmployeeNo
		  LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	     ON SUI.UserID = MQI.DecisionUserID
	WHERE 1=1
			AND MQI.InspectionDocType LIKE @InspectionDocType 
			AND (MQI.DecisionResult LIKE @DecisionResult) 
			AND (MQI.MaterialCode LIKE @MaterialCode) 
			AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
			AND (MDI.SourceCustomerCode LIKE @CustomerCode) 
			AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)         --OR  (MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시 조건추가 (박진호, 2020.08.11)
			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))               -- 사업장코드 kilee 추가   (2020.03.31)
			AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- 자재유형코드 kilee 추가 (2020.06.29)
			AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- 자재그룹코드 kilee 추가 (2020.06.29)
		   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시 조건추가 (박진호, 2020.08.11)		  		 
		 
END
