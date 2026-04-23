

-- =============================================
-- Author:	Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-22
-- Browsable : true
-- Group : 근무시간설정
-- Description: CalendarMaster, CalendarDetail IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCalendarMasterDetail_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = NULL	
WITH RECOMPILE
AS
BEGIN
	CREATE TABLE #SEQUENCE_TABLE
	(
		KeyValue VARCHAR(20),
		UID_KEY VARCHAR(50)
	)
	
	SET NOCOUNT ON;
	
	
	EXEC usp_CalendarMaster_iud @pProcessUserID, @pProcessLanguage, 'CalendarMaster_view', @pXml
	
	EXEC usp_CalendarDetail_iud @pProcessUserID, @pProcessLanguage, 'CalendarDetail_view', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
	
END


