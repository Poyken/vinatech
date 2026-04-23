-- =============================================
-- Author:		Nguyễn Hải Triêu
-- Create date: 2025-07-09
-- Description: Bắt đầu sửa
-- =============================================
CREATE PROCEDURE usp_UpdateBeginFixTime 
	-- Add the parameters for the stored procedure here
	@pId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DefectReportsAnDon
    SET BeginFix = GETDATE()
    WHERE Id = @pId;
END
