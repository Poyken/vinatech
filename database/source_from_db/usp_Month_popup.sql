-- =============================================
-- Author : kilee
-- Group : 기준년월 popup
-- Browsable : true
-- Create date : 2019-08-26
-- Description : PO정보조회 >수동PO생성부분 > 기준년월popup 
-- Modified :

-- EXEC usp_Month_popup '',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_Month_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage
			    

	SELECT SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, -2, CONVERT(smalldatetime, GetDate())), 121), 1, 7) 
	UNION ALL
	 
    SELECT  SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, -1, CONVERT(smalldatetime, GetDate())), 121), 1, 7)
	UNION ALL
	       
   SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 1, 7)
   UNION ALL

	SELECT SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, 1, CONVERT(smalldatetime, GetDate())), 121), 1, 7)
	UNION ALL

	SELECT SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, 2, CONVERT(smalldatetime, GetDate())), 121), 1, 7)
	UNION ALL

	SELECT SUBSTRING(CONVERT(VARCHAR(10), DATEADD(MONTH, 3, CONVERT(smalldatetime, GetDate())), 121), 1, 7)
  		   

END
