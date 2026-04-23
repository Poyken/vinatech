

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-02
-- Browsable : true
-- Group : 일일작업카렌더
-- Description:	일일작업카렌더 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayWorkCalendar_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pFacilityRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pFromJobDate DATE = NULL,
	@pToJobDate DATE = NULL	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END
	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	DECLARE @FacilityRouteCode VARCHAR(20) = CASE WHEN ISNULL(@pFacilityRouteCode,'') = '' THEN '*' ELSE @pFacilityRouteCode END
	DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
	DECLARE @FromJobDate DATE = CASE WHEN ISNULL(@pFromJobDate,'') = '' THEN GETDATE() ELSE @pFromJobDate END
	DECLARE @ToJobDate DATE = CASE WHEN ISNULL(@pToJobDate,'') = '' THEN GETDATE() ELSE @pToJobDate END
    
	SELECT
			DWC.DayWorkCalendarNo AS OldDayWorkCalendarNo,
			DWC.DayWorkCalendarNo,
			DWC.JobDate,
			DWC.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			DWC.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			DWC.LineCode,
			LI.LineName,
			DWC.RouteCode,
			RI.RouteName,
			DWC.FacilityRouteCode,
			--FR.FacilityRouteName,
			--FR.FacilityRouteNameL,
			DWC.MachineCode,
			MM.MachineName,
			DWC.CalendarCode,
			CM.CalendarName,
			DWC.StartDateTime,
			DWC.EndDateTime,
			DWC.CreateDateTime,
			DWC.CreateUserID,
			DWC.ChangeDateTime,
			DWC.ChangeUserID
	FROM
			STB_DayWorkCalendar DWC WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = DWC.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = DWC.CompanyCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = DWC.LineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = DWC.RouteCode
			--LEFT OUTER JOIN STB_FacilityRoute FR WITH(NOLOCK)
			--	ON FR.FacilityRouteCode = DWC.FacilityRouteCode
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MM.MachineCode = DWC.MachineCode
			LEFT OUTER JOIN STB_CalendarMaster CM WITH(NOLOCK)
				ON CM.CalendarCode = DWC.CalendarCode
				
	WHERE
			(((@CompanyCode = '*') OR (DWC.CompanyCode = @CompanyCode)) OR (ISNULL(DWC.CompanyCode, '') = '')) AND
			(((@WorkCenterCode = '*') OR (DWC.WorkCenterCode = @WorkCenterCode)) OR (ISNULL(DWC.WorkCenterCode, '') = '')) AND
			(((@LineCode = '*') OR (DWC.LineCode = @LineCode)) OR (ISNULL(DWC.LineCode, '') = '')) AND
			(((@RouteCode = '*') OR (DWC.RouteCode = @RouteCode)) OR (ISNULL(DWC.RouteCode, '') = '')) AND
			(((@FacilityRouteCode = '*') OR (DWC.FacilityRouteCode = @FacilityRouteCode)) OR (ISNULL(DWC.FacilityRouteCode, '') = '')) AND
			(((@MachineCode = '*') OR (DWC.MachineCode = @MachineCode)) OR (ISNULL(DWC.MachineCode, '') = '')) AND
			((DWC.JobDate >= @FromJobDate) AND (@ToJobDate >= DWC.JobDate))
			

END


