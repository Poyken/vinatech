-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-02-05
-- Description:	Láy dữ liệu tự động
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDataFromAgingAndSorting]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pFromDate DATETIME=null,
    @pToDate   DATETIME=null
	
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @FromDate varchar(19) = convert(varchar(10),@pFromDate,120) + ' 10:00:00'
	declare @Todate varchar(19) = convert(varchar(10),dateadd(DAY,1,@pTodate),120) + ' 10:00:00'
    -- Insert statements for procedure here
	SELECT * from STB_AgingSortingData where (CreatedDateTime >= @FromDate AND CreatedDateTime <= @ToDate)
END
