-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-29
-- Description:	Lây ra danh sách của file đẩy lên MES
-- =============================================
CREATE PROCEDURE [dbo].[usp_getFinishGood_ImportExcel]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20) =NULL,
	@pProcessLanguage VARCHAR(20) =NULL,
	@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select 
		@pLotNo AS LotNo,
		'' AS PackingID,
		'' AS MaterialCode,
		'' AS Voltage,
		'' AS Farad,
		'' AS MBISizeW,
		'' AS MBISizeH,
		'' AS Marking,
		'' AS Quantity,
		'' AS Unit,
		'' AS ProductName,
		'' as WarehouseName,
		'' AS WarehouseType
END
