-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-06-29
-- Browsable : true
-- Group : SmartCTQ
-- Description:	샘플검사수준정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_InspectionLevel_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			IL.InspectionLevelSeq AS OldInspectionLevelSeq,
			IL.InspectionLevelSeq,
			IL.InspectionLevel,
			IL.MinGrQty,
			IL.MaxGrQty,
			IL.SampleChar,
			IL.SampleQty,
			IL.CreateDateTime,
			IL.CreateUserID,
			IL.ChangeDateTime,
			IL.ChangeUserID
	FROM
			STB_InspectionLevel IL WITH(NOLOCK)
	ORDER BY
			IL.InspectionLevel,
			IL.MinGrQty


END
