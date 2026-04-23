-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-04
-- Description:	Get inventory special SparePart
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SpecialSparePartInv_get] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL,
		@pFromDate date,
		@pToDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	SET @pToDate = DATEADD(DAY, 1, @pToDate)
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), @pToDate, 120) + ' 10:00:00'

	SELECT
		SSPI.SparePartCode,
		SSPI.SparePartName,
		SSPI.SparePartSpec01,
		(sum(case when SSPIO.IOType='IN' AND SSPIO.CreateDateTime BETWEEN @FromDate AND @ToDate  then SSPIO.IOQty else 0 end)
		- sum(case when SSPIO.IOType='OUT' AND SSPIO.CreateDateTime BETWEEN @FromDate AND @ToDate then SSPIO.IOQty else 0 end)) AS Quantity,
		SSPI.WorkCenterCode,
		WCI.WorkCenterName

	FROM 
		STB_VN_SpecialSparePartInfo SSPI WITH(NOLOCK)
		LEFT JOIN STB_VN_SpecialSparePartIOHist SSPIO WITH(NOLOCK) ON SSPIO.SparePartCode = SSPI.SparePartCode
		LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK) ON SSPI.WorkCenterCode = WCI.WorkCenterCode
	WHERE 1=1
		AND SSPI.IsUsed = 1 AND
		SSPI.CompanyCode LIKE @CompanyCode AND
		SSPI.WorkCenterCode LIKE @WorkCenterCode 
	GROUP BY
		SSPI.SparePartCode,
		SSPI.SparePartName,
		SSPI.SparePartSpec01,
		SSPI.WorkCenterCode,
		WCI.WorkCenterName






END
