
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-31
-- Browsable : true
-- Group : 생산관리
-- Description: [B420] 일일 생산계획수립
-- Modified: 조회 프로시저
-- =============================================

-- EXEC [usp_GetProductionOrderForDayPlan_Del] '','','','','','' , '' ,'2019-05-01' ,'2019-05-31'

CREATE PROCEDURE [dbo].[usp_GetProductionOrderForDayPlan_Del]
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

	SELECT
			@LineCode AS LineCode,
			POI.PONo,
			POI.PlanYearMonth,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			POI.MaterialCode,
			MM.MaterialName,
			POI.PlanQty AS POPlanQty,
			POI.ProdFinishQty,
			SC.ShiftCode AS PlanShiftCode,
			SC.Shift,
			0 AS NumericField
	FROM
			STB_ProductionOrderInfo POI                   WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode       = POI.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG    WITH(NOLOCK)  ON PG.ProductGroupCode = MM.ProductGroupCode
			CROSS JOIN VW_ShiftCode SC
	WHERE 1=1
	   AND POI.CompanyCode LIKE @CompanyCode 
	   AND POI.WorkCenterCode LIKE @WorkCenterCode 
	   AND MM.ProductGroupCode LIKE @ProductGroupCode 
	   AND POI.MaterialCode LIKE @MaterialCode 
	   AND POI.IsFix = 1 
	   AND POI.IsCancel = 0 
	   AND ((POI.IsFinish IS NULL) OR (POI.IsFinish = 0))
			

	;WITH Items AS
	(
		SELECT
			--'ProdPrior' AS PlanItem,
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE
						Language = @ProcessLanguage AND
						SR.Name = '^ProdPrior^'
			) AS PlanItem,
			'NumericFIeld' AS RefField,
			'Numeric'       AS DataType,
			'ProdPrior'      AS DataField
		UNION ALL SELECT
			--'PlanCT',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE 1=1
				   AND Language = @ProcessLanguage 
				   AND SR.Name = '^PlanCT^'
			) ,
			'NumericFIeld',
			'Numeric',
			'PlanCT'
		UNION ALL SELECT
			--'PlanQty',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE 1=1
						AND Language = @ProcessLanguage 
						AND SR.Name = '^PlanQty^'
			),
			'NumericFIeld',
			'Numeric',
			'PlanQty'
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
			--'ProdPrior' AS PlanItem,
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE
						Language = @ProcessLanguage AND
						SR.Name = '^ProdPrior^'
			) AS PlanItem,
			'NumericFIeld' AS RefField,
			'Numeric'       AS DataType,
			'ProdPrior'      AS DataField
		UNION ALL SELECT
			--'PlanCT',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE
						Language = @ProcessLanguage AND
						SR.Name = '^PlanCT^'
			),
			'NumericFIeld',
			'double',
			'PlanCT'
		UNION ALL SELECT
			--'PlanQty',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE
						Language = @ProcessLanguage AND
						SR.Name = '^PlanQty^'
			),
			'NumericFIeld',
			'double',
			'PlanQty'
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
				DPP.ProdPrior,
				DPP.PlanCT,
				Items.PlanItem,
				Items.DataField
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
				CROSS JOIN Items
				LEFT OUTER JOIN VW_ShiftCode SC					               ON SC.ShiftCode       = DPP.PlanShiftCode
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = DPP.MaterialCode
		WHERE 1=1
		  AND DPP.CompanyCode LIKE @CompanyCode 
		  AND DPP.WorkCenterCode LIKE @WorkCenterCode 
		  AND MM.ProductGroupCode LIKE @ProductGroupCode 
		  AND DPP.MaterialCode LIKE @MaterialCode 
		  AND DPP.LineCode = @LineCode 
		  AND DPP.PlanDate BETWEEN @FromDate  AND @ToDate
		  AND DPP.PONo LIKE '190426%'

END
