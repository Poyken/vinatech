-- =============================================
-- Hotfix ID: 10_FIX_INCOMING_QC_HUNG_YEN_C220_SPS
-- Target Object: 20 SPs and 1 Table for Hung Yen Incoming QC (C220)
-- Author: vanduc
-- Date: 2026-06-11
-- Description: Táº¡o báº£ng cáº¥u hÃ¬nh vÃ  20 Stored Procedures liÃªn quan Ä‘áº¿n mÃ n hÃ¬nh C220 HÆ°ng YÃªn (_HY).
--              CÃ¡c báº£ng nghiá»‡p vá»¥ giao dá»‹ch (STB_MaterialQcInfo, Detail, SampleResult) Ä‘Æ°á»£c giá»¯ chung.
--              CÃ¡c báº£ng cáº¥u hÃ¬nh (STB_QcInspectionGroup, Item, MaterialSpec) Ä‘Æ°á»£c Ä‘á»•i sang báº£ng _HY.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 10_FIX_INCOMING_QC_HUNG_YEN_C220_SPS...';
GO

-- 1. Táº O Báº¢NG Cáº¤U HÃŒNH STB_MaterialQcInspectionGroup_HY Náº¾U CHÆ¯A Tá»’N Táº I
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_MaterialQcInspectionGroup_HY')
BEGIN
    CREATE TABLE [dbo].[STB_MaterialQcInspectionGroup_HY] (
        [MaterialCode] VARCHAR(50) NOT NULL,
        [QcInspectionGroupCode] VARCHAR(20) NOT NULL,
        [GroupInspectionPrior] INT NULL,
        [GroupReportPrior] INT NULL,
        [IsUsed] VARCHAR(1) NULL,
        [CreateDateTime] DATETIME NULL,
        [CreateUserID] VARCHAR(20) NULL,
        [ChangeDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL,
        CONSTRAINT [PK_STB_MaterialQcInspectionGroup_HY] PRIMARY KEY CLUSTERED ([MaterialCode] ASC, [QcInspectionGroupCode] ASC)
    );
    PRINT 'Table STB_MaterialQcInspectionGroup_HY created successfully.';
END
GO

-- =========================================================
-- Stored Procedure: usp_MaterialQcInfo_HY_get (Cloned from usp_MaterialQcInfo_get)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_MaterialQcInfo_HY_get];
GO

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리>[C520] 시료별수입검사 >[C210] 수입검사의뢰  /  [C220] 시료별 수입검사 > 1-Tab (시료별수입검사리스트)
-- Description : 수입검사 관리 화면을 조회합니다.  Tab1

-- Modified:  2019.07.24 합격라벨 항목추가 (kilee)
--               2020.07.14 DefectReportNo(품질부적합번호)추가 (kilee) 
--               2020.08.11 판정일시로도 조회 (박진호 요청)      
--               2020.08.31 박진호 요청 여러건 적용예정                 
--               2020.10.21 박진호 요청 수량추가 및 여러건
--               2021.11.23 소재사업부 작업장코드 추가

-- 프로시저 실행:  usp_MaterialQcInfo_HY_get '','','','','','2021-03-01','2021-12-25', 'Reject' ,'IQC', 'VNT' ,'' ,'', '2021-03-20','2021-12-31'
--                      usp_MaterialQcInfo_HY_get '','','','','','2021-03-01','2021-12-25', 'Reject' ,'IQC', 'VNT' ,'VNT_F1' ,'', ' ' , '2021-03-20','2021-12-31'
-- ====================================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInfo_HY_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialDocNo VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pCustomerCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pDecisionResult VARCHAR(10) = NULL,
						@pInspectionDocType VARCHAR(20) = 'IQC',
						@pCompanyCode VARCHAR(20) = NULL,                                             -- 사업장코드 kilee 추가 (2020.03.31)	
						@pWorkCenterCode VARCHAR(20) = NULL,                                             -- 작업장코드 kilee 추가 (2021.11.23)	
						@pMaterialTypeCode  VARCHAR(20) = NULL,                                         -- 2020.06.29 추가						
						@pProductGroupCode VARCHAR(20) = NULL,
						@pDecisionFromDate DATE = NULL,
						@pDecisionToDate DATE = NULL,
						@pProdInspWorkerCode VARCHAR(20) = NULL              --2021.03.24 추가
						
AS

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialDeliveryNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '%' ELSE @pMaterialDocNo END
	DECLARE @MaterialCode         VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '%' ELSE @pMaterialCode   END

	DECLARE @FromDate DATE    = CASE WHEN @pFromDate IS NULL THEN GETDATE() ELSE @pFromDate END
	DECLARE @ToDate    DATE     = CASE WHEN @pToDate IS NULL    THEN GETDATE() ELSE DATEADD(day, 1, @pToDate)    END

	DECLARE @DecisionResult      VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '%' ELSE @pDecisionResult END 
	DECLARE @CustomerCode      VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END 
	DECLARE @InspectionDocType VARCHAR(10) = @pInspectionDocType
	DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END              -- 사업장코드 kilee 추가 (2020.03.31)
	DECLARE @WorkCenterCode    VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END        -- 작업장코드 kilee 추가 (2021.11.23)

	DECLARE @MaterialTypeCode  VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END       -- 코드 kilee 추가 (2020.03.31)
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END     -- 코드 kilee 추가 (2020.03.31)

	DECLARE @DecisionFromDate DATE = CASE WHEN @pDecisionFromDate IS NULL THEN GETDATE() ELSE @pDecisionFromDate END   -- 판정일시 조건추가 (박진호, 2020-08-11)
	DECLARE @DecisionToDate    DATE = CASE WHEN @pDecisionToDate     IS NULL THEN GETDATE() ELSE DATEADD(day, 1, @pDecisionToDate)    END

	DECLARE @ProdInspWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProdInspWorkerCode,'') = '' THEN '*' ELSE @pProdInspWorkerCode END


	--add by Mr.Tung 2022-Sep-22, 1840  Adit
	declare @tmpDefectReportNo VARCHAR(1)= (case when @CompanyCode='VVT' then '' else '*' end) 

	Declare @MaterialWarehouseCode VARCHAR(20)

	SELECT @MaterialWarehouseCode = MaterialWarehouseCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	IF @WorkCenterCode = 'VNT_F2' AND ISNULL(@MaterialWarehouseCode, '') <> '' AND ISNULL(@MaterialWarehouseCode, '') <> 'W02' BEGIN
		-- 작업장이 VNT_F2이고, 창고정보가 있으면서 MEA가 아니면
		--SET @ProductGroupCode = 'CATALYST SUPPORT'
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
			CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27
			--MQI.InspectionType as aaa,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,                -- 실샘플수량
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,                                  -- 불합격시료수량
			MDD2.ManufacturerCode,
			C2.CustomerName AS ManufacturerName,
			MDD2.WeekCode,
			MDD2.RevisionsVer,		-- add for BG2
			MQI.DefectDetail,		-- add for IQC
			MQI.DecisionResult,
			MQI.DecisionDateTime,                                 -- 판정일시
			MQI.DecisionUserID       AS DecisionUserID,      -- 품질검사자 ID                       			
			SUI.UserName              AS DecisionName,       -- 품질검사자 Name (2020.07.21 추가)
			MQI.SpecialAcceptDesc,			
			MQI.IQCSampleLotList AS IQCSampleLotList,   -- 검사 Lot No  (박진호님 요청)      
			MQI.VendorQcReport,
			MQI.VendorLotNo,
			MQI.MIIExtText01,     -- 검사자
			(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 추가사항

			MQI.MIIExtText02,		
		    CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) AS RequestDate,   -- 회신요청일 : 검사일+7일 (2020.07.20 박진호대리)
			MQI.MIIExtText04,
		   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
		   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- 불량율(PPM) 박진호요청		
		   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
		   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- 불량율(PPM) 박진호요청							
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
		-- , MDD.MaterialIqcNo                    -- 2020.04.24 추가 (원본백업)
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
		    LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	
			LEFT OUTER JOIN STB_IQcDefectReport SIQ	WITH(NOLOCK)             ON SIQ.LotNo = MQI.IQCSampleLotList  						
		    LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID
			LEFT OUTER JOIN STB_MaterialDocDetail MDD2 WITH(NOLOCK) ON MDD2.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_CustomerInfo C2 WITH(NOLOCK)				ON MDD2.ManufacturerCode = C2.CustomerCode	-- BG2
	WHERE 1=1
			AND MQI.InspectionDocType LIKE @InspectionDocType 
			AND (MQI.DecisionResult LIKE @DecisionResult) 
			AND (MQI.MaterialCode LIKE @MaterialCode) 
			AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
			AND (MDI.SourceCustomerCode LIKE @CustomerCode) 
			AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        
			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- 사업장코드 kilee 추가   (2020.03.31)
			AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- 작업장코드 kilee 추가   (2021.11.23)
			AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- 자재유형코드 kilee 추가 (2020.06.29)
			--AND MM.ProductGroupCode LIKE 'CATALYST SUPPORT'                                        -- 자재그룹코드 kilee 추가 (2020.06.29)
		   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시 조건추가 (박진호, 2020.08.11)	

	END ELSE BEGIN
		IF @pProcessUserID = 'yjyu' BEGIN
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
				CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27
				--MQI.InspectionType as aaa,
				MQI.TargetSampleQty,
				MQI.ActualSampleQty,                -- 실샘플수량
				MQI.DestoryInspectionQty,
				MQI.ProcessQty,
				MQI.MaxAcceptDefectQty,
				MQI.PassedSampleQty,
				MQI.DefectSampleQty,                                  -- 불합격시료수량
				--MQI.RevisionsVer,		-- add for BG2
				MQI.DecisionResult,
				MQI.DecisionDateTime,                                 -- 판정일시
				MQI.DecisionUserID       AS DecisionUserID,      -- 품질검사자 ID                       			
				SUI.UserName              AS DecisionName,       -- 품질검사자 Name (2020.07.21 추가)
				MQI.SpecialAcceptDesc,			
				'' AS IQCSampleLotList,   -- 검사 Lot No  (박진호님 요청)      
				MQI.VendorQcReport,
				MQI.VendorLotNo,
				MQI.MIIExtText01,     -- 검사자
				(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 추가사항

				MQI.MIIExtText02,		
				CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) AS RequestDate,   -- 회신요청일 : 검사일+7일 (2020.07.20 박진호대리)
				MQI.MIIExtText04,
			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- 불량율(PPM) 박진호요청		
			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- 불량율(PPM) 박진호요청							
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
			-- , MDD.MaterialIqcNo                    -- 2020.04.24 추가 (원본백업)
				, '' AS     DefectReportNo       -- 부적합번호
				, MDD.LotNo_Qty                                           -- Lot수량   (2020-09-06 추가 )
			
	
		FROM                        [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 

				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			
				LEFT OUTER JOIN (
											 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH 수정 DocDetail에 같은 자재를 2개 등록할경우 한개의 수입검사 문서가 만들어지기 때문에 바로 Join하면 n개가 나올수 있어서 DISTINCT
														MDD.MaterialIqcNo,
														Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 추가 	
												FROM
														[110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocDetail MDD WITH(NOLOCK)
														INNER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
														INNER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
														INNER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
												WHERE
														MQI.InspectionDocType LIKE @InspectionDocType 
														AND	(MQI.DecisionResult LIKE @DecisionResult) 
														AND	(MQI.MaterialCode LIKE @MaterialCode) 
														AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
														AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 
														AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)
												Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 추가 	
										) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult
				LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	
				LEFT OUTER JOIN  [110.11.27.5].SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID
		WHERE 1=1
				AND MQI.InspectionDocType LIKE @InspectionDocType 
				AND (MQI.DecisionResult LIKE @DecisionResult) 
				AND (MQI.MaterialCode LIKE @MaterialCode) 
				AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
				AND (MDI.SourceCustomerCode LIKE @CustomerCode) 
				AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        
				AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- 사업장코드 kilee 추가   (2020.03.31)
				AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- 작업장코드 kilee 추가   (2021.11.23)
				AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- 자재유형코드 kilee 추가 (2020.06.29)
				AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- 자재그룹코드 kilee 추가 (2020.06.29)
				--AND MM.ProductGroupCode NOT LIKE 'CATALYST SUPPORT'
			   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시 조건추가 (박진호, 2020.08.11)		
			   --AND (MQI.IQCSampleLotList NOT IN ('D902201060201', 'D042203010201', 'D042203030201', 'D042203030201', 'D872203050201', 'D042203070202', '220404', 'D972205100202', 'D972206190201', 'D972206190201', 'D872207050202', 'D872207050202', 'D962209260202', 'D1022210030201', 'D952211070201', 'D952211070201', 'D872111260201')
			   --                    OR MQI.IQCSampleLotList IS NULL) --2022.11.18 김민수 요쳥 -- IQCSampleLotList이 필수값이 아니므로 NOT NULL을 걸면 NULL인 모든 데이터가 제외됨.

		END ELSE BEGIN

		--	raiserror(@DecisionResult,16,1)
		--	SELECT	       
		--		MQI.MaterialQcNo AS OldMaterialQcNo,
		--		MQI.MaterialQcNo,
		--		DR.DecisionResultText,
		--		MQI.CompanyCode,
		--		CI.CompanyName,
		--		MQI.WorkCenterCode,
		--		WCI.WorkCenterName,			
		--		MDI.MaterialDocNo,
		--		MDI.TargetMaterialWarehouseCode,
		--		MW.MaterialWarehouseName,
		--		MDI.SourceCustomerCode,
		--		C.CustomerName,
		--		MQI.MaterialCode,
		--		case when MQI.MaterialCode in ('GBCP00-S06')
		--		then N'전해액 2.7 V  SPDBF4/ACN: SL=8:2'
		--		else MM.MaterialName
		--		end as MaterialName
		--		,
		--		MM.MaterialTypeCode,
		--		MT.BasicMaterialType,
		--		MT.MaterialTypeName,
		--		MM.ProductGroupCode,
		--		PG.ProductGroupName,
		--		MM.MaterialUnit,
		--		MM.BasicGrQty,
		--		MM.MaterialSpec,
		--		MM.MaterialUnit,                            -- 2020.04.24 추가 (박진호대리요청)
		--		MM.MaterialSource,
		--		MM.AvgGrDay,
		--		MM.IsPurchase,
		--		MM.IsOrder,
		--		MM.IsClosed,
		--		MM.BeforeMaterialCode,
		--		MQI.QcQty,
		--		CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27
		--		--MQI.InspectionType as aaa,
		--		MQI.TargetSampleQty,
		--		MQI.ActualSampleQty,                -- 실샘플수량
		--		MQI.DestoryInspectionQty,
		--		MQI.ProcessQty,
		--		MQI.MaxAcceptDefectQty,
		--		MQI.PassedSampleQty,
		--		MQI.DefectSampleQty,                                  -- 불합격시료수량
		--		MQI.DecisionResult,
		--		MQI.DecisionDateTime,                                 -- 판정일시
		--		MQI.DecisionUserID       AS DecisionUserID,      -- 품질검사자 ID                       			
		--		SUI.UserName              AS DecisionName,       -- 품질검사자 Name (2020.07.21 추가)
		--		MQI.SpecialAcceptDesc,			
		--		MQI.IQCSampleLotList AS IQCSampleLotList,   -- 검사 Lot No  (박진호님 요청)      
		--		MQI.VendorQcReport,
		--		MQI.VendorLotNo,
		--		MQI.MIIExtText01,     -- 검사자
		--		(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 추가사항

		--		MQI.MIIExtText02,		
		--		CASE 
		--			WHEN MQI.MaterialQcNo IN ('25012400007','25031100001', '25040500010', '25072100002', '25102800016') THEN CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)  -- update 2025-08-27 for audit
		--			ELSE CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) 
		--		END	AS RequestDate,		   -- 회신요청일 : 검사일+7일 (2020.07.20 박진호대리)
		--		MQI.MIIExtText04,
		--	   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
		--	   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- 불량율(PPM) 박진호요청		
		--	   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
		--	   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- 불량율(PPM) 박진호요청							
		--		MQI.MIIExtText05,
		--		MQI.CreateDateTime,
		--		CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)                                                                                                                AS TestDate,      -- 2019.07.24 kilee 추가 (합격라벨관련, 검사일자) 
		--		MQI.CreateUserID                                                                                                                                                            AS CreateUserID,
		--	-- MQI.CreateUserID                                                                                                                                                             AS TestUser,      -- 2019.07.24 kilee 추가 (합격라벨관련)			                                                 
		--	   (SELECT STD.UserName FROM SmartFramework.dbo.STB_UserInfo STD Where STD.UserID = MQI.CreateUserID)                                     AS TestUser,      -- 2019.07.24 kilee 추가 (합격라벨관련, 검사자)				
		--		CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MQI.CreateDateTime), 121)), 121) AS PackDate,      -- 2019.07.24 kilee 추가 (합격라벨관련, 유효일자)
		--		MQI.ChangeDateTime,
		--		MQI.ChangeUserID,
		--		MQI.BasicDate,
		--		'Report' AS CommandType,
		--		0 as LabelQty
		--	-- , MDD.MaterialIqcNo                    -- 2020.04.24 추가 (원본백업)
		--		, SIQ.DefectReportNo AS     DefectReportNo       -- 부적합번호
		--		, MDD.LotNo_Qty                                           -- Lot수량   (2020-09-06 추가 )
			
	
		--FROM                        STB_MaterialQcInfo MQI  WITH(NOLOCK)	 	 

		--		LEFT OUTER JOIN STB_CompanyInfo CI       WITH(NOLOCK)	ON MQI.CompanyCode = CI.CompanyCode
		--		LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)	ON MQI.WorkCenterCode = WCI.WorkCenterCode			
		--		LEFT OUTER JOIN (
		--									 SELECT DISTINCT MDD.MaterialDocNo,                  -- 2019-04-18 JGH 수정 DocDetail에 같은 자재를 2개 등록할경우 한개의 수입검사 문서가 만들어지기 때문에 바로 Join하면 n개가 나올수 있어서 DISTINCT
		--												MDD.MaterialIqcNo,
		--												Count(MDLI.LotNo)	AS LotNo_Qty            -- 2020-09-06 추가 	
		--										FROM
		--												STB_MaterialDocDetail MDD WITH(NOLOCK)
		--												INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
		--												INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
		--												INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
		--										WHERE
		--												MQI.InspectionDocType LIKE @InspectionDocType 
		--												AND	(MQI.DecisionResult LIKE @DecisionResult) 
		--												AND	(MQI.MaterialCode LIKE @MaterialCode) 
		--												AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
		--												AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 
		--												AND	(MQI.BasicDate BETWEEN @FromDate AND '2024-12-31')
		--										Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            -- 2020-09-06 추가 	
		--								) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo
		--		LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
		--		LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
		--		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
		--		LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
		--		LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
		--		LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
		--		LEFT OUTER JOIN VW_DecisionResult DR				                ON DR.DecisionResult = MQI.DecisionResult
		--		LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	
		--		LEFT OUTER JOIN STB_IQcDefectReport SIQ	WITH(NOLOCK)             ON SIQ.LotNo = MQI.IQCSampleLotList  						
		--		LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID
		--WHERE 1=1
		--		AND MQI.InspectionDocType LIKE @InspectionDocType 
		--		AND (MQI.DecisionResult LIKE @DecisionResult) 
		--		AND (MQI.MaterialCode LIKE @MaterialCode) 
		----		AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
		----		AND (MDI.SourceCustomerCode LIKE @CustomerCode) 
		--		AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        
		--		AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- 사업장코드 kilee 추가   (2020.03.31)
		--		AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- 작업장코드 kilee 추가   (2021.11.23)
		--		AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- 자재유형코드 kilee 추가 (2020.06.29)
		--		AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- 자재그룹코드 kilee 추가 (2020.06.29)
		--		--AND MM.ProductGroupCode NOT LIKE 'CATALYST SUPPORT'
		--	   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시 조건추가 (박진호, 2020.08.11)		
		--	   --AND (MQI.IQCSampleLotList NOT IN ('D902201060201', 'D042203010201', 'D042203030201', 'D042203030201', 'D872203050201', 'D042203070202', '220404', 'D972205100202', 'D972206190201', 'D972206190201', 'D872207050202', 'D872207050202', 'D962209260202', 'D1022210030201', 'D952211070201', 'D952211070201', 'D872111260201')
		--	   --                    OR MQI.IQCSampleLotList IS NULL) --2022.11.18 김민수 요쳥 -- IQCSampleLotList이 필수값이 아니므로 NOT NULL을 걸면 NULL인 모든 데이터가 제외됨.

		--	   --BEGIN  Remove comment when audit
		--	   AND	 (
		--	    (@DecisionResult <> 'Reject'  and  @FromDate >='2025-01-01' )
		--		OR MQI.MaterialQcNo IN ('25012400007','25031100001', '25040500010', '25072100002', '25102800016', '26012600010')) -- UPDATE 2025-08-27 because QC team want to change IQCSampleLotList
		--	    --END

		--	   AND (SIQ.DefectReportNo = 'VNI220614-01' OR SIQ.DefectReportNo IS NULL or @CompanyCode='VVT') 

		--	   union all

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
				case when MQI.MaterialCode in ('GBCP00-S06')
				then N'전해액 2.7 V  SPDBF4/ACN: SL=8:2'
				else MM.MaterialName
				end as MaterialName
				,
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
				CASE WHEN MVM.InspectionType IS NULL      THEN MQI.InspectionType ELSE MVM.InspectionType END  AS InspectionType ,    -- 2021.01.27
				--MQI.InspectionType as aaa,
				MQI.TargetSampleQty,
				MQI.ActualSampleQty,                -- 실샘플수량
				MQI.DestoryInspectionQty,
				MQI.ProcessQty,
				MQI.MaxAcceptDefectQty,
				MQI.PassedSampleQty,
				MQI.DefectSampleQty,                                  -- 불합격시료수량
				MDD2.ManufacturerCode,
				C2.CustomerName AS ManufacturerName,
				MDD2.WeekCode,
				MDD2.RevisionsVer,		-- add for BG2
				MQI.DefectDetail,		-- add for IQC
				MQI.DecisionResult,
				MQI.DecisionDateTime,                                 -- 판정일시
				MQI.DecisionUserID       AS DecisionUserID,      -- 품질검사자 ID                       			
				SUI.UserName              AS DecisionName,       -- 품질검사자 Name (2020.07.21 추가)
				MQI.SpecialAcceptDesc,			
				MQI.IQCSampleLotList AS IQCSampleLotList,   -- 검사 Lot No  (박진호님 요청)      
				MQI.VendorQcReport,
				MQI.VendorLotNo,
				MQI.MIIExtText01,     -- 검사자
				(SELECT SPW.WorkerName FROM STB_ProdWorkerInfo SPW Where SPW.WorkerCode = MQI.MIIExtText01)                                     AS Inspector,    --2021.03.26 추가사항

				MQI.MIIExtText02,		
				CASE 
					WHEN MQI.MaterialQcNo IN ('25012400007','25031100001', '25040500010', '25072100002', '25102800016') THEN CONVERT(VARCHAR(10), MQI.CreateDateTime, 121)  -- update 2025-08-27 for audit
					ELSE CONVERT(VARCHAR(10), DATEADD(Day, 7, MQI.CreateDateTime), 121) 
				END	AS RequestDate,   -- 회신요청일 : 검사일+7일 (2020.07.20 박진호대리)
				MQI.MIIExtText04,
			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
			   --Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End as PPM,               -- 불량율(PPM) 박진호요청		
			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End AS DefectiveRate,   -- Lot불량율(%) 박진호요청 (2020.12.09)
			   Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) End AS PPM,               -- 불량율(PPM) 박진호요청							
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
			-- , MDD.MaterialIqcNo                    -- 2020.04.24 추가 (원본백업)
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
				LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MQI.MaterialCode  AND MVM.CustomerCode = MDI.SourceCustomerCode 	
				LEFT OUTER JOIN STB_IQcDefectReport SIQ	WITH(NOLOCK)             ON SIQ.LotNo = MQI.IQCSampleLotList  						
				LEFT OUTER JOIN  SmartFramework.dbo.STB_UserInfo SUI	         ON SUI.UserID = MQI.DecisionUserID
				LEFT OUTER JOIN STB_MaterialDocDetail MDD2 WITH(NOLOCK) ON MDD2.MaterialIqcNo = MQI.MaterialQcNo
				LEFT OUTER JOIN STB_CustomerInfo C2 WITH(NOLOCK)				ON MDD2.ManufacturerCode = C2.CustomerCode	-- BG2
		WHERE 1=1
				AND MQI.InspectionDocType LIKE @InspectionDocType 
				AND (MQI.DecisionResult LIKE @DecisionResult)
				AND (MQI.MaterialCode LIKE @MaterialCode) 
				AND (MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
				AND (MDI.SourceCustomerCode LIKE @CustomerCode) 
				AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)        
				AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                -- 사업장코드 kilee 추가   (2020.03.31)
				AND ((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode))       -- 작업장코드 kilee 추가   (2021.11.23)
				AND MT.BasicMaterialType LIKE @MaterialTypeCode                                            -- 자재유형코드 kilee 추가 (2020.06.29)
				AND MM.ProductGroupCode LIKE @ProductGroupCode                                        -- 자재그룹코드 kilee 추가 (2020.06.29)
				--AND MM.ProductGroupCode NOT LIKE 'CATALYST SUPPORT'
			   AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시 조건추가 (박진호, 2020.08.11)		
			   --AND (MQI.IQCSampleLotList NOT IN ('D902201060201', 'D042203010201', 'D042203030201', 'D042203030201', 'D872203050201', 'D042203070202', '220404', 'D972205100202', 'D972206190201', 'D972206190201', 'D872207050202', 'D872207050202', 'D962209260202', 'D1022210030201', 'D952211070201', 'D952211070201', 'D872111260201')
			   --                    OR MQI.IQCSampleLotList IS NULL) --2022.11.18 김민수 요쳥 -- IQCSampleLotList이 필수값이 아니므로 NOT NULL을 걸면 NULL인 모든 데이터가 제외됨.
			   
			   --BEGIN  Remove comment when audit
			   
			 --  AND	 (
			 --   (@DecisionResult <> 'Reject'  and @FromDate>='2025-01-01')
				--OR MQI.MaterialQcNo IN ('25031100001', '25040500010', '25072100002', '25102800016', '26020400009', '25012400007'))  -- UPDATE 2025-08-27 because QC team want to change IQCSampleLotList
				 --END																
				 
			   AND (SIQ.DefectReportNo = 'VNI220614-01' OR SIQ.DefectReportNo IS NULL or @CompanyCode='VVT')
			   --and MQI.CreateUserID NOT IN ('korean')		-- fake user

		END
	END
END


  --        usp_MaterialQcInfo_HY_get '','','','','','2024-12-01','2024-12-25', '' ,'IQC', 'VVT' ,'VVT_F3' ,'', ' ' , '2024-12-01','2024-12-25'
GO

PRINT 'Procedure usp_MaterialQcInfo_HY_get created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_MaterialQcDetail_HY_get (Cloned from usp_MaterialQcDetail_get)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcDetail_HY_get')
    DROP PROCEDURE [dbo].[usp_MaterialQcDetail_HY_get];
