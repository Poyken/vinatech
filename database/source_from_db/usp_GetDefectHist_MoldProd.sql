

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 관리
-- Description:	불량 수동등록 조회용
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectHist_MoldProd]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode

	;WITH ProdDefect AS
	(
		SELECT
				DRI.DefectCode,
				SUM(DRI.DefectQty) AS DefectQty
		FROM
				STB_MoldProdHist MPH WITH(NOLOCK)
				INNER JOIN STB_DefectRepairInfo DRI WITH(NOLOCK)
					ON DRI.DayPlanNo = MPH.MoldProdNo
		WHERE
				MPH.DayPlanNo = @DayPlanNo AND
				DRI.MaterialCode = @MaterialCode
		GROUP BY
				DRI.DefectCode
	)
		SELECT
				DI.DefectCode,
				DI.BasicDefectName,
				PD.DefectQty,
				DI.IsRealDefect
		FROM
				STB_DefectInfo DI WITH(NOLOCK)
				LEFT OUTER JOIN ProdDefect PD
					ON PD.DefectCode = DI.DefectCode
		WHERE
				DI.UseGroup = '사출' AND
				DI.IsUsed = 1
		ORDER BY
				DI.DisplayIndex
END