
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 팝업
-- Description:	작업장에 속하는 설비정보 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProductMachine_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pInjectType VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @InjectType VARCHAR(20) = CASE WHEN ISNULL(@pInjectType,'') = '' THEN '%' ELSE @pInjectType END
	
	SELECT
			MPM.MachineCode,
			MPM.MachineName,
			MPM.InjectType,
			MPM.Capa
	FROM
			STB_MoldProductMachine MPM WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPM.WorkCenterCode = WCI.WorkCenterCode
	WHERE
			WCI.CompanyCode LIKE @CompanyCode AND
			MPM.WorkCenterCode LIKE @WorkCenterCode AND
			MPM.InjectType LIKE @InjectType
	ORDER BY
			MPM.DisplayIndex
END


