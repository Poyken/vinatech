-- Procedure: usp_GetBaseCodeRemark_popup





-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-23
-- Browsable : true
-- Group : 시스템관리
-- Description:	기본코드관리 조회_POPUP
-- Modified:

-- exec usp_GetBaseCodeRemark_popup '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBaseCodeRemark_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pCodeGroup,'') = '' THEN '*' ELSE @pCodeGroup END
    
	SELECT
			IsNull(BC.ItemCode,'') AS [ItemCode],
			IsNull(BC.Description,'') AS [Description],
			IsNull(BC.Remark,'') AS [Remark]
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	
			( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)
    ORDER BY BC.DisplayIndex

END





--select * from STB_BaseCode where CodeGroup = 'ITWorkerCode'


--insert into STB_BaseCode values ( 'ITWorkerCode', '19080501', 'Mr.Tung', '','')
GO