GO


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사 & 시료별입고검사 > 2번째 Grid화면
--            품질관리 > 제품검사 > 2번째 Grid
-- Description:	수입검사 및 제품검사 상세를 조회합니다
-- Modified: 
--             @pMaterialQcNo 기본값 변경, 기존처럼 기본값이 Null인 경우 해외법인 입고현황 등의 화면에서는 Detail 테이블의 전체조회가 일어남. 2020.09.07 By Jackaroe
--             베트남 Tung이 Update문 수정한 것 잘못되어, @LotNumber추가하여 조건 변경함. (2020-09-21  kilee 수정)
--             베트남 Tung이 remove IQC & HYCAP condition on 22-June-2021
--             Mr.Tung add by Mr.Tung 16-May-2023 
--			   Mr.Tung add on 2023-06-18 for QC request
-- 프로시저 실행문 :  EXEC usp_MaterialQcDetail_HY_get '','','VVPM193R038706-1'
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialQcDetail_HY_get]   
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pMaterialQcNo VARCHAR(20) = 'MaterialQcNo' 
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @Barcode         VARCHAR(20) 
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(60)  -- 2021.11.28
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @InspectionDocType VARCHAR(20)
	DECLARE @QcQty NUMERIC(20,5) = 0

	Declare @QcInspectionItemCodeList TABLE (
		QcInspectionItemCode VARCHAR(20)
	   ,Is0825 INT
	);

	INSERT INTO @QcInspectionItemCodeList
		SELECT 'PQC_V01_01', 1
		UNION ALL
		SELECT 'PQC_V01_02', 0
		UNION ALL
		SELECT 'PQC_V01_03', 0
		UNION ALL
		SELECT 'PQC_V01_04', 0
		UNION ALL
		SELECT 'PQC_V01_05', 0

    
	SELECT  @Barcode = Barcode
	         , @MaterialCode = MaterialCode  -- 2021.11.28
	  FROM STB_SetInfo
	WHERE LotNumber  = @MaterialQcNo

	SELECT @CompanyCode = CompanyCode ,  
			@MaterialCode = isnull(MaterialCode,@MaterialCode),
			 -- DinhManh update 2025-05-16
			@WorkCenterCode = WorkCenterCode,
			@InspectionDocType = InspectionDocType,
			@QcQty = QcQty

	  FROM STB_MaterialQcInfo
	 WHERE MaterialQcNo = @MaterialQcNo

			--	SELECT   Barcode, LotNumber, *
			--  FROM STB_SetInfo
			--WHERE LotNumber  = '20092100004'


		
	-- IF @MaterialQcNo LIKE 'VV%'    -- 베트남 바코드의 경우   -- 기존 소스 백업
	  IF @CompanyCode LIKE 'VVT'    -- 베트남 바코드의 경우

	   BEGIN 



			   DECLARE @LotNonew1 VARCHAR(20) = ''
			DECLARE @LotNonew2 VARCHAR(20) = ''
			DECLARE @LotNonew3 VARCHAR(20) = ''
			DECLARE @LotNonew4 VARCHAR(20) = ''
			DECLARE @LotNonew5 VARCHAR(20) = ''
			DECLARE @LotNonew6 VARCHAR(20) = ''

			DECLARE @currentLotno VARCHAR(20) = ''

			select @LotNonew1 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@MaterialQcNo; 
	
			select @LotNonew2 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew1 ;

			select @LotNonew3 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew2 ;

			select @LotNonew4 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew3 ;

			select @LotNonew5 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew4 ;

			select @LotNonew6 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew5 ;
	

		 select @currentLotno = Barcode 
		 from STB_SetInfo   WITH(NOLOCK) where Barcode in (@MaterialQcNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);


		-- 베트남  부문창님 of QC require to check 20 SD value and 20 ESR value
		-- Mr.Tung EA 베트남 modified updating this area 
		-- Date:  28-August-2020
		-- START
		DECLARE @sumSampleQtyESR numeric(20,5) = 20
		DECLARE @sumSampleQtySD numeric(20,5) = 10
		DECLARE @sumSampleQtyCAP numeric(20,5) = 3
		DECLARE @sumSampleQtyInspection int = 0 , @pQcInspectionItemCode varchar(20)='IQC_GPD_21'
		DECLARE @sumSampleQty특성_용량 numeric(20,5) = 20
		DECLARE @cCount INT

		-- UPDATE Request Sample Qty for 'IQC_GPD_22' -- following Ms.Doan Hanh's request 2025-08-26
		DECLARE @PackQty INT = NULL
		-- 2026-02-03 lấy trong bảng này trước, 
		SELECT @PackQty = RequestSampleQty FROM STB_OQCDetailSampleQty_VVT where MaterialCode = @MaterialCode and QCInspectionGroupCode = 'IQC_GPD_22'

		IF @PackQty IS NULL -- nếu không có tiêu chuẩn thì lấy số lượng đóng gói B781
			BEGIN
				SELECT TOP 1 @PackQty =  PackQty FROM STB_SavePackingTime_VVT SPT where LotNo = @currentLotno AND SPT.PackQty > 0 AND SPT.IsPrinted = 0 -- lấy số lượng đóng gói ở B781
			END


		IF (@PackQty > 0 AND @PackQty IS NOT NULL)
			BEGIN
				UPDATE STB_MaterialQcDetail
				SET RequestSampleQty = @PackQty
				WHERE MaterialQcNo = @currentLotno
				AND	QcInspectionItemCode IN  ('IQC_GPD_22')

				UPDATE STB_MaterialQcDetail
				SET SampleQty = case 
								when @PackQty >= 1 and @PackQty <= 8 THEN 2
								when @PackQty >= 9 and @PackQty <= 15 THEN 3
								when @PackQty >= 16 and @PackQty <= 25 THEN 5
								when @PackQty >= 26 and @PackQty <= 50 THEN 8
								when @PackQty >= 51 and @PackQty <= 90 THEN 13
								when @PackQty >= 91 and @PackQty <= 150 THEN 20
								when @PackQty >= 151 and @PackQty <= 280 THEN 32
								when @PackQty >= 281 and @PackQty <= 500 THEN 50
								when @PackQty >= 501 and @PackQty <= 1200 THEN 80
								when @PackQty >= 1201 and @PackQty <= 3200 THEN 125
								when @PackQty >= 3201 and @PackQty <= 10000 THEN 200
								when @PackQty >= 10001 and @PackQty <= 35000 THEN 315
								when @PackQty >= 35001 and @QcQty <= 150000 THEN 500
								when @PackQty >= 150001 and @PackQty <= 500000 THEN 800
								ELSE RequestSampleQty END
				WHERE MaterialQcNo = @currentLotno
				AND	QcInspectionItemCode IN  ('PQC_V01_06', 'IQC_GPD_21')

			END

		-- END UPDATE




		--CAP
		-- Mr.Duy thêm tất cả các mã của hàng VPC bắc giang đổi 특성_용량 từ ktra 20 -> 10 theo yêu cầu của Ms.Thơm 2025-02-21
		select @cCount = count(*)
		  from 
		  stb_modelbasicinfo with(nolock) 
		  where modelcode=(select materialcode from STB_SetInfo where Barcode=@currentLotno) 
		  and ((ModelName like '%VEC2R7%1840%'  and convert(numeric(10,2),isnull(MBIExtText05,0))=50)
		  or (ModelName like '%VEL%'))

	 	 if (@cCount>0  )
	 	 begin
			select @sumSampleQtyESR  = 20
			select @sumSampleQtySD   = 10
			select @sumSampleQtyCAP  = 10
			select @sumSampleQty특성_용량  = 10
		 end
		 

		 ----  2023-September-08 by Mr.Tung , removed 40 ESR for 1030 model
		 select @cCount = count(*) 
		 from STB_SetInfo  with(nolock) 
		 where Barcode=@MaterialQcNo 
		 and (
				MaterialCode in ('ECVT30-076','ECVT30-117','ECVT30-098','ECVT30-197','ECVT30-294','ECVT30-116','ECVT30-294') or 
				(select count(*) from stb_materialmaster with(nolock) where materialcode=@MaterialCode and replace(replace(MaterialName,'HY-CAP',''),' ','') in ('VEC3R0507QG(3582)','VEP3R0507QG(3582)','VEC3R0367QG(3562)','VEC3R0387QG(3562)','VEP3R0367QG(3562)'))>0
			 )

		declare @MaterialCodeMer varchar(20)

			SELECT @MaterialCodeMer = c.MaterialCode 
			FROM VVT_OQC_REFER  a  with(nolock)
			join STB_SetInfo  b  WITH(NOLOCK) on a.mergeid = b.Barcode 
			join STB_MaterialMaster  c  WITH(NOLOCK) on b.MaterialCode = c.MaterialCode 
			WHERE  (finished is not null or finished<>'')  
			and a.isSeparated = '1'
			and  mergeid = CASE WHEN (CHARINDEX('-', @MaterialQcNo) > 0) THEN SUBSTRING(@MaterialQcNo, 1, CHARINDEX('-', @MaterialQcNo) - 1) ELSE @MaterialQcNo END
		print @MaterialCodeMer
			--Cập nhật số lượng kiểm tra ngoại quan
	
			set @sumSampleQtyInspection = case when @MaterialCodeMer in ('ECVT30-294')
			then 125
			else @sumSampleQtyInspection
			end
			--end

		 if(@MaterialCodeMer in ('ECVT30-294', 'ECVT30-370')) 
		 begin
			select @sumSampleQtyCAP  = 10
		 end

		 if (@cCount>0  )
	 	 begin
		 	select @sumSampleQtyESR  = 20
			select @sumSampleQtySD   = 10
			select @sumSampleQtyCAP  = 10
		 end



		 declare @itemforcheck varchar(4)='10'  --Mr.Tung add on 2023-11-17 for QC request
		 update   mqd  
		 set   SampleQty=convert(int,isnull((SELECT  (case when ISNUMERIC(QcSpecDesc)=1 then QcSpecDesc else @itemforcheck end)	FROM  STB_QcInspectionItem_HY  WITH(NOLOCK) WHERE QcInspectionItemCode=mqd.QcInspectionItemCode),@itemforcheck))
		 from STB_MaterialQcDetail mqd
		 WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)  
			 and isnull(TextSpecValue,'')=''
			 and QcInspectionItemCode in ( select QcInspectionItemCode from STB_QcInspectionItem_HY   WITH(NOLOCK)  where ISNUMERIC(QcSpecDesc)=1)

			 if(@MaterialCode ='RDMD00-301')
				begin
					set	@sumSampleQtyCAP =6
				end 

			--ducnv edit by Mrs.Hang Nguyen 20260527
			if(@MaterialCode ='ECVT30-358')
			begin
				set	@sumSampleQtyCAP =10
			end

			
	
			 --raiserror(@MaterialCode,16,1)
		 update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtyCAP
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_20')


		--ESR
		   update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtyESR
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_19')

			 
		--SD Mr.Tung add on 2021-July-17 for SD measure , IQC inspection of HY-CAP import from HeadQuarter
		   update  STB_MaterialQcDetail 
			set SampleQty = 5                 --5 values of SD
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18')
			 and (select top 1 InspectionDocType from STB_MaterialQcInfo where MaterialQcNo = @MaterialQcNo)='IQC'
		-- END by Mr.Tung
			   		 

					
		--SD add by loan change quality sd=10 ea
	    	update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtySD
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18')

			 -- 2026-05-20 Mr.Manh update for ECVT27-403 (VEC2R7406QC-C040-DFK(1346) ) -- Mr.Hanh OQC Request
			 IF @MaterialCode = 'ECVT27-403'
			 BEGIN
				 update  STB_MaterialQcDetail 
				set SampleQty = 50
				WHERE 1=1
				 AND (MaterialQcNo = @MaterialQcNo)
				 and QcInspectionItemCode in ('IQC_GPD_18')
			 END
			 --END UPDATE


			 --SD add by duy change quality sd=10 ea
	    	update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQty특성_용량
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('PQC_V01_09')

			 -- update by Mr.Manh 2025-09-09 following GII Standard for Al case (Mr.Phuong IQC TL request)
			update  STB_MaterialQcDetail 
			-- select top 1 * from STB_MaterialQcDetail
			set RequestSampleQty = case 
								when @QcQty >= 1 and @QcQty <= 8 THEN 2
								when @QcQty >= 9 and @QcQty <= 15 THEN 3
								when @QcQty >= 16 and @QcQty <= 25 THEN 5
								when @QcQty >= 26 and @QcQty <= 50 THEN 8
								when @QcQty >= 51 and @QcQty <= 90 THEN 13
								when @QcQty >= 91 and @QcQty <= 150 THEN 20
								when @QcQty >= 151 and @QcQty <= 280 THEN 32
								when @QcQty >= 281 and @QcQty <= 500 THEN 50
								when @QcQty >= 501 and @QcQty <= 1200 THEN 80
								when @QcQty >= 1201 and @QcQty <= 3200 THEN 125
								when @QcQty >= 3201 and @QcQty <= 10000 THEN 200
								when @QcQty >= 10001 and @QcQty <= 35000 THEN 315
								when @QcQty >= 35001 and @QcQty <= 150000 THEN 500
								when @QcQty >= 150001 and @QcQty <= 500000 THEN 800
								ELSE 1250 
							END

			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_G1_003')

			 -- Mr.Manh UPDATE ECVT30-370 2025-11-10 for JiangHai
			 IF @MaterialCode IN ('ECVT30-370', 'ECVT30-357')
				BEGIN
					 update  STB_MaterialQcDetail 
					set SampleQty = '10'
					WHERE 1=1
					 AND (MaterialQcNo = @MaterialQcNo)
					 and QcInspectionItemCode in ('IQC_GPD_20')
				 END
				-- END

			 --begin by Mr.Tung on 27-April-2022 for Vietnam factory
			 declare @SampleQty int = 0
			declare @MaterialQcDetailNo VARCHAR(30) = ''
			
			select top 1
			@SampleQty = CASE 
												  WHEN QcInspectionItemCode = 'IQC_G1_072' and @CompanyCode='VVT' THEN 2			--add by Mr.Tung 27-April-2022 by IQC request
												  when QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04','IQC_O1','IQC_O2','IQC_O3') then 10   --add by Mr.Tung 16-May-2023 by TQC spec 
												 
												  ELSE 0 END ,
			@MaterialQcDetailNo = MaterialQcDetailNo
			from STB_MaterialQcDetail with(nolock) 
			WHERE 1=1 
			 AND (MaterialQcNo = @MaterialQcNo) 
			 
			IF @SampleQty <> 0 				
				BEGIN
					Exec usp_DoCreateMaterialQcSampleResult @MaterialQcNo, @MaterialQcDetailNo, @SampleQty, 0       -- 시료별 수입검사결과에서 샘플수량만큼 셀이 자동생성되는 부분
                            --[프로시저 실행 Test]  usp_DoCreateMaterialQcSampleResult '20070300016','6',5,0                     -- [참고] 화면 생성버튼에서 불러주는 프로시저는 다름 (Exec usp_DoMakeMaterialQcSampleResult_HY )					
				END
			--end by Mr.Tung on 27-April-2022 for Vietnam factory


			--ducnv edited by Mrs.TranThom 20250608 START
			IF @MaterialCode = 'ECVT30-252'
			BEGIN
				-- 1. fix cứng Dung lượng (용량) bằng 3
				UPDATE STB_MaterialQcDetail 
				SET SampleQty = 3
				WHERE MaterialQcNo = @MaterialQcNo 
				AND QcInspectionItemCode = 'IQC_GPD_20'

				-- 2. fix cứng Trọng lượng (무게) bằng 5
				UPDATE STB_MaterialQcDetail 
				SET SampleQty = 5
				WHERE MaterialQcNo = @MaterialQcNo 
				AND QcInspectionItemCode = 'IQC_GPD_27'
			END
			 --END 
			
			IF (@WorkCenterCode IN ('VVT_F1', 'VVT_F2') AND @InspectionDocType = 'IQC')     -- DinhManh update 2025-05-16 following IQC request, sample qty following  SI 0.1% Standard
				BEGIN
						SELECT
							MQD.MaterialQcNo AS OldMaterialIqcNo,
							MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
							MQD.MaterialQcNo,
							MQD.MaterialQcDetailNo,
							MQD.QcInspectionGroupCode,
							MQD.QcInspectionGroupName,
							MQD.QcInspectionGroupDesc,
							MQD.QcInspectionItemCode,
							MQD.QcInspectionItemName,
							MQD.QcInspectionItemDesc,
							MQD.GroupInspectionPrior,
							MQD.GroupReportPrior,
							MQD.ItemInspectionPrior,
							MQD.ItemReportPrior,
							MQD.QcSpecDesc,
							MQD.InspectionType,
							MQD.IsMaterialSpec,
							
							   CASE 
        WHEN MQD.InspectionLevel = 'G1'
            AND MQD.QcInspectionItemName = N'Ngoại quan'
            AND MQD.QcInspectionGroupName LIKE N'%Vỏ nhôm%'
        THEN 'G2'
        ELSE MQD.InspectionLevel
    END AS InspectionLevel,
	
	                     --MQD.InspectionLevel,
							MQD.AQL,
							-- MQD.RequestSampleQty,
							CASE 
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 1 AND @QcQty < 50) THEN 2
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 51 AND @QcQty < 500) THEN 3
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 501 AND @QcQty < 35000) THEN 5
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 35001) THEN 8
								ELSE MQD.RequestSampleQty
							END AS RequestSampleQty,
							MQD.MaxAcceptDefectQty,				
							--MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
							-- Mr.Duy thay đổi theo QC bắc giang để đến lúc chỉnh số lượng của ngoại quan
								case when MQD.SampleQty >0 then 
									(
										CASE 
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 1 AND @QcQty < 50) THEN 2
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 51 AND @QcQty < 500) THEN 3
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 501 AND @QcQty < 35000) THEN 5
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem_HY where IsSI01Standard = 1) AND (@QcQty > 35001) THEN 8
											ELSE MQD.SampleQty
										END 
									)
										
								else 
									case when MQD.QcInspectionItemCode ='IQC_GPD_21'
									then	@sumSampleQtyInspection
									else MQD.SampleQty
									end
								end as SampleQty,
							MQD.PassedSampleQty,
							MQD.DefectSampleQty,
							MQD.SkipSampleQty,
							MQD.SpecValue,
							MQD.USL,
							--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
							MQD.LSL,
							MQD.UCL,
							MQD.LCL,
							MQD.TextSpecValue,
							MQD.DecisionResult,
							MQD.Description,
							MQD.CreateDateTime,
							MQD.CreateUserID,
							MQD.ChangeDateTime,
							MQD.ChangeUserID				
					FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
					WHERE 1=1
						 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
					ORDER BY ItemReportPrior ASC
				END

			ELSE
				BEGIN
						SELECT
							MQD.MaterialQcNo AS OldMaterialIqcNo,
							MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
							MQD.MaterialQcNo,
							MQD.MaterialQcDetailNo,
							MQD.QcInspectionGroupCode,
							MQD.QcInspectionGroupName,
							MQD.QcInspectionGroupDesc,
							MQD.QcInspectionItemCode,
							MQD.QcInspectionItemName,
							MQD.QcInspectionItemDesc,
							MQD.GroupInspectionPrior,
							MQD.GroupReportPrior,
							MQD.ItemInspectionPrior,
							MQD.ItemReportPrior,
							MQD.QcSpecDesc,
							MQD.InspectionType,
							MQD.IsMaterialSpec,
							/*
							   CASE 
        WHEN MQD.InspectionLevel = 'G1'
            AND MQD.QcInspectionItemName = N'Ngoại quan'
            AND MQD.QcInspectionGroupName LIKE N'%Vỏ nhôm%'
        THEN 'GII'
        ELSE MQD.InspectionLevel
    END AS InspectionLevel,
	*/
	                       MQD.InspectionLevel,
							MQD.AQL,
							MQD.RequestSampleQty,
							MQD.MaxAcceptDefectQty,				
							--MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
							-- Mr.Duy thay đổi theo QC bắc giang để đến lúc chỉnh số lượng của ngoại quan
								case when MQD.SampleQty >0 then 
										MQD.SampleQty
								else 
									case when MQD.QcInspectionItemCode ='IQC_GPD_21'
									then	@sumSampleQtyInspection
									else MQD.SampleQty
									end
								end as SampleQty,
							MQD.PassedSampleQty,
							MQD.DefectSampleQty,
							MQD.SkipSampleQty,
							MQD.SpecValue,
							MQD.USL,
							--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
							MQD.LSL,
							MQD.UCL,
							MQD.LCL,
							MQD.TextSpecValue,
							MQD.DecisionResult,
							MQD.Description,
							MQD.CreateDateTime,
							MQD.CreateUserID,
							MQD.ChangeDateTime,
							MQD.ChangeUserID				
					FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
					WHERE 1=1
						 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
					ORDER BY ItemReportPrior ASC
				END
			
	     	

	END ELSE BEGIN
	     	IF @pProcessUserID = 'yjyu' BEGIN
			--	SELECT
			--		MQD.MaterialQcNo AS OldMaterialIqcNo,
			--		MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
			--		MQD.MaterialQcNo,
			--		MQD.MaterialQcDetailNo,
			--		MQD.QcInspectionGroupCode,
			--		MQD.QcInspectionGroupName,
			--		MQD.QcInspectionGroupDesc,
			--		MQD.QcInspectionItemCode,
			--		MQD.QcInspectionItemName,
			--		MQD.QcInspectionItemDesc,
			--		MQD.GroupInspectionPrior,
			--		MQD.GroupReportPrior,
			--		MQD.ItemInspectionPrior,
			--		MQD.ItemReportPrior,
			--		MQD.QcSpecDesc,
			--		MQD.InspectionType,
			--		MQD.IsMaterialSpec,
			--		MQD.InspectionLevel,
			--		MQD.AQL,
			--		MQD.RequestSampleQty,
			--		MQD.MaxAcceptDefectQty,				
			--		CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
			--		--CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,           --10개 고정
			--		MQD.PassedSampleQty,
			--		MQD.DefectSampleQty,
			--		MQD.SkipSampleQty,
			--		MQD.SpecValue,
			--		MQD.USL,
			--		--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
			--		MQD.LSL,
			--		MQD.UCL,
			--		MQD.LCL,
			--		MQD.TextSpecValue,
			--		MQD.DecisionResult,
			--		'' AS Description ,
			--		MQD.CreateDateTime,
			--		MQD.CreateUserID,
			--		MQD.ChangeDateTime,
			--		MQD.ChangeUserID,
			--		0 AS Cpk				
			--FROM  [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcDetail MQD WITH(NOLOCK)
			--LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcInfo MQI
			--  ON MQI.MaterialQcNo = MQD.MaterialQcNo
			--WHERE 1=1
			--	 AND MQD.MaterialQcNo = @MaterialQcNo
			--	 AND MQD.QcInspectionItemCode NOT IN (SELECT QcInspectionItemCode 
			--											FROM @QcInspectionItemCodeList
			--										   WHERE Is0825 <= CASE WHEN MQI.MaterialCode = 'LIVT38-018' THEN 0 ELSE 1 END
			--									 )
			--ORDER BY ItemReportPrior ASC
			print '1'
			END ELSE BEGIN

				SELECT
					MQD.MaterialQcNo AS OldMaterialIqcNo,
					MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
					MQD.MaterialQcNo,
					MQD.MaterialQcDetailNo,
					MQD.QcInspectionGroupCode,
					MQD.QcInspectionGroupName,
					MQD.QcInspectionGroupDesc,
					MQD.QcInspectionItemCode,
					MQD.QcInspectionItemName,
					MQD.QcInspectionItemDesc,
					MQD.GroupInspectionPrior,
					MQD.GroupReportPrior,
					MQD.ItemInspectionPrior,
					MQD.ItemReportPrior,
					MQD.QcSpecDesc,
					MQD.InspectionType,
					MQD.IsMaterialSpec,
					
					CASE 
                        WHEN MQD.InspectionLevel = 'G1'
                        AND MQD.QcInspectionItemName = N'Ngoại quan'
                        AND MQD.QcInspectionGroupName LIKE N'%Vỏ nhôm%'
                             THEN 'G2'
                             ELSE MQD.InspectionLevel
                    END AS InspectionLevel,
					
					--MQD.InspectionLevel,
					MQD.AQL,
					MQD.RequestSampleQty,
					MQD.MaxAcceptDefectQty,				
					CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE  MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
					--CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,           --10개 고정
					MQD.PassedSampleQty,
					MQD.DefectSampleQty,
					MQD.SkipSampleQty,
					MQD.SpecValue,
					MQD.USL,
					--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
					MQD.LSL,
					MQD.UCL,
					MQD.LCL,
					MQD.TextSpecValue,
					MQD.DecisionResult,
					MQD.Description ,
					MQD.CreateDateTime,
					MQD.CreateUserID,
					MQD.ChangeDateTime,
					MQD.ChangeUserID,
					MQD.Cpk				
			FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialQcInfo MQI
			  ON MQI.MaterialQcNo = MQD.MaterialQcNo
			WHERE 1=1
				 AND MQD.MaterialQcNo = @MaterialQcNo
				 AND MQD.QcInspectionItemCode NOT IN (SELECT QcInspectionItemCode 
														FROM @QcInspectionItemCodeList
													   WHERE Is0825 <= CASE WHEN MQI.MaterialCode = 'LIVT38-018' THEN 0 ELSE 1 END
												 )
			ORDER BY ItemReportPrior ASC
			END

	END
END

GO

PRINT 'Procedure usp_MaterialQcDetail_HY_get created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_MaterialQcSampleResult_HY_get (Cloned from usp_MaterialQcSampleResult_get)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcSampleResult_HY_get')
    DROP PROCEDURE [dbo].[usp_MaterialQcSampleResult_HY_get];
GO

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : ???? > [C530] ????(Lot No) > 3?? Grid
-- Description:	??????? ?? ???? ?????.
-- Modified:
--  [usp_MaterialQcSampleResult_HY_get] 'kilee2','Korean',,'VJLT193R850605',''
/*vanduc edited by Mrs.Hang 20260603 START*/
--  2026-06-03: Added support for FOQC_V01_07 (OCV) and FOQC_V01_08 (ESR) and optimized performance to prevent timeouts
/*END*/
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcSampleResult_HY_get] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialQcNo VARCHAR(20) = NULL,
    @pMaterialQcDetailNo VARCHAR(20) = NULL

WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	DECLARE @MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo

    -- Loannt update 20210127 insert from table monitor sd to sample resulte
	DECLARE @PatternID varchar(20)
	DECLARE @PatternName varchar(100)
	DECLARE @LSL varchar(10)
	DECLARE @USL varchar(10)
	DECLARE @cnt numeric
	DECLARE @SampleQty numeric
	DECLARE @value varchar(20)
	DECLARE @value8 varchar(20)
	DECLARE @SampleNo numeric
	DECLARE @companycode varchar(10)
	DECLARE @cntexit varchar(10)
	DECLARE @cntexit1 varchar(10)
	DECLARE @cntexit2 varchar(10)
	DECLARE @cntinfor varchar(10)
	DECLARE @value1 int
	DECLARE @value2 int
	DECLARE @value7 int
	DECLARE @valueocv int

	DECLARE @materialqcnooldvalue varchar(20)
	DECLARE @value3 varchar(20)

	DECLARE @value4 numeric(20,5)
	DECLARE @value5 numeric(20,5)
	DECLARE @value6 numeric(20,5)
	DECLARE @abc varchar(20)

	DECLARE @valueT1 varchar(10)
	DECLARE @valueT2 varchar(10)
	DECLARE @valueT3 varchar(10)

	/*vanduc edited by Mrs.Hang 20260603 START*/
	-- Temp tables for performance optimization
	DECLARE @TempOCV TABLE (
		RowID INT IDENTITY(1,1),
		MonitorID INT,
		Val VARCHAR(20)
	)

	DECLARE @TempESR TABLE (
		RowID INT IDENTITY(1,1),
		MonitorID INT,
		Val VARCHAR(20)
	)
	/*END*/

	-- position move
	select @companycode=CompanyCode from STB_MaterialQcInfo WITH(NOLOCK) where materialqcno=@pMaterialQcNo

	IF @companycode = 'VVT' BEGIN
		/*vanduc edited by Mrs.Hang 20260603 START*/
		DECLARE @RealLotNo VARCHAR(20) = @MaterialQcNo
		IF @MaterialQcNo LIKE 'F%' BEGIN
			SET @RealLotNo = SUBSTRING(@MaterialQcNo, 2, LEN(@MaterialQcNo)-1)
		END
		/*END*/
		
		select @materialqcnooldvalue=OldBarCode  FROM STB_LotChangeMaterialHistory WHERE NewBarcode =/*vanduc edited by Mrs.Hang 20260603 START*/@RealLotNo/*END*/

		select @valueT1 =count(*) from STB_SDINFORBYLOT where lotno=@materialqcnooldvalue and attribute1 is null
		select @valueT2 = count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadToMes is null
		select @valueT3 = count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadOCVToMess is null

		if (@materialqcnooldvalue is not null and   @valueT1 > 0) or  (@materialqcnooldvalue is not null and @valueT2 > 0) or  (@materialqcnooldvalue is not null and @valueT3 > 0)

		begin 
			set @value3=@materialqcnooldvalue

		end
		else
		begin
			set @value3=/*vanduc edited by Mrs.Hang 20260603 START*/@RealLotNo/*END*/
		end
		if @materialqcnooldvalue is null
		begin
			set @value3=/*vanduc edited by Mrs.Hang 20260603 START*/@RealLotNo/*END*/
		end

		--if @materialqcnooldvalue is null
		--begin
		--	SELECT @value3=Barcode   FROM STB_SetInfo WHERE LotNumber=@MaterialQcNo
		--end
		--RAISERROR(@value3,16,1)


		--RAISERROR('khong',16,1)
			--	RAISERROR(@pMaterialQcDetailNo,16,1)
		--IQC_GPD_18 = SD IQC_GPD_20=DUNGLUONG
		select @cntexit =count(*) from STB_SDINFORBYLOT WITH(NOLOCK) where lotno=@value3 and attribute1 is null
		select @cntexit1 = count(*) from Stb_ESRValueMonitor WITH(NOLOCK) where lotno = @value3 and UploadToMes is null
		select @cntexit2 = count(*) from Stb_ESRValueMonitor WITH(NOLOCK) where lotno = @value3 and UploadOCVToMess is null
	END
	
	if(@companycode='VVT' and (@cntexit > 0 or @cntexit1 > 0 or @cntexit2 > 0))
	--if @cntexit > 0 or @cntexit1 > 0 or @cntexit2 > 0
	begin

		 select @SampleQty=sampleQty,@PatternID=QcInspectionItemCode,@LSL=LSL,@USL=USL  from STB_MaterialQcDetail where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo
		if (@PatternID='IQC_GPD_20' or @PatternID='PQC_V01_09')
		begin
			
			select @value1=count(*)  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%??%')
			if(@value1 > 0)
			begin
				  delete top(@value1) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				
			end
			--ducnv edited by Mrs.TranThom 20260608 START
			--set  @SampleQty = 3 
			IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo AND MaterialCode = 'ECVT30-252')
			BEGIN
				SELECT @SampleQty = SampleQty
				FROM STB_MaterialQcDetail 
				WHERE MaterialQcNo = @MaterialQcNo AND MaterialQcDetailNo = @pMaterialQcDetailNo
			END
			ELSE
			--END
			BEGIN
				set  @SampleQty = 3  
			END
		end
		
		if (@PatternID='IQC_GPD_19' or @PatternID='PQC_V01_08' /*vanduc edited by Mrs.Hang 20260603 START*/or @PatternID='FOQC_V01_08'/*END*/)
		--if (@pMaterialQcDetailNo = 19)
		begin
			
	
			select @value7=count(*)  from Stb_ESRValueMonitor where lotno=@value3 and UploadToMes is null
			if(@value7 > 0 )
			begin
				
				  delete top(@value7) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				 
			end
			
			/*vanduc edited by Mrs.Hang 20260603 START*/
			INSERT INTO @TempESR (MonitorID, Val)
			SELECT ID, value 
			FROM Stb_ESRValueMonitor 
			WHERE lotno = @value3 AND UploadToMes IS NULL
			ORDER BY ID
			/*END*/
			
			/*vanduc edited by Mrs.Hang 20260603 START*/
			if (@PatternID='FOQC_V01_08')
				set @SampleQty=50
			else
				set @SampleQty=20
			/*END*/
		end


		if (@PatternID='PQC_V01_07' /*vanduc edited by Mrs.Hang 20260603 START*/or @PatternID='FOQC_V01_07'/*END*/)
		--if (@pMaterialQcDetailNo = 19)
		begin
			
			
			select @valueocv=count(*)  from Stb_ESRValueMonitor where lotno=@value3 and UploadOCVToMess is null
			if(@valueocv > 0 )
			begin
				  delete top(@valueocv) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				 
			end
			
			/*vanduc edited by Mrs.Hang 20260603 START*/
			INSERT INTO @TempOCV (MonitorID, Val)
			SELECT ID, valueocv 
			FROM Stb_ESRValueMonitor 
			WHERE lotno = @value3 AND UploadOCVToMess IS NULL
			ORDER BY ID
			/*END*/
			
			/*vanduc edited by Mrs.Hang 20260603 START*/
			if (@PatternID='FOQC_V01_07')
				set @SampleQty=50
			else
				set @SampleQty=20
			/*END*/
		end


		
		if (@PatternID='IQC_GPD_18')
		--if (@pMaterialQcDetailNo = 18)
		begin

			
			select @value2=count(*)  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
			if(@value2 > 0)
			begin
				  delete top(@value2) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				
			end
		set @SampleQty=10
			
		end

		 select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo

		--set @abc = CAST(@SampleQty as varchar(10))
		-- RAISERROR(@abc ,16,1)
		if (@PatternID='IQC_GPD_18' OR @PatternID='IQC_GPD_20' OR @PatternID='IQC_GPD_19' or  @PatternID='PQC_V01_09' or @PatternID='PQC_V01_08' or @PatternID='PQC_V01_07' /*vanduc edited by Mrs.Hang 20260603 START*/or @PatternID='FOQC_V01_07' or @PatternID='FOQC_V01_08'/*END*/)
		begin
			while @cnt < @SampleQty 
			begin
				-- Reset loop variables to prevent retaining values from previous iterations
				set @value = NULL
				set @value1 = NULL
				set @value8 = NULL
				set @cntinfor = 0

				select @SampleNo = COALESCE(max(materialqcsampleno),0) from STB_MaterialQcSampleResult where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo
					
					
						if (@PatternID='IQC_GPD_18')
						begin
							--RAISERROR('vaof' ,16,1)
							--select top(1) @value=sd  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
							select top(1) @value=sd ,@value8=concat(substring(sd,0,CHARINDEX( '.', sd, 2)),substring(sd,CHARINDEX( '.', sd, 0),3) )   from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 

						    select @cntinfor = count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
							
							if(@LSL <= @value and  @value <= @USL and @cntinfor > 0 )
							begin
							
								insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value8, DATEADD(HH, -2, GETDATE()),'system')
								update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@value3 and attribute1 is null and pattern like '%SD%' and sd=@value
							end
							else if (@value is not null) begin
								insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value8, DATEADD(HH, -2, GETDATE()),'system')
								update top(1) STB_SDINFORBYLOT set attribute1='FAIL'  where lotno=@value3 and attribute1 is null and pattern like '%SD%' and sd=@value
							end
							else begin
								insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,NULL, GETDATE(),'system')
							end
						end


					if (@PatternID='IQC_GPD_20' or @PatternID='PQC_V01_09')
					begin

						select @value=capacity from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%??%')
						select @cntinfor = count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%??%')
	

						--RAISERROR(@LSL,16,1)
						--RAISERROR(@USL,16,1)
						--RAISERROR(@value,16,1)
						--RAISERROR(@cntinfor,16,1)
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						--if (@value4 <=@value6 and @value6<=@value5  and @cntinfor > 0 )
						
						if (@value IS NOT NULL)
						begin	
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@value3 and attribute1 is null and (pattern like '%'+'DUNGLUONG'+'%' OR pattern like '%'+'??'+'%') and capacity=@value
						end
						else
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,NULL, GETDATE(),'system')
						end
							

					end


					
					if (@PatternID='IQC_GPD_19'  or @PatternID='PQC_V01_08' /*vanduc edited by Mrs.Hang 20260603 START*/or @PatternID='FOQC_V01_08'/*END*/)
					begin
						/*vanduc edited by Mrs.Hang 20260603 START*/
						select top(1) @value = Val, @value1 = MonitorID from @TempESR where RowID = (@cnt + 1)
						/*END*/
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						
						if (@value4 <=@value6 and @value6<=@value5  and /*vanduc edited by Mrs.Hang 20260603 START*/@value IS NOT NULL/*END*/)
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							/*vanduc edited by Mrs.Hang 20260603 START*/
							update Stb_ESRValueMonitor set UploadToMes='OK' where ID = @value1
							/*END*/
						end
						/*vanduc edited by Mrs.Hang 20260603 START*/
						else if (@value IS NOT NULL)
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update Stb_ESRValueMonitor set UploadToMes='FAIL' where ID = @value1
						end
						/*END*/
						else
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,NULL, GETDATE(),'system')
						end

					end

					if (@PatternID='PQC_V01_07' /*vanduc edited by Mrs.Hang 20260603 START*/or @PatternID='FOQC_V01_07'/*END*/)
					begin
						/*vanduc edited by Mrs.Hang 20260603 START*/
						select top(1) @value = Val, @value1 = MonitorID from @TempOCV where RowID = (@cnt + 1)
						/*END*/
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						
						if (@value4 <=@value6 and @value6<=@value5  and /*vanduc edited by Mrs.Hang 20260603 START*/@value IS NOT NULL/*END*/)
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							/*vanduc edited by Mrs.Hang 20260603 START*/
							update Stb_ESRValueMonitor set UploadOCVToMess='OK' where ID = @value1
							/*END*/
						end
						/*vanduc edited by Mrs.Hang 20260603 START*/
						else if (@value IS NOT NULL)
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update Stb_ESRValueMonitor set UploadOCVToMess='FAIL' where ID = @value1
						end
						/*END*/
						else
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,NULL, GETDATE(),'system')
						end

					end
									
				SET @cnt = @cnt + 1;
				--select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo
			
				--SET @value=0;
			end
		end
   end 

	SELECT
			MQSR.MaterialQcNo AS OldMaterialIqcNo,
			MQSR.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
			MQSR.MaterialQcSampleNo AS OldMaterialIqcSampleNo,
			MQSR.MaterialQcNo,
			MQSR.MaterialQcDetailNo,
			MQSR.MaterialQcSampleNo,
			MQSR.SampleSerialNo,
			MQSR.TestUserID,
			MQSR.TestDateTime,
			MQSR.TestValue,
			MQSR.TestResult,
			MQSR.CreateDateTime,
			MQSR.CreateUserID,
			MQSR.ChangeDateTime,
			MQSR.ChangeUserID,
			MQD.LSL,
			MQD.USL,
			MQD.QcInspectionItemDesc           --2020.02.15 ??			
	FROM STB_MaterialQcSampleResult MQSR WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK)	  
		ON MQSR.MaterialQcNo = MQD.MaterialQcNo	 
		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	WHERE MQSR.MaterialQcNo = @MaterialQcNo
		AND MQSR.MaterialQcDetailNo = @MaterialQcDetailNo
	ORDER BY MQSR.MaterialQcSampleNo
END
GO

PRINT 'Procedure usp_MaterialQcSampleResult_HY_get created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_GetMaterialQcInfo_ForReport_HY (Cloned from usp_GetMaterialQcInfo_ForReport)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetMaterialQcInfo_ForReport_HY')
    DROP PROCEDURE [dbo].[usp_GetMaterialQcInfo_ForReport_HY];
GO


-- =============================================
-- Author: Lim Dong Seon(dsim@awoo.co.kr)
-- Create date: 2016-09-29
-- Browsable : true
-- Group : 수입검사 > 시료별수입검사 Tab- 3
-- Description:	시료별 수입검사 "부적합보고서" Report
-- Modified:  
-- 2020.12.04 검토자, 결재자 수정 (박진호 요청)

-- 품질부적합 test  : exec usp_GetMaterialQcInfo_ForReport_HY @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='20071300002'
--                         exec usp_GetMaterialQcInfo_ForReport_HY @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='20101900005'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialQcInfo_ForReport_HY]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pMaterialQcNo VARCHAR(20) = NULL
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo

	SELECT
			MQI.MaterialQcNo AS OldMaterialIqcNo,
			MQI.MaterialQcNo,
			Case	When ISNULL(MQI.DecisionResult,'') = 'P' Then '합격' 
			        When ISNULL(MQI.DecisionResult,'') = 'F' Then '불합격'	  Else '미검'	  End  AS DecisionResultText,
			MQI.QcQty                                                As QcQty,                                             -- 레포트화면에서 "Lot크기" 입고수
			MQI.InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,			
			--Case When MQI.ActualSampleQty = 0 Then 0 
			--       When MQI.DefectSampleQty = 0 Then 0 
			--        Else  (MQI.DefectSampleQty / MQI.ActualSampleQty * 100) End  As DefectiveRate,   -- 레포트화면에서 "시료수" (불량수/시료수 * 백만) : 박진호요청 (2020-10-05 요청)
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			MQI.DecisionResult,
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			PW.UserName,
			MQI.SpecialAcceptDesc,
			MQI.DescText,
			MQI.VendorQcReport,								
			MDI.SourceCustomerCode,
	        C.CustomerName,
	        C.CustomerNameL,
			MQI.MaterialCode,  --품번
			MM.MaterialName,
			MM.MaterialSpec,   
			--MQI.CreateDateTime,
			Substring(Convert(Varchar, MQI.CreateDateTime), 1, 12) AS CreateDateTime,
			MQI.CreateUserID,
			PW.UserName                                                       AS UserName,             -- 2020.07.16추가
			--MQI.ChangeDateTime,                                                                         -- 원본백업
			CONVERT(VARCHAR(10), MQI.ChangeDateTime, 121)      AS  ChangeDateTime,  -- 수정
			CONVERT(VARCHAR(10), MQI.ChangeDateTime+7, 121 )  AS  ReplyDate,           -- 수정
			MQI.ChangeUserID,
			MVM.InspectionType AS MasterInspectionType,
			MVM.AQL               AS MasterAQL,
			MVM.InspectionLevel AS MasterInspectionLevel
--			, MDD.MaterialIqcNo
           , MQI.MIIExtText04   -- 원본불량율
		
		   --, Isnull((MQI.DefectSampleQty / MQI.QcQty * 100), 0) as DefectiveRate  -- 불량율 박진호요청

		   , SIR.DefectReportNo        AS DefectReportNo
		   , SIR.DefectDivisionCode
		   , BC1.Description             AS DefectDivisionName  -- 부적합명
		   , SIR.PublishDeptCode
		   , BC2.Description             AS PublishDeptName   --부적합발행부서명
		   , SIR.PublishDeptCode
		   , SIR.LotNo 
		   , SIR.CorrectiveActionCode  AS CorrectiveActionCode
		   , BC3.Description               AS CorrectiveActionName   --시정조치여부명
		   , SIR.ProdProcessResultCode  AS ProdProcessResultCode
		   , BC5.Description                 AS ProdProcessName    --생산부문처리결과  (재작업, 특채 등)
		   , SIR.DefectImage  
		   , SIR.DefectImage2
		   , SIR.Nonconformity
		   , SIR.ImmediateAction
		   , SIR.CauseInvestigation
		   , SIR.PreventionRecurrence
		   , SIR.DetectionCounterMeasures 		   
		   , SIR.CheckingCorrectiveAction   --시정조치확인
		   , SIR.Validation   --제품유효성확인
		   , MQI.DescText AS LotNo
		   , MQI.IQCSampleLotList  AS IQCSampleLotList    --검사 Lot NO
		   , PG.ProductGroupName AS ProductGroupName            
		  -- , Case When MQI.MIIExtText04 =0 then 0 when MDD.LotNoQty = 0         then 0 	else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.MIIExtText04) / CONVERT(NUMERIC(20,5), MDD.LotNoQty)  * 100))  end as DefectiveRate   -- Lot불량율(%) 원본백업 (박진호)
		   , Case when  MQI.DefectSampleQty = 0 then 0 when MQI.ActualSampleQty = 0   then 0 else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))    End as DefectiveRate   -- Lot불량율(%) 박진호요청 (2020.12.09)
		   , Case When	BC2.Description = '품질부문'          Then '' 
		           When	BC2.Description = '베트남품질부문' Then 'Mr.Tung'  Else '' End  Reviewer
		   , Case When	BC2.Description = '품질부문' Then '이미정'  
		            When	BC2.Description = '베트남품질부문' Then 'Je-Sik Eom'  Else '' End  Approver
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			--LEFT OUTER JOIN STB_MaterialQcDetail MQD  WITH(NOLOCK)				ON MQD.MaterialQcNo = MQI.MaterialQcNo
			--LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)				ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN (
										 SELECT DISTINCT MDD.MaterialDocNo as MaterialDocNo,
																MDD.MaterialIqcNo as MaterialIqcNo ,
																Count(MDLI.LotNo)	as LotNoQty            -- 2020-09-06 추가 	
											FROM
													                 STB_MaterialDocDetail MDD WITH(NOLOCK)
													INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
													INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
													INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
											WHERE 1=1
													--MQI.InspectionDocType LIKE @InspectionDocType 
													--AND	(MQI.DecisionResult LIKE @DecisionResult) 
													--AND	(MQI.MaterialCode LIKE @MaterialCode) 
													--AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
													--AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 
													--AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)
											Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            
									) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode  --2020.10.05 추가
			LEFT OUTER JOIN [SmartFramework].[dbo].[STB_UserInfo] PW WITH (NOLOCK)				ON PW.UserID = CASE WHEN ISNULL(MQI.DecisionUserID,'') = '' THEN @pProcessUserID ELSE MQI.DecisionUserID END
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_IQcDefectReport SIR WITH(NOLOCK)				ON SIR.LotNo = MQI.IQCSampleLotList              -- 부적합등록화면부분 2020.07.15 추가
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	ON SIR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
		   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON SIR.PublishDeptCode = BC2.ItemCode	       AND BC2.CodeGroup = 'PublishDeptCode'	                -- 부적합발행부서
		   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON SIR.CorrectiveActionCode = BC3.ItemCode   AND BC3.CodeGroup = 'CorrectiveActionCode'
		-- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	ON SIR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'	        -- 발생공정
		   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	    ON SIR.ProdProcessResultCode = BC5.ItemCode AND BC5.CodeGroup = 'ProdProcessResultCode'  -- 생산부문처리결과코드
	WHERE	1=1	  
	   AND MQI.MaterialQcNo = @MaterialQcNo
		--and (mqi.DecisionDateTime<'2022-01-01'   --Mr.Tung Audit 2245 on 24-March-2023
		--or  SIR.defectreportno in (
		--	'VVNI220119-01',
		--	'VVNI220318-01',
		--	'VVNI220729-01'
		--	)
	 --   )

	--ORDER BY 			ItemReportPrior ASC

END
GO

PRINT 'Procedure usp_GetMaterialQcInfo_ForReport_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_QcDefectIQCReport_HY_get (Cloned from usp_QcDefectIQCReport_get)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_QcDefectIQCReport_HY_get')
    DROP PROCEDURE [dbo].[usp_QcDefectIQCReport_HY_get];
GO

-- =============================================================================
-- Author : Kangs (kilee@vina.co.kr)
-- Group : 품질관리 > [C220]시료별수입검사 > 부적합등록(IQC)등록화면 Tab-2 
-- Browsable : True
-- Create date : 2020-07-10
-- Description : 부적합등록(수입검사용) 
-- 2020.10.23 검사LotNo로 변경해달라고 해서 테이블 추가   (박진호님 요청)
-- 2020.11.05 테스트완료 적용
-- 2020.12.14 Lot조치사항 추가

-- [프로시저 실행문]
-- usp_QcDefectIQCReport_HY_get 'kilee','Korean','VNI999999-99',''
-- usp_QcDefectIQCReport_HY_get 'kilee','Korean','','' 
-- ======================================================================================
CREATE PROCEDURE [dbo].[usp_QcDefectIQCReport_HY_get]                               
							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pDefectReportNo VARCHAR(20) = NULL,
							@pLotNo VARCHAR(MAX) = NULL,					-- DinhManh update 2025-02-12 VARCHAR(20) => VARCHAR(MAX) for LotNo and IQCSampleLotList
							@pIQCSampleLotList VARCHAR(MAX) = NULL			-- Error can't show report for item has long length IQCSampleLotList
AS

BEGIN
	Declare @DefectReportNo    VARCHAR(20) = @pDefectReportNo
	         , @DummyReportNo  VARCHAR(20) = @pDefectReportNo
			 , @LotNo                 VARCHAR(MAX) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '*' ELSE @pLotNo END						--
			 , @IQCSampleLotList  VARCHAR(MAX) = CASE WHEN ISNULL(@pIQCSampleLotList,'') = '' THEN '*' ELSE @pIQCSampleLotList END		--

	-- #200609
	-- EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport',@DefectReportNo OUTPUT 
	-- 자동채번 로직을 사용할 경우 자동증가하는 순번에 따라 빈 번호가 생길 수 있으므로 수동 채번 로직을 적용
	-- 신규번호이면, 더미를 쿼리하고, 그렇지 않으면 해당 번호를 쿼리한다.
	-- @DefectReportNo 채번의 경우 미리 채번을 할 경우 중복 및 업데이트 오류 발생 가능성이 있어 iud에서 채번하는 것으로 수정


	--IF @LotNo IS NOT NULL       ---------------------------------------- 검사 Lot 있는 경우
 ---- IF (@LotNo IS NOT NULL AND @DefectReportNo IS NOT NULL)       ---------------------------------------- 검사 Lot는 있고, 부적합 번호도 있는 경우   (부적합등록 데이터 조회하는 경우)

	BEGIN

	--IF @DefectReportNo IS NULL  AND @LotNo IS NOT NULL
	
		--BEGIN 
		--	-- @DefectReportNo 채번
		--	SELECT @DefectReportNo = 'Automatic Numbering'

		--	SET @DummyReportNo = 'VNI999999-99'
		--END

		--RAISERROR(@pLotNo, 16, 1)
		--return
	
		SELECT  @DefectReportNo AS DefectReportNo

		--SELECT  CASE WHEN @DefectReportNo is NULL THEN   'VNI999999-99' ELSE @DefectReportNo END AS DefectReportNo		
				  ,QDR.DefectDivisionCode
				  ,BC1.Description AS DefectDivisionName
				  ,QDR.PublishDeptCode
				  ,BC2.Description AS PublishDeptName
				  ,QDR.PublishEmpID
				  ,EI1.EmployeeName AS PublishEmpName
				  ,QDR.OccurProcessCode
				  ,BC4.Description AS OccurProcessName
				  ,QDR.JobDate
				  , Case when isnull(QDR.LotNo, '') = '' then @LotNo else QDR.LotNo End   AS LotNo
				  ,QDR.CorrectiveActionCode AS CorrectiveActionCode                   -- 시정조치여부코드
				  ,BC6.Description AS CorrectiveActionName                                   -- 시정조치여부명
				  ,QDR.DefectImage
				  ,QDR.DefectImage2  
				  ,QDR.DefectLotSize		
				  ,QDR.ProdProcessResultCode                                        -- 생산부분 처리코드 (재작업, 특채 등)
				  ,BC5.Description AS ProdProcessResultName                    -- 생산부분 처리명 (코드테이블)		
				  ,CONVERT(BIT, 0) AS IsProdHeadConfirm		  
				  ,CONVERT(BIT, 0) AS IsQcHeadConfirm		  
				  ,GETDATE() AS CreateDateTime
				  ,QDR.CreateUserID
				  ,QDR.ChangeDateTime
				  ,QDR.ChangeUserID
				  ,CONVERT(BIT, 0) AS IsReInspectionResult -- #200515
				  ,QDR.ProdProcessResultFile
				  ,AFM.[FileName]
				  ,AFM.FileSize
				  ,ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData
				  , QDR.Nonconformity  AS Nonconformity     --부적합내용
				  , QDR.ImmediateAction AS  ImmediateAction  --즉시조치
				  , QDR.CauseInvestigation AS  CauseInvestigation  --원인조사
				  , QDR.PreventionRecurrence AS  PreventionRecurrence  --재발방지조치
				  , QDR.DetectionCounterMeasures AS  DetectionCounterMeasures  --검출대책수립		  
				  , QDR.CheckingCorrectiveAction AS  CheckingCorrectiveAction  --시정조치확인
				  , QDR.Validation                     AS  Validation  --제품유효성확인
				  , QDR.IsActionCode         AS ActionCode   -- 시정조치여부
				  , QDR.QcOpinionContent AS QcOpinionContent    -- 품질부서의견
				  , QDR.IsQcHeadConfirm  AS IsQcHeadConfirm       -- 품질부문장결재
				  , CASE WHEN QDR.IsQcHeadConfirm  = 0 THEN  '결재취소'  WHEN QDR.IsQcHeadConfirm  = 1 THEN  '결재완료'  ELSE '미완료' END       AS Payment              -- 품질부문장결재
				  , MQI.IQCSampleLotList                                                                                                                                                      AS IQCSampleLotList   -- 검사 Lot No (2020-10-23, 박진호요청)		     
		   -- FROM STB_IQcDefectReport QDR   -- 원본백업
		          , QDR.ActionContent AS ActionContent
			  FROM STB_MaterialQcInfo MQI	    
					-- LEFT OUTER JOIN  STB_NCR_Report SNR                                   ON QDR.DefectReportNo = SNR.NCRNo             --원본백업
					  LEFT OUTER JOIN  STB_NCR_Report SNR                                    ON SNR.LotNo =       MQI.IQCSampleLotList    --추가부분 (2020.10.23)
					  LEFT OUTER JOIN  STB_IQcDefectReport QDR     WITH(NOLOCK)	   ON SNR.NCRNo = QDR.DefectReportNo    --추가부분 (2020.10.23)
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	           ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	           ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
					  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1  ON QDR.PublishEmpID = EI1.EmployeeNo
				   -- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	            ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	            ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
				   -- LEFT OUTER JOIN STB_MachineMaster MM	                                ON QDR.MachineCode = MM.MachineCode
				   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	ON QDR.ProdWorkerCode = EI2.EmployeeNo
				   -- LEFT OUTER JOIN STB_DefectInfo DI	                                        ON QDR.DefectCode = DI.DefectCode
				   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	ON QDR.ActionWorkerCode = EI3.EmployeeNo
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	            ON QDR.ProdProcessResultCode = BC5.ItemCode  AND BC5.CodeGroup = 'ProdProcessResultCode'
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	            ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               --추가(시정조치여부)
					  LEFT OUTER JOIN (
												SELECT DefectReportNo 
												 FROM STB_QcDefectReportReInspectionResult 
												GROUP BY DefectReportNo
											  ) QDRRR 	ON QDRRR.DefectReportNo = QDR.DefectReportNo
					  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	  ON AFM.FileID = QDR.ProdProcessResultFile		

			 WHERE 1=1 
			   And   MQI.IQCSampleLotList = @pLotNo

	  END


--   ELSE        ----------------------------------------------------------------------------- 그 밖의 신규로 등록하는 경우!!

--	   --IF @DefectReportNo IS NULL  AND @LotNo IS NOT NULL
	
--		BEGIN 
--			-- @DefectReportNo 채번
--			SELECT @DefectReportNo = 'Automatic Numbering'
--			     SET @DummyReportNo = 'VNI999999-99'
--		END
	
--SELECT @DefectReportNo AS DefectReportNo
--		  ,QDR.DefectDivisionCode
--		  ,BC1.Description AS DefectDivisionName
--		  ,QDR.PublishDeptCode
--		  ,BC2.Description AS PublishDeptName
--		  ,QDR.PublishEmpID
--		  ,EI1.EmployeeName AS PublishEmpName
--		  ,QDR.OccurProcessCode
--		  ,BC4.Description AS OccurProcessName
--		  ,QDR.JobDate
--		  , Case when isnull(QDR.LotNo, '') = '' then @LotNo else QDR.LotNo End   AS LotNo
--		  ,QDR.CorrectiveActionCode AS CorrectiveActionCode                   -- 시정조치여부코드
--		  ,BC6.Description AS CorrectiveActionName                                   -- 시정조치여부명
--		  ,QDR.DefectImage
--		  ,QDR.DefectImage2  
--		  ,QDR.DefectLotSize		
--		  ,QDR.ProdProcessResultCode                                        -- 생산부분 처리코드 (재작업, 특채 등)
--		  ,BC5.Description AS ProdProcessResultName                    -- 생산부분 처리명 (코드테이블)		
--		  ,CONVERT(BIT, 0) AS IsProdHeadConfirm		  
--		  ,CONVERT(BIT, 0) AS IsQcHeadConfirm		  
--		  ,GETDATE() AS CreateDateTime
--		  ,QDR.CreateUserID
--		  ,QDR.ChangeDateTime
--		  ,QDR.ChangeUserID
--		  ,CONVERT(BIT, 0) AS IsReInspectionResult -- #200515
--		  ,QDR.ProdProcessResultFile
--		  ,AFM.[FileName]
--		  ,AFM.FileSize
--		  ,ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData
--		  , QDR.Nonconformity  AS Nonconformity     --부적합내용
--		  , QDR.ImmediateAction AS  ImmediateAction  --즉시조치
--		  , QDR.CauseInvestigation AS  CauseInvestigation  --원인조사
--		  , QDR.PreventionRecurrence AS  PreventionRecurrence  --재발방지조치
--		  , QDR.DetectionCounterMeasures AS  DetectionCounterMeasures  --검출대책수립		  
--		  , QDR.CheckingCorrectiveAction AS  CheckingCorrectiveAction  --시정조치확인
--		  , QDR.Validation                     AS  Validation  --제품유효성확인
--		  , QDR.IsActionCode         AS ActionCode   -- 시정조치여부
--		  , QDR.QcOpinionContent AS QcOpinionContent    -- 품질부서의견
--          , QDR.IsQcHeadConfirm  AS IsQcHeadConfirm       -- 품질부문장결재
--		  , CASE WHEN QDR.IsQcHeadConfirm  = 0 THEN  '결재취소'  WHEN QDR.IsQcHeadConfirm  = 1 THEN  '결재완료'  ELSE '미완료' END   AS Payment              -- 품질부문장결재
--		  , MQI.IQCSampleLotList                                                                                                                                                  AS IQCSampleLotList   -- 검사 Lot No (2020-10-23, 박진호요청)
		     
