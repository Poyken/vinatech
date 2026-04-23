-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_ManTest260304_get
	-- Add the parameters for the stored procedure here
	@pStt VARCHAR(2) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @pStt = '1' 
		BEGIN
			SELECT '1' AS STT, 'Manh' as NameVi
		END
	ELSE
		BEGIN
			SELECT '2' AS STT, 'Thuc' as NameVi UNION ALL
			SELECT '3' AS STT, 'Hai' as NameVi
		END
END
