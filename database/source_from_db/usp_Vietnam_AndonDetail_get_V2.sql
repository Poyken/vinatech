-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-21
-- Description:	Hiển Thị Danh sách lỗi và nguyên nhân đánh giá với nhà máy bắc giang
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_AndonDetail_get_V2]
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
	 SELECT TOP 200 
    Id,
    LineCode,
    RouteName,
    ErrorName,
    ErrorDescription,
    DetectedBy,
    Operator,
	MachineRootCause,
    Reason,
    Countermeasure,
    Repairer,


    CASE 
        WHEN BeginFix IS NOT NULL THEN DATEADD(HOUR, -2, BeginFix) 
        ELSE NULL 
    END AS BeginFix,

    CASE 
        WHEN FinishFix IS NOT NULL THEN DATEADD(HOUR, -2, FinishFix) 
        ELSE NULL 
    END AS FinishFix,

    CASE 
        WHEN CreatedAt IS NOT NULL THEN DATEADD(HOUR, -2, CreatedAt) 
        ELSE NULL 
    END AS CreatedAt,
    Status,
    DATEDIFF(MINUTE, BeginFix, FinishFix) AS RepairDuration
FROM DefectReportsAndon_BG
ORDER BY Id DESC;
END
