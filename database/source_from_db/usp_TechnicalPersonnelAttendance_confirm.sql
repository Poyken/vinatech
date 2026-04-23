-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 2019-12-31
-- Description : 출결정보확인
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_TechnicalPersonnelAttendance_confirm]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pAttendanceDate DATE,
    @pWorkerCode VARCHAR(20)
AS
BEGIN
	UPDATE STB_TechnicalPersonnelAttendanceInfo
	   SET IsConfirm = 1
	 WHERE AttendanceDate = @pAttendanceDate
	   AND WorkerCode = @pWorkerCode
END