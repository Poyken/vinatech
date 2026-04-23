-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.11.03
-- Browsable : true
-- Group : 생산관리
-- Description:	(전극) 월별생산계획수량을 관리합니다 / Power-BI자료 (주영진님 요청- 2021.06.04)
-- Modified:
--             
--  프로시저 실행 : usp_MonthProdPlan_get  @pProcessUserID = '', @pProcessLanguage = 'Korean', @pCompanyCode = 'VNT', @pWorkCenterCode = 'VNT_F1', @pPlanYearMonth = '', @pLineCode = ''
-- ==============================================================================================================================================================
CREATE PROCEDURE [dbo].[usp_MonthProdPlan_get]
	@pProcessUserID varchar(20),
	@pProcessLanguage varchar(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pPlanYearMonth DATE,
	@pLineCode VARCHAR(20) = NULL

AS

BEGIN
	Declare  @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
			   ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
			   ,@PlanYearMonth    DATE            = @pPlanYearMonth
			    ,@LineCode          VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	PRINT @PlanYearMonth

	IF @PlanYearMonth = '1900-01-01' BEGIN
		SET @PlanYearMonth = GETDATE()
	END

	SELECT MPP.CompanyCode
	      ,CI.CompanyName
          ,MPP.WorkCenterCode
		  ,WCI.WorkCenterName
          ,MPP.PlanYearMonth
		  ,MPP.LineCode
		  ,LI.LineDesc AS LineName
          ,MPP.MaterialCode
		 ,SMM.MaterialName AS MaterialName
		  ,MBI.MBIExtText04
		  ,MBI.MBIExtText05
          , IsNull(MPP.PlanQty, 0) As PlanQty
		  , IsNull(MPP.Batch, 0)   As Batch    -- 추가
		  , Case When (MPP.PlanQty * MPP.Batch) is null then 0 else (MPP.PlanQty * MPP.Batch) End As ProdQty    --추가
          ,MPP.CreateDateTime
          ,MPP.CreateUserID
          ,MPP.ChangeDateTime
          ,MPP.ChangeUserID
	  FROM STB_MonthProdPlan MPP
			  LEFT OUTER JOIN STB_CompanyInfo CI	       ON MPP.CompanyCode = CI.CompanyCode
			  LEFT OUTER JOIN STB_WorkCenterInfo WCI	    ON MPP.WorkCenterCode = WCI.WorkCenterCode
			 
			  LEFT OUTER JOIN STB_LineInfo LI	                ON LI.LineCode = MPP.LineCode
			  LEFT OUTER JOIN STB_MaterialMaster  SMM    ON SMM.MaterialCode = MPP.MaterialCode         -- 추가사항

			   LEFT OUTER JOIN STB_ModelBasicInfo MBI	    ON MPP.MaterialCode = MBI.ModelCode
	 WHERE 1=1
	   AND MPP.PlanYearMonth BETWEEN dbo.fnGetFirstDayOfMonth(@PlanYearMonth) AND dbo.fnGetLastDayOfMonth(@PlanYearMonth)
	   AND (@CompanyCode = '*' OR MPP.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MPP.WorkCenterCode = @WorkCenterCode)
	   AND (@LineCode = '*' OR MPP.LineCode = @LineCode)

END



/*


 Select * from STB_ModelBasicInfo where modelcode in ( 'CRYPB6-006', 'CRMSB6-010')


*/