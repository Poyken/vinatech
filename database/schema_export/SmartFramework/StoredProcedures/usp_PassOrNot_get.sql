-- Procedure: usp_PassOrNot_get

-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2021-02-19
-- Browsable : True
-- Group : 시스템관리
-- Description:	기본코드관리 조회
-- Modified: 
-- usp_PassOrNot_get '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_PassOrNot_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromCodeGroup VARCHAR(50)  = 'PassOrNot',
	@pToCodeGroup VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromCodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pFromCodeGroup,'') = '' THEN '*' ELSE @pFromCodeGroup END
	DECLARE @ToCodeGroup     VARCHAR(50) = CASE WHEN ISNULL(@pToCodeGroup,'') = '' THEN '*' ELSE @pToCodeGroup END

    
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
	WHERE 	1=1
		--AND	(@FromCodeGroup = '*') OR (BC.CodeGroup = @FromCodeGroup) 
		AND		BC.CodeGroup LIKE 'Pass%'

END






GO

