-- Procedure: usp_GetBaseCode_popup2
-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-07-07
-- Browsable : true
-- Group : 시스템관리
-- Description:	전극 두 공정 POPUP ('Mixing', 'Coating')   
-- Modified:

-- Exec usp_GetBaseCode_popup2 '','','ElectrodeRouteCode'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBaseCode_popup2]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pCodeGroup,'') = '' THEN '*' ELSE @pCodeGroup END
    
	SELECT
			IsNull(BC.ItemCode,'')   AS [ItemCode],
			IsNull(BC.Description,'') AS [Description]
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	1=1
	   AND  ( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)
	   AND ItemCode in ( 'Coating','RollPress')                                           -- 안제헌대리 요청 (2020.07.07)
	   --AND ItemCode in ('Mixing', 'Coating','RollPress','Slitting')                                          
    ORDER BY BC.DisplayIndex

END
GO

