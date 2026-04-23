-- =============================================
-- Author:Nguyen Hai Trieu
-- Create date: 2025-04-28
-- Description:	Show list of waste 
-- =============================================
CREATE PROCEDURE usp_PopupWaste_T888

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT WS.CODENVL,WS.NAMESNVL FROM
   STB_VN_B598 WS
END
