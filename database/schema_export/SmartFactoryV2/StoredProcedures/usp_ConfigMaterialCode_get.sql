-- Procedure: usp_ConfigMaterialCode_get
-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-23
-- Description:	Danh sách chuyển đổi mã code NVL bên KTSP 
-- =============================================
CREATE PROCEDURE [dbo].[usp_ConfigMaterialCode_get] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID varchar(20)= NULL,
    @pProcessLanguage varchar(20)= NULL,
	@pMaterialCode varchar(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF LTRIM(RTRIM(@pMaterialCode)) = '' SET @pMaterialCode = NULL;

	SELECT *
	FROM STB_ChangeMaterialCode_Config
	WHERE 
		(@pMaterialCode IS NULL 
		  OR oldMaterialCode = @pMaterialCode 
		  OR NewMaterialCode = @pMaterialCode)
END

GO

