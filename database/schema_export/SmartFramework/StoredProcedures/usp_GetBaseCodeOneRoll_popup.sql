-- Procedure: usp_GetBaseCodeOneRoll_popup


-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-20
-- Browsable : true
-- Group : 시스템관리
-- Description:	기본코드관리 조회_POPUP (원롤/슬리팅롤)
-- Modified:

--  usp_GetBaseCodeOneRoll_popup '','','ElectrodeRouteGroup'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBaseCodeOneRoll_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pCodeGroup,'') = '' THEN '*' ELSE @pCodeGroup END
    
	SELECT
			IsNull(BC.ItemCode,'') AS [ItemCode],
			IsNull(BC.Description,'') AS [Description]
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	1=1
	  AND ( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)	  
    ORDER BY BC.DisplayIndex

END





-- Select * from STB_BaseCode where CodeGroup LIKE 'Electrode%'


--insert into STB_BaseCode values ( 'ITWorkerCode', '19080501', 'Mr.Tung', '','')



--SELECT *			
--	FROM
--			STB_BaseCode BC WITH(NOLOCK)
--	WHERE 	1=1
--	  AND (BC.CodeGroup = 'ElectrodeRouteGroup')	  
--    ORDER BY BC.DisplayIndex
GO

