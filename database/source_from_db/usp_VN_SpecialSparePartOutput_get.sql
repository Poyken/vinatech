-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-04
-- Description:	Get history output special SparePart
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SpecialSparePartOutput_get]
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
		SSPIO.ID,
		SSPIO.SparePartLotID,
		SSPI.SparePartCode,
		SSPI.SparePartName,
		SSPIO.IOQty,
		SSPIO.SPWarehouseCode,
		SSPIO.LineCode,
		SSPIO.MachineCode,
		COUNT(Lot.LotID) as 'LotCount',
	    (SSPI.CycleReplace / SSPI.LotQty) AS LifeQty,
		SSPIO.WorkCenterCode,
		SSPIO.CreateDateTime,
		SSPIO.CreateUserID
	FROM 
		STB_VN_SpecialSparePartIOHist SSPIO WITH(NOLOCK) 
		LEFT JOIN STB_VN_SpecialSparePartInfo SSPI WITH(NOLOCK) ON SSPIO.SparePartCode = SSPI.SparePartCode
		LEFT JOIN STB_VN_SpecialSparePartLotInfo Lot ON SSPIO.SparePartLotID = Lot.SparePartLotID
	WHERE 1=1 
		AND SSPI.IsUsed = 1
		AND SSPIO.IOType = 'OUT'
		AND SSPI.CompanyCode LIKE @CompanyCode
		AND SSPI.WorkCenterCode LIKE @WorkCenterCode
		AND SSPIO.CreateDateTime BETWEEN @FromDate AND @ToDate
	GROUP BY
		SSPIO.ID,
		SSPIO.SparePartLotID,
		SSPI.SparePartCode,
		SSPI.SparePartName,
		SSPI.CycleReplace,
		SSPI.LotQty,
		SSPIO.IOQty,
		SSPIO.SPWarehouseCode,
		SSPIO.LineCode,
		SSPIO.MachineCode,
		SSPIO.WorkCenterCode,
		SSPIO.CreateDateTime,
		SSPIO.CreateUserID
	
END
