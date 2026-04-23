CREATE PROC [dbo].[usp_VN_Lineifor_bg]
AS
BEGIN

SELECT

		LineCode,
		LineName,
		LineDesc,
		LineType
FROM
		STB_LineInfo WITH(NOLOCK)
WHERE
		CompanyCode = 'VVT' AND IsUsed = 1 AND WorkCenterCode = 'VVT_F2' AND LineName <>''
	
		
END