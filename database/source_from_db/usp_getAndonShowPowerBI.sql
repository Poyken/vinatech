-- ================================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-15
-- Description:	Show dữ liệu lên Power BI
-- exec usp_getAndonShowPowerBI '','','2025-12-01','2025-12-31','VVT','VVT_F1'
-- ================================================
CREATE PROCEDURE [dbo].[usp_getAndonShowPowerBI] 
			          @pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
                       @pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL,
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	/*
    -- Gán mặc định nếu không truyền tham số
    SET @pFromDate = CASE WHEN ISNULL(@pFromDate, '') = '' THEN DATEADD(DAY, -60, GETDATE()) ELSE @pFromDate END;
    SET @pToDate = CASE WHEN ISNULL(@pToDate, '') = '' THEN GETDATE() ELSE @pToDate END;
    SET @pCompanyCode = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '%' ELSE @pCompanyCode END;
    SET @pWorkCenterCode = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '%' ELSE @pWorkCenterCode END;
*/
	-- Điều kiện lọc riêng cho từng site
	IF (@pCompanyCode = 'VVT' AND @pWorkCenterCode = 'VVT_F1')
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

	        --T3.Status AS TRANG_THAI,
	        DATEDIFF(MINUTE, BeginFix, FinishFix) AS RepairDuration

	    FROM DefectReportsAnDon t3
	    WHERE CreatedAt >= @pFromDate AND CreatedAt <= @pToDate
	    ORDER BY Id DESC;
	END
END
