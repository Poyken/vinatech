-- Procedure: usp_CompanyInfo_popup_test_B567890
CREATE PROCEDURE [dbo].[usp_CompanyInfo_popup_test_B567890] 

WITH RECOMPILE
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
GO

