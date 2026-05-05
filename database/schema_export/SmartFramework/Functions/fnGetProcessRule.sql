-- Function: fnGetProcessRule

-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.06.06
-- Description:	전역설정값을 가져옵니다.
-- =============================================
CREATE FUNCTION [dbo].[fnGetProcessRule]
(
	@pRuleCode VARCHAR(50),
	@pDefaultSetValue VARCHAR(50) = NULL
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @ReturnValue VARCHAR(50)
	
	IF @pDefaultSetValue IS NULL
		SET @pDefaultSetValue = ''
		
	SELECT
			@ReturnValue = GPR.SettingValue
	FROM
			STB_GlobalProcessRule GPR
	WHERE
			GPR.RuleCode = @pRuleCode
	
	IF @ReturnValue IS NULL
	BEGIN
		SET @ReturnValue = @pDefaultSetValue
	END
	
	-- Return the result of the function
	RETURN @ReturnValue

END


GO

