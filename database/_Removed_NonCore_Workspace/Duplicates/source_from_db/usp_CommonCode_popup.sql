-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 공통코드 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommonCode_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CodeGroup VARCHAR(50) = @pCodeGroup

	SELECT
			BC.ItemCode AS ItemCode
		   ,BC.Description AS ItemName
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = @CodeGroup
END
