-- Procedure: usp_CommInspSelectGroup_get



-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사선택분류정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspSelectGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspSelectGroupCode VARCHAR(20) = NULL,
	@pCommInspSelectGroupName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CommInspSelectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pCommInspSelectGroupCode,'') = '' THEN '*' ELSE @pCommInspSelectGroupCode END
	DECLARE @CommInspSelectGroupName NVARCHAR(100) = CASE WHEN ISNULL(@pCommInspSelectGroupName,'') = '' THEN '*' ELSE @pCommInspSelectGroupName END

    
	SELECT
			CISG.CommInspSelectGroupCode AS OldCommInspSelectGroupCode,
			CISG.CommInspSelectGroupCode,
			CISG.CommInspSelectGroupName,
			CISG.CommInspSelectGroupDesc,
			CISG.CreateDateTime,
			CISG.CreateUserID,
			CISG.ChangeDateTime,
			CISG.ChangeUserID
	FROM
			STB_CommInspSelectGroup CISG WITH(NOLOCK)
	WHERE
			((@CommInspSelectGroupCode = '*') OR (CISG.CommInspSelectGroupCode = @CommInspSelectGroupCode)) AND
			((@CommInspSelectGroupName = '*') OR (CISG.CommInspSelectGroupName = @CommInspSelectGroupName)) 

END





GO

