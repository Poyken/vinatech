-- Procedure: usp_GetPlatform

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-19
-- Description:	OS 플랫폼을 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetPlatform]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			*
	FROM
			VW_Platform
END


GO

