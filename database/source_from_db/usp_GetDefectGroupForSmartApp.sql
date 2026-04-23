-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018.09.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량유형 그룹정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectGroupForSmartApp]
	@pUseGroup NVARCHAR(100) = NULL
WITH RECOMPILE, EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UseGroup NVARCHAR(100) = CASE WHEN ISNULL(@pUseGroup,'') = '' THEN '%' ELSE @pUseGroup END
	
	SELECT
			DG.DefectGroupCode,
			DG.BasicDefectGroupName,
			DG.DisplayIndex,
			DG.UseGroup
	FROM
			STB_DefectGroup DG WITH(NOLOCK)
	WHERE
			DG.IsUsed = 1 AND
			DG.UseGroup LIKE @UseGroup

END
