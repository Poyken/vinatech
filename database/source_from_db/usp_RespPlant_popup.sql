-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-04-01

-- =============================================
create PROCEDURE [dbo].[usp_RespPlant_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
   select 'KOREA' as Plant
   UNION select 'VIETNAM'  as RespTeam

END
