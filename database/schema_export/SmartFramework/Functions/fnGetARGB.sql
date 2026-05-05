-- Function: fnGetARGB



-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-26
-- Description:	ARGB 색상을 가져옵니다.
-- =============================================
CREATE FUNCTION [dbo].[fnGetARGB]
(
	@pRed BIGINT,
	@pGreen BIGINT,
	@pBlue BIGINT
)
RETURNS BIGINT
AS
BEGIN
	DECLARE	@Alpha BIGINT = CONVERT(BIGINT,255) * POWER(256,3),
			@Red BIGINT = @pRed * POWER(256,2),
			@Green BIGINT = @pGreen * 256,
			@Blue BIGINT = @pBlue

	RETURN @Alpha + @Red + @Green + @Blue
END




GO

