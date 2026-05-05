-- Procedure: usp_PDAStringResources_get






-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 시스템
-- Description:	PDA화면리스트정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDAStringResources_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLanguage VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @Language VARCHAR(20) = CASE WHEN ISNULL(@pLanguage,'') = '' THEN '*' ELSE @pLanguage END

	SELECT
			PDASR_D.Lang AS OldLang,
			PDASR_D.Name AS OldName,
			@Language AS Lang,
			PDASR_D.Name,
			PDASR_D.Value AS DefaultValue,
			PDASR.Value
	FROM
			STB_PDAStringResources PDASR_D WITH(NOLOCK)
			LEFT OUTER JOIN STB_PDAStringResources PDASR WITH(NOLOCK)
				ON PDASR.Lang = @Language AND
				PDASR.Name = PDASR_D.Name
				
	WHERE
			PDASR_D.Lang = 'Default'

END







GO

