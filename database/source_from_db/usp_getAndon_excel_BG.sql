-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-21
-- Description:	Cho phép xuất file excel
-- exec usp_getAndon_excel_BG '2025-08-01','2025-08-02',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_getAndon_excel_BG]
	-- Add the parameters for the stored procedure here
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pFromGUI varchar(10)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @pFromDate = case when isnull(@pFromDate,'')='' then dateadd(day,-60,getdate()) else @pFromDate end
	SET @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00' ;
	SELECT 
    *,
    DATEDIFF(MINUTE, BeginFix, FinishFix) AS RepairDuration
    FROM DefectReportsAndon_BG
    WHERE CreatedAt >= @FromDate AND CreatedAt <= @ToDate
    ORDER BY Id DESC;
END


