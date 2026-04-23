-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-04-01

-- =============================================
create PROCEDURE [dbo].[usp_Status_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
   select 'OPEN' as Status
   UNION select 'CLOSE'  as Status
END
