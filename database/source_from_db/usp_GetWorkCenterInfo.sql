-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-01-22
-- Description:	Lấy ra danh sách các nhà máy ở VINATHI
-- =============================================
CREATE PROCEDURE usp_GetWorkCenterInfo 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
			WCI.WorkCenterCode,
			WCI.WorkCenterName
	FROM
			STB_WorkCenterInfo WCI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
	WHERE
			(WCI.IsUsed = 1) and WorkCenterCode in('VVT_F1','VVT_F2','VVT_F3','VVT_F4')
END
