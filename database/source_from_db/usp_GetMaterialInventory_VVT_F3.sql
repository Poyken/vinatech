-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 20258-08-13
-- Description:	Gộp đóng thùng to với packing sử dụng trước MES
-- exec usp_GetMaterialInventory_VVT_F3 'trieu','vi','PKHN612614'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialInventory_VVT_F3]
	-- Add the parameters for the stored procedure here
    @pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
        FGHN.MaterialCode,
        FGHN.LotNo,
        FGHN.PackingID,
        FGHN.ProductName,
        FGHN.Voltage,
        FGHN.Farad,
        FGHN.MBISizeH,
        FGHN.MBISizeW,
        FGHN.Marking,
        FGHN.Quantity AS CurrentQty
    FROM FinishGoodMESInstock_HN AS FGHN
    WHERE FGHN.PackingID = @pPackingID;
END
