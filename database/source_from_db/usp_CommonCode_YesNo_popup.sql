-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 공통코드 팝업(YesNo)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommonCode_YesNo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			BC.ItemCode AS SpecInOutYn
		   ,BC.Description AS ItemName
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = 'YesNo'
	ORDER BY BC.ItemCode DESC
END