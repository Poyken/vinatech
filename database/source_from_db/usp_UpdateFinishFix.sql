-- =============================================
-- Author:		Nguyen Hai Trieu
-- Create date: 2025-07-09
-- Description:	Hoàn thành việc sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateFinishFix]
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
	UPDATE DefectReportsAnDon
    SET Reason = @pReason,
        Countermeasure = @pCountermeasure,
        Repairer = @pRepairer,
        FinishFix = GETDATE(),
        Status = 1
    WHERE Id = @pId
END