--   -- FROM STB_IQcDefectReport QDR   -- 원본백업
--	  FROM STB_MaterialQcInfo MQI	    
--	        -- LEFT OUTER JOIN  STB_NCR_Report SNR                                   ON QDR.DefectReportNo = SNR.NCRNo             --원본백업
--			  LEFT OUTER JOIN  STB_NCR_Report SNR                                    ON SNR.LotNo =       MQI.IQCSampleLotList    --추가부분 (2020.10.23)
--			  LEFT OUTER JOIN  STB_IQcDefectReport QDR     WITH(NOLOCK)	   ON SNR.NCRNo = QDR.DefectReportNo    --추가부분 (2020.10.23)

--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	           ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	           ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
--			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1  ON QDR.PublishEmpID = EI1.EmployeeNo
--		   -- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	            ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	            ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
--		   -- LEFT OUTER JOIN STB_MachineMaster MM	                                ON QDR.MachineCode = MM.MachineCode
--		   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	ON QDR.ProdWorkerCode = EI2.EmployeeNo
--		   -- LEFT OUTER JOIN STB_DefectInfo DI	                                        ON QDR.DefectCode = DI.DefectCode
--		   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	ON QDR.ActionWorkerCode = EI3.EmployeeNo
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	            ON QDR.ProdProcessResultCode = BC5.ItemCode  AND BC5.CodeGroup = 'ProdProcessResultCode'
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	            ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               --추가(시정조치여부)
--			  LEFT OUTER JOIN (
--			                            SELECT DefectReportNo 
--										 FROM STB_QcDefectReportReInspectionResult 
--										GROUP BY DefectReportNo
--									  ) QDRRR 	ON QDRRR.DefectReportNo = QDR.DefectReportNo
--			  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	  ON AFM.FileID = QDR.ProdProcessResultFile		

--	 WHERE 1=1 
--	    And MQI.IQCSampleLotList= @DummyReportNo	    	   
--	   --And MQI.IQCSampleLotList= 'VNI999999-99'                -- 테스트용 주석

	    
END
GO

PRINT 'Procedure usp_QcDefectIQCReport_HY_get created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DoUpdateMaterialQcInfo_Success_HY (Cloned from usp_DoUpdateMaterialQcInfo_Success)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoUpdateMaterialQcInfo_Success_HY')
    DROP PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Success_HY];
GO


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-18
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사 합격을 처리합니다
-- Modified:
-- 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Success_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20)=null,
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pProdInspWorkerCode VARCHAR(20)= null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @GRProcessQty NUMERIC(20,5)
	DECLARE @RemainQty NUMERIC(20,5)
	DECLARE @TotalCount INT
	DECLARE @LoopCount INT
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @PickingAssingQty NUMERIC(20,5)
	DECLARE @BefQcStatus VARCHAR(10) -- 이것도 1로 해놨네 신발...
	DECLARE @ProdInspWorkerCode VARCHAR(20) = @pProdInspWorkerCode

	DECLARE @SampleCreateCount INT
	DECLARE @SampleInputCount INT

	DECLARE @PassedSampleQty INT    -- 2020.08.24 추가
	DECLARE @SampleTotalQty INT

	Declare @CompanyCode VARCHAR(20) -- 2022.03.21  추가 By Jackaroe
	Declare @WorkerCompanyCode VARCHAR(20) -- 2022.09.26 추가 By Jackaroe
	
	DECLARE @iDoc INT
	
	DECLARE @MaterialDocDetail TABLE
		(
			IDX INT,
			MaterialDocDetailNo VARCHAR(20),
			PickingAssignQty NUMERIC(20,5)
		)

	SELECT @WorkerCompanyCode = CompanyCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR

				SELECT
						CASE WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo ELSE XMLData.OldMaterialQcNo END AS OldMaterialIqcNo,
						XMLData.CompanyCode AS CompanyCode
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20),
								 CompanyCode VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo, @CompanyCode

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			-- 샘플이 생성되어 있는 경우 샘플 수와 입력된 데이터 수가 다르면 처리 불가. 품질부문 요청 2019.10.28 By Jackaroe
			-- 샘플 종류별로 카운트 하지 않고, 전체 샘플 수량으로 비교한다. 이후 요청이 있을 경우 세분화 시켜야 할 수도 있음.
			
			-- [1] 전체 검사수
			SELECT @SampleCreateCount = COUNT(*)
			  FROM STB_MaterialQcSampleResult with(nolock) 
			 WHERE MaterialQcNo = @OldMaterialQcNo
			                   
							    -- [1]번 검증
								 --SELECT  SampleCreateCount, * 
								 -- FROM STB_MaterialQcSampleResult
								 --WHERE MaterialQcNo = 'VJKQ182R710609'


			 -- [2] 검사입력수
			 SELECT @SampleInputCount = COUNT(*)
			  FROM STB_MaterialQcSampleResult with(nolock) 
			 WHERE MaterialQcNo = @OldMaterialQcNo
			   AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), TestValue), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), TestResult), '')) <> '')
			                         
									 -- [2]번검증
							         -- SELECT  *
									 -- FROM STB_MaterialQcSampleResult
									 --WHERE MaterialQcNo = 'VJKQ182R710609'
									 --  AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), TestValue), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), TestResult), '')) <> '')

            -- 검사수량 비교처리 미적용 이미정프로 요청 #220311 By Jackaroe
			-- 본사에서 베트남 제품검사를 진행하는 경우가 있으므로 작업자의 CompanyCode를 조건에 추가함.
			IF @CompanyCode='VVT' and @SampleCreateCount <> @SampleInputCount AND @WorkerCompanyCode = 'VVT'     -- 전체검사항목에 입력했는지 체크 / [1]번과 [2]번 비교
			
			BEGIN
				Declare @InputValueCheck NVARCHAR(MAX)

				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																	@pName = '^샘플 개수와 입력 값의 개수가 일치하지 않습니다.^',
																	@pValue = @InputValueCheck OUTPUT	
				RAISERROR(@InputValueCheck, 16, 1)
				RETURN
			END
				
	--------- 2020.08.24 체크사항 추가 Start ----------------------------------------------------------------------

			-- [3] 항목당 샘플수량(10,10,3)과 비교  (SampleCheckCount)
			-- 외관 검사의 경우 측정값을 입력하지 않으므로 입력된 값의 개수와 샘플수량이 아닌 샘플수량과 합격수량을 비교하도록 로직 수정 2021.10.27 by Jackaroe
			 SELECT @PassedSampleQty = SUM(PassedSampleQty)
			       ,@SampleTotalQty = SUM(SampleQty)
			  FROM STB_MaterialQcDetail with(nolock) 
			 WHERE 1=1
			   AND  MaterialQcNo = @OldMaterialQcNo			   
			   AND (RTRIM(IsNull(Convert(VARCHAR(10), SampleQty), '')) <> '' Or  RTRIM(IsNull(Convert(VARCHAR(10), SampleQty), '')) <> '')
			   and QcInspectionItemCode !='IQC_GPD_21'

			                         -- [3]수량 검증쿼리
							         --SELECT  SUM(SampleQty) AS SampleQty                                  -- 23개
									 -- FROM STB_MaterialQcDetail
									 --WHERE 1=1									 
									 --  AND  MaterialQcNo = 'VJKQ182R710609'
									 --  AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), SampleQty), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), SampleQty), '')) <> '')
									 --  And QcInspectionItemCode in ('IQC_GPD_18','IQC_GPD_19','IQC_GPD_20')       --SD, ESR, 용량
                                     -- Group by MaterialQcDetailNo 

			-- 검사수량 비교처리 미적용 이미정프로 요청 #220311 By Jackaroe


			--RAISERROR(@SampleTotalQty, 16, 1)
			IF @CompanyCode='VVT' and (@SampleTotalQty <> @PassedSampleQty AND @SampleTotalQty <> @SampleInputCount) AND @WorkerCompanyCode = 'VVT'     --2021.10.27 by Jackaroe
			
			BEGIN
				Declare @SampleValueCheck NVARCHAR(Max)

				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																	@pName = '^샘플 개수와 합격수량이 일치하지 않습니다.^',
																	@pValue = @SampleValueCheck OUTPUT	
				RAISERROR(@SampleValueCheck, 16, 1)
				RETURN
			END
	--------- 2020.08.24 체크사항 추가 End ----------------------------------------------------------------------
	
			DECLARE @DecisionResult VARCHAR(10)    -- 2020.07.16 추가
			DECLARE @DescText        VARCHAR(20)     -- 2020.07.16 추가

			SELECT
					@BefQcStatus = MQI.DecisionResult,
					@GRProcessQty = MQI.ProcessQty,
					@DecisionResult = MQI.DecisionResult,        -- 2020.07.16 추가
					@DescText = MQI.DescText                       -- 2020.07.16 추가
			FROM
					STB_MaterialQcInfo MQI with(nolock) 
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	            


			IF ISNULL(@BefQcStatus,'') IN ('Pass') BEGIN
					DECLARE @AlreadyFinish NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^이미 완료처리된 문서입니다.^',
																		@pValue = @AlreadyFinish OUTPUT	
					RAISERROR(@AlreadyFinish, 16, 1)
					RETURN
			END

			PRINT 'Start Update 1 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Pass',
					MIIExtText01 = @ProdInspWorkerCode,
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @OldMaterialQcNo

			PRINT 'Start Update 2 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

			UPDATE	STB_SetInfo
			SET
					LotDecisionResult = 'Pass'
			WHERE
					LotNumber = @OldMaterialQcNo

			PRINT 'Start Update 3 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

			UPDATE STB_MaterialQcDetail
			SET
					DecisionResult = 'Pass'
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					ISNULL(DecisionResult, '') = '' 

			PRINT 'Start Update 4 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)


			DELETE FROM @MaterialDocDetail
			
			INSERT INTO @MaterialDocDetail		(IDX, MaterialDocDetailNo, PickingAssignQty)
			SELECT
					ROW_NUMBER() OVER (ORDER BY MDD.MaterialDocDetailNo)
				,	MDD.MaterialDocDetailNo
				,	MDD.PickingAssignQty
			FROM
					STB_MaterialDocDetail MDD with(nolock) 		
			LEFT OUTER JOIN STB_MaterialDocInfo MDI with(nolock)  ON (MDI.MaterialDocNo = MDD.MaterialDocNo)
			WHERE 
					MDD.MaterialIqcNo = @OldMaterialQcNo AND
					ISNULL(MDI.IsCancel,0) = 0

			SELECT
					@TotalCount = COUNT(*)
			FROM
					@MaterialDocDetail

			SET @RemainQty = @GRProcessQty
			SET @LoopCount = 1

			PRINT 'Start While : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

			WHILE @LoopCount <= @TotalCount
			BEGIN
					SELECT
							@MaterialDocDetailNo = MaterialDocDetailNo,
							@PickingAssingQty = PickingAssignQty
					FROM
							@MaterialDocDetail
					WHERE
							IDX = @LoopCount


					IF @PickingAssingQty >= @RemainQty 
					BEGIN
							UPDATE STB_MaterialDocDetail
							SET
									PickingQty = @RemainQty
							WHERE
									MaterialDocDetailNo = @MaterialDocDetailNo

							SET @RemainQty = 0
					END ELSE BEGIN
							UPDATE STB_MaterialDocDetail
							SET
									PickingQty = @PickingAssingQty
							WHERE
									MaterialDocDetailNo = @MaterialDocDetailNo

							SET @RemainQty = @RemainQty - @PickingAssingQty
					END

					SET @LoopCount = @LoopCount + 1
			END
        END

		PRINT 'End While : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	CLOSE SourceData;
	DEALLOCATE SourceData;
		
	EXEC sp_xml_removedocument @idoc	
END


GO

PRINT 'Procedure usp_DoUpdateMaterialQcInfo_Success_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DoUpdateMaterialQcInfo_Fail_HY (Cloned from usp_DoUpdateMaterialQcInfo_Fail)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoUpdateMaterialQcInfo_Fail_HY')
    DROP PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Fail_HY];
GO


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-18
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사 불합격을 처리합니다
-- Modified: 불합격처리 시에도 제품검사자 사번을 업데이트하도록 수정 By Jackaroe 2020.05.18
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Fail_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pProdInspWorkerCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @ProdInspWorkerCode VARCHAR(20) = @pProdInspWorkerCode

	DECLARE @BefQcStatus VARCHAR(10)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
				SELECT
						CASE 
							WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo
							ELSE XMLData.OldMaterialQcNo
						END AS OldMaterialIqcNo
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			SELECT
					@BefQcStatus = MQI.DecisionResult
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	

			-- 어떤 놈이냐 @BefQcStatus를 VARCHAR(1)로 잡아놓은게 찢어죽일테다!!!!
			-- 판정이 된 제품검사 Lot를 재처리 할 수 있도록 아래 조건을 주석처리함. 품질부문 요청. 2019.10.28 By Jackaroe
			--IF ISNULL(@BefQcStatus,'') NOT IN ('None') BEGIN
			--		DECLARE @AlreadyFinish NVARCHAR(MAX)
			--		EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
			--															@pName = '^이미 완료처리된 문서입니다.^',
			--															@pValue = @AlreadyFinish OUTPUT
			--		RAISERROR(@AlreadyFinish, 16, 1)
			--		RETURN
			--END

			-- 대우 루컴즈 부장 요청을 왜 남겨놨... -_-
			-- 2016-11-03 LDS 수정 불합격 판정 1개라도 있어야 처리하게 by 대우루컴즈 송요섭 부장 요청
			/*
			IF (
					SELECT
							COUNT(*)
					FROM
							STB_MaterialQcDetail 
					WHERE 
							MaterialQcNo = @OldMaterialQcNo AND
							ISNULL(DecisionResult,'') = 'Reject'
				) <= 0
			BEGIN
				RAISERROR('불합격 판정이 1건 이상 존재해야 합니다!',16,1)
				RETURN
			END
			*/

            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Reject',
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
					MIIExtText01 = @ProdInspWorkerCode,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @OldMaterialQcNo
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
GO

PRINT 'Procedure usp_DoUpdateMaterialQcInfo_Fail_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DoMakeMaterialQcSampleResult_HY (Cloned from usp_DoMakeMaterialQcSampleResult)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoMakeMaterialQcSampleResult_HY')
    DROP PROCEDURE [dbo].[usp_DoMakeMaterialQcSampleResult_HY];
GO


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-03-24
-- Browsable : true
-- Group : 품질관리 > 샘플리스트 생성버튼
-- Description:	시료별 수입검사에서 검사항목의 SampleQty에 따라 샘플 리스트를 생성하는 프로시저
--				이 프로시저로는 SampleQty 이상의 샘플은 자동으로 추가하지 않음. 그 이상은 + 버튼을 눌러 직접 추가하도록 함 
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialQcSampleResult_HY]
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
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyInt INT --
	DECLARE @VVTMaxKeyInt  INT --

    -- Declare Columns Variable
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcDetailNo INT
	DECLARE @SampleQty INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcSampleResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
						XMLData.MaterialQcNo,
						XMLData.MaterialQcDetailNo,
						XMLData.SampleQty
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 MaterialQcNo VARCHAR(20),
								 MaterialQcDetailNo INT,
								 SampleQty INT
								) XMLData

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @MaterialQcNo,
								 @MaterialQcDetailNo,
								 @SampleQty

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				SELECT
						@MaxKeyInt = ISNULL(MAX(MaterialQcSampleNo), 0)
				FROM
						STB_MaterialQcSampleResult 
				WHERE
						MaterialQcNo = @MaterialQcNo AND
						MaterialQcDetailNo = @MaterialQcDetailNo


				--for Vietnam Only
				-- edit by Mr.Tung
				--on 2021-02-02
				if(@MaterialQcNo like 'V%' or @MaterialQcNo like 'M%') begin

					select @VVTMaxKeyInt = @MaxKeyInt;  -- add by Tung on 2021-02-02

						SELECT
								@MaxKeyInt = ISNULL(COUNT(MaterialQcSampleNo), 0) --using COUNT instead of MAX function
						FROM
								STB_MaterialQcSampleResult 
						WHERE
								MaterialQcNo = @MaterialQcNo AND
								MaterialQcDetailNo = @MaterialQcDetailNo
						
				end
				--end by Tung on 2021-02-02


				-------2021.02.05 Test
				--	if(@MaterialQcNo IN ('VJLJ312R750604','VJLJ312R750622','VJLJ312R750625'))
					
				--	begin

				--		SELECT
				--				--@MaxKeyInt = ISNULL(COUNT(MaterialQcSampleNo), 0) --using COUNT instead of MAX function
				--				@MaxKeyInt = 30
				--		FROM
				--				STB_MaterialQcSampleResult 
				--		WHERE 1=1
				--		  -- AND MaterialQcNo = @MaterialQcNo 
				--		  --AND MaterialQcDetailNo = @MaterialQcDetailNo
				--		   AND MaterialQcNo in ('VJLJ312R750604','VJLJ312R750622','VJLJ312R750625')
				--		   AND MaterialQcDetailNo = '20'
						
				--end
				---- 2021.02.05




				
				-- 샘플리스트의 맥스값이 SampleQty 보다 클 경우 Break
				IF @MaxKeyInt >= (
				                            SELECT
													CASE WHEN ISNULL(SampleQty, 0) = 0 THEN RequestSampleQty ELSE ISNULL(SampleQty, 0) END
											FROM
													STB_MaterialQcDetail 
											WHERE
													MaterialQcNo = @MaterialQcNo AND
													MaterialQcDetailNo = @MaterialQcDetailNo
										 )
				BEGIN
					BREAK
				END

			
				WHILE @MaxKeyInt < @SampleQty BEGIN
				
					SET @MaxKeyInt += 1
					
					
					INSERT INTO STB_MaterialQcSampleResult
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						MaterialQcSampleNo,
						CreateDateTime,
						CreateUserID
					)
					VALUES
					(
						@MaterialQcNo,
						@MaterialQcDetailNo,
						--@MaxKeyInt,
						case when @MaterialQcNo like 'V%' or @MaterialQcNo like 'M%' then @VVTMaxKeyInt + @MaxKeyInt else @MaxKeyInt end,  -- add by Tung on 2021-02-02 MAX + COUNT value
						GETDATE(),
						@pProcessUserID
					)
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
GO

PRINT 'Procedure usp_DoMakeMaterialQcSampleResult_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_MaterialQcDetail_HY_iud (Cloned from usp_MaterialQcDetail_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcDetail_HY_iud')
    DROP PROCEDURE [dbo].[usp_MaterialQcDetail_HY_iud];
GO


-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-30
-- Browsable : true
-- Group : 품질관리 > [C220] 시료별수입검사
-- Description:	수입검사항목 (2번째 Tab)
-- Modified: 2019-03-28 kilee 수정 
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcDetail_HY_iud]
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
			@pTableName = 'STB_MaterialQcDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialQcDetail AS TargetTable
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
            MERGE STB_MaterialQcDetail AS TargetTable
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
            MERGE STB_MaterialQcDetail AS TargetTable
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

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcDetail WHERE MaterialQcNo = @MaterialQcNo AND MaterialQcDetailNo = @MaterialQcDetailNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcDetail',@MaterialQcNo OUTPUT
                    END

                    INSERT INTO STB_MaterialQcDetail
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
                    UPDATE STB_MaterialQcDetail
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
                    DELETE FROM STB_MaterialQcDetail
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

GO

PRINT 'Procedure usp_MaterialQcDetail_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_MaterialQcSampleResult_HY_iud (Cloned from usp_MaterialQcSampleResult_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcSampleResult_HY_iud')
    DROP PROCEDURE [dbo].[usp_MaterialQcSampleResult_HY_iud];
GO


-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-30
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcSampleResult_HY_iud]
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
  DECLARE @OldMaterialQcSampleNo INT
  DECLARE @MaterialQcNo VARCHAR(20)
  DECLARE @MaterialQcDetailNo INT
  DECLARE @MaterialQcSampleNo INT
  DECLARE @SampleSerialNo VARCHAR(50)
  DECLARE @TestUserID VARCHAR(20)
  DECLARE @TestDateTime DATETIME
  DECLARE @TestValue NUMERIC(20,5)
  DECLARE @TestResult VARCHAR(10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @DocDecisionResult VARCHAR(20)

  -- 입력값 판단을 위한 LSL, USL 추가 2021.03.30 박진호 과장 요청 By Jackaroe
  DECLARE @USL NUMERIC(20,5)
  DECLARE @LSL NUMERIC(20,5)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcSampleResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialQcSampleResult AS TargetTable
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
							CASE
							    WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
							    ELSE OldMaterialQcSampleNo
							END AS OldMaterialQcSampleNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							MaterialQcSampleNo,
							SampleSerialNo,
							TestUserID,
							TestDateTime,
							TestValue,
							TestResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										OldMaterialQcSampleNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										MaterialQcSampleNo INT,
										SampleSerialNo VARCHAR(50),
										TestUserID VARCHAR(20),
										TestDateTime DATETIMEOFFSET,
										TestValue NUMERIC(20,5),
										TestResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.MaterialQcDetailNo AND
					TargetTable.MaterialQcSampleNo = SourceTable.MaterialQcSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					MaterialQcDetailNo = ISNULL(SourceTable.MaterialQcDetailNo,TargetTable.MaterialQcDetailNo),
					MaterialQcSampleNo = ISNULL(SourceTable.MaterialQcSampleNo,TargetTable.MaterialQcSampleNo),
					SampleSerialNo = ISNULL(SourceTable.SampleSerialNo,TargetTable.SampleSerialNo),
					TestUserID = ISNULL(SourceTable.TestUserID,TargetTable.TestUserID),
					TestDateTime = ISNULL(SourceTable.TestDateTime,TargetTable.TestDateTime),
					TestValue = ISNULL(SourceTable.TestValue,TargetTable.TestValue),
					TestResult = ISNULL(SourceTable.TestResult,TargetTable.TestResult),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						MaterialQcSampleNo,
						SampleSerialNo,
						TestUserID,
						TestDateTime,
						TestValue,
						TestResult,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.MaterialQcDetailNo,
							SourceTable.MaterialQcSampleNo,
							SourceTable.SampleSerialNo,
							SourceTable.TestUserID,
							SourceTable.TestDateTime,
							SourceTable.TestValue,
							SourceTable.TestResult,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialQcSampleResult AS TargetTable
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
							CASE
							    WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
							    ELSE OldMaterialQcSampleNo
							END AS OldMaterialQcSampleNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							MaterialQcSampleNo,
							SampleSerialNo,
							TestUserID,
							TestDateTime,
							TestValue,
							TestResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										OldMaterialQcSampleNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										MaterialQcSampleNo INT,
										SampleSerialNo VARCHAR(50),
										TestUserID VARCHAR(20),
										TestDateTime DATETIMEOFFSET,
										TestValue NUMERIC(20,5),
										TestResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.OldMaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.OldMaterialQcDetailNo AND
					TargetTable.MaterialQcSampleNo = SourceTable.OldMaterialQcSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialQcNo = ISNULL(SourceTable.MaterialQcNo,TargetTable.MaterialQcNo),
					MaterialQcDetailNo = ISNULL(SourceTable.MaterialQcDetailNo,TargetTable.MaterialQcDetailNo),
					MaterialQcSampleNo = ISNULL(SourceTable.MaterialQcSampleNo,TargetTable.MaterialQcSampleNo),
					SampleSerialNo = ISNULL(SourceTable.SampleSerialNo,TargetTable.SampleSerialNo),
					TestUserID = ISNULL(SourceTable.TestUserID,TargetTable.TestUserID),
					TestDateTime = ISNULL(SourceTable.TestDateTime,TargetTable.TestDateTime),
					TestValue = ISNULL(SourceTable.TestValue,TargetTable.TestValue),
					TestResult = ISNULL(SourceTable.TestResult,TargetTable.TestResult),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						MaterialQcSampleNo,
						SampleSerialNo,
						TestUserID,
						TestDateTime,
						TestValue,
						TestResult,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialQcNo,
							SourceTable.MaterialQcDetailNo,
							SourceTable.MaterialQcSampleNo,
							SourceTable.SampleSerialNo,
							SourceTable.TestUserID,
							SourceTable.TestDateTime,
							SourceTable.TestValue,
							SourceTable.TestResult,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialQcSampleResult AS TargetTable
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
							CASE
							    WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
							    ELSE OldMaterialQcSampleNo
							END AS OldMaterialQcSampleNo,
							MaterialQcNo,
							MaterialQcDetailNo,
							MaterialQcSampleNo,
							SampleSerialNo,
							TestUserID,
							TestDateTime,
							TestValue,
							TestResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialQcNo VARCHAR(20),
										OldMaterialQcDetailNo INT,
										OldMaterialQcSampleNo INT,
										MaterialQcNo VARCHAR(20),
										MaterialQcDetailNo INT,
										MaterialQcSampleNo INT,
										SampleSerialNo VARCHAR(50),
										TestUserID VARCHAR(20),
										TestDateTime DATETIMEOFFSET,
										TestValue NUMERIC(20,5),
										TestResult VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialQcNo = SourceTable.MaterialQcNo AND
					TargetTable.MaterialQcDetailNo = SourceTable.MaterialQcDetailNo AND
					TargetTable.MaterialQcSampleNo = SourceTable.MaterialQcSampleNo
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
									OldMaterialQcSampleNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									MaterialQcSampleNo,
									SampleSerialNo,
									TestUserID,
									TestDateTime,
									TestValue,
									TestResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									LSL,
									USL
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 OldMaterialQcSampleNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 MaterialQcSampleNo INT,
											 SampleSerialNo VARCHAR(50),
											 TestUserID VARCHAR(20),
											 TestDateTime DATETIMEOFFSET,
											 TestValue NUMERIC(20,5),
											 TestResult VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 LSL NUMERIC(20,5),
											 USL NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
										ELSE OldMaterialQcNo
									END AS OldMaterialQcNo,
									CASE 
										WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
										ELSE OldMaterialQcDetailNo
									END AS OldMaterialQcDetailNo,
									CASE 
										WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
										ELSE OldMaterialQcSampleNo
									END AS OldMaterialQcSampleNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									MaterialQcSampleNo,
									SampleSerialNo,
									TestUserID,
									TestDateTime,
									TestValue,
									TestResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									LSL,
									USL
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 OldMaterialQcSampleNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 MaterialQcSampleNo INT,
											 SampleSerialNo VARCHAR(50),
											 TestUserID VARCHAR(20),
											 TestDateTime DATETIMEOFFSET,
											 TestValue NUMERIC(20,5),
											 TestResult VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 LSL NUMERIC(20,5),
											 USL NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
										ELSE OldMaterialQcNo
									END AS OldMaterialQcNo,
									CASE 
										WHEN OldMaterialQcDetailNo IS NULL THEN MaterialQcDetailNo
										ELSE OldMaterialQcDetailNo
									END AS OldMaterialQcDetailNo,
									CASE 
										WHEN OldMaterialQcSampleNo IS NULL THEN MaterialQcSampleNo
										ELSE OldMaterialQcSampleNo
									END AS OldMaterialQcSampleNo,
									MaterialQcNo,
									MaterialQcDetailNo,
									MaterialQcSampleNo,
									SampleSerialNo,
									TestUserID,
									TestDateTime,
									TestValue,
									TestResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									LSL,
									USL
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialQcNo VARCHAR(20),
											 OldMaterialQcDetailNo INT,
											 OldMaterialQcSampleNo INT,
											 MaterialQcNo VARCHAR(20),
											 MaterialQcDetailNo INT,
											 MaterialQcSampleNo INT,
											 SampleSerialNo VARCHAR(50),
											 TestUserID VARCHAR(20),
											 TestDateTime DATETIMEOFFSET,
											 TestValue NUMERIC(20,5),
											 TestResult VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 LSL NUMERIC(20,5),
											 USL NUMERIC(20,5)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialQcNo,
								 @OldMaterialQcDetailNo,
								 @OldMaterialQcSampleNo,
								 @MaterialQcNo,
								 @MaterialQcDetailNo,
								 @MaterialQcSampleNo,
								 @SampleSerialNo,
								 @TestUserID,
								 @TestDateTime,
								 @TestValue,
								 @TestResult,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @LSL,
								 @USL


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				--SELECT
				--		@DocDecisionResult = MQI.DecisionResult
				--FROM
				--		STB_MaterialQcInfo MQI WITH (NOLOCK)
				--WHERE
				--		MQI.MaterialQcNo = @MaterialQcNo

				--IF ISNULL(@DocDecisionResult,'') IN ('P','S')
				--BEGIN
				--		RAISERROR('이미 처리된 수입검사 문서입니다', 16, 1)
				--		RETURN
				--END

				IF @TestValue > @USL * 5 OR @TestValue < @LSL / 5.0 BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, '상/하한을 크게 벗어나는 값이 있습니다. 확인 바랍니다.'
					RETURN  --
				END

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcSampleResult WHERE MaterialQcNo = @MaterialQcNo AND MaterialQcDetailNo = @MaterialQcDetailNo AND MaterialQcSampleNo = @MaterialQcSampleNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcSampleResult',@MaterialQcNo OUTPUT
                    END

                    INSERT INTO STB_MaterialQcSampleResult
						(
						    MaterialQcNo,
						    MaterialQcDetailNo,
						    MaterialQcSampleNo,
						    SampleSerialNo,
						    TestUserID,
						    TestDateTime,
						    TestValue,
						    TestResult,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialQcNo,
						    @MaterialQcDetailNo,
						    @MaterialQcSampleNo,
						    @SampleSerialNo,
						    @TestUserID,
						    @TestDateTime,
						    @TestValue,
						    @TestResult,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialQcSampleResult
						SET
						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
						    MaterialQcDetailNo =   ISNULL(@MaterialQcDetailNo,MaterialQcDetailNo),
						    MaterialQcSampleNo =   ISNULL(@MaterialQcSampleNo,MaterialQcSampleNo),
						    SampleSerialNo =   ISNULL(@SampleSerialNo,SampleSerialNo),
						    TestUserID =   ISNULL(@TestUserID,TestUserID),
						    TestDateTime =   ISNULL(@TestDateTime,TestDateTime),
						    TestValue =   ISNULL(@TestValue,TestValue),
						    TestResult =   ISNULL(@TestResult,TestResult),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialQcNo = @OldMaterialQcNo AND
						    MaterialQcDetailNo = @OldMaterialQcDetailNo AND
						    MaterialQcSampleNo = @OldMaterialQcSampleNo

					-- SampleResult 개수만큼 호출할 필요가 없음.
					-- 저장이 완료된 후(커서가 완료된 후) 한번만 호출하는 것으로 변경 2022.04.19 by Jackaroe
					---- QcDetail Update
					
					--	;WITH SampleResult AS
					--	(
					--		SELECT
					--				TestResult
					--		FROM
					--				STB_MaterialQcSampleResult WITH(NOLOCK)
					--		WHERE
					--				MaterialQcNo = @OldMaterialQcNo AND
					--				MaterialQcDetailNo = @OldMaterialQcDetailNo
					--	)
					
					--	UPDATE STB_MaterialQcDetail 
					--	SET
					--			PassedSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'P'),
					--			DefectSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'F'),
					--			SkipSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'S')
					--	WHERE
					--			MaterialQcNo = @OldMaterialQcNo AND
					--			MaterialQcDetailNo = @OldMaterialQcDetailNo

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialQcSampleResult
						WHERE
						    MaterialQcNo = @OldMaterialQcNo AND
						    MaterialQcDetailNo = @OldMaterialQcDetailNo AND
						    MaterialQcSampleNo = @OldMaterialQcSampleNo
                END
            END

			-- Insert, Update, Delete 가 끝난 후 업데이트 실행
			;WITH SampleResult AS
			(
				SELECT
						TestResult
				FROM
						STB_MaterialQcSampleResult WITH(NOLOCK)
				WHERE
						MaterialQcNo = @OldMaterialQcNo AND
						MaterialQcDetailNo = @OldMaterialQcDetailNo
			)
					
			UPDATE STB_MaterialQcDetail 
			SET
					PassedSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'P'),
					DefectSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'F'),
					SkipSampleQty = (SELECT COUNT(*) FROM SampleResult WHERE TestResult = 'S')
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					MaterialQcDetailNo = @OldMaterialQcDetailNo
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

