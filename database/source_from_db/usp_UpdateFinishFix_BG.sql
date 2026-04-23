-- =============================================
-- Author:		Nguyễn Hải Trièu
-- Create date: 2025-07-21
-- Description:	Cập nhật lại time hoàn thành
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateFinishFix_BG]
	-- Add the parameters for the stored procedure here
	@pId INT,
    @pReason NVARCHAR(100),
    @pCountermeasure NVARCHAR(100),
    @pRepairer NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DefectReportsAndon_BG
    SET Reason = @pReason,
        Countermeasure = @pCountermeasure,
        Repairer = @pRepairer,
        FinishFix = GETDATE(),
        Status = 1
    WHERE Id = @pId
END
