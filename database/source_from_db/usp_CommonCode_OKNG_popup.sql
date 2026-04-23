-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 공통코드 팝업(OK/NG)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommonCode_OKNG_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			BC.ItemCode AS RollingDensityResult
		   ,BC.Description AS ItemName
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = 'OKNG'
	ORDER BY CASE WHEN BC.ItemCode = 'OK' THEN 1
	              WHEN BC.ItemCode = 'NG' THEN 2
				  ELSE 3 END
	DESC
END