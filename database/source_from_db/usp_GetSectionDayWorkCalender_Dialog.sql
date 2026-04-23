


-- =============================================
-- Author:		Ji Hyang Mi(hmji@awoo.co.kr)
-- Create date: 2017-11-17
-- Browsable : true
-- Group : 일일근무카렌더
-- Description:	구간 일일근무 카렌더 다이어로그 레이아웃 화면입니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSectionDayWorkCalender_Dialog]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;


	SELECT
			GETDATE() AS FromDate,
			DATEADD(DD,5,GETDATE()) AS ToDate,
			@pCompanyCode AS CompanyCode,
			@pWorkCenterCode AS WorkCenterCode,
			'' AS LineCode,
			'' AS CalendarCode,
			'' AS MachineCode

END