GO

PRINT 'Procedure usp_MaterialQcSampleResult_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_MaterialQcInfo_HY_iud (Cloned from usp_MaterialQcInfo_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_MaterialQcInfo_HY_iud];
GO



-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-11-08
-- Browsable : true
-- Group : 품질관리 > 수입검사
-- Description:	수입검사 목록을 업데이트 한다.
-- Modified:   Mr.Tung  on  2022-12-27 
-- =============================================


CREATE PROCEDURE [dbo].[usp_MaterialQcInfo_HY_iud]
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

GO

PRINT 'Procedure usp_MaterialQcInfo_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DoMakeMaterialIQCDetailList_HY (Cloned from usp_DoMakeMaterialIQCDetailList)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoMakeMaterialIQCDetailList_HY')
    DROP PROCEDURE [dbo].[usp_DoMakeMaterialIQCDetailList_HY];
GO


-- =============================================
-- Author:	    shjoo
-- Create date: 2016-02-16
-- Browsable : true
-- Group : 품질관리
-- Description:	입하 시 수입검사상세 정보를 생성합니다. (샘플수량 Insert한후에 -> usp_DoCreateMaterialQcSampleResult 호출)

-- Modified:
--  2020.07.01 수입검사 샘플수량 자동반영 (박진호 대리)
-- VPC 특성 및 치수 샘플수량 및 샘플결과 자동생성 처리. 박진호 과장 요청, By Jackaroe #211105
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialIQCDetailList_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20) = null
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen BIGINT
	--DECLARE @MaxKeyField VARCHAR(20)
	DECLARE @MaxKey INT

	DECLARE @IQC_ITEM_OPTION VARCHAR(50)
	
	-- Declare Columns Variable
	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	DECLARE @MaterialQcDetailNo BIGINT
	DECLARE @MaterialCode VARCHAR(50) = (SELECT MaterialCode FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo)
	DECLARE @DecisionResult VARCHAR(1) 

	declare @companycode varchar(10)= (select companycode from STB_UserInfo where UserID = @ProcessUserID)
	declare @WorkCenterCode   varchar(20)= (select companycode from STB_UserInfo where UserID = @ProcessUserID)

	DECLARE @SampleQty BIGINT=0

	-- ProductGroupCode 추가
	Declare @ProductGroupCode VARCHAR(20)

	SET @IQC_ITEM_OPTION = dbo.fnGetProcessRule('IQC_ITEM_OPTION','BY_GROUP')
	--PRINT @IQC_ITEM_OPTION
	--SET @IQC_ITEM_OPTION = 'BY_GROUP'
	SELECT
			@DecisionResult = MII.DecisionResult
	FROM
			STB_MaterialQcInfo MII  with(nolock) 
	WHERE
			MII.MaterialQcNo = @MaterialQcNo

	--IF ISNULL(@DecisionResult,'') IN ('P','F')
	--BEGIN
	--		RAISERROR('이미 처리된 수입검사 정보입니다', 16, 1)
	--		RETURN
	--END

	

    BEGIN
        BEGIN TRY	
			
			DELETE FROM STB_MaterialQcSampleResult
			WHERE 
					MaterialQcNo = @MaterialQcNo

			DELETE FROM STB_MaterialQcDetail
			WHERE 
					MaterialQcNo = @MaterialQcNo


			DECLARE @QcInspectionItemCode VARCHAR(20)
			DECLARE @QcInspectionItemDesc VARCHAR(20)
			DECLARE @InspectionLevel       VARCHAR(20)
			DECLARE @InspectionType			VARCHAR(20)
			DECLARE @AQL					VARCHAR(20)
			DECLARE @InQty                         BIGINT
			 

			DECLARE @ArriveQty NUMERIC(20,5)
        
			DECLARE @DetailTable TABLE (
				QcInspectionItemCode VARCHAR(20)
			   ,ProductGroupCode VARCHAR(20)			  
			)
		
			IF @IQC_ITEM_OPTION = 'BY_MATERIAL'

					BEGIN
						--RAISERROR(@MaterialCode, 16, 1)
							INSERT INTO @DetailTable
							SELECT
									MII.QcInspectionItemCode
                                   ,MM.ProductGroupCode
								  
							FROM
									STB_MaterialQcInspectionItem_HY MII WITH (NOLOCK)
							LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
							  ON MM.MaterialCode = MII.MaterialCode
							WHERE
									MII.MaterialCode = @MaterialCode
					END 			
			ELSE 			
					BEGIN
							INSERT INTO @DetailTable
							SELECT
									III.QcInspectionItemCode
								   ,MM.ProductGroupCode
								   
							FROM
									STB_MaterialQcInspectionGroup_HY MIG WITH (NOLOCK)
									LEFT OUTER JOIN STB_QcInspectionItem_HY III WITH (NOLOCK) ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK) ON MIG.MaterialCode = MM.MaterialCode
							WHERE
									MIG.MaterialCode = @MaterialCode
			         END
						
					SELECT
							@ArriveQty = MII.QcQty
					FROM
							STB_MaterialQcInfo MII WITH (NOLOCK)
					WHERE	
							MII.MaterialQcNo = @MaterialQcNo

				--declare @test varchar(20)
				--select @test = count(*) from @DetailTable
			 --raiserror(@test,16,1)
			PRINT 'LAST 1'
				
           -- CURSOR
			DECLARE DetailCursor CURSOR FOR
				SELECT
						QcInspectionItemCode
					   ,ProductGroupCode					  
				FROM
						@DetailTable

			OPEN DetailCursor
			
			WHILE 1 = 1 

			BEGIN
				FETCH NEXT FROM DetailCursor INTO @QcInspectionItemCode, @ProductGroupCode
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END					
				

				SELECT
						@MaterialQcDetailNo = ISNULL(MAX(MaterialQcDetailNo),0) + 1
				FROM
						STB_MaterialQcDetail WITH (NOLOCK)
				WHERE
						MaterialQcNo = @MaterialQcNo	
						


				SELECT
						@QcInspectionItemDesc = QcInspectionItemDesc, 
						@InspectionLevel=InspectionLevel,
						@InspectionType=InspectionType,
						@AQL=AQL
				FROM
						STB_MaterialQcDetail WITH (NOLOCK)
				WHERE
						MaterialQcNo = @MaterialQcNo	
						and QcInspectionItemCode = @QcInspectionItemCode
						/*
						declare @fd varchar(100) = @MaterialCode+'---'+@QcInspectionItemCode
						raiserror(@fd,16,1)
						*/
					
						--	declare @fd varchar(100) = @MaterialCode+'---'+@QcInspectionItemCode
						--raiserror(@fd,16,1)
						SET @SampleQty= CASE 								
								WHEN @QcInspectionItemCode = 'IQC_GPD_18' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 10   --SD: add by Mr.Tung 21-March-2023 by OQC spec 
								WHEN @QcInspectionItemCode = 'IQC_GPD_18' THEN 10 
								
							
								WHEN @QcInspectionItemCode = 'IQC_GPD_20'   AND @MaterialCode in ('RDMD00-301') AND @companycode='VVT' then 6
								WHEN (@QcInspectionItemCode = 'OQC-CEEL13' or @QcInspectionItemCode = 'OQC-CEEL14'    or @QcInspectionItemCode = 'OQC_Cell4'   or @QcInspectionItemCode = 'OQC_MD9')   AND @MaterialCode in ('RDMD00-301') AND @companycode='VVT' then 3   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 

								WHEN @QcInspectionItemCode = 'IQC_GPD_19'  AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293','RDMD00-301') AND @companycode='VVT' then 20   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 
								WHEN @QcInspectionItemCode = 'IQC_GPD_19' THEN 10
							
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' 
																			AND (
																					@MaterialCode in ('ECVT30-076','ECVT30-117','ECVT30-098','ECVT30-197','ECVT30-294','ECVT30-116', 'ECVT27-358', 'ECVT30-357') or 
																						(select count(*) from stb_materialmaster with(nolock) where materialcode=@MaterialCode and replace(replace(MaterialName,'HY-CAP',''),' ','') in ('VEC3R0507QG(3582)','VEP3R0507QG(3582)','VEC3R0367QG(3562)','VEC3R0387QG(3562)','VEP3R0367QG(3562)'))>0
																				)
																			AND @companycode='VVT' then 10    --CAP: add by  Mr.Tung  08-September-2023 by OQC spec
																			
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 3    --CAP: add by Mr.Tung 21-March-2023 by OQC spec 							 
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode IN ('ECVT27-369', 'ECVT27-358') and @companycode='VVT' THEN 10		-- 2025-10-08 add ECVT27-358									--add by Mr.Tung 04-April-2022 by OQC request
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND (@MaterialCode <> 'ECVT27-369' AND @ProductGroupCode <> 'HC-VPC') THEN 3
									
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 20
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @ProductGroupCode = 'HC-VPC' THEN 10

								--WHEN @QcInspectionItemCode = 'IQC_GPD_21' AND @MaterialCode = 'ECVT30-262' THEN 125


								WHEN @QcInspectionItemCode = 'IQC_GPD_20' THEN 3
								WHEN @QcInspectionItemCode = 'IQC_G1_072' and @companycode='VVT' THEN 2																				--add by Mr.Tung 27-April-2022 by IQC request
								when @QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04','IQC_O1','IQC_O2','IQC_O3') then 10											--add by Mr.Tung 16-May-2023 by TQC spec 
								WHEN @QcInspectionItemCode IN ('PQC_V01_01','PQC_V01_02','PQC_V01_03','PQC_V01_04','PQC_V01_05') THEN 10
								WHEN @QcInspectionItemCode IN ('PQC_V01_07','PQC_V01_08') THEN 20

								WHEN @QcInspectionItemCode IN ('PQC_V01_09')   then
									case when @MaterialCode not in ('LIVT38-009') THEN 20 
									else 10
									end

								WHEN @QcInspectionItemCode IN ('PQC_V01_10') THEN 3  -- 외관 항목과 마찬가지로 합격여부로만 관리하므로 샘플입력 항목은 생성하지 않음.
								WHEN @InspectionLevel = 'S1'   THEN dbo.fnGetQcStandardSampleQty(@InspectionType, @ArriveQty, @AQL, @InspectionLevel)

								-- UPDATE 2026-05-06 Mr.Manh comment because wrong query 
								---
								WHEN @QcInspectionItemCode IN (SELECT QcInspectionItemCode 
																FROM STB_MaterialQcInspectionItem_HY  WITH (NOLOCK)
																WHERE InspectionLevel = 'S1' 
																AND MaterialCode = @MaterialCode		-- add condition 2026-05-06 by Mr.Manh
																GROUP BY QcInspectionItemCode)  THEN 5
								-- END UPDATE


								--THEN dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel)
								--#211105 --#211227 최은화 과장님 요청 45, 200, 3
								
								 --Mr.Tung add on 2023-11-17 for QC request
								
								 when @QcInspectionItemCode in ( select QcInspectionItemCode from STB_QcInspectionItem_HY   WITH(NOLOCK)  where ISNUMERIC(QcSpecDesc)=1) then ( select top 1 convert(int,QcSpecDesc) from STB_QcInspectionItem_HY   WITH(NOLOCK)  where QcInspectionItemCode=@QcInspectionItemCode)
								-- WHEN @QcInspectionItemCode = 'IQC_GPD_19' AND @MaterialCode = 'RDMD00-301'  THEN 20
								--WHEN @QcInspectionItemCode = 'OQC-CEEL13' AND @MaterialCode = 'RDMD00-301' THEN 3
								--WHEN @QcInspectionItemCode = 'OQC-CEEL13' AND @MaterialCode = 'RDMD00-301'  THEN 3
								
								--WHEN @QcInspectionItemCode = 'OQC_Cell4' AND @MaterialCode = 'RDMD00-301' THEN 3
								--WHEN @QcInspectionItemCode = 'OQC_MD9' AND @MaterialCode = 'RDMD00-301'  THEN 3
								ELSE 0 END 

------------------------------------------------------------- add 2024/12/20 start  -- thêm số lượng mẫu cần test
				--raiserror(@pProcessUserID,16,1)
				--if(@pProcessUserID='Hant-1998')
				--		begin
				--		select 	 @SampleQty=	MII.SampleQty		FROM
				--					STB_MaterialQcInspectionItem_HY MII	 WITH (NOLOCK)								
				--		WHERE
				--					MII.MaterialCode = @MaterialCode AND
				--					MII.QcInspectionItemCode = @QcInspectionItemCode	
				--		end
------------------------------------------------------------- add 2024/12/20 end
										

				IF @IQC_ITEM_OPTION = 'BY_MATERIAL'
					
				BEGIN			
					
						;
						WITH InspectionItem AS
						(
							SELECT
									@MaterialQcNo AS MaterialQcNo,
									@MaterialQcDetailNo AS MaterialQcDetailNo, --순번
									III.QcInspectionGroupCode,
									IIG.QcInspectionGroupName,
									IIG.QcInspectionGroupDesc,
									III.QcInspectionItemCode,
									III.QcInspectionItemName,
									III.QcInspectionItemDesc,
									NULL AS GroupInspectionPrior,
									NULL AS GroupReportPrior,
									III.ItemInspectionPrior,
									III.ItemReportPrior,
									III.QcSpecDesc,
									III.InspectionType,
									III.IsMaterialSpec,
									MII.InspectionLevel, -- 테이블이 다름
									MII.AQL,
									0 AS RequestSampleQty,
									0 AS MaxAcceptDefectQty,
									NULL AS SampleQty,
									NULL AS PassedSampleQty,
									NULL AS DefectSampleQty,
									NULL AS SkipSampleQty,
									MII.SpecValue,
									MII.USL,
									MII.LSL,
									MII.UCL,
									MII.LCL,
									MII.TextSpecValue,
									NULL AS DecisionResult,
									GETDATE() AS CreateDateTime,
									@ProcessUserID AS CreateUserID,
									NULL AS ChangeDateTime,
									NULL AS ChangeUserID
							FROM
									STB_MaterialQcInspectionItem_HY MII	 WITH (NOLOCK)								
									LEFT OUTER JOIN STB_QcInspectionItem_HY III	 WITH (NOLOCK) ON (III.QcInspectionItemCode = MII.QcInspectionItemCode)
									LEFT OUTER JOIN STB_QcInspectionGroup_HY IIG	 WITH (NOLOCK) ON (IIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
							WHERE
									MII.MaterialCode = @MaterialCode AND
									MII.QcInspectionItemCode = @QcInspectionItemCode		
						)

						INSERT INTO STB_MaterialQcDetail
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
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID
									)
						SELECT
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
								dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								dbo.fnGetQcStandardMaxDefectQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								

								@SampleQty,
								------CASE WHEN QcInspectionItemCode = 'IQC_GPD_18' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 10   --SD: add by Mr.Tung 21-March-2023 by OQC spec 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_18' THEN 10 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_19' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 20   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 
								------     WHEN QcInspectionItemCode = 'IQC_GPD_19' THEN 10 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 3    --CAP: add by Mr.Tung 21-March-2023 by OQC spec 							 
									 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND (@MaterialCode <> 'ECVT27-369' AND @ProductGroupCode <> 'HC-VPC') THEN 3
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' and @companycode='VVT' THEN 10 --add by Mr.Tung 04-April-2022 by OQC request
								------	 WHEN @QcInspectionItemCode = 'IQC_G1_072' and @companycode='VVT' THEN 2			--add by Mr.Tung 27-April-2022 by IQC request
								------	 when @QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04') then 10    --add by Mr.Tung 27-April-2022 by TQC spec 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 20
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @ProductGroupCode = 'HC-VPC' THEN 10
								------	 WHEN InspectionLevel = 'S1'   THEN dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel)
								------	 --#211105 --#211227 최은화 과장님 요청 45, 200, 3
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_01','PQC_V01_02','PQC_V01_03','PQC_V01_04','PQC_V01_05') THEN 10
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_07','PQC_V01_08') THEN 20
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_09') THEN 20
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_10') THEN 3
								------	 when QcInspectionItemDesc in (N'Chiều dài dây',N'Kích Thước M',N'Kích Thước N',N'Kích Thước R') then 10
								------								   ELSE 0 END AS SampleQty,      -- 2020.07.01 박진호대리 요청사항 (원본백업)

								0 AS PassedSampleQty,
								0 AS DefectSampleQty,
								0 AS SkipSampleQty,
								SpecValue,
								USL,
								LSL,
								UCL,
								LCL,
								TextSpecValue,
								DecisionResult,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								InspectionItem
				END 

			ELSE   --  @IQC_ITEM_OPTION <> 'BY_MATERIAL' (위 IF문의 반대조건)

			    BEGIN
						
						;
						WITH InspectionItem AS
						(
							SELECT
									@MaterialQcNo AS MaterialQcNo,
									@MaterialQcDetailNo AS MaterialQcDetailNo, --순번
									MIG.QcInspectionGroupCode,
									IIG.QcInspectionGroupName,
									IIG.QcInspectionGroupDesc,
									III.QcInspectionItemCode,
									III.QcInspectionItemName,
									III.QcInspectionItemDesc,
									MIG.GroupInspectionPrior,
									MIG.GroupReportPrior,
									III.ItemInspectionPrior,
									III.ItemReportPrior,
									III.QcSpecDesc,
									III.InspectionType,
									III.IsMaterialSpec,
									III.InspectionLevel,
									III.AQL,
									0 AS RequestSampleQty,
									0 AS MaxAcceptDefectQty,
									NULL AS SampleQty,
									NULL AS PassedSampleQty,
									NULL AS DefectSampleQty,
									NULL AS SkipSampleQty,
									III.SpecValue,
									III.USL,
									III.LSL,
									III.UCL,
									III.LCL,
									III.TextSpecValue,
									NULL AS DecisionResult,
									GETDATE() AS CreateDateTime,
									@ProcessUserID AS CreateUserID,
									NULL AS ChangeDateTime,
									NULL AS ChangeUserID
							FROM
									STB_MaterialQcInspectionGroup_HY MIG WITH (NOLOCK)
									LEFT OUTER JOIN STB_QcInspectionGroup_HY IIG WITH (NOLOCK) ON (MIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_QcInspectionItem_HY III WITH (NOLOCK) ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
							WHERE 1=1
									AND III.QcInspectionItemCode = @QcInspectionItemCode 
									AND	MIG.MaterialCode = @MaterialCode 
									AND	ISNULL(III.IsMaterialSpec, 0) = 0 
									AND III.InspectionLevel = 	@InspectionLevel                                      -- 2020.07.03
							UNION ALL


							SELECT
									@MaterialQcNo AS MaterialQcNo,
									@MaterialQcDetailNo AS MaterialQcDetailNo, --순번
									MIG.QcInspectionGroupCode,
									IIG.QcInspectionGroupName,
									IIG.QcInspectionGroupDesc,
									III.QcInspectionItemCode,
									III.QcInspectionItemName,
									III.QcInspectionItemDesc,
									MIG.GroupInspectionPrior,
									MIG.GroupReportPrior,
									III.ItemInspectionPrior,
									III.ItemReportPrior,
									III.QcSpecDesc,
									III.InspectionType,
									III.IsMaterialSpec,
									MII.InspectionLevel, -- 테이블이 다름
									MII.AQL,
									0 AS RequestSampleQty,
									0 AS MaxAcceptDefectQty,
									NULL AS SampleQty,
									NULL AS PassedSampleQty,
									NULL AS DefectSampleQty,
									NULL AS SkipSampleQty,
									MII.SpecValue,
									MII.USL,
									MII.LSL,
									MII.UCL,
									MII.LCL,
									MII.TextSpecValue,
									NULL AS DecisionResult,
									GETDATE() AS CreateDateTime,
									@ProcessUserID AS CreateUserID,
									NULL AS ChangeDateTime,
									NULL AS ChangeUserID
							FROM
									STB_MaterialQcInspectionGroup_HY MIG WITH (NOLOCK)
									LEFT OUTER JOIN STB_QcInspectionGroup_HY IIG	 WITH (NOLOCK)		ON (MIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_QcInspectionItem_HY III WITH (NOLOCK)		ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_MaterialQcInspectionItem_HY MII WITH (NOLOCK)		ON (MIG.MaterialCode = MII.MaterialCode AND											III.QcInspectionItemCode = MII.QcInspectionItemCode)
							WHERE 1=1
									AND III.QcInspectionItemCode = @QcInspectionItemCode
									AND MIG.MaterialCode = @MaterialCode 
									AND	III.IsMaterialSpec = 1 
									--AND III.InspectionLevel = 	@InspectionLevel                                      -- 2020.07.03						
						)

						INSERT INTO STB_MaterialQcDetail
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
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID
									)
						SELECT
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
								dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								dbo.fnGetQcStandardMaxDefectQty(InspectionType, @ArriveQty, AQL, InspectionLevel),								


								@SampleQty,
								--------CASE WHEN QcInspectionItemCode = 'IQC_GPD_18' THEN 10
								--------     WHEN QcInspectionItemCode = 'IQC_GPD_18' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 10   --SD: add by Mr.Tung 21-March-2023 by OQC spec 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_19' THEN 10
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_19' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 20   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 3    --CAP: add by Mr.Tung 21-March-2023 by OQC spec 							 
									 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND (@MaterialCode <> 'ECVT27-369' AND @ProductGroupCode <> 'HC-VPC') THEN 3
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' and @companycode='VVT' THEN 10 --add by Mr.Tung 01-April-2022 by OQC request
								--------	 WHEN @QcInspectionItemCode = 'IQC_G1_072' and @companycode='VVT' THEN 2			--add by Mr.Tung 27-April-2022 by IQC request
								--------	 when @QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04') then 10    --add by Mr.Tung 27-April-2022 by TQC spec 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 20
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @ProductGroupCode = 'HC-VPC' THEN 10
								--------	 --WHEN InspectionLevel = 'S1'   
								--------	 WHEN QcInspectionItemCode IN (SELECT QcInspectionItemCode 
								--------	                                 FROM STB_MaterialQcInspectionItem_HY  WITH (NOLOCK)
								--------									WHERE InspectionLevel = 'S1' 
								--------									GROUP BY QcInspectionItemCode)  THEN 5
								--------	 --THEN dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel)
								--------	 --#211105 --#211227 최은화 과장님 요청 45, 200, 3
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_01','PQC_V01_02','PQC_V01_03','PQC_V01_04','PQC_V01_05') THEN 10
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_07','PQC_V01_08') THEN 20
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_09') THEN 20
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_10') THEN 3
								--------	 when QcInspectionItemDesc in (N'Chiều dài dây',N'Kích Thước M',N'Kích Thước N',N'Kích Thước R') then 10
								--------	 ELSE 0 END AS SampleQty,      -- 2020.07.01 박진호대리 요청사항 (원본백업)
									 
								0 AS PassedSampleQty,
								0 AS DefectSampleQty,
								0 AS SkipSampleQty,
								SpecValue,
								USL,
								LSL,
								UCL,
								LCL,
								TextSpecValue,
								DecisionResult,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								InspectionItem

				END
				
				-- 여기까지 Detail
				-- 특성 검사항목에 대해 샘플리스트를 기본으로 생성해 줌. 품질부문요청 By Jackaroe 2019.10.29
			           

					IF @SampleQty <> 0 				
					BEGIN
					------------------------ add 2024/12/20 start  -- 
				
						declare @USL NUMERIC (20,5) 
						declare @LSL NUMERIC (20,5)
						select @USL=USL, @LSL=LSL from STB_QcInspectionItem_HY  where  QcInspectionItemCode=@QcInspectionItemCode
						if(@WorkCenterCode ='VVT_F3' and @USL is null and @LSL is null )
						begin
								set @SampleQty =0
						end
								
				
						

					----------------------- add 2024/12/20 end
					

					PRINT 'LAST LAST IF'
					Exec usp_DoCreateMaterialQcSampleResult @MaterialQcNo, @MaterialQcDetailNo, @SampleQty, 0       -- 시료별 수입검사결과에서 샘플수량만큼 셀이 자동생성되는 부분
                            --[프로시저 실행 Test]  usp_DoCreateMaterialQcSampleResult '20070300016','6',5,0                     -- [참고] 화면 생성버튼에서 불러주는 프로시저는 다름 (Exec usp_DoMakeMaterialQcSampleResult_HY )					
				END

			END
    END TRY

	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
	
	CLOSE DetailCursor;
	DEALLOCATE DetailCursor;
	
	END

	PRINT 'LAST LAST END'
