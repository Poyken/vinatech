
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-31
-- Browsable : true
-- Group : 팝업
-- Description: 교대조 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShiftCode_popup]
WITH RECOMPILE, EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			ShiftCode,
			Shift
	FROM
			VW_ShiftCode

END

