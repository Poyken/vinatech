-- Function: fnMakeZeroNumber



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnMakeZeroNumber] (@pData VARCHAR(MAX),@iLength int)
RETURNS VARCHAR(MAX) AS
BEGIN
	RETURN RIGHT(REPLICATE('0',@iLength) + @pData,@iLength)

END




GO

