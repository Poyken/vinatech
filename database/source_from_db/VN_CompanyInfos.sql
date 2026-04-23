
CREATE PROC VN_CompanyInfos
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT
			CI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CI.CompanyDesc,
			CI.CompanyDescL
	FROM
			STB_CompanyInfo CI WITH(NOLOCK)
	WHERE
			CI.IsUsed = 1
    ORDER BY 
			CI.CompanyCode

END

