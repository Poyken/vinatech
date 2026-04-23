
CREATE PROCEDURE usp_VN_LineInfor
	
AS
BEGIN
	SET NOCOUNT ON;


    SELECT
			LI.CompanyCode,
			CI.CompanyName,
			LI.WorkCenterCode,
			WCI.WorkCenterName,
			LI.LineCode,
			LI.LineDesc AS LineName,
			LI.LineType
	FROM
			STB_LineInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
	WHERE
		LI.CompanyCode ='VVT'
	     and
			LI.IsUsed = 1
END


