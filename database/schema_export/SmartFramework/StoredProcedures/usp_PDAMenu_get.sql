-- Procedure: usp_PDAMenu_get






-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 시스템
-- Description:	PDA화면리스트정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDAMenu_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @Name VARCHAR(50) = CASE WHEN ISNULL(@pName,'') = '' THEN '%' ELSE @pName END

	SELECT
			PDAM.Name AS OldName,
			PDAM.Name,
			CASE WHEN ISNULL(PDAM.ParentName,'') = '' THEN 'MENU' ELSE PDAM.ParentName END AS ParentName,
			PDAM.DefaultCaption,
			CASE
				WHEN ISNULL(PDASR.Value,'') = '' THEN CASE WHEN ISNULL(PDASRD.Value,'') = '' THEN PDAM.DefaultCaption ELSE PDASRD.Value END
				ELSE PDASR.Value
			END AS Caption,
			PDAM.TypeName,
			PDAM.IsUse,
			PDAM.CreateDateTime,
			PDAM.CreateUserID,
			PDAM.ChangeDateTime,
			PDAM.ChangeUserID
	FROM
			STB_PDAMenu PDAM WITH(NOLOCK)
			LEFT OUTER JOIN STB_PDAStringResources PDASR WITH(NOLOCK)
				ON PDASR.Lang = @ProcessLanguage AND 
				PDASR.Name = PDAM.Name				
			LEFT OUTER JOIN STB_PDAStringResources PDASRD WITH(NOLOCK)
				ON PDASRD.Lang = 'Default' AND
				PDASRD.Name = PDAM.Name
	WHERE
			PDAM.Name LIKE @Name
	UNION ALL
	SELECT
			'MENU',
			'MENU',
			'',
			'',
			'',
			'',
			CONVERT(BIT,1),
			NULL,
			NULL,
			NULL,
			NULL

END

GO