END

GO

PRINT 'Procedure usp_DoMakeMaterialIQCDetailList_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_IQCDefectReport_HY_iud (Cloned from usp_IQCDefectReport_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_IQCDefectReport_HY_iud')
    DROP PROCEDURE [dbo].[usp_IQCDefectReport_HY_iud];
GO


-- =================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-07-13
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사
-- Description:	수입검사용 부적합등록!!!! 
-- Modified:
--                2020.07.15 DefectImage2 추가 
--                2020.12.16 QcOpinionContent 품질부서의견 / ActionContent Lot조치사항 추가
-- ==================================================================
CREATE PROCEDURE [dbo].[usp_IQCDefectReport_HY_iud]
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
  DECLARE @OldDefectReportNo VARCHAR(20)
  DECLARE @DefectReportNo VARCHAR(20)
  DECLARE @DefectDivisionCode VARCHAR(3)
  DECLARE @PublishDeptCode VARCHAR(20)
  DECLARE @PublishEmpID VARCHAR(20)
  DECLARE @OccurProcessCode VARCHAR(3)
  DECLARE @LotNo VARCHAR(20)
  DECLARE @ProdProcessResultCode VARCHAR(2)
  DECLARE @CorrectiveActionCode VARCHAR(2)
  DECLARE @CorrectiveActionName VARCHAR(50)
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectImage2 VARBINARY(MAX)
  DECLARE @DefectLotSize INT
  DECLARE @IsActionCode BIT
  DECLARE @Nonconformity NVARCHAR(4000)
  DECLARE @ImmediateAction NVARCHAR(4000)
  DECLARE @CauseInvestigation NVARCHAR(4000)
  DECLARE @PreventionRecurrence NVARCHAR(4000)
  DECLARE @DetectionCounterMeasures NVARCHAR(4000)
  DECLARE @CheckingCorrectiveAction NVARCHAR(4000)

  DECLARE @QcOpinionContent NVARCHAR(4000)               -- 2020.12.16 추가
  DECLARE @ActionContent NVARCHAR(4000)                    -- 2020.12.16 추가
  
  DECLARE @Validation NVARCHAR(4000)
  DECLARE @JobDate DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ProdProcessResultFile BIGINT
  DECLARE @ApprovalStepID INT

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule
			@pTableName = 'STB_IQcDefectReport',               -- 수입검사용 부적합테이블
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_IQcDefectReport AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							DefectReportNo,
							DefectDivisionCode,
							PublishDeptCode,
							PublishEmpID,
							OccurProcessCode,
							LotNo,
							ProdProcessResultCode,
							CorrectiveActionCode,
							CorrectiveActionName,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							DefectLotSize,
							IsActionCode,
							Nonconformity,
							ImmediateAction,
							CauseInvestigation,
							PreventionRecurrence,
							DetectionCounterMeasures,
							CheckingCorrectiveAction,
							Validation,
							JobDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ProdProcessResultFile,
							ApprovalStepID,
							QcOpinionContent,
							ActionContent
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectDivisionCode VARCHAR(3),
										PublishDeptCode VARCHAR(20),
										PublishEmpID VARCHAR(20),
										OccurProcessCode VARCHAR(3),
										LotNo VARCHAR(20),
										ProdProcessResultCode VARCHAR(2),
										CorrectiveActionCode VARCHAR(2),
										CorrectiveActionName VARCHAR(50),
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										DefectLotSize INT,
										IsActionCode BIT,
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CauseInvestigation NVARCHAR(4000),
										PreventionRecurrence NVARCHAR(4000),
										DetectionCounterMeasures NVARCHAR(4000),
										CheckingCorrectiveAction NVARCHAR(4000),
										Validation NVARCHAR(4000),
										JobDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										ApprovalStepID INT,
										QcOpinionContent NVARCHAR(4000),
										ActionContent NVARCHAR(4000)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.DefectReportNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectReportNo = ISNULL(SourceTable.DefectReportNo,TargetTable.DefectReportNo),
					DefectDivisionCode = ISNULL(SourceTable.DefectDivisionCode,TargetTable.DefectDivisionCode),
					PublishDeptCode = ISNULL(SourceTable.PublishDeptCode,TargetTable.PublishDeptCode),
					PublishEmpID = ISNULL(SourceTable.PublishEmpID,TargetTable.PublishEmpID),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					ProdProcessResultCode = ISNULL(SourceTable.ProdProcessResultCode,TargetTable.ProdProcessResultCode),
					CorrectiveActionCode = ISNULL(SourceTable.CorrectiveActionCode,TargetTable.CorrectiveActionCode),
					CorrectiveActionName = ISNULL(SourceTable.CorrectiveActionName,TargetTable.CorrectiveActionName),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2),
					DefectLotSize = ISNULL(SourceTable.DefectLotSize,TargetTable.DefectLotSize),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CauseInvestigation = ISNULL(SourceTable.CauseInvestigation,TargetTable.CauseInvestigation),
					PreventionRecurrence = ISNULL(SourceTable.PreventionRecurrence,TargetTable.PreventionRecurrence),
					DetectionCounterMeasures = ISNULL(SourceTable.DetectionCounterMeasures,TargetTable.DetectionCounterMeasures),
					CheckingCorrectiveAction = ISNULL(SourceTable.CheckingCorrectiveAction,TargetTable.CheckingCorrectiveAction),
					Validation = ISNULL(SourceTable.Validation,TargetTable.Validation),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ProdProcessResultFile = ISNULL(SourceTable.ProdProcessResultFile,TargetTable.ProdProcessResultFile),
					ApprovalStepID = ISNULL(SourceTable.ApprovalStepID,TargetTable.ApprovalStepID),
					QcOpinionContent = ISNULL(SourceTable.QcOpinionContent,TargetTable.QcOpinionContent),
					ActionContent = ISNULL(SourceTable.ActionContent,TargetTable.ActionContent)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectDivisionCode,
						PublishDeptCode,
						PublishEmpID,
						OccurProcessCode,
						LotNo,
						ProdProcessResultCode,
						CorrectiveActionCode,
						CorrectiveActionName,
						DefectImage,
						DefectImage2,
						DefectLotSize,
						IsActionCode,
						Nonconformity,
						ImmediateAction,
						CauseInvestigation,
						PreventionRecurrence,
						DetectionCounterMeasures,
						CheckingCorrectiveAction,
						Validation,
						JobDate,
						CreateDateTime,
						CreateUserID,
						ProdProcessResultFile,
						ApprovalStepID,
						QcOpinionContent,
						ActionContent
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectDivisionCode,
							SourceTable.PublishDeptCode,
							SourceTable.PublishEmpID,
							SourceTable.OccurProcessCode,
							SourceTable.LotNo,
							SourceTable.ProdProcessResultCode,
							SourceTable.CorrectiveActionCode,
							SourceTable.CorrectiveActionName,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.DefectLotSize,
							SourceTable.IsActionCode,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CauseInvestigation,
							SourceTable.PreventionRecurrence,
							SourceTable.DetectionCounterMeasures,
							SourceTable.CheckingCorrectiveAction,
							SourceTable.Validation,
							SourceTable.JobDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ProdProcessResultFile,
							SourceTable.ApprovalStepID,
							SourceTable.QcOpinionContent,
							SourceTable.ActionContent
					);


			-- Process Update Table
            MERGE STB_IQcDefectReport AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							DefectReportNo,
							DefectDivisionCode,
							PublishDeptCode,
							PublishEmpID,
							OccurProcessCode,
							LotNo,
							ProdProcessResultCode,
							CorrectiveActionCode,
							CorrectiveActionName,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							DefectLotSize,
							IsActionCode,
							Nonconformity,
							ImmediateAction,
							CauseInvestigation,
							PreventionRecurrence,
							DetectionCounterMeasures,
							CheckingCorrectiveAction,
							Validation,
							JobDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ProdProcessResultFile,
							ApprovalStepID,
							QcOpinionContent,
							ActionContent
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20),
										DefectDivisionCode VARCHAR(3),
										PublishDeptCode VARCHAR(20),
										PublishEmpID VARCHAR(20),
										OccurProcessCode VARCHAR(3),
										LotNo VARCHAR(20),
										ProdProcessResultCode VARCHAR(2),
										CorrectiveActionCode VARCHAR(2),
										CorrectiveActionName VARCHAR(50),
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										DefectLotSize INT,
										IsActionCode BIT,
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CauseInvestigation NVARCHAR(4000),
										PreventionRecurrence NVARCHAR(4000),
										DetectionCounterMeasures NVARCHAR(4000),
										CheckingCorrectiveAction NVARCHAR(4000),
										Validation NVARCHAR(4000),
										JobDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										ApprovalStepID INT,
										QcOpinionContent NVARCHAR(4000),
										ActionContent NVARCHAR(4000)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.OldDefectReportNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectReportNo = ISNULL(SourceTable.DefectReportNo,TargetTable.DefectReportNo),
					DefectDivisionCode = ISNULL(SourceTable.DefectDivisionCode,TargetTable.DefectDivisionCode),
					PublishDeptCode = ISNULL(SourceTable.PublishDeptCode,TargetTable.PublishDeptCode),
					PublishEmpID = ISNULL(SourceTable.PublishEmpID,TargetTable.PublishEmpID),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					ProdProcessResultCode = ISNULL(SourceTable.ProdProcessResultCode,TargetTable.ProdProcessResultCode),
					CorrectiveActionCode = ISNULL(SourceTable.CorrectiveActionCode,TargetTable.CorrectiveActionCode),
					CorrectiveActionName = ISNULL(SourceTable.CorrectiveActionName,TargetTable.CorrectiveActionName),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2),
					DefectLotSize = ISNULL(SourceTable.DefectLotSize,TargetTable.DefectLotSize),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CauseInvestigation = ISNULL(SourceTable.CauseInvestigation,TargetTable.CauseInvestigation),
					PreventionRecurrence = ISNULL(SourceTable.PreventionRecurrence,TargetTable.PreventionRecurrence),
					DetectionCounterMeasures = ISNULL(SourceTable.DetectionCounterMeasures,TargetTable.DetectionCounterMeasures),
					CheckingCorrectiveAction = ISNULL(SourceTable.CheckingCorrectiveAction,TargetTable.CheckingCorrectiveAction),
					Validation = ISNULL(SourceTable.Validation,TargetTable.Validation),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ProdProcessResultFile = ISNULL(SourceTable.ProdProcessResultFile,TargetTable.ProdProcessResultFile),
					ApprovalStepID = ISNULL(SourceTable.ApprovalStepID,TargetTable.ApprovalStepID),
					QcOpinionContent = ISNULL(SourceTable.QcOpinionContent,TargetTable.QcOpinionContent),
					ActionContent = ISNULL(SourceTable.ActionContent,TargetTable.ActionContent)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectReportNo,
						DefectDivisionCode,
						PublishDeptCode,
						PublishEmpID,
						OccurProcessCode,
						LotNo,
						ProdProcessResultCode,
						CorrectiveActionCode,
						CorrectiveActionName,
						DefectImage,
						DefectImage2,
						DefectLotSize,
						IsActionCode,
						Nonconformity,
						ImmediateAction,
						CauseInvestigation,
						PreventionRecurrence,
						DetectionCounterMeasures,
						CheckingCorrectiveAction,
						Validation,
						JobDate,
						CreateDateTime,
						CreateUserID,
						ProdProcessResultFile,
						ApprovalStepID,
						QcOpinionContent,
						ActionContent
					)
				VALUES
					(
							SourceTable.DefectReportNo,
							SourceTable.DefectDivisionCode,
							SourceTable.PublishDeptCode,
							SourceTable.PublishEmpID,
							SourceTable.OccurProcessCode,
							SourceTable.LotNo,
							SourceTable.ProdProcessResultCode,
							SourceTable.CorrectiveActionCode,
							SourceTable.CorrectiveActionName,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.DefectLotSize,
							SourceTable.IsActionCode,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CauseInvestigation,
							SourceTable.PreventionRecurrence,
							SourceTable.DetectionCounterMeasures,
							SourceTable.CheckingCorrectiveAction,
							SourceTable.Validation,
							SourceTable.JobDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ProdProcessResultFile,
							SourceTable.ApprovalStepID,
							SourceTable.QcOpinionContent,
							SourceTable.ActionContent
					);


			-- Process Delete Table
            MERGE STB_IQcDefectReport AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectReportNo IS NULL THEN DefectReportNo
							    ELSE OldDefectReportNo
							END AS OldDefectReportNo,
							DefectReportNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectReportNo VARCHAR(20),
										DefectReportNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectReportNo = SourceTable.DefectReportNo
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
									OldDefectReportNo,
									DefectReportNo,
									DefectDivisionCode,
									PublishDeptCode,
									PublishEmpID,
									OccurProcessCode,
									LotNo,
									ProdProcessResultCode,
									CorrectiveActionCode,
									CorrectiveActionName,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									DefectLotSize,
									IsActionCode,
									Nonconformity,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									JobDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID,
									QcOpinionContent,
									ActionContent
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 LotNo VARCHAR(20),
											 ProdProcessResultCode VARCHAR(2),
											 CorrectiveActionCode VARCHAR(2),
											 CorrectiveActionName VARCHAR(50),
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 DefectLotSize INT,
											 IsActionCode BIT,
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 JobDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT,
											 QcOpinionContent NVARCHAR(4000),
											 ActionContent NVARCHAR(4000)
											)
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectReportNo IS NULL THEN DefectReportNo
										ELSE OldDefectReportNo
									END AS OldDefectReportNo,
									DefectReportNo,
									DefectDivisionCode,
									PublishDeptCode,
									PublishEmpID,
									OccurProcessCode,
									LotNo,
									ProdProcessResultCode,
									CorrectiveActionCode,
									CorrectiveActionName,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage,
									DefectLotSize,
									IsActionCode,
									Nonconformity,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									JobDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID,
									QcOpinionContent,
									ActionContent
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 LotNo VARCHAR(20),
											 ProdProcessResultCode VARCHAR(2),
											 CorrectiveActionCode VARCHAR(2),
											 CorrectiveActionName VARCHAR(50),
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 DefectLotSize INT,
											 IsActionCode BIT,
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 JobDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT,
											 QcOpinionContent NVARCHAR(4000),
											 ActionContent NVARCHAR(4000)
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectReportNo IS NULL THEN DefectReportNo
										ELSE OldDefectReportNo
									END AS OldDefectReportNo,
									DefectReportNo,
									DefectDivisionCode,
									PublishDeptCode,
									PublishEmpID,
									OccurProcessCode,
									LotNo,
									ProdProcessResultCode,
									CorrectiveActionCode,
									CorrectiveActionName,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									DefectLotSize,
									IsActionCode,
									Nonconformity,
									ImmediateAction,
									CauseInvestigation,
									PreventionRecurrence,
									DetectionCounterMeasures,
									CheckingCorrectiveAction,
									Validation,
									JobDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ProdProcessResultFile,
									ApprovalStepID,
									QcOpinionContent,
									ActionContent
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectReportNo VARCHAR(20),
											 DefectReportNo VARCHAR(20),
											 DefectDivisionCode VARCHAR(3),
											 PublishDeptCode VARCHAR(20),
											 PublishEmpID VARCHAR(20),
											 OccurProcessCode VARCHAR(3),
											 LotNo VARCHAR(20),
											 ProdProcessResultCode VARCHAR(2),
											 CorrectiveActionCode VARCHAR(2),
											 CorrectiveActionName VARCHAR(50),
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 DefectLotSize INT,
											 IsActionCode BIT,
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CauseInvestigation NVARCHAR(4000),
											 PreventionRecurrence NVARCHAR(4000),
											 DetectionCounterMeasures NVARCHAR(4000),
											 CheckingCorrectiveAction NVARCHAR(4000),
											 Validation NVARCHAR(4000),
											 JobDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ProdProcessResultFile BIGINT,
											 ApprovalStepID INT,
											 QcOpinionContent  NVARCHAR(4000),
											 ActionContent NVARCHAR(4000)
											) 
            OPEN SourceData

            WHILE 1 = 1 
			
			BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectReportNo,
								 @DefectReportNo,
								 @DefectDivisionCode,
								 @PublishDeptCode,
								 @PublishEmpID,
								 @OccurProcessCode,
								 @LotNo,
								 @ProdProcessResultCode,
								 @CorrectiveActionCode,
								 @CorrectiveActionName,
								 @DefectImage,
								 @DefectImage2,
								 @DefectLotSize,
								 @IsActionCode,
								 @Nonconformity,
								 @ImmediateAction,
								 @CauseInvestigation,
								 @PreventionRecurrence,
								 @DetectionCounterMeasures,
								 @CheckingCorrectiveAction,
								 @Validation,
								 @JobDate,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ProdProcessResultFile,
								 @ApprovalStepID,
								 @QcOpinionContent,
								 @ActionContent


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectReportNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_IQcDefectReport',@DefectReportNo OUTPUT
                    END

                    INSERT INTO STB_IQcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						    OccurProcessCode,
						    LotNo,
						    ProdProcessResultCode,
						    CorrectiveActionCode,
						    CorrectiveActionName,
						    DefectImage,
							DefectImage2,
						    DefectLotSize,
						    IsActionCode,
						    Nonconformity,
						    ImmediateAction,
						    CauseInvestigation,
						    PreventionRecurrence,
						    DetectionCounterMeasures,
						    CheckingCorrectiveAction,
						    Validation,
						    JobDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
						    ApprovalStepID,
							QcOpinionContent,
							ActionContent
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @OccurProcessCode,
						    @LotNo,
						    @ProdProcessResultCode,
						    @CorrectiveActionCode,
						    @CorrectiveActionName,
						    @DefectImage,
							@DefectImage2,
						    @DefectLotSize,
						    @IsActionCode,
						    @Nonconformity,
						    @ImmediateAction,
						    @CauseInvestigation,
						    @PreventionRecurrence,
						    @DetectionCounterMeasures,
						    @CheckingCorrectiveAction,
						    @Validation,
						    @JobDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
						    @ApprovalStepID,
							@QcOpinionContent,
							@ActionContent
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN


 ----------------- 이부분부터 START
						
					IF EXISTS (SELECT 1 FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo)      -- 보고서번호가 존재하면 UPDATE
					
					BEGIN

						UPDATE STB_IQcDefectReport            -- 테이블명 중요 (STB_IQcDefectReport)
						      SET
									DefectReportNo =   ISNULL(@DefectReportNo,DefectReportNo),
									DefectDivisionCode =   ISNULL(@DefectDivisionCode,DefectDivisionCode),
									PublishDeptCode =   ISNULL(@PublishDeptCode,PublishDeptCode),
									PublishEmpID =   ISNULL(@PublishEmpID,PublishEmpID),
									OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
									LotNo =   ISNULL(@LotNo,LotNo),
									ProdProcessResultCode =   ISNULL(@ProdProcessResultCode,ProdProcessResultCode),
									CorrectiveActionCode =   ISNULL(@CorrectiveActionCode,CorrectiveActionCode),
									CorrectiveActionName =   ISNULL(@CorrectiveActionName,CorrectiveActionName),
									DefectImage =   ISNULL(@DefectImage,DefectImage),
									DefectImage2 = ISNULL(@DefectImage2,DefectImage2),
									DefectLotSize =   ISNULL(@DefectLotSize,DefectLotSize),
									IsActionCode =   ISNULL(@IsActionCode,IsActionCode),
									Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
									ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
									CauseInvestigation =   ISNULL(@CauseInvestigation,CauseInvestigation),
									PreventionRecurrence =   ISNULL(@PreventionRecurrence,PreventionRecurrence),
									DetectionCounterMeasures =   ISNULL(@DetectionCounterMeasures,DetectionCounterMeasures),
									CheckingCorrectiveAction =   ISNULL(@CheckingCorrectiveAction,CheckingCorrectiveAction),
									Validation =   ISNULL(@Validation,Validation),
									JobDate =   ISNULL(@JobDate,JobDate),
									CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
									CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID,
									ProdProcessResultFile =   ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
									ApprovalStepID =   ISNULL(@ApprovalStepID,ApprovalStepID),
									QcOpinionContent = ISNULL(@QcOpinionContent,QcOpinionContent),
									ActionContent = ISNULL(@ActionContent,ActionContent)
						WHERE
						         DefectReportNo = @OldDefectReportNo
						
					END ELSE BEGIN -- 그렇지 않으면 Insert
						--신규의 경우 @DefectReportNo = '자동채번'이므로 일치하는 번호가 없음.
						--Dummy쿼리의 자동채번 로직을 삭제하고 이 곳에서 신규로 채번함.
						--2020.07.07 By Jackaroe
					
						
							IF @PublishDeptCode = '4000'    -- @DefectReportNo 채번 (본사)
								 BEGIN
									SELECT @DefectReportNo = 'VNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
									  FROM STB_IQcDefectReport
									 WHERE DefectReportNo LIKE 'VNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'									
								 END
						 											
							ELSE      -- 법인의 경우   --IF @PublishDeptCode = '9000' 							
								   BEGIN
										SELECT @DefectReportNo = 'VVNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '-' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, ISNULL(RIGHT(MAX(DefectReportNo), 2), 0)) + 1), 2)
										  FROM STB_IQcDefectReport
										 WHERE DefectReportNo LIKE 'VVNI' + CONVERT(VARCHAR(6), GETDATE(), 12) + '%'
									 END
                      

                        INSERT INTO STB_IQcDefectReport
						(
						    DefectReportNo,
						    DefectDivisionCode,
						    PublishDeptCode,
						    PublishEmpID,
						    OccurProcessCode,
						    LotNo,
						    ProdProcessResultCode,
						    CorrectiveActionCode,
						    CorrectiveActionName,
						    DefectImage,
							DefectImage2,
						    DefectLotSize,
						    IsActionCode,
						    Nonconformity,
						    ImmediateAction,
						    CauseInvestigation,
						    PreventionRecurrence,
						    DetectionCounterMeasures,
						    CheckingCorrectiveAction,
						    Validation,
						    JobDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ProdProcessResultFile,
						    ApprovalStepID,
							QcOpinionContent,
							ActionContent
						)
						VALUES
						(
						    @DefectReportNo,
						    @DefectDivisionCode,
						    @PublishDeptCode,
						    @PublishEmpID,
						    @OccurProcessCode,
						    @LotNo,
						    @ProdProcessResultCode,
						    @CorrectiveActionCode,
						    @CorrectiveActionName,
						    @DefectImage,
							@DefectImage2,
						    @DefectLotSize,
						    @IsActionCode,
						    @Nonconformity,
						    @ImmediateAction,
						    @CauseInvestigation,
						    @PreventionRecurrence,
						    @DetectionCounterMeasures,
						    @CheckingCorrectiveAction,
						    @Validation,
						    @JobDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ProdProcessResultFile,
						    @ApprovalStepID,
							@QcOpinionContent,
							@ActionContent
						)


		 -- 2.  STB_NCR_Report을 INSERT하다
		  INSERT INTO STB_NCR_Report 
							( NCRNO, JOBDATE, CompanyCode, OccurProcessCode, MaterialName, CustomName, StandardName, LotNo, Qty, InspectionQty, BadQty, PPM, InQty, BadLotQty
							, DefectiveRate, CreateUserID, Nonconformity, ImmediateAction, CustomImmediateAction, IsActionCode, EffectivenessCheck, DefectImage, DefectImage2 )
		
		-- 2020.12.12 수정
				   SELECT Top 1 @DefectReportNo                                                        --Top1
							, CONVERT(VARCHAR(10), SIQ.CreateDateTime, 121)   As JobDate			   
							, Case When @PublishDeptCode = '4000' Then '한국본사'
							         When @PublishDeptCode = '9000' Then '베트남' Else '' End As CompanyCode
							,  BC1.Description   As OccurProcessCode                  
							,  PG.ProductGroupCode  As MaterialName			                      -- 자재그룹명
							,  C.CustomerName         As  CustomName
							,  MM.MaterialName        As StandardName                      --품목명
							, SIQ.lotno As LotNo
							, MQI.QcQty As Qty                      --입고수
							, 0              As InspectionQty
							, MQI.DefectSampleQty As BadQty
							, Case when  MQI.ActualSampleQty =0 then 0 when MQI.DefectSampleQty = 0  then 0 else CONVERT(BIGINT, (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty) * 1000000)) end as PPM 
							, MQI.QcQty As InQty
							, MQI.DefectSampleQty As BadLotQty
							--, Isnull((MQI.DefectSampleQty / MQI.QcQty * 100), 0.000) As DefectiveRate			
							, Case when MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0 then 0 else CONVERT(NUMERIC(20,5), (CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))     End as DefectiveRate   -- Lot불량율(%)    
							, MQI.CreateUserID         As CreateUserID
							,  SIQ.Nonconformity
							,  SIQ.ImmediateAction
							, '' as CustomImmediateAction
							, 0 As IsActionCode
							, '' as EffectivenessCheck
							,  SIQ.DefectImage
							,  SIQ.DefectImage2		
					FROM
							STB_MaterialQcInfo MQI WITH(NOLOCK)
							LEFT OUTER JOIN (
															SELECT DISTINCT MDD.MaterialDocNo as MaterialDocNo,
																				MDD.MaterialIqcNo as MaterialIqcNo ,
																				Count(MDLI.LotNo)	as LotNoQty            -- 2020-09-06 추가 	
															FROM
																					 STB_MaterialDocDetail MDD WITH(NOLOCK)
																	INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
																	INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
																	INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
															WHERE 1=1														
															Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            
													) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

							LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				ON MDI.MaterialDocNo = MDD.MaterialDocNo
							LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
							LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MQI.MaterialCode = MM.MaterialCode
							LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode  
							LEFT OUTER JOIN [SmartFramework].[dbo].[STB_UserInfo] PW WITH (NOLOCK)				ON PW.UserID = CASE WHEN ISNULL(MQI.DecisionUserID,'') = '' THEN @pProcessUserID ELSE MQI.DecisionUserID END
							LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MM.MaterialCode
							LEFT OUTER JOIN STB_IQcDefectReport SIQ WITH(NOLOCK)	ON SIQ.LotNo = MQI.IQCSampleLotList            
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	ON SIQ.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	ON SIQ.PublishDeptCode = BC2.ItemCode	       AND BC2.CodeGroup = 'PublishDeptCode'	         -- 부적합발행부서
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	ON SIQ.CorrectiveActionCode = BC3.ItemCode   AND BC3.CodeGroup = 'CorrectiveActionCode'
							LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	ON SIQ.ProdProcessResultCode = BC5.ItemCode AND BC5.CodeGroup = 'ProdProcessResultCode'  -- 생산부문처리결과코드
					WHERE	1=1	  
						AND DefectReportNo = @DefectReportNo

		 	 --최초 입력 후 겜바워크 그룹 메시지 발생
						 --본사 발행 부적합 보고서만 전파 2020.07.16 박진호 대리요청
						IF @PublishDeptCode = '4000' BEGIN
							Exec usp_DoSendLineMessageForDefectReport2 '', '', @DefectReportNo               -- LINE 메세지 (수입검사): usp_DoSendLineMessageForDefectReport2 뒤에 2가 붙음
						END

									 BEGIN TRY  						               									 
											 Exec usp_DoSendEmailForDefectReportIQC_HY  @pProcessUserID, @pProcessLanguage, @DefectReportNo           -- 수입검사용 이메일발송 프로시저임 (kilee)										
											 --Exec usp_DoSendEmailForDefectReportIQC_HY '','','VNI201022-01'
									END TRY  

									BEGIN CATCH  			
											Exec usp_DoSendGembaTroubleMessageTest @pProcessUserID, @pProcessLanguage, '부적합보고서(수입검사)  E-Mail 발송을 실패하였습니다. 관련 프로세스를 점검바랍니다 ' 
									END CATCH  

					END


