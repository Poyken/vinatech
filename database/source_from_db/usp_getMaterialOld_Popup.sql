-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-23
-- Description:	Lấy danh sách các mã nguyên vật liệu cũ
-- =============================================
CREATE PROCEDURE [dbo].[usp_getMaterialOld_Popup]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT oldMaterialCode
	FROM STB_ChangeMaterialCode_Config
END
