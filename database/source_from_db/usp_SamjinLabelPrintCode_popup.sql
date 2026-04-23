-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-25
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_SamjinLabelPrintCode_popup
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 'CC30017-00393' AS SamjinCode, 'VEL08253R8506G-B034' AS VinatechCode  UNION ALL
    SELECT 'CC30017-00430' AS SamjinCode, 'VEL08253R8506G-B030R' AS VinatechCode

	
END
