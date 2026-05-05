-- Procedure: usp_DoDeleteHelp







-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr
-- Create date: 2016-07-21
-- Description:	도움말을 삭제합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteHelp]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pId VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsFolder BIT
	SELECT
			@IsFolder = IsFolder
	FROM
			STB_Help H WITH(NOLOCK)
	WHERE
			H.Id = @pId

    IF @IsFolder = 1 BEGIN
		UPDATE STB_Help
		SET
				ParentId = NULL
		WHERE
				ParentId = @pId
	END

	DELETE FROM STB_Help
	WHERE	Id = @pId

	DELETE FROM STB_HelpLanguage
	WHERE	Id = @pId
END








GO

