-- Procedure: usp_PDAGetMenu

-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : PDA
-- Browsable : false
-- Create date : 2018-09-03
-- Description : PDA 메뉴 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDAGetMenu]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			PM.Name,
			PM.ParentName,
			ISNULL(PSR.Value, PM.DefaultCaption) AS Caption,
			PM.TypeName
	FROM
			STB_PDAMenu PM WITH(NOLOCK)
			LEFT OUTER JOIN STB_PDAStringResources PSR WITH(NOLOCK)
				ON	PSR.Lang = @ProcessLanguage AND
					PSR.Name = PM.DefaultCaption
	WHERE
			PM.IsUse = 1
END

GO

