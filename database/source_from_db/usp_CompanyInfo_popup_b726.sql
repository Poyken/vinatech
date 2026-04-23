
-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-14
-- Browsable : true
-- Group :
-- Description:	사업장정보 popup 조회용
-- EXEC usp_CompanyInfo_popup
-- =============================================
CREATE PROCEDURE [dbo].[usp_CompanyInfo_popup_b726] 

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

