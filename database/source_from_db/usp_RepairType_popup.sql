-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 팝업
-- Create date: 2018-08-27
-- Description:	수리유형 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_RepairType_popup]
	@pExcludeRepairType VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ExcludeRepairType VARCHAR(100) = ISNULL(@pExcludeRepairType,'')

	SELECT
			RT.RepairType,
			RT.RepairTypeName
	FROM
			VW_RepairType RT
	WHERE
			RT.RepairType NOT IN (SELECT Item FROM dbo.fnSplitToTable(',',@ExcludeRepairType))
END
