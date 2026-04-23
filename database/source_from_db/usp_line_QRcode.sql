CREATE PROC usp_line_QRcode
@LineCode NVARCHAR(50)
AS
BEGIN
SELECT LineCode,LineName  FROM STB_LineInfo WHERE CompanyCode = 'VVT' AND IsUsed = 1 AND LineCode = @LineCode
END