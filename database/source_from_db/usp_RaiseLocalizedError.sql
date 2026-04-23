-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : false
-- Create date : 2018-07-30
-- Description : 다국어 처리 에러발생
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_RaiseLocalizedError]
	@pProcessLanguage VARCHAR(20),
	@pMessage NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Name NVARCHAR(MAX) = '^' + isnull(@pMessage,'') + '^',    --Add @pMessage if NULL by Mr.Tung on 2023-01-18
			@ErrorMessage NVARCHAR(MAX)

	EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
														@Name,
														@ErrorMessage OUTPUT
	RAISERROR(@ErrorMessage,16,1)
END
