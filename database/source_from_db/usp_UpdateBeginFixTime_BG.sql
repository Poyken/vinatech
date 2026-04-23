-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-21
-- Description:	Cập nhật lại time bắt đầu sửa
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateBeginFixTime_BG]
	-- Add the parameters for the stored procedure here
   @pId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DefectReportsAndon_BG
    SET BeginFix = GETDATE()
    WHERE Id = @pId;
END
