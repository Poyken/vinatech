-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-08
-- Description:	Export dữ liệu sang excel
-- exec usp_getAndon_excel '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_getAndon_excel] 
	-- Add the parameters for the stored procedure here
		@pFromDate DATETIME = NULL,
	    @pToDate DATETIME = NULL,
	    @pFromGUI varchar(10)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP 300
    *,
    DATEDIFF(MINUTE, BeginFix, FinishFix) AS RepairDuration
FROM DefectReportsAnDon

ORDER BY Id DESC;
END
