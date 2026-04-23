-- =============================================
-- Author:		 Nguyễn Hải Triều	
-- Create date: 2025-06-30
-- Description:	Lấy danh sách các công đoạn
-- =============================================
CREATE PROCEDURE usp_GetCellLineAndon_Popup 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select CellLIneID,CellLineName from CellLines
END
