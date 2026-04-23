-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-04-01

-- =============================================
create PROCEDURE [dbo].[usp_MaxNo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDate_Meeting date =null

AS
BEGIN
   select case when max(no) > 0 then max(no)+1 else 1 end nocnt from Stb_MeetingAgenda where Date_Meeting = @pDate_Meeting

END
