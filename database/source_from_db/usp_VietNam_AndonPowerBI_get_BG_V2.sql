-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-25
-- Description:	Gọi để lấy dữ liệu để show PowerBI
-- exec usp_VietNam_AndonPowerBI_get_BG_V2 '2025-09-01','2025-09-30'
-- =============================================
CREATE PROCEDURE [dbo].[usp_VietNam_AndonPowerBI_get_BG_V2]
	-- Add the parameters for the stored procedure here
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 set @pFromDate = case when isnull(@pFromDate,'')='' then dateadd(day,-60,getdate()) else @pFromDate end
	 set @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	 DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	 DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00' ;
	 SELECT 
    Id,
    LineCode,
    RouteName,
    ErrorName,
	MachineName,
    ErrorDescription,
    DetectedBy,
    Operator,
	MachineRootCause,
    Reason,
    Countermeasure,
    Repairer,
	CreatedAt,
    BeginFix,
    FinishFix,
    CASE 
        WHEN FinishFix IS NOT NULL AND CreatedAt IS NOT NULL 
        THEN DATEDIFF(MINUTE, CreatedAt, FinishFix) 
        ELSE NULL 
    END AS DowntimeMinutes,

    CASE 
        WHEN FinishFix IS NOT NULL AND BeginFix IS NOT NULL 
        THEN DATEDIFF(MINUTE, BeginFix, FinishFix) 
        ELSE NULL 
    END AS RepairDuration,
	CASE 
        WHEN BeginFix IS NOT NULL AND CreatedAt IS NOT NULL 
        THEN DATEDIFF(MINUTE, CreatedAt, BeginFix) 
        ELSE NULL 
    END AS Waitingtime,
	FORMAT(CreatedAt, 'yy-MM-dd') AS JobDate
FROM DefectReportsAndon_BG
WHERE CreatedAt >= @FromDate AND CreatedAt <= @ToDate
ORDER BY Id DESC;

END

