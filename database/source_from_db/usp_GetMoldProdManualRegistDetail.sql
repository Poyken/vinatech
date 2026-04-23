

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 생산관리
-- Description:	수작업 품목별 생산실적 조회 및 등록 화면
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldProdManualRegistDetail]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pDayPlanNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @DayPlanNo VARCHAR(20) = CASE WHEN ISNULL(@pDayPlanNo,'') = '' THEN '*' ELSE @pDayPlanNo END
   
	SELECT
	        MPPD.DayPlanNo,
			MPPD.MaterialCode,
			MM.MaterialName,
	        MM.MaterialTypeCode,
	        MT.MaterialTypeName,	        
	        MM.ProductGroupCode,
	        PG.ProductGroupName,
	        MM.MaterialSpec,	        
			MPPD.PlanQty,
			ISNULL(SUM(MPPH.ProdQty),0) AS ProdQty,
			ISNULL(SUM(MPPH.DefectQty),0) AS DefectQty,
			ISNULL(SUM(MPPH.TryQty),0) AS TryQty,
	        DPP.MoldNumber,
	        DPP.PlanQty AS PlanShot
	FROM
			STB_MoldProdPlanDetail MPPD WITH(NOLOCK)
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)
				ON DPP.DayPlanNo = MPPD.DayPlanNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MPPD.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MPPD.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode	= PG.ProductGroupCode
			LEFT OUTER JOIN STB_MoldProdHist MPH WITH(NOLOCK)
				ON MPH.DayPlanNo = DPP.DayPlanNo
			LEFT OUTER JOIN STB_MoldProductProdHist MPPH WITH(NOLOCK)
				ON MPPH.MoldProdNo = MPH.MoldProdNo AND
				MPPH.MaterialCode = MPPD.MaterialCode
	WHERE
			MPPD.DayPlanNo = @DayPlanNo
	GROUP BY
			MPPD.DayPlanNo,
			MPPD.MaterialCode,
			MM.MaterialName,
	        MM.MaterialTypeCode,
	        MT.MaterialTypeName,	        
	        MM.ProductGroupCode,
	        PG.ProductGroupName,
	        MM.MaterialSpec,	        
			MPPD.PlanQty,
			DPP.MoldNumber,
			DPP.PlanQty
END