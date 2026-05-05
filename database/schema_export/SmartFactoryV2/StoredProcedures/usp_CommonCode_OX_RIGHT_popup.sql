-- Procedure: usp_CommonCode_OX_RIGHT_popup
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 공통코드 팝업(O/X)
-- Modified :
-- =============================================
CReate PROCEDURE [dbo].[usp_CommonCode_OX_RIGHT_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			BC.ItemCode AS HeadGapInitRight
		   ,BC.Description AS ItemName
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = 'OX'
	ORDER BY CASE WHEN BC.ItemCode = 'O' THEN 1
	              WHEN BC.ItemCode = 'X' THEN 2
				  ELSE 3 END
	DESC
END
GO

