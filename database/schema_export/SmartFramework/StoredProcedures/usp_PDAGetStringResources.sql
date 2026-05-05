-- Procedure: usp_PDAGetStringResources

-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : PDA
-- Browsable : false
-- Create date : 2018-09-03
-- Description : PDA 언어별 문자열 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDAGetStringResources]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			PDASR_D.Name,
			ISNULL(PDASR.Value,PDASR_D.Value) AS Value
	FROM
			STB_PDAStringResources PDASR_D WITH(NOLOCK)
			LEFT OUTER JOIN STB_PDAStringResources PDASR WITH(NOLOCK)
				ON	PDASR.Lang = @ProcessLanguage AND
					PDASR.Name = PDASR_D.Name
	WHERE
			PDASR_D.Lang = 'Default'
END

GO

