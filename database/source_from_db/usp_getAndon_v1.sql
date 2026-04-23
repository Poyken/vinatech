-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-15
-- Description: Lấy dữ liệu andon
-- usp_getAndon_v1 '','','2025-07-01','2025-07-15','','VVT_F1'
-- =============================================
CREATE PROCEDURE [dbo].[usp_getAndon_v1]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE 
	  @vToDate datetime,
	  @vFromDate datetime,
	  @vCompanyCode VARCHAR(20),
	  @vWorkCenterCode VARCHAR(20);
	 set @vCompanyCode=@pCompanyCode;
	 set @pFromDate = case when isnull(@pFromDate,'')='' then dateadd(day,-60,getdate()) else @pFromDate end
	 set @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	 DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	 DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00' 
	 DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    -- Insert statements for procedure here

     if(@WorkCenterCode='VVT_F1')
	 BEGIN
	   SELECT 
       Id,
       LineCode,
       RouteName,
       ErrorName,
       ErrorDescription,
       DetectedBy,
       Operator,
       Reason,
       Countermeasure,
       Repairer,

    CASE 
        WHEN BeginFix IS NOT NULL THEN DATEADD(HOUR, 0, BeginFix) 
        ELSE NULL 
    END AS BeginFix,

    CASE 
        WHEN FinishFix IS NOT NULL THEN DATEADD(HOUR, 0, FinishFix) 
        ELSE NULL 
    END AS FinishFix,

    CASE 
        WHEN CreatedAt IS NOT NULL THEN DATEADD(HOUR, 0, CreatedAt) 
        ELSE NULL 
    END AS CreatedAt,

    Status,
    DATEDIFF(MINUTE, BeginFix, FinishFix) AS RepairDuration,
	DATEDIFF(MINUTE, CreatedAt, BeginFix) AS RepairWaitingTime
    FROM DefectReportsAnDon
    WHERE CreatedAt>=@FromDate AND CreatedAt<=@ToDate
    ORDER BY Id DESC;
	 END
	 else if(@WorkCenterCode='VVT_F2')
	 BEGIN
	 SELECT 
       Id,
       LineCode,
       RouteName,
       ErrorName,
       ErrorDescription,
       DetectedBy,
       Operator,
       Reason,
       Countermeasure,
       Repairer,

    CASE 
        WHEN BeginFix IS NOT NULL THEN DATEADD(HOUR, 0, BeginFix) 
        ELSE NULL 
    END AS BeginFix,

    CASE 
        WHEN FinishFix IS NOT NULL THEN DATEADD(HOUR, 0, FinishFix) 
        ELSE NULL 
    END AS FinishFix,

    CASE 
        WHEN CreatedAt IS NOT NULL THEN DATEADD(HOUR, 0, CreatedAt) 
        ELSE NULL 
    END AS CreatedAt,

    Status,
    DATEDIFF(MINUTE, BeginFix, FinishFix) AS RepairDuration,
	DATEDIFF(MINUTE, CreatedAt, BeginFix) AS RepairWaitingTime
FROM DefectReportsAnDon_BG
WHERE CreatedAt>=@FromDate AND CreatedAt<=@ToDate
ORDER BY Id DESC;


	 END

	 

	
END
