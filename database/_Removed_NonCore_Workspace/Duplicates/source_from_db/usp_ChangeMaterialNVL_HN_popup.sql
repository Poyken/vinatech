-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-22
-- Description:	Lấy ra các mã nguyên vật liệu cần chuyển theo mã gốc
 -- exec usp_ChangeMaterialNVL_HN_popup 'VE250708-002'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ChangeMaterialNVL_HN_popup]
	-- Add the parameters for the stored procedure here
	@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    DECLARE @pMaterialCode nvarchar(100)
	DECLARE @LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END
	-- Lấy ra mã nguyên vật liệu để theo Lotno
	select TOP 1 @pMaterialCode=MaterialCode from STB_MaterialLotInfo where LotNo=@LotNo;

    -- Insert statements for procedure here
	SELECT OldMaterialCode,NewMaterialCode FROM STB_ChangeMaterial_HN
	WHERE OldMaterialCode=@pMaterialCode
END
