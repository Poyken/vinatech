-- Procedure: usp_BaseCode_get





-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-23
-- Browsable : true
-- Group : 시스템관리
-- Description:	기본코드관리 조회
-- Modified: 2018-08-25 @pToCodeGroup 무시하도록 수정 (jspark)
-- =============================================
CREATE PROCEDURE [dbo].[usp_BaseCode_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromCodeGroup VARCHAR(50) = NULL,
	@pToCodeGroup VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromCodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pFromCodeGroup,'') = '' THEN '*' ELSE @pFromCodeGroup END
	DECLARE @ToCodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pToCodeGroup,'') = '' THEN '*' ELSE @pToCodeGroup END

    
	SELECT
			BC.CodeGroup AS OldCodeGroup,
			BC.ItemCode AS OldItemCode,
			IsNull(BC.CodeGroup,'') AS [CodeGroup],
			IsNull(BC.ItemCode,'') AS [ItemCode],
			IsNull(BC.Description,'') AS [Description],
			IsNull(CG.CodeGroupName,'') AS [gDescription],
			BC.DisplayIndex,
			BC.Remark
	FROM
			STB_BaseCode BC WITH(NOLOCK)
			LEFT OUTER JOIN	VW_CodeGroup CG				ON BC.CodeGroup = CG.CodeGroup			
	WHERE 	
			(@FromCodeGroup = '*') OR (BC.CodeGroup = @FromCodeGroup) 
	--		(BC.CodeGroup >= @FromCodeGroup or @FromCodeGroup = '*')  AND
	--		(BC.CodeGroup <= @ToCodeGroup or @ToCodeGroup = '*')

END






GO

