-- Procedure: usp_InspectionBaseCode_Popup





-- =============================================
-- Author: Kangs (kilee2@vina.co.kr)
-- Create date: 2022-02-10
-- Browsable : True
-- Group : 시스템관리
-- Description:	공정검사코드조회_POPUP
-- Modified:

--  usp_InspectionBaseCode_Popup '','',''
--  usp_InspectionBaseCode_Popup 'kilee','Korean','process steps'
-- =============================================
CREATE PROCEDURE [dbo].[usp_InspectionBaseCode_Popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pCodeGroup,'') = '' THEN '*' ELSE @pCodeGroup END
    
	SELECT
			IsNull(BC.ItemCode,'') AS [RouteCode]
			, IsNull(BC.Description,'') AS [RouteName]
			--, BC.CodeGroup
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	1=1
	   AND 	(BC.CodeGroup = 'process steps')
	  

    ORDER BY BC.DisplayIndex

END





--select * from STB_BaseCode where CodeGroup = 'ITWorkerCode'


--insert into STB_BaseCode values ( 'ITWorkerCode', '19080501', 'Mr.Tung', '','')
GO

