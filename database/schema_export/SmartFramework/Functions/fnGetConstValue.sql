-- Function: fnGetConstValue



-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-25
-- Description:	상수값을 가져옵니다.
-- =============================================
CREATE FUNCTION [dbo].[fnGetConstValue]
(
	@pConstName NVARCHAR(100),
	@pDefaultValue NVARCHAR(MAX) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @ConstValue NVARCHAR(MAX)
	
	SELECT
			@ConstValue = ISNULL(SFCC.ConstValue, @pDefaultValue)
	FROM
			STB_ConstCodeInfo SFCC WITH(NOLOCK)
	WHERE
			SFCC.ConstName = @pConstName

	RETURN @ConstValue

END



GO

