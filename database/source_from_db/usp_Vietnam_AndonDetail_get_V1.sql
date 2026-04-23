-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-08
-- Description:	Hiển thị danh sách các lỗi
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_AndonDetail_get_V1]
	-- Add the parameters for the stored procedure here
		@pFromDate DATETIME = NULL,
	    @pToDate DATETIME = NULL,
	    @pFromGUI varchar(10)=null
AS
BEGIN
 SELECT TOP 200 
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
FROM DefectReportsAnDon
ORDER BY Id DESC;



END
