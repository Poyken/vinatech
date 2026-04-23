-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-23
-- Description:	Hiển thị danh sách các mã nguyên vật liệu thay đổi theo mã ban đầu
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialChange_popup]
	-- Add the parameters for the stored procedure here
   @pMaterialCode VARCHAR(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT NewMaterialCode from STB_ChangeMaterialCode_Config where oldMaterialCode=@pMaterialCode
END
