-- =============================================
-- Author: SJC
-- Create date: 2022-01-06
-- Browsable : true
-- Group : 공통
-- Description:	Coating품번에서 파생되는 Slitting 품번을 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CoatingToSlitting_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pElectrodeLotNumber VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
      DECLARE @CompanyCode VARCHAR(20) = NULL
      DECLARE @WorkCenterCode VARCHAR(20) = NULL

	SELECT @CompanyCode = DPP.CompanyCode
	      ,@WorkCenterCode = DPP.WorkCenterCode
	FROM STB_SetInfo SI
	LEFT OUTER JOIN STB_DayProdPlan DPP 
		ON SI.DayPlanNo = DPP.DayPlanNo
	WHERE SI.Barcode = @pElectrodeLotNumber

	SELECT CTSM.CoatingMaterialCode
		  ,CTSM.SlittingWidth
		  ,CTSM.SlittingMaterialCode
	  FROM STB_SetInfo SI WITH(NOLOCK)
	  LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)
		ON SI.DayPlanNo = DPP.DayPlanNo
	  LEFT OUTER JOIN STB_CoatingToSlittingMaster CTSM WITH(NOLOCK)
		ON SI.MaterialCode = CTSM.CoatingMaterialCode
	 WHERE CTSM.CompanyCode = @CompanyCode
	   AND CTSM.WorkCenterCode = @WorkCenterCode
	   AND SI.Barcode = @pElectrodeLotNumber
END