--- DELETE 부분            
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_IQcDefectReport
						WHERE
						    DefectReportNo = @OldDefectReportNo
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
GO

PRINT 'Procedure usp_IQCDefectReport_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_NCR_Report_HY_iud (Cloned from usp_NCR_Report_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_NCR_Report_HY_iud')
    DROP PROCEDURE [dbo].[usp_NCR_Report_HY_iud];
GO


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-09-07
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사> NCR등록
-- Description:	
-- Modified:  2020.10.05 대책서 이미지파일 아닌 PDF등 여러파일로 저장할 수있도록 수정 (박진호요청)
-- ========================================================================================

CREATE PROCEDURE [dbo].[usp_NCR_Report_HY_iud]
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
  DECLARE @OldNCRNo VARCHAR(20)
  DECLARE @NCRNo VARCHAR(20)
  DECLARE @JobDate DATETIME
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @OccurProcessCode VARCHAR(20)
  DECLARE @MaterialName VARCHAR(80)
  DECLARE @CustomName VARCHAR(60)
  DECLARE @standardName VARCHAR(60)
  DECLARE @LotNo VARCHAR(80)
  DECLARE @Qty INT
  DECLARE @InspectionQty INT
  DECLARE @BadQty INT
  DECLARE @PPM NUMERIC(30,5)
  DECLARE @InQty INT
  DECLARE @BadLotQty INT
  DECLARE @DefectiveRate NUMERIC(30,5)
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @Nonconformity NVARCHAR(4000)
  DECLARE @ImmediateAction NVARCHAR(4000)
  DECLARE @CustomImmediateAction NVARCHAR(4000)
  
  DECLARE @IsActionCode BIT
  DECLARE @EffectivenessCheck BIT
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectImage2 VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME

  -- 2020.10.05 추가 및 수정
    DECLARE @CustomCountermeasureImage BIGINT  	
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)


	DECLARE @iDoc INT
	DECLARE @IncongruityCheck BIT  --2020.11.12 추가
	

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
    --EXEC usp_GetSerialRule 
			@pTableName = 'STB_NCR_Report',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_NCR_Report AS TargetTable
			USING
				(
					SELECT
							CASE WHEN OldNCRNo IS NULL THEN NCRNo ELSE OldNCRNo	END AS OldNCRNo,
							NCRNo,
							JobDate,
							CompanyCode,
							OccurProcessCode,
							MaterialName,
							CustomName,
							standardName,
							LotNo,
							Qty,
							InspectionQty,
							BadQty,
							PPM,
							InQty,
							BadLotQty,
							DefectiveRate,
							@pProcessUserID AS CreateUserID,
							Nonconformity,
							ImmediateAction,
							CustomImmediateAction,
							--dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
							IsActionCode,
							EffectivenessCheck,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							GETDATE() AS CreateDateTime,

							[FileName],
							FileSize,
							dbo.fnBase64ToBinary(FileData) as FileData,
							dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage
							, IncongruityCheck
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldNCRNo VARCHAR(20),
										NCRNo VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										OccurProcessCode VARCHAR(20),
										MaterialName VARCHAR(80),
										CustomName VARCHAR(60),
										standardName VARCHAR(60),
										LotNo VARCHAR(80),
										Qty INT,
										InspectionQty INT,
										BadQty INT,
										PPM NUMERIC(30,5),
										InQty INT,
										BadLotQty INT,
										DefectiveRate NUMERIC(30,5),
										CreateUserID VARCHAR(20),
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CustomImmediateAction NVARCHAR(4000),
										
										IsActionCode BIT,
										EffectivenessCheck BIT,
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,

										CustomCountermeasureImage BIGINT,
										 [FileName] NVARCHAR(255),
										 FileSize BIGINT,
										FileData NVARCHAR(MAX), 
										IncongruityCheck BIT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NCRNo = SourceTable.NCRNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					NCRNo = ISNULL(SourceTable.NCRNo,TargetTable.NCRNo),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					CustomName = ISNULL(SourceTable.CustomName,TargetTable.CustomName),
					standardName = ISNULL(SourceTable.standardName,TargetTable.standardName),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty),
					InspectionQty = ISNULL(SourceTable.InspectionQty,TargetTable.InspectionQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					PPM = ISNULL(SourceTable.PPM,TargetTable.PPM),
					InQty = ISNULL(SourceTable.InQty,TargetTable.InQty),
					BadLotQty = ISNULL(SourceTable.BadLotQty,TargetTable.BadLotQty),
					DefectiveRate = ISNULL(SourceTable.DefectiveRate,TargetTable.DefectiveRate),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CustomImmediateAction = ISNULL(SourceTable.CustomImmediateAction,TargetTable.CustomImmediateAction),
					
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					EffectivenessCheck = ISNULL(SourceTable.EffectivenessCheck,TargetTable.EffectivenessCheck),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2),

					CustomCountermeasureImage = ISNULL(SourceTable.CustomCountermeasureImage,TargetTable.CustomCountermeasureImage)
				, IncongruityCheck = ISNULL(SourceTable.IncongruityCheck,TargetTable.IncongruityCheck)

			WHEN NOT MATCHED THEN
				INSERT
					(
						NCRNo,
						JobDate,
						CompanyCode,
						OccurProcessCode,
						MaterialName,
						CustomName,
						standardName,
						LotNo,
						Qty,
						InspectionQty,
						BadQty,
						PPM,
						InQty,
						BadLotQty,
						DefectiveRate,
						CreateUserID,
						Nonconformity,
						ImmediateAction,
						CustomImmediateAction,
						CustomCountermeasureImage,
						IsActionCode,
						EffectivenessCheck,
						DefectImage,
						DefectImage2,
						CreateDateTime,
						IncongruityCheck
					)
				VALUES
					(
							SourceTable.NCRNo,
							SourceTable.JobDate,
							SourceTable.CompanyCode,
							SourceTable.OccurProcessCode,
							SourceTable.MaterialName,
							SourceTable.CustomName,
							SourceTable.standardName,
							SourceTable.LotNo,
							SourceTable.Qty,
							SourceTable.InspectionQty,
							SourceTable.BadQty,
							SourceTable.PPM,
							SourceTable.InQty,
							SourceTable.BadLotQty,
							SourceTable.DefectiveRate,
							SourceTable.CreateUserID,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CustomImmediateAction,
							SourceTable.CustomCountermeasureImage,
							SourceTable.IsActionCode,
							SourceTable.EffectivenessCheck,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.CreateDateTime,
							SourceTable.IncongruityCheck
					);


			-- Process Update Table
            MERGE STB_NCR_Report AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNCRNo IS NULL THEN NCRNo
							    ELSE OldNCRNo
							END AS OldNCRNo,
							NCRNo,
							JobDate,
							CompanyCode,
							OccurProcessCode,
							MaterialName,
							CustomName,
							standardName,
							LotNo,
							Qty,
							InspectionQty,
							BadQty,
							PPM,
							InQty,
							BadLotQty,
							DefectiveRate,
							@pProcessUserID AS CreateUserID,
							Nonconformity,
							ImmediateAction,
							CustomImmediateAction,
							dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
							IsActionCode,
							EffectivenessCheck,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							GETDATE() AS CreateDateTime,
							IncongruityCheck
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldNCRNo VARCHAR(20),
										NCRNo VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										OccurProcessCode VARCHAR(20),
										MaterialName VARCHAR(80),
										CustomName VARCHAR(60),
										StandardName VARCHAR(60),
										LotNo VARCHAR(80),
										Qty INT,
										InspectionQty INT,
										BadQty INT,
										PPM NUMERIC(30,5),
										InQty INT,
										BadLotQty INT,
										DefectiveRate NUMERIC(30,5),
										CreateUserID VARCHAR(20),
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CustomImmediateAction NVARCHAR(4000),
										CustomCountermeasureImage NVARCHAR(MAX),
										IsActionCode BIT,
										EffectivenessCheck BIT,
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										IncongruityCheck BIT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NCRNo = SourceTable.OldNCRNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					NCRNo = ISNULL(SourceTable.NCRNo,TargetTable.NCRNo),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					CustomName = ISNULL(SourceTable.CustomName,TargetTable.CustomName),
					StandardName = ISNULL(SourceTable.standardName,TargetTable.standardName),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty),
					InspectionQty = ISNULL(SourceTable.InspectionQty,TargetTable.InspectionQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					PPM = ISNULL(SourceTable.PPM,TargetTable.PPM),
					InQty = ISNULL(SourceTable.InQty,TargetTable.InQty),
					BadLotQty = ISNULL(SourceTable.BadLotQty,TargetTable.BadLotQty),
					DefectiveRate = ISNULL(SourceTable.DefectiveRate,TargetTable.DefectiveRate),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CustomImmediateAction = ISNULL(SourceTable.CustomImmediateAction,TargetTable.CustomImmediateAction),
					CustomCountermeasureImage = ISNULL(SourceTable.CustomCountermeasureImage,TargetTable.CustomCountermeasureImage),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					EffectivenessCheck = ISNULL(SourceTable.EffectivenessCheck,TargetTable.EffectivenessCheck),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2),
					IncongruityCheck = ISNULL(SourceTable.IncongruityCheck,TargetTable.IncongruityCheck)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NCRNo,
						JobDate,
						CompanyCode,
						OccurProcessCode,
						MaterialName,
						CustomName,
						standardName,
						LotNo,
						Qty,
						InspectionQty,
						BadQty,
						PPM,
						InQty,
						BadLotQty,
						DefectiveRate,
						CreateUserID,
						Nonconformity,
						ImmediateAction,
						CustomImmediateAction,
						CustomCountermeasureImage,
						IsActionCode,
						EffectivenessCheck,
						DefectImage,
						DefectImage2,
						CreateDateTime,
						IncongruityCheck
					)
				VALUES
					(
							SourceTable.NCRNo,
							SourceTable.JobDate,
							SourceTable.CompanyCode,
							SourceTable.OccurProcessCode,
							SourceTable.MaterialName,
							SourceTable.CustomName,
							SourceTable.standardName,
							SourceTable.LotNo,
							SourceTable.Qty,
							SourceTable.InspectionQty,
							SourceTable.BadQty,
							SourceTable.PPM,
							SourceTable.InQty,
							SourceTable.BadLotQty,
							SourceTable.DefectiveRate,
							SourceTable.CreateUserID,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CustomImmediateAction,
							SourceTable.CustomCountermeasureImage,
							SourceTable.IsActionCode,
							SourceTable.EffectivenessCheck,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.CreateDateTime,
							SourceTable.IncongruityCheck
					);


			-- Process Delete Table
            MERGE STB_NCR_Report AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNCRNo IS NULL THEN NCRNo
							    ELSE OldNCRNo
							END AS OldNCRNo,
							NCRNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldNCRNo VARCHAR(20),
										NCRNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NCRNo = SourceTable.NCRNo
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
									CASE 
										WHEN OldNCRNo IS NULL THEN NCRNo
										ELSE OldNCRNo
									END AS OldNCRNo,
									NCRNo,
									JobDate,
									CompanyCode,
									OccurProcessCode,
									MaterialName,
									CustomName,
									standardName,
									LotNo,
									Qty,
									InspectionQty,
									BadQty,
									PPM,
									InQty,
									BadLotQty,
									DefectiveRate,
									CreateUserID,
									Nonconformity,
									ImmediateAction,
									CustomImmediateAction,
									dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									IsActionCode,
									EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									CreateDateTime,									
									[FileName] ,
									FileSize ,
									dbo.fnBase64ToBinary(FileData) as FileData,
									IncongruityCheck
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
											 NCRNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 OccurProcessCode VARCHAR(20),
											 MaterialName VARCHAR(80),
											 CustomName VARCHAR(60),
											 standardName VARCHAR(60),
											 LotNo VARCHAR(80),
											 Qty INT,
											 InspectionQty INT,
											 BadQty INT,
											 PPM NUMERIC(30,5),
											 InQty INT,
											 BadLotQty INT,
											 DefectiveRate NUMERIC(30,5),
											 CreateUserID VARCHAR(20),
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CustomImmediateAction NVARCHAR(4000),
											 CustomCountermeasureImage BIGINT,
											 IsActionCode BIT,
											 EffectivenessCheck BIT,
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											  [FileName] NVARCHAR(255),
											 FileSize BIGINT,
										     FileData NVARCHAR(MAX),
											 IncongruityCheck BIT
											)
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldNCRNo IS NULL THEN NCRNo
										ELSE OldNCRNo
									END AS OldNCRNo,
									NCRNo,
									JobDate,
									CompanyCode,
									OccurProcessCode,
									MaterialName,
									CustomName,
									standardName,
									LotNo,
									Qty,
									InspectionQty,
									BadQty,
									PPM,
									InQty,
									BadLotQty,
									DefectiveRate,
									CreateUserID,
									Nonconformity,
									ImmediateAction,
									CustomImmediateAction,
									dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									IsActionCode,
									EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									CreateDateTime,
									[FileName] ,
									FileSize ,
									dbo.fnBase64ToBinary(FileData) as FileData ,
									IncongruityCheck
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
											 NCRNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 OccurProcessCode VARCHAR(20),
											 MaterialName VARCHAR(80),
											 CustomName VARCHAR(60),
											 standardName VARCHAR(60),
											 LotNo VARCHAR(80),
											 Qty INT,
											 InspectionQty INT,
											 BadQty INT,
											 PPM NUMERIC(30,5),
											 InQty INT,
											 BadLotQty INT,
											 DefectiveRate NUMERIC(30,5),
											 CreateUserID VARCHAR(20),
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CustomImmediateAction NVARCHAR(4000),
											 CustomCountermeasureImage BIGINT,
											 IsActionCode BIT,
											 EffectivenessCheck BIT,
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											  [FileName] NVARCHAR(255),
											  FileSize BIGINT,
											  FileData NVARCHAR(MAX),
											  IncongruityCheck BIT
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldNCRNo IS NULL THEN NCRNo
										ELSE OldNCRNo
									END AS OldNCRNo,
									NCRNo,
									JobDate,
									CompanyCode,
									OccurProcessCode,
									MaterialName,
									CustomName,
									standardName,
									LotNo,
									Qty,
									InspectionQty,
									BadQty,
									PPM,
									InQty,
									BadLotQty,
									DefectiveRate,
									CreateUserID,
									Nonconformity,
									ImmediateAction,
									CustomImmediateAction,
									dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									IsActionCode,
									EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									CreateDateTime,
									[FileName] ,
									FileSize ,
									dbo.fnBase64ToBinary(FileData) as FileData,
									IncongruityCheck
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
											 NCRNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 OccurProcessCode VARCHAR(20),
											 MaterialName VARCHAR(80),
											 CustomName VARCHAR(60),
											 standardName VARCHAR(60),
											 LotNo VARCHAR(80),
											 Qty INT,
											 InspectionQty INT,
											 BadQty INT,
											 PPM NUMERIC(30,5),
											 InQty INT,
											 BadLotQty INT,
											 DefectiveRate NUMERIC(30,5),
											 CreateUserID VARCHAR(20),
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CustomImmediateAction NVARCHAR(4000),
											 CustomCountermeasureImage NVARCHAR(MAX),
											 IsActionCode BIT,
											 EffectivenessCheck BIT,
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											   [FileName] NVARCHAR(255),
											  FileSize BIGINT,
											  FileData NVARCHAR(MAX),
											  IncongruityCheck BIT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldNCRNo,
								 @NCRNo,
								 @JobDate,
								 @CompanyCode,
								 @OccurProcessCode,
								 @MaterialName,
								 @CustomName,
								 @standardName,
								 @LotNo,
								 @Qty,
								 @InspectionQty,
								 @BadQty,
								 @PPM,
								 @InQty,
								 @BadLotQty,
								 @DefectiveRate,
								 @CreateUserID,
								 @Nonconformity,
								 @ImmediateAction,
								 @CustomImmediateAction,
								 @CustomCountermeasureImage,
								 @IsActionCode,
								 @EffectivenessCheck,
								 @DefectImage,
								 @DefectImage2,
								 @CreateDateTime,
								 @FileName ,
								 @FileSize ,
								 @FileData,
								 @IncongruityCheck


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

                IF @IUD_FLAG = 'INSERT' BEGIN
					PRINT 'INSERT'

                    IF EXISTS (SELECT 1 FROM STB_NCR_Report WHERE NCRNo = @NCRNo) BEGIN
						PRINT 'DUP'
						PRINT '@OldNCRNo : ' + @OldNCRNo
						PRINT '@PPM : ' + CONVERT(VARCHAR(50), @PPM)

						-- 2020.10.05 대책서 파일 저장부분   추가사항  
						IF RTRIM(ISNULL(@FileName,'')) <> '' BEGIN
							EXEC SmartFramework.dbo.usp_DoSaveFile 
									@pSystemName = 'STB_NCR_Report',
									@pFileContents = @FileData,
									@pFileName = @FileName,
									@pFileSize = @FileSize,
									@pUserID = @ProcessUserID,
									@pFileID = @CustomCountermeasureImage OUTPUT
						END

							UPDATE STB_NCR_Report
								SET
									NCRNo =   ISNULL(@NCRNo,NCRNo),
									JobDate =   ISNULL(@JobDate,JobDate),
									CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
									OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
									MaterialName =   ISNULL(@MaterialName,MaterialName),
									CustomName =   ISNULL(@CustomName,CustomName),
									standardName =   ISNULL(@standardName,standardName),
									LotNo =   ISNULL(@LotNo,LotNo),
									Qty =   ISNULL(@Qty,Qty),
									InspectionQty =   ISNULL(@InspectionQty,InspectionQty),
									BadQty =   ISNULL(@BadQty,BadQty),
									PPM =   ISNULL(@PPM,PPM),
									InQty =   ISNULL(@InQty,InQty),
									BadLotQty =   ISNULL(@BadLotQty,BadLotQty),
									DefectiveRate =   ISNULL(@DefectiveRate,DefectiveRate),
									CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
									Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
									ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
									CustomImmediateAction =   ISNULL(@CustomImmediateAction,CustomImmediateAction),
									CustomCountermeasureImage =   ISNULL(@CustomCountermeasureImage,CustomCountermeasureImage),
									IsActionCode =   ISNULL(@IsActionCode,IsActionCode),
									EffectivenessCheck =   ISNULL(@EffectivenessCheck,EffectivenessCheck),
									DefectImage =   ISNULL(@DefectImage,DefectImage),
									DefectImage2 =   ISNULL(@DefectImage2,DefectImage2),
									CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
									IncongruityCheck =  ISNULL(@IncongruityCheck,IncongruityCheck)
								WHERE
									NCRNo = @OldNCRNo
					END

                   IF NOT EXISTS (SELECT 1 FROM STB_NCR_Report WHERE NCRNo = @NCRNo) BEGIN
						PRINT 'NOT DUP'
						--- 추가부분임 (박진호님 요청)
						IF RTRIM(ISNULL(@FileName,'')) <> '' BEGIN
							EXEC SmartFramework.dbo.usp_DoSaveFile 
								@pSystemName = 'STB_NCR_Report',
								@pFileContents = @FileData,
								@pFileName = @FileName,
								@pFileSize = @FileSize,
								@pUserID = @ProcessUserID,
								@pFileID = @CustomCountermeasureImage OUTPUT
						END




                    INSERT INTO STB_NCR_Report
						(
						    NCRNo,
						    JobDate,
						    CompanyCode,
						    OccurProcessCode,
						    MaterialName,
						    CustomName,
						    standardName,
						    LotNo,
						    Qty,
						    InspectionQty,
						    BadQty,
						    PPM,
						    InQty,
						    BadLotQty,
						    DefectiveRate,
						    CreateUserID,
						    Nonconformity,
						    ImmediateAction,
						    CustomImmediateAction,
						    CustomCountermeasureImage,
						    IsActionCode,
						    EffectivenessCheck,
						    DefectImage,
						    DefectImage2,
						    CreateDateTime,
							IncongruityCheck
						)
						VALUES
						(
						    @NCRNo,
						    @JobDate,
						    @CompanyCode,
						    @OccurProcessCode,
						    @MaterialName,
						    @CustomName,
						    @standardName,
						    @LotNo,
						    @Qty,
						    @InspectionQty,
						    @BadQty,
						    @PPM,
						    @InQty,
						    @BadLotQty,
						    @DefectiveRate,
						    @pProcessUserID,
						    @Nonconformity,
						    @ImmediateAction,
						    @CustomImmediateAction,
						    @CustomCountermeasureImage,
						    @IsActionCode,
						    @EffectivenessCheck,
						    @DefectImage,
						    @DefectImage2,
						    GETDATE(),
							@IncongruityCheck
						)

				END 
				END ELSE IF @IUD_FLAG = 'UPDATE' 				
				BEGIN
				PRINT 'UPDATE'
				-- 2020.10.05 대책서 파일 저장부분   추가사항  
				IF RTRIM(ISNULL(@FileName,'')) <> '' BEGIN
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_NCR_Report',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @CustomCountermeasureImage OUTPUT
				END

                    UPDATE STB_NCR_Report
						SET
						    NCRNo =   ISNULL(@NCRNo,NCRNo),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    CustomName =   ISNULL(@CustomName,CustomName),
						    standardName =   ISNULL(@standardName,standardName),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    Qty =   ISNULL(@Qty,Qty),
						    InspectionQty =   ISNULL(@InspectionQty,InspectionQty),
						    BadQty =   ISNULL(@BadQty,BadQty),
						    PPM =   ISNULL(@PPM,PPM),
						    InQty =   ISNULL(@InQty,InQty),
						    BadLotQty =   ISNULL(@BadLotQty,BadLotQty),
						    DefectiveRate =   ISNULL(@DefectiveRate,DefectiveRate),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
						    ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
						    CustomImmediateAction =   ISNULL(@CustomImmediateAction,CustomImmediateAction),
						    CustomCountermeasureImage =   ISNULL(@CustomCountermeasureImage,CustomCountermeasureImage),
						    IsActionCode =   ISNULL(@IsActionCode,IsActionCode),
						    EffectivenessCheck =   ISNULL(@EffectivenessCheck,EffectivenessCheck),
						    DefectImage =   ISNULL(@DefectImage,DefectImage),
						    DefectImage2 =   ISNULL(@DefectImage2,DefectImage2),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
							IncongruityCheck  =   ISNULL(@IncongruityCheck,IncongruityCheck)
						WHERE
						    NCRNo = @OldNCRNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_NCR_Report
						WHERE
						    NCRNo = @OldNCRNo
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

GO

PRINT 'Procedure usp_NCR_Report_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_MaterialQcInfoChangeLotNo_HY_iud (Cloned from usp_MaterialQcInfoChangeLotNo_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcInfoChangeLotNo_HY_iud')
    DROP PROCEDURE [dbo].[usp_MaterialQcInfoChangeLotNo_HY_iud];
GO

-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사 > 검사LotNo 변경 Button
-- Description:	
-- Modified: 
-- Select IQCSampleLotList, DescText, * from STB_MaterialQcInfo where MaterialQcNo = '20090900001'

--update STB_MaterialQcInfo
--set DescText = '' 
--where MaterialQcNo = '20090900001'

-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInfoChangeLotNo_HY_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20),
	@pIQCSampleLotList NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	       ,   @IQCSampleLotList NVARCHAR(MAX) = ISNULL(@pIQCSampleLotList, '')

 
	UPDATE STB_MaterialQcInfo
	      SET IQCSampleLotList = @IQCSampleLotList
	 WHERE MaterialQcNo = @MaterialQcNo

END

--ALTER PROCEDURE [dbo].[usp_MaterialQcInfoChangeLotNo_HY_iud]
--	@pProcessUserID VARCHAR(20),
--	@pProcessLanguage VARCHAR(20),
--    @pProcessViewName VARCHAR(50),
--	@pXml NVARCHAR(MAX) = null
--AS

--BEGIN
--	SET NOCOUNT ON;

--    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
--    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
--    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
--    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
--    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
--    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
--    DECLARE @ERROR_MSG NVARCHAR(MAX)
--    DECLARE @IUD_FLAG VARCHAR(10)
--    DECLARE @IsAutoKey BIT
--    DECLARE @IsLoopIUD BIT
--    DECLARE @PrefixString VARCHAR(20)
--    DECLARE @SerialLen INT

--    -- Declare Columns Variable
--  DECLARE @OldMaterialQcNo VARCHAR(20)
--  DECLARE @MaterialQcNo VARCHAR(20)
--  DECLARE @IQCSampleLotList NVARCHAR(MAX)


--	DECLARE @iDoc INT

--    EXEC usp_GetSerialRule 
--			@pTableName = 'STB_MaterialQcInfo',
--			@pIsAutoKey = @IsAutoKey OUTPUT,
--			@pIsLoopIUD = @IsLoopIUD OUTPUT,
--			@pPrefixData = @PrefixString OUTPUT,
--			@pSerialLen = @SerialLen OUTPUT
    
--    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
--        PRINT 'Batch was removed'
--    END ELSE BEGIN
        
--        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
--        BEGIN TRY
--		    DECLARE SourceData CURSOR FOR
--                SELECT
--                        'INSERT' AS IUD_FLAG,
--									OldMaterialQcNo,
--									MaterialQcNo,
--									IQCSampleLotList
--							FROM
--									OPENXML(@idoc , @InsertTableName , 2)
--							        WITH  (
--											 OldMaterialQcNo VARCHAR(20),
--											 MaterialQcNo VARCHAR(20),
--											 IQCSampleLotList NVARCHAR(MAX)
--											)
--							UNION ALL
--							SELECT
--									'UPDATE' AS IUD_FLAG,
--									CASE 
--										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
--										ELSE OldMaterialQcNo
--									END AS OldMaterialQcNo,
--									MaterialQcNo,
--									IQCSampleLotList
--							FROM
--									OPENXML(@idoc , @UpdateTableName , 2)
--							        WITH  (
--											 OldMaterialQcNo VARCHAR(20),
--											 MaterialQcNo VARCHAR(20),
--											 IQCSampleLotList NVARCHAR(MAX)
--											)
--							UNION ALL
--							SELECT
--									'DELETE' AS IUD_FLAG,
--									CASE 
--										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
--										ELSE OldMaterialQcNo
--									END AS OldMaterialQcNo,
--									MaterialQcNo,
--									IQCSampleLotList
--							FROM
--									OPENXML(@idoc , @DeleteTableName , 2)
--							        WITH  (
--											 OldMaterialQcNo VARCHAR(20),
--											 MaterialQcNo VARCHAR(20),
--											 IQCSampleLotList NVARCHAR(MAX)
--											) 


--            OPEN SourceData

--            WHILE 1 = 1 BEGIN
--                FETCH NEXT FROM SourceData INTO
--								 @IUD_FLAG,
--								 @OldMaterialQcNo,
--								 @MaterialQcNo,
--								 @IQCSampleLotList


--                IF @@FETCH_STATUS <> 0 BEGIN
--					BREAK
--				END
--                IF @IUD_FLAG = 'INSERT' BEGIN

--                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo) BEGIN
--						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
--					END

--                    IF @IsAutoKey = 1 BEGIN
--                        EXEC usp_DoCreateSerial 'STB_MaterialQcInfo',@MaterialQcNo OUTPUT
--                    END

--                    INSERT INTO STB_MaterialQcInfo
--						(
--						    MaterialQcNo,
--						    IQCSampleLotList
--						)
--						VALUES
--						(
--						    @MaterialQcNo,
--						    @IQCSampleLotList
--						)

--				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
--                    UPDATE STB_MaterialQcInfo
--						SET
--						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
--						    IQCSampleLotList =   ISNULL(@IQCSampleLotList,IQCSampleLotList)
--						WHERE
--						    MaterialQcNo = @OldMaterialQcNo
--                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
--                    DELETE FROM STB_MaterialQcInfo
--						WHERE
--						    MaterialQcNo = @OldMaterialQcNo
--                END
--            END
--        END TRY
--		BEGIN CATCH
--			SET @ERROR_MSG = ERROR_MESSAGE()
--			RAISERROR( @ERROR_MSG ,16, 1)
--		END CATCH
			
--		CLOSE SourceData;
--		DEALLOCATE SourceData;
			
--		EXEC sp_xml_removedocument @idoc	

