-- =============================================
-- Author:		DinhManh
-- Create date: 2025-07-04
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SlittingKnifeInfo_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pSlittingKnifeCode VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SlittingKnifeCode VARCHAR(30) = CASE WHEN ISNULL(@pSlittingKnifeCode,'') = '' THEN '%' ELSE @pSlittingKnifeCode END

	SELECT
			SKI.SlittingKnifeCode,
			SKI.SlittingKnifeName,
			SKI.StandardQty,
			SKI.Model,
			SKI.IsUsed,
			SKI.SPNote,
			SKI.CreateDateTime,
			SKI.CreateUserID,
			SKI.ChangeDateTime,
			SKI.ChangeUserID
	FROM
		STB_VN_SlittingKnifeInfo SKI WITH(NOLOCK)
	WHERE
		SKI.SlittingKnifeCode LIKE @SlittingKnifeCode
END
