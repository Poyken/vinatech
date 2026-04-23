
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-31
-- Browsable : true
-- Group : 생산관리 > 생산계획 > 일일생산계획수립
-- Description: [B420] 일일 생산계획수립
-- Modified:  Grid 조회용 프로시저
-- 전체 PO가 아니라 현재를 기준으로 2개월 전부터 미래일자의 PO가 조회되도록 개선 (2019.05.13 kilee 수정, 2019.08.30 By Jackaroe)
-- 계획수량 입력 컬럼의 날짜 포멧을 년월일에서 월일로 변경. 2019.09.27 주영진 요청 , By Jackaroe 롤백

--    usp_GetProductionOrderForDayPlan_20220217  '','','','','','' , 'ASSYLINE-01' ,'2022-02-01' ,'2022-02-10'
-- ==============================================================================================

CREATE PROCEDURE [dbo].[usp_GetProductionOrderForDayPlan_20220217]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pProductGroupCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @DiffDate INT = DATEDIFF(DAY,@FromDate,@ToDate)
	DECLARE @PlanQtyName NVARCHAR(100)
	DECLARE @ProdPriorName NVARCHAR(100)
	DECLARE @PlanCTName NVARCHAR(100)

	DECLARE @FromMonth VARCHAR(12) = SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, -2, GetDate()), 121), 0, 8)       -- SELECT SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, -2, GetDate()), 121), 0, 8)   ex)2020-04
	DECLARE @ToMonth     VARCHAR(12) = '9999-12' -- 미래일자의 PO는 모두 조회되도록 수정 2019.08.30 By Jackaroe

	--- 1. 
	SELECT
			@LineCode AS LineCode,
			POI.PONo,
			POI.PlanYearMonth,                                                                                                                               -- 계획년월
			MM.ProductGroupCode,
			PG.ProductGroupName,
			POI.MaterialCode,
			MM.MaterialName,
			POI.PlanQty AS POPlanQty,
			POI.ProdFinishQty,
			SC.ShiftCode                                                                                               AS PlanShiftCode,
			SC.Shift,
			0                                                                                                             AS NumericField,
			( SELECT ISNULL(SUM(PLANQTY), 0)
			   FROM STB_DayProdPlan SP 
			  WHERE SP.PONO = POI.PONO 
			    AND SP.PlanDate BETWEEN @FromDate AND @ToDate
				AND SP.PlanShiftCode = SC.ShiftCode
				AND SP.LineCode LIKE @LineCode
		    )        AS PlanQty
	FROM
			STB_ProductionOrderInfo POI                 WITH(NOLOCK)                                                          
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode       = POI.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup  PG   WITH(NOLOCK)  ON PG.ProductGroupCode = MM.ProductGroupCode
			CROSS JOIN VW_ShiftCode SC
	WHERE 1=1
	   AND POI.CompanyCode LIKE @CompanyCode 
	   AND POI.WorkCenterCode LIKE @WorkCenterCode 
	   AND MM.ProductGroupCode LIKE @ProductGroupCode 
	   AND POI.MaterialCode LIKE @MaterialCode 
	   AND POI.IsFix = 1 
	   AND POI.IsCancel = 0 
	   AND ((POI.IsFinish IS NULL) OR (POI.IsFinish = 0))
	   AND POI.PlanYearMonth BETWEEN @FromMonth AND @ToMonth
	   AND SC.Shift IN ('주간','야간')
     ORDER BY 	POI.PlanYearMonth DESC


	 

	 --2
	;WITH Items AS
	(
		
		SELECT
			--'PlanQty',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE 1=1
				  --AND Language = @ProcessLanguage 
				   AND Language = 'Korean'
						AND SR.Name = '^PlanQty^'
			) AS PlanItem,
			'NumericFIeld' AS RefField,
			'Int' AS DataType,
			'PlanQty' AS DataField
	)




	SELECT 
			dbo.fnConvertDateTimeToVarchar('yyyy-MM-dd',DATEADD(DAY,MSV.number,@FromDate)) AS BandName,
			DATEADD(DAY,MSV.number,@FromDate) AS PlanDate,
			Items.PlanItem,
			Items.RefField,
			Items.DataType,
			Items.DataField
	FROM
			master..spt_values MSV WITH (NOLOCK)
			CROSS JOIN Items
	WHERE
			MSV.[type] = 'P' AND MSV.number <= @DiffDate
	


	;WITH Items AS
	(
		SELECT
			--'PlanQty',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE 1=1
						AND Language = @ProcessLanguage 
						AND SR.Name = '^PlanQty^'
			) AS  PlanItem,
			'NumericFIeld' AS RefField,
			'Int'             AS DataType,
			'PlanQty'        AS DataField		
	)
	
		SELECT
				@LineCode AS LineCode,
				DPP.PONo,
				DPP.DayPlanNo,
			 	dbo.fnConvertDateTimeToVarchar('yyyy-MM-dd',DPP.PlanDate) AS BandName,
				DPP.PlanDate,
				DPP.PlanShiftCode,
				SC.Shift,
				DPP.PlanQty,
				--DPP.ProdPrior,
				--DPP.PlanCT,
				Items.PlanItem,
				Items.DataField
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
				CROSS JOIN Items
				LEFT OUTER JOIN VW_ShiftCode SC					             ON SC.ShiftCode       = DPP.PlanShiftCode
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = DPP.MaterialCode
		WHERE 1=1
		  AND DPP.CompanyCode LIKE @CompanyCode 
		  AND DPP.WorkCenterCode LIKE @WorkCenterCode 
		  AND MM.ProductGroupCode LIKE @ProductGroupCode 
		  AND DPP.MaterialCode LIKE @MaterialCode 
		  AND DPP.LineCode LIKE @LineCode 
		  AND DPP.PlanDate BETWEEN @FromDate  AND @ToDate
		  AND DPP.IsCancel = 0
		  AND SC.Shift IN ('주간','야간')
		 ORDER BY
				DPP.PONo,
				DPP.LineCode,
				DPP.PlanDate,
				DPP.PlanShiftCode

END