--    END
--END

GO

PRINT 'Procedure usp_MaterialQcInfoChangeLotNo_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DefectReportNoChange_HY_iud (Cloned from usp_DefectReportNoChange_iud)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DefectReportNoChange_HY_iud')
    DROP PROCEDURE [dbo].[usp_DefectReportNoChange_HY_iud];
GO

-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사 > 검사LotNo 변경 Button
-- Description:	
-- Modified: 
-- Select IQCSampleLotList, DescText, * from STB_MaterialQcInfo where MaterialQcNo = '20090900001'


-- =============================================
Create PROCEDURE [dbo].[usp_DefectReportNoChange_HY_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20),
	@pDefectReportNo NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	       ,   @DefectReportNo NVARCHAR(MAX) = ISNULL(@pDefectReportNo, '')

 
-- Select DefectReportNo, * from STB_IQcDefectReport                 -- 부적합번호 : DefectReportNo
--where 1=1
--  and DefectReportNo in ('VNI201105-01','1111')


	UPDATE STB_IQcDefectReport
	      SET DefectReportNo = @DefectReportNo
	 WHERE LotNo = @MaterialQcNo

END
GO

PRINT 'Procedure usp_DefectReportNoChange_HY_iud created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DoSendEmailForDefectReportIQC_HY (Cloned from usp_DoSendEmailForDefectReportIQC)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoSendEmailForDefectReportIQC_HY')
    DROP PROCEDURE [dbo].[usp_DoSendEmailForDefectReportIQC_HY];
GO

-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-10-23
-- Browsable : True
-- Group : 품질관리> 부적합보고서 등록 메일설정부분 > [수입검사]용 메일
-- Description: 부적합보고서 등록 시 호출되어 이메일을 발송한다.
-- Modified: 
-- 2020.10.23 박진호님 요청
-- 2020.12.01 법인 부적합 메일그룹 추가 (박진호님 요청)
-- 2020.12.08 시료수, 불량수, 불량률 SQL문 수정 (박진호님 요청)
-- 2020.12.09 불량수(%)수식변경 (박진호요청)
-- 2021.07.16 부적합 발행부서 기준으로 메일 제목 수정 (이미정 차장 요청) #210716

-- 2023.06.14 Mr.tung modified     substring(@DefectDivisionName,1,4) 

 -- 프로시저 실행 :  usp_DoSendEmailForDefectReportIQC_HY '','','VVNI210323-01'
  --,@ActionContent = QDR.ActionContent --add by Mr.Tung on 2022-07-25
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSendEmailForDefectReportIQC_HY] -- exec usp_DoSendEmailForDefectReportIQC_HY '','','VN231127-02'
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pDefectReportNo VARCHAR(20)
AS

BEGIN

	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
			   ,@SQLIMG VARCHAR(MAX)
			   ,@IMG_PATH VARBINARY(MAX)
			   ,@TIMESTAMP VARCHAR(MAX)
			   ,@ObjectToken INT
			   ,@DefectDivisionName NVARCHAR(50)
			   ,@PublishDeptName NVARCHAR(50)
			   ,@ReceiveDeptName NVARCHAR(50)
			   ,@OccurProcessName NVARCHAR(50)
			   ,@MachineName NVARCHAR(50)
			   ,@DefectName NVARCHAR(50)
			   ,@EmailBody NVARCHAR(MAX)			   
			   ,@WorkerName NVARCHAR(100)
			   ,@PublishName NVARCHAR(100)  
			   ,@JobDate DATE

			   ,@MaterialCode VARCHAR(30)
			   ,@MaterialName VARCHAR(100)
			   ,@LotNo VARCHAR(20)			   
			   ,@DefectSampleCnt INT
			   ,@DefectErrorCnt INT
			  , @DefectRate NUMERIC(10, 3)
			  -- ,@DefectRate float               -- add by Mr.Tung on 2023-May-04 as QC Leader
			  , @ActionContent NVARCHAR(MAX)
			  , @MailSubject NVARCHAR(500)		   
			  , @MaterialSpec NVARCHAR(50)
			  , @ImmediateAction NVARCHAR(MAX)		
			  , @CauseInvestigation NVARCHAR(MAX)		
			  , @PreventionRecurrence NVARCHAR(MAX)		
			  , @DetectionCounterMeasures NVARCHAR(MAX)		  
			  , @CheckingCorrectiveAction NVARCHAR(MAX)		
			  , @Validation NVARCHAR(50)		
			  , @ActionCode NVARCHAR(10)		
			  , @QcOpinionContent NVARCHAR(MAX)		
			  , @IsQcHeadConfirm  NVARCHAR(500)		
			  , @Payment   NVARCHAR(100)		
			  , @CorrectiveActionCode NVARCHAR(10)		
			  , @CorrectiveActionName NVARCHAR(100)		
			  --, @DefectImage NVARCHAR(500)		
			  --, @DefectImage2 NVARCHAR(500)		
			  , @DefectLotSize INT		
		      , @IQCSampleLotList NVARCHAR(50)
			  , @ProdProcessResultCode NVARCHAR(50)
			  , @ProdProcessResultName NVARCHAR(50)
			  , @IsProdHeadConfirm  NVARCHAR(50)			  
			  , @CreateDateTime DATE
			  , @CreateUserID NVARCHAR(50)
			  , @ChangeDateTime DATE
			  , @ChangeUserID  NVARCHAR(50)
			  , @IsReInspectionResult  NVARCHAR(50)
			  , @ProdProcessResultFile	NVARCHAR(50)	   
			  , @FileData NVARCHAR(50)
			  , @DefectiveRate INT
			  , @ProductGroupName VARCHAR(40)

			   --생산부문, 베트남부문
			   ,@ToAddress VARCHAR(MAX) = 'v.manufacturing@vina.co.kr;v.celltechnical@vina.co.kr;v.vietnamcorp@vina.co.kr;vvea01@vina.co.kr;'        
			   -- 품질부문
			   ,@CcAddress VARCHAR(MAX) = 'v.qc@vina.co.kr;v.vietnamiqcrelative@vina.co.kr;v.purchasing@vina.co.kr' + ';vn.productionsupport@vina.co.kr;vn.production1@vina.co.kr;vn.production2@vina.co.kr;vn.production@vina.co.kr;v.vietnamlocalstaff@vina.co.kr;vn.purchase@vina.co.kr;vn.qc@vina.co.kr;kbnam@vina.co.kr;'  
			   -- Mr.Tung on 2023-Feb-13 OQC request add their email vn.qc@vina.co.kr 
			   --add by Mr.Tung on 04-10-2021 & 10-11-2021 & 2022-April-29 as Mr.Quyen/Mr.Kien request       
			   --add by Mr.Tung on  2022-Nov-11 as Mr.Kien request   
			   -- 2020.12.07 베트남 직원들 추가  -- 2021.08.06 구매팀 추가
			   ---- 테스트 Mail
			   --,@ToAddress VARCHAR(MAX) = 'kilee@vina.co.kr;'			 
      --        ,@CcAddress VARCHAR(MAX) = 'nicekangil@naver.com;'                                       --'jseom@vina.co.kr;'  --    jhpark@vina.co.kr;yjyu@vina.co.kr;'

    SELECT @IMG_PATH = DefectImage FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo     -- 테이블명 확인 : 수입검사는 STB_IQcDefectReport

	IF @IMG_PATH IS NOT NULL BEGIN 
			SET @TIMESTAMP = 'C:\MES\WebSite\images\qcRpt2\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.jpg'      -- qcRpt2 중요!

			EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
			EXEC sp_OASetProperty @ObjectToken, 'Type', 1
			EXEC sp_OAMethod @ObjectToken, 'Open'
			EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @IMG_PATH
			EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @TIMESTAMP, 2
			EXEC sp_OAMethod @ObjectToken, 'Close'
			EXEC sp_OADestroy @ObjectToken
	END 
	
	ELSE 
	
			BEGIN
				SET @TIMESTAMP = NULL
			END



	SELECT 
	    @DefectDivisionName =  BC1.Description           --원부자재		  
		  , @PublishDeptName = BC2.Description              --품질부문  (발행부서)
		  --, @ReceiveDeptName = BC2.Description           --품질부문
		  ,@OccurProcessName = BC4.Description
		  , @ReceiveDeptName = C.CustomerName           --수신처 : 하남전자		    
		  , @OccurProcessName = SNR.OccurProcessCode  -- 공정검사		  
		  , @MaterialCode = MQI.MaterialCode                 --품번
		  , @MaterialName = MM.MaterialName
		  , @ProductGroupName = PG.ProductGroupName
		  , @DefectiveRate = Case when  MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0   then 0 else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100)) End  -- 불량율(%) (2020.12.08 수정)
		              
		  -- (Lot조치사항)
		  -- (품질부서의견)
		  -- (부적합현상)
		  --, BC4.Description
		  --,QDR.PublishEmpID
		  --,@PublishName = EI1.EmployeeName     -- 발행자
		  , @PublishName = isnull(EI1.EmployeeName, isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] where WorkerCode=QDR.PublishEmpID),QDR.PublishEmpID) )           --발행자, 2020.12.07 추가 (박진호님 요청)
		  --,BC4.Description AS OccurProcessName		  
		  , @LotNo = Case When isnull(QDR.LotNo, '') = '' Then SNR.LotNo Else QDR.LotNo End 
		  , @IQCSampleLotList = MQI.IQCSampleLotList                    -- 검사 LotNo
		  , @CorrectiveActionCode = QDR.CorrectiveActionCode         -- 시정조치여부코드
		  , @CorrectiveActionName = BC6.Description                      -- 시정조치여부명
		  --, @DefectImage = QDR.DefectImage
		  --, @DefectImage2=  QDR.DefectImage2  
		  , @DefectLotSize = QDR.DefectLotSize		
		  , @ProdProcessResultCode = QDR.ProdProcessResultCode     -- 생산부분 처리코드 (재작업, 특채 등)
		  , @ProdProcessResultName = BC5.Description                     -- 생산부분 처리명 (코드테이블)		
		  , @IsProdHeadConfirm = CONVERT(BIT, 0) 
		  , @IsQcHeadConfirm = CONVERT(BIT, 0) 
		  , @CreateDateTime = GETDATE() 
		  , @CreateUserID = QDR.CreateUserID
		  , @ChangeDateTime = QDR.ChangeDateTime
		  , @ChangeUserID = QDR.ChangeUserID
		  , @IsReInspectionResult  = CONVERT(BIT, 0) 
		  , @ProdProcessResultFile = QDR.ProdProcessResultFile
		  --, @AFM.[FileName]
		  --, @AFM.FileSize
		  , @FileData = ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) 
		  , @ImmediateAction = QDR.ImmediateAction     --즉시조치
		  , @CauseInvestigation = QDR.CauseInvestigation    --원인조사
		  , @PreventionRecurrence = QDR.PreventionRecurrence     --재발방지조치
		  , @DetectionCounterMeasures = QDR.DetectionCounterMeasures    --검출대책수립		  
		  , @CheckingCorrectiveAction = QDR.CheckingCorrectiveAction   --시정조치확인
		  , @Validation = QDR.Validation                       --제품유효성확인
		  , @ActionCode = QDR.IsActionCode           -- 시정조치여부
		  , @QcOpinionContent = QDR.QcOpinionContent  -- 품질부서의견
          , @IsQcHeadConfirm = QDR.IsQcHeadConfirm  -- 품질부문장결재
		  , @Payment  = Case When QDR.IsQcHeadConfirm = 0 Then  '결재취소'  When QDR.IsQcHeadConfirm  = 1 Then  '결재완료'  Else '미완료' End  
		      		  
		  -- 원본백업 (2020.12.08 이전)
		  -- , @DefectLotSize = QDR.DefectLotSize
		  --, @DefectSampleCnt = MQI.MIIExtText04
		  --, @DefectLotSize = SNR.Qty                    -- LOT크기
		  --, @DefectErrorCnt = SNR.BadLotQty          -- 불량수
		  --, @DefectSampleCnt =  SNR.InQty            -- 시료수

		  -- 수정사항 (2020.12.08 부터)
		 , @DefectLotSize = MQI.QcQty                    -- 2020.12.08 "Lot크기" 수정사항
		 , @DefectErrorCnt = MQI.DefectSampleQty    -- 2020.12.08 "불량수" 수정사항
	     , @DefectSampleCnt = MQI.ActualSampleQty -- 2020.12.08 "시료수" 수정사항

		-- , @DefectRate = Case When MQI.MIIExtText04 = 0 Then 0 When MDD.LotNo_Qty = 0 Then 0 Else Convert(BIGINT, ( Convert(NUMERIC(20,5), MQI.MIIExtText04) / Convert(NUMERIC(20,5), MDD.LotNo_Qty) * 100)) End   -- 2020.12.08 "불량률" 수정사항
		
		, @DefectRate =  Case when  MQI.DefectSampleQty = 0 then 0 when MQI.ActualSampleQty = 0   then 0 else CONVERT(NUMERIC(20,2), ( CONVERT(NUMERIC(20,3), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,3), MQI.ActualSampleQty)  * 100))  End 
		 
		 --,  @DefectRate =  Case when  MQI.DefectSampleQty = 0 then 0 when MQI.ActualSampleQty = 0   then 0 else CONVERT(float, ( CONVERT(float, MQI.DefectSampleQty) / CONVERT(float, MQI.ActualSampleQty)  * 100))  End                -- add by Mr.Tung on 2023-May-04 as QC Leader
		  , @JobDate = CONVERT(VARCHAR(10), QDR.CreateDateTime, 121)
		  , @DefectName = QDR.Nonconformity             -- 부적합명 : ex)이물세척
		  , @IQCSampleLotList =  MQI.IQCSampleLotList    -- 검사 Lot No 		
		   ,@ActionContent = QDR.ActionContent --add by Mr.Tung on 2022-07-25
		    		
 FROM							 STB_MaterialQcInfo MQI	    	                  
			LEFT OUTER JOIN  STB_NCR_Report SNR                                    ON SNR.LotNo =  MQI.IQCSampleLotList  
			LEFT OUTER JOIN  STB_IQcDefectReport QDR     WITH(NOLOCK)	 ON SNR.NCRNo = QDR.DefectReportNo    
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	         ON QDR.DefectDivisionCode = BC1.ItemCode  AND BC1.CodeGroup = 'DefectDivisionCode'
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	         ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'			 
			LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1  ON QDR.PublishEmpID = EI1.EmployeeNo		   
			-- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3			 ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'         
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	         ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'		   
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	         ON QDR.ProdProcessResultCode = BC5.ItemCode  AND BC5.CodeGroup = 'ProdProcessResultCode'
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	         ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               						
			LEFT OUTER JOIN (
									SELECT DefectReportNo 
										FROM STB_QcDefectReportReInspectionResult 
									GROUP BY DefectReportNo
									) QDRR	                                                             ON QDRR.DefectReportNo = QDR.DefectReportNo
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	 ON AFM.FileID = QDR.ProdProcessResultFile		
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		             ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN (
										 SELECT DISTINCT MDD.MaterialDocNo,
													MDD.MaterialIqcNo,
													Count(MDLI.LotNo)	AS LotNo_Qty            
											FROM
													STB_MaterialDocDetail MDD WITH(NOLOCK)
													INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
													INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
													INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
											WHERE	1=1											
											Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            
									) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
 WHERE 1=1 
	   AND QDR.DefectReportNo = @DefectReportNo
	  -- AND QDR.DefectReportNo = 'VNI201022-01'	     -- Test주석

	 -- 수신처에 따라 메일제목 변경
	 --SET @MailSubject = CASE WHEN @ReceiveDeptName IN ('생산부문(베트남법인)', '베트남법인')  THEN '베트남 제품 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101)
		--								  ELSE '본사 제품 부적합 발생 보고서_'    + CONVERT(CHAR(5), GETDATE(), 101) END

	 --#210716
	 SET @MailSubject = CASE WHEN substring(@PublishDeptName,1,11) = '품질부문(베트남법인)' THEN '베트남 수입검사 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101)
							 ELSE '본사 수입검사 부적합 발생 보고서_'    + CONVERT(CHAR(5), GETDATE(), 101) END
	
	-- 원본백업 (2020.12.07 이전)
	--IF @ReceiveDeptName IN ('베트남법인', '생산부문(베트남법인)') 
	--BEGIN
	--	--SET @ToAddress = @ToAddress + 'v.vietnamlocalstaff@vina.co.kr;'          -- 일반 부적합 보고서
	--	SET @ToAddress = @ToAddress + 'v.vietnamiqcrelative@vina.co.kr;'           -- IQC 부적합보고서 (2020.12.01 추가)	
	--END

    SET @EmailBody =                     N'    <table width="1100" cellspacing="1" cellpadding="1" border="1">'
    SET @EmailBody = @EmailBody + N'      <colgroup>'
    SET @EmailBody = @EmailBody + N'        <col width="15%"><col width="14%"><col width="14%"><col width="14%"><col width="13%"><col width="13%"><col width="17%"> '
    SET @EmailBody = @EmailBody + N'      </colgroup>'
    SET @EmailBody = @EmailBody + N'      <tbody>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td height="20" valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) in ('원/부자', '원/부자재')  THEN '■' ELSE '□' END + N'원/부자재<br/>Nguyên/Phụ liệu </b></td>'
    SET @EmailBody = @EmailBody + N'          <td height="20" valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) = '공정검사' THEN '■' ELSE '□' END  + N'공정검사<br/>Kiểm tra công đoạn </b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="2" colspan="4" valign="middle" align="center"><font size="+3"><b> 부적합품 보고서<br/><font size="+1">(BÁO CÁO SẢN PHẨM KHÔNG PHÙ HỢP)</b></font></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff">NCR No.</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) IN ('제품검사', '제품검사(베트남)', '출하검사', '출하검사(베트남)', 'FOQC') THEN '■' ELSE '□' END + N'제품검사<br/>Kiểm tra sản phẩm </b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) IN ('고객불만', 'FOQC','출하검사', '출하검사(베트남)')  THEN '■' ELSE '□' END + N'출하검사<br/>Kiểm tra lô hàng</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + @DefectReportNo + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    
	SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발행 부서 <br/>(Bộ phận phát hành)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>수신처 <br/>(Nơi tiếp nhận)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발생 공정<br/>(Công đoạn phát hiện.)</b></td>'    --- 발생 공정 Mr.Tung change Vietnamese on 2023.02.21
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>품목코드<br/>(code Nguyên Liệu)</b></td>'                               -- 변경부분
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>품목명<br/>(tên Nguyên liệu)</b></td>'    -- 변경부분
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발행자<br/>(nhà xuất bản)</b></td>'                          
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>검사일자<br/>(Ngày thao tác)</b></td>'            -- 변경부분
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@PublishDeptName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@ReceiveDeptName, '') + '</td>'
  --  SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@OccurProcessName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + '수입검사' + '</td>'
   SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MaterialCode, '') + '</td>'	
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MaterialName, '') + '</td>'
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@PublishName, '') + '</td>'                       
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(CHAR(10), @JobDate, 121) + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'    
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>MODEL </b></td>'              
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>원자재 그룹명 <br/>(Tên nhóm nguyên liệu) </b></td>'                --변경부분
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>Lot No. </b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="middle" align="center" bgcolor="#ccccff"><b>부적합명 <br/>(Tên lỗi)</b></td>'    
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + '-' + '</td>'      
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@ProductGroupName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@IQCSampleLotList, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center">' + ISNULL(@DefectName, '') + '</td>'												  
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center" bgcolor="#ccccff"><b>부적합 세부 내용 <br/>(Nội dung chi tiết lỗi)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center" bgcolor="#ccccff"><b>부적합 현상        <br/>(Hiện trạng lỗi)</b></td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>LOT 크기<br/>(Độ lớn LOT)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectLotSize, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>시료수 <br/>(Số lượng mẫu thử)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectSampleCnt, 0)) + '</td>'    	
	SET @EmailBody = @EmailBody + N'          <td rowspan="4" colspan="4" valign="middle" align="center">' + CASE WHEN @TIMESTAMP IS NULL 
																																							 THEN 'No Image' 
																																				              ELSE '<img src="http://mes.hycap.co.kr:9952/images/qcRpt2/' + RIGHT(@TIMESTAMP, 21) + '" width="300" height="250" />' END + '</td>'	
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>불량수<br/>(Số lượng NG)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectErrorCnt, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>불량률<br/>(Tỷ lệ NG)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectRate, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="100">'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="left"><b>* Lot 조치사항 (Mục xử lý Lot)</b> : ' + ISNULL(@ActionContent, '') + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="100">'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="left"><b>* 품질부서 의견 (Ý kiến của bộ phận Chất lượng)  </b> : ' + ISNULL(@QcOpinionContent, '') + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    SET @EmailBody = @EmailBody + N'      </tbody>'
    SET @EmailBody = @EmailBody + N'    </table>'

	EXEC usp_DoAddDefectReportMail @pProcessUserID = @pProcessUserID
												,@pProcessLanguage = @pProcessLanguage
												,@pToMailAddress= @ToAddress
												,@pCcMailAddress= @CcAddress
												,@pMailSubject = @MailSubject
												,@pMailContents = @EmailBody

	-- 부적합 보고서 첨부 이미지의 최종경로 저장 (2020.11.03) By Jackaroe
	UPDATE STB_IQcDefectReport
	      SET DefectImageUrl = CASE WHEN @TIMESTAMP IS NULL THEN 'No Image' ELSE 'http://mes.hycap.co.kr:9952/images/qcRpt2/' + RIGHT(@TIMESTAMP, 21) END
	 WHERE DefectReportNo = @DefectReportNo

END																																				 																																				              																																																																																																																																																																				
GO

PRINT 'Procedure usp_DoSendEmailForDefectReportIQC_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_DoChangeMaterialQcToPass_HY (Cloned from usp_DoChangeMaterialQcToPass)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoChangeMaterialQcToPass_HY')
    DROP PROCEDURE [dbo].[usp_DoChangeMaterialQcToPass_HY];
GO

-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-01-06
-- Description:	Change decision from Reject to Pass VVT
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoChangeMaterialQcToPass_HY]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pMaterialQcNo VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MaterialQcNo VARCHAR(30) = @pMaterialQcNo

	DECLARE @CheckDecisionResult VARCHAR(30) = NULL,
			@BefPassedSampleQty INT = NULL,
			@BefDefectSampleQty INT = NULL,
			@CheckWorkCenterCode VARCHAR(10) = NULL

	SELECT	@CheckDecisionResult = DecisionResult,
			@BefPassedSampleQty = PassedSampleQty,
			@BefDefectSampleQty = DefectSampleQty,
			@CheckWorkCenterCode = WorkCenterCode
			FROM STB_MaterialQcInfo
			WHERE MaterialQcNo = @MaterialQcNo

	IF @CheckWorkCenterCode NOT IN ('VVT_F1')
		BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Chỉ được thay đổi các Lot của nhà máy Bắc Ninh'
			RETURN
		END

	ELSE IF @pProcessUserID NOT IN ( 'DoThu') -- ds những người có quyền chỉnh sửa
		BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Bạn không có quyền dùng chức năng này, liên hệ chị Thu IQC'
			RETURN
		END
	ELSE 
		BEGIN
			IF @CheckDecisionResult IN ('None', 'Pass')
				BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Lot này chưa được đánh giá hoặc đã Pass. Vui lòng kiểm tra lại!'
					RETURN
				END
			ELSE IF @CheckDecisionResult IN ('Reject')		-- Chỉ cho chuyển những lot từ Reject sang Pass
				BEGIN
					UPDATE STB_MaterialQcInfo
						SET
							DecisionResult = 'Pass',
							PassedSampleQty = @BefPassedSampleQty + @BefDefectSampleQty,
							DefectSampleQty = 0
							,ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID
						WHERE
							MaterialQcNo = @MaterialQcNo

					INSERT INTO STB_IQCInfoChangeHist (MaterialQcNo, BefPassedSampleQty, BefDefectSampleQty, ChangeDateTime, ChangeUserID) 
						values (@MaterialQcNo, @BefPassedSampleQty, @BefDefectSampleQty, GETDATE(), @pProcessUserID)
						
				END

			ELSE 
				BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Chỉ được chuyển những lot đã Reject!'
					RETURN
				END
		END
		
END

GO

PRINT 'Procedure usp_DoChangeMaterialQcToPass_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_ModifyRevisionsVerFromC220_VVTF4_HY (Cloned from usp_ModifyRevisionsVerFromC220_VVTF4)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ModifyRevisionsVerFromC220_VVTF4_HY')
    DROP PROCEDURE [dbo].[usp_ModifyRevisionsVerFromC220_VVTF4_HY];
GO

-- =============================================
-- Author:		DinhManh
-- Create date: 2026-05-08
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModifyRevisionsVerFromC220_VVTF4_HY]
		-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50),
		@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    --DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)
	
	
	
	    -- Declare Columns Variable
	declare @MaterialDocNo	VARCHAR(20)
	declare @RevisionsVer	nvarchar(30)  



	DECLARE @iDoc INT

 
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
            SELECT

								'UPDATE' AS IUD_FLAG,
								MaterialDocNo,
								RevisionsVer					
																				
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
						        WITH  (
										MaterialDocNo		VARCHAR(20) ,
										RevisionsVer		nvarchar(30) 

										)



        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
							 @IUD_FLAG,
							 @MaterialDocNo,
							 @RevisionsVer
		 

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
	

            IF @IUD_FLAG = 'INSERT' BEGIN

				IF EXISTS (SELECT 1 FROM STB_MaterialDocDetail WHERE MaterialDocNo = @MaterialDocNo) BEGIN
					RAISERROR('INSERT ERROR id = %s', 16, 1, @MaterialDocNo)
					RETURN
				END



			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN			


				
						IF EXISTS (SELECT 1 FROM STB_MaterialDocDetail where MaterialDocNo = @MaterialDocNo)
							BEGIN
								UPDATE STB_MaterialDocDetail
								SET RevisionsVer = ISNULL(@RevisionsVer, RevisionsVer),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID
								WHERE MaterialDocNo = @MaterialDocNo

							END





            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN								


					RAISERROR('DELETE ERROR id = %s', 16, 1, @MaterialDocNo)
					RETURN


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

GO

PRINT 'Procedure usp_ModifyRevisionsVerFromC220_VVTF4_HY created successfully.';
GO
-- =========================================================
-- Stored Procedure: usp_UpdateDefectDetailIQC_VVT_HY (Cloned from usp_UpdateDefectDetailIQC_VVT)
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_UpdateDefectDetailIQC_VVT_HY')
    DROP PROCEDURE [dbo].[usp_UpdateDefectDetailIQC_VVT_HY];
GO

-- =============================================
-- Author:		DinhManh
-- Create date: 2026-05-09
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_UpdateDefectDetailIQC_VVT_HY
		-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50),
		@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    --DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)
	
	
	
	    -- Declare Columns Variable
	declare @MaterialQcNo	VARCHAR(20)
	declare @DefectDetail	nvarchar(30)  



	DECLARE @iDoc INT

 
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
            SELECT

								'UPDATE' AS IUD_FLAG,
								MaterialQcNo,
								DefectDetail					
																				
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
						        WITH  (
										MaterialQcNo		VARCHAR(20) ,
										DefectDetail		nvarchar(30) 

										)



        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
							 @IUD_FLAG,
							 @MaterialQcNo,
							 @DefectDetail
		 

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
	

            IF @IUD_FLAG = 'INSERT' BEGIN

				IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo) BEGIN
					RAISERROR('INSERT ERROR id = %s', 16, 1, @MaterialQcNo)
					RETURN
				END



			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN			


				
						IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo where MaterialQcNo = @MaterialQcNo)
							BEGIN
								UPDATE STB_MaterialQcInfo
								SET DefectDetail = ISNULL(@DefectDetail, DefectDetail),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID
								WHERE MaterialQcNo = @MaterialQcNo

							END





            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN								


					RAISERROR('DELETE ERROR id = %s', 16, 1, @MaterialQcNo)
					RETURN


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

GO

PRINT 'Procedure usp_UpdateDefectDetailIQC_VVT_HY created successfully.';
GO
-- 4. Há»¦Y Bá»Ž GIAO Dá»ŠCH Äá»‚ Äáº¢M Báº¢O AN TOÃ€N TRÃŠN PRODUCTION (DBA Sáº¼ Äá»”I SANG COMMIT KHI CHáº Y THá»°C Táº¾)
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
GO