-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-04-01

-- =============================================
CREATE PROCEDURE [dbo].[usp_RespTeam_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
   select 'PRODUCTION' as RespTeam
   UNION select 'PROD. CONTROL'  as RespTeam
   UNION select 'MACHINE'  as RespTeam
   UNION select 'MACHINE TECHNICAL'  as RespTeam
   UNION select 'QC'  as RespTeam  --add by Mr.Tung on 15-May-2021 follow mr TrinhTung request
END
