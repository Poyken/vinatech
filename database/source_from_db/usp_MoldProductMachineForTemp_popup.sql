

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-04
-- Description:	작업장에 속하는 설비정보 조회(IsMoldTempControl = '1' 인것만)- 팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProductMachineForTemp_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
		
	
	SELECT
			MPM.MachineCode,
			MPM.MachineName,
			MPM.InjectType,
			MPM.Capa,
			MPM.MonitoringGroup,
			MPM.ErpMachineCode,
			MPM.MoldProdNo,
			WCI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MPM.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MPM.DisplayIndex
	FROM
			STB_MoldProductMachine MPM WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
	WHERE
			((@CompanyCode = '*') OR (WCI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (MPM.WorkCenterCode = @WorkCenterCode))
			AND ((MPM.IsTemperatureControl = 1))
	ORDER BY
			MPM.DisplayIndex
			
END


