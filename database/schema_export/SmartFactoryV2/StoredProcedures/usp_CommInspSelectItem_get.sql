-- Procedure: usp_CommInspSelectItem_get



-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사 선택항목정보 조회
-- Modified:
-- 프로시저 실행 : [usp_CommInspSelectItem_get] '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspSelectItem_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspSelectGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CommInspSelectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pCommInspSelectGroupCode,'') = '' THEN '' ELSE @pCommInspSelectGroupCode END

    
	SELECT
			CISI.CommInspSelectItemCode AS OldCommInspSelectItemCode,
			CISI.CommInspSelectItemCode,
			
			CISI.CommInspSelectGroupCode AS OldCommInspSelectGroupCode,
			CISI.CommInspSelectGroupCode,
			
			CISI.CommInspSelectItemValue,
			CISI.CommInspSelectITemDesc,
			CISI.CommInspSelectResult,
			CISI.DisplayIndex,
			CISI.CreateDateTime,
			CISI.CreateUserID,
			CISI.ChangeDateTime,
			CISI.ChangeUserID
	FROM
			STB_CommInspSelectItem CISI WITH(NOLOCK)
	WHERE
			((@CommInspSelectGroupCode = '*') OR (CISI.CommInspSelectGroupCode = @CommInspSelectGroupCode)) 

END





GO

