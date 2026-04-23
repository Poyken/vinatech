
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 사양그룹정보
-- Description:	사양그룹정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecGroup_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT
			SG.SpecGroupCode,
			SG.SpecGroupName,
			SG.SpecGroupNameL,
			SG.IsUsed,
			SG.CreateDateTime,
			SG.CreateUserID,
			SG.ChangeDateTime,
			SG.ChangeUserID
	FROM
			STB_SpecGroup SG WITH(NOLOCK)
	WHERE
			SG.IsUsed = 1

END

