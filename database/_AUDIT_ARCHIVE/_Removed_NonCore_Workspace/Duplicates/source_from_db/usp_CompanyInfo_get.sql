-- =============================================
-- Author:	Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.07.22
-- Browsable : true
-- Group :
-- Description:	사업장정보를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_CompanyInfo_get] 
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END,
			@CompanyName NVARCHAR(50) = CASE WHEN ISNULL(@pCompanyName,'') = '' THEN '*' ELSE @pCompanyName END
		
		
	SELECT
			CI.CompanyCode AS OldCompanyCode,
			CI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CI.CompanyDesc,
			CI.CompanyDescL,
			CI.IsUsed,
			CI.CreateDateTime,
			CI.CreateUserID,
			CI.ChangeDateTime,
			CI.ChangeUserID
	FROM
			STB_CompanyInfo CI WITH(NOLOCK)
	WHERE
			((@CompanyCode = '*') OR (CI.CompanyCode = @CompanyCode)) AND
			((@CompanyName = '*') OR (CI.CompanyName = @CompanyName))
			
END
