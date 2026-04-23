

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 팝업
-- Description:	설비정보-팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineMaster_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	
	SELECT
			RTRIM(MM.MachineCode) AS MachineCode,
			MM.MachineName,
			MM.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MM.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MM.IsProdMachine,
			MM.MachineTypeCode,
			MT.MachineTypeName
			
	FROM
			STB_MachineMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MM.WorkCentercode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MM.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode)) 
			AND (MM.IsUsed = 1)
END