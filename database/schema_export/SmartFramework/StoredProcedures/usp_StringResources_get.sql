-- Procedure: usp_StringResources_get





-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-10-18
-- Browsable : true
-- Group : 시스템
-- Description:	String Resouce 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_StringResources_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLanguage VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Language VARCHAR(20) = CASE WHEN ISNULL(@pLanguage,'') = '' THEN '*' ELSE @pLanguage END
    
	SELECT
			@Language AS OldLanguage,
			SR_D.Type AS OldType,
			SR_D.Name AS OldName,

			@Language AS Language,
			SR_D.Type,
			SR_D.Name,
			SR_D.Value AS DefaultValue,
			SR.Value,
			SR_D.Description,
			SR.ChangeDateTime
	FROM
			STB_StringResources SR_D WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources SR WITH (NOLOCK)
				ON (SR.Language = @Language AND SR_D.Type = SR.Type AND SR_D.Name = SR.Name)
	WHERE
			( SR_D.Language = 'Default' )

END








GO

