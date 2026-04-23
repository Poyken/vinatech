
CREATE PROC usp_vn_Line_timeatt
AS
BEGIN
SELECT
		LineCode,LineName 
FROM
		STB_LineInfo WITH(NOLOCK) 
WHERE
		CompanyCode = 'VVT' AND IsUsed = 1
END